import 'package:flutter/material.dart';

// ==========================================
// 1. EVENT (Aksi yang dipicu oleh pengguna)
// ==========================================
abstract class ReportEvent {}

class SubmitReportEvent extends ReportEvent {
  final String title;
  final String description;

  SubmitReportEvent({required this.title, required this.description});
}

// ==========================================
// 2. STATE (Kondisi layar saat ini)
// ==========================================
abstract class ReportState {}

class ReportInitial extends ReportState {}

class ReportLoading extends ReportState {}

class ReportSuccess extends ReportState {
  final String message;
  ReportSuccess(this.message);
}

class ReportError extends ReportState {
  final String errorMessage;
  ReportError(this.errorMessage);
}

// ==========================================
// CONTROLLER (Memproses Event menjadi State)
// ==========================================
class CreateReportController extends ChangeNotifier {
  ReportState _state = ReportInitial();
  ReportState get state => _state;

  // Fungsi utama untuk menerima event
  void dispatch(ReportEvent event) async {
    if (event is SubmitReportEvent) {
      await _handleSubmit(event);
    }
  }

  Future<void> _handleSubmit(SubmitReportEvent event) async {
    // 3. VALIDATION (Memastikan data sudah benar)
    if (event.title.trim().isEmpty || event.description.trim().isEmpty) {
      _state = ReportError("Judul dan deskripsi laporan tidak boleh kosong!");
      notifyListeners();
      return;
    }

    if (event.title.trim().length < 5) {
      _state = ReportError("Judul laporan terlalu singkat (minimal 5 karakter).");
      notifyListeners();
      return;
    }

    // Ubah State menjadi Loading
    _state = ReportLoading();
    notifyListeners();

    try {
      // Simulasi proses pengiriman data ke server / database (contoh: 2 detik)
      await Future.delayed(const Duration(seconds: 2));

      // Ubah State menjadi Success
      _state = ReportSuccess("Laporan Anda berhasil dikirim!");
      notifyListeners();
    } catch (e) {
      // Ubah State menjadi Error jika terjadi kegagalan jaringan
      _state = ReportError("Terjadi kesalahan sistem. Silakan coba lagi.");
      notifyListeners();
    }
  }
}