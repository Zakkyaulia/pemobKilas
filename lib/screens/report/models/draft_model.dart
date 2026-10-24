/// Model data representasi draft laporan KILAS UNAND.
///
/// Menyimpan kondisi parsial atau lengkap dari sebuah laporan yang sedang
/// disusun pengguna sebelum dipublikasikan ke linimasa atau peta.
class DraftModel {
  const DraftModel({
    required this.id,
    this.title,
    this.description,
    this.selectedCategory = 'Kondisi Kampus',
    this.mediaFilePath,
    this.isVideo = false,
    this.locationName,
    this.coordinates,
    this.latitude,
    this.longitude,
    required this.createdAt,
    required this.updatedAt,
  });

  /// Identitas unik draft (misal: "draft-1718901234567").
  final String id;

  /// Judul laporan yang belum selesai ditulis.
  final String? title;

  /// Deskripsi atau keterangan laporan yang belum selesai ditulis.
  final String? description;

  /// Kategori isu yang dipilih: 'Kondisi Kampus' atau 'Informasi Penting'.
  final String selectedCategory;

  /// Path berkas media lokal di penyimpanan perangkat pengguna (jika ada).
  final String? mediaFilePath;

  /// Menandakan apakah media berupa video atau gambar.
  final bool isVideo;

  /// Nama lokasi atau landmark kampus saat draft disimpan.
  final String? locationName;

  /// Koordinat ringkas GPS (format: "lat, lng").
  final String? coordinates;

  /// Nilai latitude GPS saat draft disimpan.
  final double? latitude;

  /// Nilai longitude GPS saat draft disimpan.
  final double? longitude;

  /// Waktu pembuatan awal draft.
  final DateTime createdAt;

  /// Waktu terakhir draft diubah atau disimpan ulang.
  final DateTime updatedAt;

  /// Membuat salinan instans draft dengan modifikasi beberapa atribut.
  DraftModel copyWith({
    String? id,
    String? title,
    String? description,
    String? selectedCategory,
    String? mediaFilePath,
    bool? isVideo,
    String? locationName,
    String? coordinates,
    double? latitude,
    double? longitude,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return DraftModel(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      selectedCategory: selectedCategory ?? this.selectedCategory,
      mediaFilePath: mediaFilePath ?? this.mediaFilePath,
      isVideo: isVideo ?? this.isVideo,
      locationName: locationName ?? this.locationName,
      coordinates: coordinates ?? this.coordinates,
      latitude: latitude ?? this.latitude,
      longitude: longitude ?? this.longitude,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  /// Menghasilkan representasi judul yang aman ditampilkan di antarmuka pengguna.
  String get displayTitle {
    if (title != null && title!.trim().isNotEmpty) {
      return title!.trim();
    }
    return 'Draft Tanpa Judul';
  }

  /// Menghasilkan representasi cuplikan keterangan untuk card pratinjau.
  String get displayDescription {
    if (description != null && description!.trim().isNotEmpty) {
      return description!.trim();
    }
    return 'Belum ada keterangan laporan.';
  }

  /// Cek apakah draft memiliki lampiran media.
  bool get hasMedia => mediaFilePath != null && mediaFilePath!.trim().isNotEmpty;
}
