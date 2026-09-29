import '../models/laporan.dart';

class LaporanRepository {
  static const List<Laporan> _items = [
    Laporan(
      id: '1',
      judul: 'Plafon GKB B-204 Bocor',
      lokasi: 'Gedung GKB B',
      kategori: 'Darurat',
      dukungan: 48,
    ),
  ];

  Future<List<Laporan>> fetchItems({bool simulateError = false}) async {
    await Future.delayed(const Duration(seconds: 2));
    if (simulateError) {
      throw Exception('Gagal memuat data. Periksa koneksi internet.');
    }
    return _items;
  }
}
