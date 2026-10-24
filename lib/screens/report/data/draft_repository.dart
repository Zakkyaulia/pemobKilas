import 'package:flutter/foundation.dart';

import '../models/draft_model.dart';

/// Repository lokal singleton pengelola draft laporan (ChangeNotifier).
///
/// Menyimpan, memperbarui, dan menghapus draf laporan secara reaktif
/// di memori perangkat sehingga pengguna dapat melanjutkan penulisan
/// laporan kapan saja tanpa kehilangan progres.
class DraftRepository extends ChangeNotifier {
  DraftRepository._() {
    _initInitialData();
  }

  static final DraftRepository instance = DraftRepository._();

  final List<DraftModel> _drafts = [];

  /// Daftar seluruh draft laporan yang tersimpan (immutable).
  List<DraftModel> get drafts => List.unmodifiable(_drafts);

  /// Jumlah draft laporan yang tersimpan.
  int get draftCount => _drafts.length;

  /// Memeriksa apakah ada draft tersimpan.
  bool get hasDrafts => _drafts.isNotEmpty;

  /// Inisialisasi contoh draft agar pengujian antarmuka langsung terlihat.
  void _initInitialData() {
    final now = DateTime.now();
    _drafts.addAll([
      DraftModel(
        id: 'draft-mock-1',
        title: 'Lampu Penerangan Mati Depan Gedung H',
        description:
            'Lampu jalan utama di dekat taman depan Gedung H mati sejak dua hari lalu. Kondisi gelap saat malam menyulitkan mahasiswa yang pulang kuliah praktikum.',
        selectedCategory: 'Kondisi Kampus',
        locationName: 'Gedung H, Kampus Limau Manis',
        coordinates: '-0.9142, 100.4582',
        latitude: -0.9142,
        longitude: 100.4582,
        createdAt: now.subtract(const Duration(hours: 3, minutes: 20)),
        updatedAt: now.subtract(const Duration(hours: 1, minutes: 10)),
      ),
      DraftModel(
        id: 'draft-mock-2',
        title: 'Pengumuman Jadwal Perawatan Server Lab Komputer',
        description:
            'Akan diadakan pemeliharaan berkala jaringan server pada hari Sabtu malam mulai pukul 22.00 WIB.',
        selectedCategory: 'Informasi Penting',
        locationName: 'Lab Terpadu Komputer, Gedung FTI',
        coordinates: '-0.9155, 100.4590',
        latitude: -0.9155,
        longitude: 100.4590,
        createdAt: now.subtract(const Duration(days: 1, hours: 2)),
        updatedAt: now.subtract(const Duration(hours: 18)),
      ),
    ]);
  }

  /// Menyimpan draft baru atau memperbarui jika ID sudah ada sebelumnya.
  void saveDraft(DraftModel draft) {
    final index = _drafts.indexWhere((d) => d.id == draft.id);
    if (index >= 0) {
      _drafts[index] = draft.copyWith(updatedAt: DateTime.now());
    } else {
      _drafts.insert(0, draft);
    }
    notifyListeners();
  }

  /// Menghapus draft berdasarkan [id].
  void deleteDraft(String id) {
    _drafts.removeWhere((d) => d.id == id);
    notifyListeners();
  }

  /// Mengambil draft berdasarkan [id] jika ditemukan.
  DraftModel? getDraft(String id) {
    try {
      return _drafts.firstWhere((d) => d.id == id);
    } catch (_) {
      return null;
    }
  }

  /// Menghapus semua draft sekaligus.
  void clearAll() {
    _drafts.clear();
    notifyListeners();
  }
}
