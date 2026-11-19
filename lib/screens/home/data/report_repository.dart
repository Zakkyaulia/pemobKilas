import 'package:flutter/foundation.dart';

import '../../../services/report_api_service.dart';
import '../models/report_model.dart';
import 'mock_reports.dart';

/// Singleton repository that holds the live list of reports.
///
/// Both Home, Map, Search, and Profile screens read from this single source of truth
/// so that upvote counts, bookmark states, and other mutations are
/// always in sync across the app and synced with the backend REST API.
class ReportRepository extends ChangeNotifier {
  ReportRepository._() : _reports = List<ReportModel>.from(mockReports);

  static final ReportRepository _instance = ReportRepository._();

  /// Access the shared repository instance.
  static ReportRepository get instance => _instance;

  List<ReportModel> _reports;
  bool _isLoading = false;

  /// Unmodifiable view of the current reports.
  List<ReportModel> get reports => List.unmodifiable(_reports);

  /// Status loading saat sinkronisasi API berlangsung.
  bool get isLoading => _isLoading;

  /// Number of reports.
  int get length => _reports.length;

  /// Get a report by its list index.
  ReportModel operator [](int index) => _reports[index];

  /// Update a report at [index] and notify listeners.
  void updateAt(int index, ReportModel report) {
    if (index < 0 || index >= _reports.length) return;
    _reports[index] = report;
    notifyListeners();
  }

  /// Update a report by its [id] and notify listeners.
  void updateById(String id, ReportModel report) {
    final index = _reports.indexWhere((r) => r.id == id);
    if (index != -1) {
      _reports[index] = report;
      notifyListeners();
    }
  }

  /// Tambahkan laporan baru di urutan teratas (paling baru).
  void addReport(ReportModel report) {
    _reports.insert(0, report);
    notifyListeners();
  }

  /// Hapus laporan secara lokal berdasarkan [id] dan beritahu seluruh listener.
  void deleteById(String id) {
    final index = _reports.indexWhere((r) => r.id == id);
    if (index != -1) {
      _reports.removeAt(index);
      notifyListeners();
    }
  }

  /// Find the index of a report by its [id]. Returns -1 if not found.
  int indexById(String id) => _reports.indexWhere((r) => r.id == id);

  // ── Integrasi REST API Backend KILAS ───────────────────────────────────────

  /// Fetch data laporan secara asinkron dari REST API backend.
  /// Jika server tidak dapat diakses (offline), tetap menggunakan data cache lokal/mock.
  Future<List<ReportModel>> fetchReports({
    String? category,
    String? query,
    String? sort,
  }) async {
    _isLoading = true;
    notifyListeners();

    try {
      final remoteReports = await ReportApiService.getReports(
        category: category,
        q: query,
        sort: sort,
      );
      if (remoteReports.isNotEmpty) {
        _reports = remoteReports;
      }
    } catch (_) {
      // Jika offline, pertahankan data yang sudah ada (fallback gracefully)
    } finally {
      _isLoading = false;
      notifyListeners();
    }

    return List.unmodifiable(_reports);
  }

  /// FR-A1: Mengirim dan mengunggah laporan baru ke backend.
  Future<ReportModel> submitNewReport({
    required String title,
    required String description,
    required String category,
    required double latitude,
    required double longitude,
    String? locationName,
    required List<String> mediaPaths,
  }) async {
    final report = await ReportApiService.createReport(
      title: title,
      description: description,
      category: category,
      latitude: latitude,
      longitude: longitude,
      locationName: locationName,
      mediaPaths: mediaPaths,
    );

    // Sisipkan langsung ke daftar lokal paling atas
    _reports.insert(0, report);
    notifyListeners();
    return report;
  }

  /// FR-A2: Mengedit laporan sendiri di backend.
  Future<ReportModel> editReport({
    required String reportId,
    String? title,
    String? description,
    String? category,
    List<String>? keptMediaIds,
    List<String>? newMediaPaths,
  }) async {
    final updated = await ReportApiService.updateReport(
      reportId: reportId,
      title: title,
      description: description,
      category: category,
      keptMediaIds: keptMediaIds,
      newMediaPaths: newMediaPaths,
    );

    updateById(reportId, updated);
    return updated;
  }

  /// FR-A3: Menghapus laporan sendiri dari backend.
  Future<void> removeReport(String reportId) async {
    await ReportApiService.deleteReport(reportId);
    deleteById(reportId);
  }

  /// FR-A5 & FR-A8: Sinkronisasi status Upvote ke backend (dengan optimistic UI update).
  Future<bool> syncUpvote(String id, bool isUpvoted, int count) async {
    // 1. Optimistic update (UI responsif seketika)
    final idx = indexById(id);
    if (idx != -1) {
      updateAt(idx, _reports[idx].copyWith(isUpvoted: isUpvoted, upvoteCount: count));
    }

    try {
      // 2. Kirim toggle ke backend
      final res = await ReportApiService.toggleUpvote(id);
      if (idx != -1) {
        updateAt(
          idx,
          _reports[idx].copyWith(isUpvoted: res.isUpvoted, upvoteCount: res.upvoteCount),
        );
      }
      return true;
    } catch (_) {
      // Jika request API gagal, rollback ke nilai sebelumnya
      if (idx != -1) {
        updateAt(idx, _reports[idx].copyWith(isUpvoted: !isUpvoted, upvoteCount: count + (isUpvoted ? -1 : 1)));
      }
      return false;
    }
  }

  /// FR-A6: Sinkronisasi status Bookmark ke backend (dengan optimistic UI update).
  Future<bool> syncBookmark(String id, bool isBookmarked) async {
    final idx = indexById(id);
    if (idx != -1) {
      updateAt(idx, _reports[idx].copyWith(isBookmarked: isBookmarked));
    }

    try {
      final res = await ReportApiService.toggleBookmark(id);
      if (idx != -1) {
        updateAt(idx, _reports[idx].copyWith(isBookmarked: res));
      }
      return true;
    } catch (_) {
      if (idx != -1) {
        updateAt(idx, _reports[idx].copyWith(isBookmarked: !isBookmarked));
      }
      return false;
    }
  }

  /// FR-A7: Mengambil koleksi bookmark dari backend untuk grid profil.
  Future<List<ReportModel>> fetchBookmarks() async {
    try {
      final remoteBookmarks = await ReportApiService.getBookmarks();
      // Tandai juga laporan terkait di feed lokal sebagai isBookmarked: true
      for (final b in remoteBookmarks) {
        final idx = indexById(b.id);
        if (idx != -1) {
          _reports[idx] = _reports[idx].copyWith(isBookmarked: true);
        }
      }
      notifyListeners();
      return remoteBookmarks;
    } catch (_) {
      // Fallback: kembalikan laporan lokal yang memiliki flag isBookmarked
      return _reports.where((r) => r.isBookmarked).toList();
    }
  }
}
