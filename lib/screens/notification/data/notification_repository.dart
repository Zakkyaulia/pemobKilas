import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;

import '../../../config/app_config.dart';
import '../../../services/auth_session_service.dart';
import '../models/notification_model.dart';

/// Singleton repository untuk mengelola state daftar notifikasi in-app KILAS.
///
/// Menyediakan:
/// - Daftar notifikasi dengan integrasi REST API backend KILAS (/api/notifications)
/// - Penanda baca (read/unread) per item
/// - Jumlah notifikasi belum dibaca (untuk badge bottom nav)
/// - Tandai semua sudah dibaca
/// - Hapus satu atau semua notifikasi
class NotificationRepository extends ChangeNotifier {
  NotificationRepository._() {
    _items = _buildMockData();
    fetchNotificationsFromBackend();
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

  // ── Integrasi REST API Backend ─────────────────────────────────────────────

  Future<Map<String, String>> _authHeaders() async {
    final token = await AuthSessionService.getToken();
    final headers = <String, String>{
      'Accept': 'application/json',
      'Content-Type': 'application/json',
    };
    if (token != null && token.isNotEmpty) {
      headers['Authorization'] = 'Bearer $token';
    }
    return headers;
  }

  /// Mengambil riwayat notifikasi dari server backend KILAS (FR-19 & FR-A8).
  Future<void> fetchNotificationsFromBackend() async {
    try {
      final token = await AuthSessionService.getToken();
      if (token == null || token.isEmpty) return;

      final uri = Uri.parse('${AppConfig.baseUrl}/api/notifications');
      final headers = await _authHeaders();
      final response = await http
          .get(uri, headers: headers)
          .timeout(AppConfig.requestTimeout);

      if (response.statusCode >= 200 && response.statusCode < 300) {
        final body = jsonDecode(response.body) as Map<String, dynamic>;
        final data = body['data'];
        if (data is List) {
          final remoteItems = data
              .map((item) => NotificationItem.fromMap(item as Map<String, dynamic>))
              .toList();
          if (remoteItems.isNotEmpty) {
            _items = remoteItems;
            notifyListeners();
          }
        }
      }
    } catch (_) {
      // Abaikan jika offline / server tidak terjangkau
    }
  }

  // ── Aksi ────────────────────────────────────────────────────────────────

  /// Menandai satu notifikasi sebagai sudah dibaca.
  void markAsRead(String id) {
    final idx = _items.indexWhere((n) => n.id == id);
    if (idx == -1) return;
    if (_items[idx].isRead) return;
    _items[idx] = _items[idx].copyWith(isRead: true);
    notifyListeners();

    // Sync ke server secara async
    _syncMarkAsRead(id);
  }

  Future<void> _syncMarkAsRead(String id) async {
    try {
      final uri = Uri.parse('${AppConfig.baseUrl}/api/notifications/$id/read');
      final headers = await _authHeaders();
      await http.patch(uri, headers: headers).timeout(AppConfig.requestTimeout);
    } catch (_) {}
  }

  /// Menandai SEMUA notifikasi sebagai sudah dibaca.
  void markAllAsRead() {
    _items = _items.map((n) => n.copyWith(isRead: true)).toList();
    notifyListeners();

    _syncMarkAllAsRead();
  }

  Future<void> _syncMarkAllAsRead() async {
    try {
      final uri = Uri.parse('${AppConfig.baseUrl}/api/notifications/read-all');
      final headers = await _authHeaders();
      await http.patch(uri, headers: headers).timeout(AppConfig.requestTimeout);
    } catch (_) {}
  }

  /// Menghapus satu notifikasi.
  void remove(String id) {
    _items.removeWhere((n) => n.id == id);
    notifyListeners();

    _syncDeleteNotification(id);
  }

  Future<void> _syncDeleteNotification(String id) async {
    try {
      final uri = Uri.parse('${AppConfig.baseUrl}/api/notifications/$id');
      final headers = await _authHeaders();
      await http.delete(uri, headers: headers).timeout(AppConfig.requestTimeout);
    } catch (_) {}
  }

  /// Menghapus semua notifikasi.
  void clearAll() {
    _items.clear();
    notifyListeners();

    _syncClearAll();
  }

  Future<void> _syncClearAll() async {
    try {
      final uri = Uri.parse('${AppConfig.baseUrl}/api/notifications');
      final headers = await _authHeaders();
      await http.delete(uri, headers: headers).timeout(AppConfig.requestTimeout);
    } catch (_) {}
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
        title: 'Laporanmu mencapai 25 upvote',
        body: '"AC Ruang Kuliah GKB C 204 bocor & tidak dingin" didukung 25 civitas UNAND.',
        timestamp: now.subtract(const Duration(minutes: 5)),
        isRead: false,
        reportId: 'post-1',
      ),
      NotificationItem(
        id: 'notif-2',
        type: NotifType.pengingat,
        title: 'Belum melapor hari ini',
        body: 'Ada kondisi kampus yang perlu dilaporkan? Bagikan lewat KILAS.',
        timestamp: now.subtract(const Duration(hours: 4)),
        isRead: false,
      ),
      // ── Kemarin ───────────────────────────────────────────────────────
      NotificationItem(
        id: 'notif-3',
        type: NotifType.upvote,
        title: 'Laporanmu mencapai 10 upvote',
        body: '"Pipa Air Toilet Bocor di Lantai 1 Gedung C" didukung 10 civitas UNAND.',
        timestamp: now.subtract(const Duration(hours: 26)),
        isRead: true,
        reportId: 'post-19',
      ),
      NotificationItem(
        id: 'notif-4',
        type: NotifType.upvote,
        title: 'Laporanmu mencapai 10 upvote',
        body: '"AC Ruang Kuliah GKB C 204 bocor & tidak dingin" didukung 10 civitas UNAND.',
        timestamp: now.subtract(const Duration(hours: 30)),
        isRead: true,
        reportId: 'post-1',
      ),
      // ── Lebih lama ────────────────────────────────────────────────────
      NotificationItem(
        id: 'notif-5',
        type: NotifType.pengingat,
        title: 'Belum melapor hari ini',
        body: 'Ada kondisi kampus yang perlu dilaporkan? Bagikan lewat KILAS.',
        timestamp: now.subtract(const Duration(days: 2, hours: 2)),
        isRead: true,
      ),
      NotificationItem(
        id: 'notif-6',
        type: NotifType.upvote,
        title: 'Laporanmu mencapai 5 upvote',
        body: '"Pipa Air Toilet Bocor di Lantai 1 Gedung C" didukung 5 civitas UNAND.',
        timestamp: now.subtract(const Duration(days: 3)),
        isRead: true,
        reportId: 'post-19',
      ),
      NotificationItem(
        id: 'notif-7',
        type: NotifType.upvote,
        title: 'Laporanmu mencapai 5 upvote',
        body: '"AC Ruang Kuliah GKB C 204 bocor & tidak dingin" didukung 5 civitas UNAND.',
        timestamp: now.subtract(const Duration(days: 4)),
        isRead: true,
        reportId: 'post-1',
      ),
    ];
  }
}
