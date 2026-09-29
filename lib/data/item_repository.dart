import '../models/item.dart';

/// Sumber data sementara (dummy). Nanti bisa diganti dengan API/database.
class ItemRepository {
  // Data dummy disesuaikan dengan aplikasi KILAS (Layanan Mahasiswa)
  static const List<Item> _items = [
    Item(
      id: '1',
      title: 'Surat Keterangan Aktif Kuliah',
      subtitle: 'Permohonan surat keterangan mahasiswa aktif semester berjalan',
      description:
          'Layanan penerbitan surat keterangan resmi dari fakultas yang menerangkan bahwa mahasiswa bersangkutan terdaftar aktif kuliah pada semester ganjil/genap.',
    ),
    Item(
      id: '2',
      title: 'Legalisir Dokumen Akademik',
      subtitle: 'Legalisir ijazah, transkrip nilai, dan sertifikat akreditasi',
      description:
          'Layanan legalisasi cap basah dan tanda tangan pimpinan untuk salinan dokumen kelulusan atau transkrip akademik mahasiswa.',
    ),
    Item(
      id: '3',
      title: 'Pengajuan Cuti Akademik',
      subtitle: 'Penghentian studi sementara untuk semester mendatang',
      description:
          'Pengajuan permohonan berhenti kuliah sementara selama satu atau dua semester karena alasan kesehatan, dinas, atau alasan pribadi yang disetujui pimpinan fakultas.',
    ),
    Item(
      id: '4',
      title: 'Surat Bebas Perpustakaan',
      subtitle: 'Surat keterangan bebas peminjaman pustaka untuk syarat wisuda',
      description:
          'Pengecekan dan penerbitan bukti bebas tanggungan buku dan denda dari Perpustakaan Pusat Universitas.',
    ),
  ];

  /// Mengambil daftar item.
  /// simulateError: true -> sengaja dibuat gagal untuk menguji error state.
  Future<List<Item>> fetchItems({bool simulateError = false}) async {
    await Future.delayed(const Duration(seconds: 2)); // simulasi waktu tunggu server
    if (simulateError) {
      throw Exception('Gagal memuat data. Periksa koneksi internet.');
    }
    return _items;
  }
}
