import '../../widgets/home/video_player_box.dart';

/// Aturan media laporan (sama dengan validasi backend, lihat ERD `report_media`).
///
/// - 1–5 media per laporan, maksimal 1 video.
/// - Foto ≤ 5 MB; video ≤ 25 MB dan ≤ 30 detik.
abstract final class MediaRules {
  static const int maxMediaPerReport = 5;
  static const int maxVideoPerReport = 1;
  static const int maxImageBytes = 5 * 1024 * 1024;
  static const int maxVideoBytes = 25 * 1024 * 1024;
  static const Duration maxVideoDuration = Duration(seconds: 30);

  /// Teks ringkas untuk ditampilkan di form.
  static const String summary =
      'Maks. 5 media (1 video) • Foto ≤ 5MB • Video ≤ 25MB & 30 dtk';

  /// Jumlah video pada daftar path media.
  static int videoCount(Iterable<String> paths) =>
      paths.where(isVideoMedia).length;

  /// Sisa slot media yang masih bisa ditambahkan.
  static int remainingSlots(Iterable<String> paths) =>
      maxMediaPerReport - paths.length;

  /// Memvalidasi penambahan satu media baru. Mengembalikan pesan error
  /// atau `null` bila boleh ditambahkan.
  static String? validateAdd({
    required List<String> current,
    required bool isVideo,
    required int bytes,
  }) {
    if (current.length >= maxMediaPerReport) {
      return 'Maksimal $maxMediaPerReport media per laporan.';
    }
    if (isVideo && videoCount(current) >= maxVideoPerReport) {
      return 'Hanya boleh $maxVideoPerReport video per laporan.';
    }
    final limit = isVideo ? maxVideoBytes : maxImageBytes;
    if (bytes > limit) {
      final sizeMb = (bytes / (1024 * 1024)).toStringAsFixed(1);
      final limitMb = limit ~/ (1024 * 1024);
      return 'Ukuran ${isVideo ? 'video' : 'foto'} ($sizeMb MB) melebihi batas $limitMb MB.';
    }
    return null;
  }
}
