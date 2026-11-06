import '../../../widgets/home/video_player_box.dart';

/// Status unggah draft laporan (FR-20 / FR-C2).
enum DraftStatus {
  /// Belum diunggah; menunggu dikirim (manual atau otomatis saat online).
  menunggu,

  /// Sedang dikirim ke server.
  mengunggah,

  /// Gagal diunggah; lihat [DraftModel.errorMessage].
  gagal,
}

extension DraftStatusLabel on DraftStatus {
  String get label {
    switch (this) {
      case DraftStatus.menunggu:
        return 'Menunggu';
      case DraftStatus.mengunggah:
        return 'Mengunggah';
      case DraftStatus.gagal:
        return 'Gagal';
    }
  }
}

/// Model data representasi draft laporan KILAS UNAND.
///
/// Menyimpan kondisi parsial atau lengkap dari sebuah laporan yang sedang
/// disusun pengguna sebelum dipublikasikan ke linimasa atau peta.
/// Draft hanya disimpan di perangkat (tidak ada di database server).
class DraftModel {
  const DraftModel({
    required this.id,
    this.title,
    this.description,
    this.selectedCategory = 'Kondisi Kampus',
    this.mediaPaths = const [],
    this.locationName,
    this.coordinates,
    this.latitude,
    this.longitude,
    this.status = DraftStatus.menunggu,
    this.errorMessage,
    this.retryCount = 0,
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

  /// Path berkas media lokal (maks. 5, maks. 1 video), urut sesuai pilihan.
  final List<String> mediaPaths;

  /// Nama lokasi hasil reverse geocoding saat draft disimpan (null jika gagal).
  final String? locationName;

  /// Koordinat ringkas GPS (format: "lat, lng").
  final String? coordinates;

  /// Nilai latitude GPS saat draft disimpan.
  final double? latitude;

  /// Nilai longitude GPS saat draft disimpan.
  final double? longitude;

  /// Status unggah draft.
  final DraftStatus status;

  /// Alasan gagal unggah terakhir (bila [status] = gagal).
  final String? errorMessage;

  /// Berapa kali draft sudah dicoba diunggah.
  final int retryCount;

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
    List<String>? mediaPaths,
    String? locationName,
    String? coordinates,
    double? latitude,
    double? longitude,
    DraftStatus? status,
    String? errorMessage,
    int? retryCount,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return DraftModel(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      selectedCategory: selectedCategory ?? this.selectedCategory,
      mediaPaths: mediaPaths ?? this.mediaPaths,
      locationName: locationName ?? this.locationName,
      coordinates: coordinates ?? this.coordinates,
      latitude: latitude ?? this.latitude,
      longitude: longitude ?? this.longitude,
      status: status ?? this.status,
      errorMessage: errorMessage ?? this.errorMessage,
      retryCount: retryCount ?? this.retryCount,
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
  bool get hasMedia => mediaPaths.isNotEmpty;

  /// Jumlah foto & video terlampir.
  int get videoCount => mediaPaths.where(isVideoMedia).length;
  int get photoCount => mediaPaths.length - videoCount;

  /// Ringkasan lampiran, misal "2 Foto • 1 Video".
  String get mediaSummary {
    final parts = <String>[
      if (photoCount > 0) '$photoCount Foto',
      if (videoCount > 0) '$videoCount Video',
    ];
    return parts.join(' • ');
  }
}
