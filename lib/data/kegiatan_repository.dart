import '../models/kegiatan.dart';

/// Sumber data sementara (dummy) untuk aplikasi KILAS.
class KegiatanRepository {
  static const List<Kegiatan> _items = [
    Kegiatan(
      id: '1',
      title: 'PKKMB Fakultas 2026',
      subtitle: 'Persiapan maba tingkat fakultas',
      description: 'Kegiatan Pengenalan Kehidupan Kampus bagi Mahasiswa Baru tingkat fakultas akan dilaksanakan secara luring. Wajib membawa perlengkapan.',
    ),
    Kegiatan(
      id: '2',
      title: 'Workshop Flutter Mahasiswa',
      subtitle: 'Belajar membuat aplikasi mobile',
      description: 'Workshop intensif selama 2 hari untuk mahasiswa jurusan Sistem Informasi.',
    ),
    Kegiatan(
      id: '3',
      title: 'Batas Pembayaran UKT',
      subtitle: 'Semester Ganjil 2026/2027',
      description: 'Batas akhir pembayaran UKT untuk mahasiswa aktif adalah tanggal 30 September 2026.',
    ),
  ];

  /// Mengambil daftar kegiatan.
  Future<List<Kegiatan>> fetchItems({bool simulateError = false}) async {
    await Future.delayed(const Duration(seconds: 2));
    if (simulateError) {
      throw Exception('Gagal memuat data. Periksa koneksi internet.');
    }
    return _items;
  }
}
