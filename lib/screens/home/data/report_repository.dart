import 'package:flutter/foundation.dart';

import '../../../services/report_api_service.dart';
import '../models/report_model.dart';

/// Filter feed laporan yang dikirim ke `GET /api/reports`.
/// Dipakai bersama oleh Beranda dan layar Cari & Filter.
class ReportFilter {
  const ReportFilter({this.category, this.query, this.sort, this.from});

  /// `kondisi_kampus` / `informasi_penting`; null = semua kategori.
  final String? category;

  /// Kata kunci (judul, keterangan, nama lokasi).
  final String? query;

  /// `terbaru` (default) / `terpopuler`.
  final String? sort;

  /// Batas awal rentang waktu; null = semua waktu.
  final DateTime? from;

  /// Tanpa filter: semua laporan, terbaru di atas.
  static const none = ReportFilter();

  bool get isActive =>
      category != null ||
      (query != null && query!.isNotEmpty) ||
      (sort != null && sort != 'terbaru') ||
      from != null;
}

/// Singleton repository that holds the live list of reports.
///
/// Both Home, Map, Search, and Profile screens read from this single source of truth
/// so that upvote counts, bookmark states, and other mutations are
/// always in sync across the app and synced with the backend REST API.
class ReportRepository extends ChangeNotifier {
  ReportRepository._();

  static final ReportRepository _instance = ReportRepository._();

  /// Access the shared repository instance.
  static ReportRepository get instance => _instance;

  /// Jumlah laporan per pengambilan (infinite scroll).
  static const int pageSize = 20;

  List<ReportModel> _reports = [];

  // ── State paginasi feed ──
  int _page = 0;
  bool _hasMore = true;
  bool _isLoading = false;
  bool _isLoadingMore = false;
  bool _hasLoadedOnce = false;
  String? _loadMoreError;

  // Filter yang sedang dipakai; halaman berikutnya memakai filter yang sama.
  ReportFilter _filter = ReportFilter.none;
  int? _totalCount;

  /// Unmodifiable view of the current reports.
  List<ReportModel> get reports => List.unmodifiable(_reports);

  /// Sedang memuat halaman pertama (buka Home / pull-to-refresh).
  bool get isLoading => _isLoading;

  /// Sedang memuat halaman berikutnya (scroll mentok bawah).
  bool get isLoadingMore => _isLoadingMore;

  /// Masih ada laporan lama yang belum dimuat.
  bool get hasMore => _hasMore;

  /// Halaman pertama sudah pernah berhasil dimuat dari server.
  bool get hasLoadedOnce => _hasLoadedOnce;

  /// Pesan error terakhir saat memuat halaman berikutnya (null jika tidak ada).
  String? get loadMoreError => _loadMoreError;

  /// Filter yang sedang aktif pada feed.
  ReportFilter get activeFilter => _filter;

  /// Jumlah seluruh laporan yang cocok dengan filter aktif (dari server).
  int? get totalCount => _totalCount;

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

  /// Memuat ulang feed dari halaman 1 (buka Home, pull-to-refresh, atau filter
  /// berubah). Tanpa [filter], filter yang sedang aktif tetap dipakai.
  ///
  /// Melempar [ReportException] jika gagal; daftar lama tetap dipertahankan.
  Future<void> refresh({ReportFilter? filter}) async {
    if (filter != null) _filter = filter;
    _isLoading = true;
    _loadMoreError = null;
    notifyListeners();

    try {
      final result = await ReportApiService.getReports(
        category: _filter.category,
        q: _filter.query,
        sort: _filter.sort,
        from: _filter.from,
        page: 1,
        limit: pageSize,
      );
      _reports = List<ReportModel>.from(result.items);
      _totalCount = result.total;
      _page = 1;
      _hasMore = result.hasMore;
      _hasLoadedOnce = true;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Memuat halaman berikutnya dan menyambungkannya di bawah daftar.
  /// Diabaikan bila sedang memuat atau sudah tidak ada data lagi.
  Future<void> loadMore() async {
    if (_isLoading || _isLoadingMore || !_hasMore || !_hasLoadedOnce) return;

    _isLoadingMore = true;
    _loadMoreError = null;
    notifyListeners();

    try {
      final result = await ReportApiService.getReports(
        category: _filter.category,
        q: _filter.query,
        sort: _filter.sort,
        from: _filter.from,
        page: _page + 1,
        limit: pageSize,
      );
      // Buang laporan yang sudah tampil: urutan bisa bergeser jika ada
      // laporan baru diunggah di antara dua pengambilan.
      final existingIds = _reports.map((r) => r.id).toSet();
      _reports.addAll(result.items.where((r) => !existingIds.contains(r.id)));
      _page += 1;
      _hasMore = result.hasMore;
    } catch (e) {
      _loadMoreError = e.toString();
    } finally {
      _isLoadingMore = false;
      notifyListeners();
    }
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
  }) async {
    // Media tidak dapat diubah saat edit (hanya teks & kategori).
    final updated = await ReportApiService.updateReport(
      reportId: reportId,
      title: title,
      description: description,
      category: category,
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
