/// Model data utama aplikasi KILAS.
/// Menyimpan informasi kegiatan/pengumuman kemahasiswaan.
class Kegiatan {
  final String id;
  final String title;
  final String subtitle;
  final String description;

  const Kegiatan({
    required this.id,
    required this.title,
    required this.subtitle,
    required this.description,
  });
}
