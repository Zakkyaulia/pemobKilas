import 'package:flutter/foundation.dart';

import '../models/report_model.dart';
import 'mock_reports.dart';

/// Singleton repository that holds the live list of reports.
///
/// Both Home and Search screens read from this single source of truth
/// so that upvote counts, bookmark states, and other mutations are
/// always in sync across the app.
class ReportRepository extends ChangeNotifier {
  ReportRepository._() : _reports = List<ReportModel>.from(mockReports);

  static final ReportRepository _instance = ReportRepository._();

  /// Access the shared repository instance.
  static ReportRepository get instance => _instance;

  final List<ReportModel> _reports;

  /// Unmodifiable view of the current reports.
  List<ReportModel> get reports => List.unmodifiable(_reports);

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

  /// Hapus laporan secara permanen berdasarkan [id] dan beritahu seluruh listener.
  void deleteById(String id) {
    final index = _reports.indexWhere((r) => r.id == id);
    if (index != -1) {
      _reports.removeAt(index);
      notifyListeners();
    }
  }

  /// Find the index of a report by its [id]. Returns -1 if not found.
  int indexById(String id) => _reports.indexWhere((r) => r.id == id);
}
