import 'package:flutter/foundation.dart';

import '../models/notification_model.dart';

/// Singleton repository untuk mengelola state daftar notifikasi in-app KILAS.
///
/// Menyediakan:
/// - Daftar notifikasi dengan mock data realistis
/// - Penanda baca (read/unread) per item
/// - Jumlah notifikasi belum dibaca (untuk badge bottom nav)
/// - Tandai semua sudah dibaca
/// - Hapus satu atau semua notifikasi
class NotificationRepository extends ChangeNotifier {
  NotificationRepository._() {
    _items = _buildMockData();
  }

  static final NotificationRepository _instance = NotificationRepository._();
  static NotificationRepository get instance => _instance;

  late List<NotificationItem> _items;

  /// Semua item notifikasi (paling baru di atas).
  List<NotificationItem> get items => List.unmodifiable(_items);

  /// Jumlah notifikasi yang belum dibaca (untuk badge merah di bottom nav).
  int get unreadCount => _items.where((n) => !n.isRead).length;

  /// Apakah ada notifikasi yang belum dibaca.
  bool get hasUnread => unreadCount > 0;

  // ── Aksi ────────────────────────────────────────────────────────────────

  /// Menandai satu notifikasi sebagai sudah dibaca.
  void markAsRead(String id) {
    final idx = _items.indexWhere((n) => n.id == id);
    if (idx == -1) return;
    if (_items[idx].isRead) return;
    _items[idx] = _items[idx].copyWith(isRead: true);
    notifyListeners();
  }

  /// Menandai SEMUA notifikasi sebagai sudah dibaca.
  void markAllAsRead() {
    _items = _items.map((n) => n.copyWith(isRead: true)).toList();
    notifyListeners();
  }

  /// Menghapus satu notifikasi.
  void remove(String id) {
    _items.removeWhere((n) => n.id == id);
    notifyListeners();
  }

  /// Menghapus semua notifikasi.
  void clearAll() {
    _items.clear();
    notifyListeners();
  }

  /// Menambahkan notifikasi baru di posisi teratas.
  void add(NotificationItem item) {
    _items.insert(0, item);
    notifyListeners();
  }

  // ── Mock Data ────────────────────────────────────────────────────────────

  static List<NotificationItem> _buildMockData() {
    final now = DateTime.now();
    return [
      // ── Hari ini ──────────────────────────────────────────────────────
      NotificationItem(
        id: 'notif-1',
        type: NotifType.upvote,
        title: '42 orang mendukung laporanmu',
        body: 'Laporan "AC Ruang Kuliah GKB C 204 bocor & tidak dingin" mendapat banyak dukungan dari warga kampus.',
        timestamp: now.subtract(const Duration(minutes: 5)),
        isRead: false,
        reportId: 'post-1',
      ),
      NotificationItem(
        id: 'notif-2',
        type: NotifType.infoResmi,
        title: 'Info Penting dari Biro Umum UNAND',
        body: 'Maintenance Lift Gedung Rektorat Sayap Kanan dijadwalkan hari ini hingga pukul 16:00 WIB.',
        timestamp: now.subtract(const Duration(hours: 2)),
        isRead: false,
        reportId: 'post-3',
      ),
      NotificationItem(
        id: 'notif-3',
        type: NotifType.statusLaporan,
        title: 'Laporanmu sedang ditindaklanjuti',
        body: 'Laporan "AC Ruang Kuliah GKB C 204" telah diteruskan ke tim fasilitas kampus untuk segera diperbaiki.',
        timestamp: now.subtract(const Duration(hours: 3)),
        isRead: false,
        reportId: 'post-1',
      ),
      NotificationItem(
        id: 'notif-4',
        type: NotifType.pengingat,
        title: 'Waktunya lapor kondisi kampus! ⏰',
        body: 'Sudah jam 16:00 WIB — ada yang perlu dilaporkan hari ini? Bantu warga kampus dengan informasi terkini.',
        timestamp: now.subtract(const Duration(hours: 4)),
        isRead: true,
      ),
      // ── Kemarin ───────────────────────────────────────────────────────
      NotificationItem(
        id: 'notif-5',
        type: NotifType.upvote,
        title: '28 orang mendukung laporanmu',
        body: 'Laporan "Genangan air hujan & dahan patah menutup bahu jalan PKM" mendapat banyak perhatian.',
        timestamp: now.subtract(const Duration(hours: 26)),
        isRead: true,
        reportId: 'post-2',
      ),
      NotificationItem(
        id: 'notif-6',
        type: NotifType.aktivitasDiri,
        title: 'Laporan berhasil diterbitkan',
        body: 'Laporan "AC Ruang Kuliah GKB C 204 bocor & tidak dingin" telah berhasil dikirimkan ke feed KILAS.',
        timestamp: now.subtract(const Duration(hours: 28)),
        isRead: true,
        reportId: 'post-1',
      ),
      // ── Lebih lama ────────────────────────────────────────────────────
      NotificationItem(
        id: 'notif-7',
        type: NotifType.infoResmi,
        title: 'Pengumuman Jadwal Pemadaman Listrik',
        body: 'PLN akan melakukan pemeliharaan jaringan di area Gedung FTI pada Kamis, 17 Oktober pukul 08:00–14:00 WIB.',
        timestamp: now.subtract(const Duration(days: 3)),
        isRead: true,
        reportId: 'post-6',
      ),
      NotificationItem(
        id: 'notif-8',
        type: NotifType.aktivitasDiri,
        title: 'Laporan berhasil diperbarui',
        body: 'Perubahan pada laporan "Fasilitas parkir depan GKB" telah tersimpan.',
        timestamp: now.subtract(const Duration(days: 4)),
        isRead: true,
        reportId: 'post-1',
      ),
    ];
  }
}
