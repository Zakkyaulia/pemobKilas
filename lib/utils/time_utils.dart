/// Utility formatting waktu dinamis dan real-time untuk aplikasi KILAS.
///
/// Menyediakan konversi [DateTime] ke format waktu relatif (Bahasa Indonesia)
/// serta perhitungan batas waktu edit laporan (FR-A2 24 jam).
class TimeUtils {
  TimeUtils._();

  /// Format waktu relatif dalam Bahasa Indonesia.
  /// [isShort] = true menghasilkan format ringkas seperti "15m lalu", "2j lalu".
  /// [isShort] = false menghasilkan format panjang seperti "15 menit yang lalu".
  static String formatTimeAgo(DateTime? dateTime, {bool isShort = true}) {
    if (dateTime == null) return 'Baru saja';

    final now = DateTime.now();
    final difference = now.difference(dateTime);

    if (difference.isNegative || difference.inSeconds < 45) {
      return 'Baru saja';
    } else if (difference.inMinutes < 60) {
      final m = difference.inMinutes;
      return isShort ? '${m}m lalu' : '$m menit yang lalu';
    } else if (difference.inHours < 24) {
      final h = difference.inHours;
      return isShort ? '${h}j lalu' : '$h jam yang lalu';
    } else if (difference.inDays < 7) {
      final d = difference.inDays;
      return isShort ? '${d}h lalu' : '$d hari yang lalu';
    } else if (difference.inDays < 30) {
      final w = (difference.inDays / 7).floor();
      return isShort ? '${w}mg lalu' : '$w minggu yang lalu';
    } else {
      const months = [
        'Jan', 'Feb', 'Mar', 'Apr', 'Mei', 'Jun',
        'Jul', 'Agt', 'Sep', 'Okt', 'Nov', 'Des'
      ];
      final monthName = months[dateTime.month - 1];
      return '${dateTime.day} $monthName ${dateTime.year}';
    }
  }

  /// Menghitung sisa waktu sebelum batas 24 jam edit habis.
  static Duration remainingEditDuration(DateTime createdAt) {
    final deadline = createdAt.add(const Duration(hours: 24));
    final diff = deadline.difference(DateTime.now());
    return diff.isNegative ? Duration.zero : diff;
  }

  /// Format sisa waktu edit dalam teks deskriptif (misal "23 jam 45 menit").
  static String formatRemainingTime(DateTime createdAt) {
    final remaining = remainingEditDuration(createdAt);
    if (remaining == Duration.zero) {
      return 'Batas waktu edit telah berakhir';
    }

    final hours = remaining.inHours;
    final minutes = remaining.inMinutes % 60;

    if (hours > 0) {
      return '$hours jam $minutes menit';
    }
    return '$minutes menit';
  }

  /// Cek apakah laporan masih dalam jendela 24 jam edit.
  static bool canEdit(DateTime? createdAt) {
    if (createdAt == null) return true;
    final diff = DateTime.now().difference(createdAt);
    return !diff.isNegative && diff.inHours < 24;
  }
}
