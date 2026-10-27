import 'package:flutter/material.dart';

/// Tipe notifikasi dalam aplikasi KILAS.
enum NotifType {
  /// Laporan kamu mendapatkan upvote dari pengguna lain.
  upvote,

  /// Ada informasi/pengumuman resmi dari admin/biro kampus.
  infoResmi,

  /// Pengingat laporan harian jam 16:00 WIB (FR-18 / FR-B7).
  pengingat,

  /// Laporan kamu ditindaklanjuti atau statusnya berubah.
  statusLaporan,

  /// Konfirmasi aksi yang kamu lakukan (buat/edit/hapus laporan).
  aktivitasDiri,
}

/// Model satu item notifikasi.
class NotificationItem {
  const NotificationItem({
    required this.id,
    required this.type,
    required this.title,
    required this.body,
    required this.timestamp,
    this.isRead = false,
    this.reportId,
  });

  final String id;
  final NotifType type;
  final String title;
  final String body;
  final DateTime timestamp;
  final bool isRead;

  /// ID laporan terkait untuk navigasi, jika ada.
  final String? reportId;

  /// Ikon yang merepresentasikan tipe notifikasi ini.
  IconData get icon {
    switch (type) {
      case NotifType.upvote:
        return Icons.arrow_upward_rounded;
      case NotifType.infoResmi:
        return Icons.campaign_rounded;
      case NotifType.pengingat:
        return Icons.alarm_rounded;
      case NotifType.statusLaporan:
        return Icons.check_circle_outline_rounded;
      case NotifType.aktivitasDiri:
        return Icons.edit_note_rounded;
    }
  }

  /// Warna aksen untuk ikon dan garis indikator.
  Color get accentColor {
    switch (type) {
      case NotifType.upvote:
        return const Color(0xFF1E60FF);
      case NotifType.infoResmi:
        return const Color(0xFF0048D4);
      case NotifType.pengingat:
        return const Color(0xFFF59E0B);
      case NotifType.statusLaporan:
        return const Color(0xFF10B981);
      case NotifType.aktivitasDiri:
        return const Color(0xFF8B5CF6);
    }
  }

  /// Warna background ikon (lebih terang).
  Color get iconBgColor {
    switch (type) {
      case NotifType.upvote:
        return const Color(0xFFDCE1FF);
      case NotifType.infoResmi:
        return const Color(0xFFDCE9FF);
      case NotifType.pengingat:
        return const Color(0xFFFEF3C7);
      case NotifType.statusLaporan:
        return const Color(0xFFD1FAE5);
      case NotifType.aktivitasDiri:
        return const Color(0xFFEDE9FE);
    }
  }

  /// Label kategori singkat untuk chip.
  String get categoryLabel {
    switch (type) {
      case NotifType.upvote:
        return 'Upvote';
      case NotifType.infoResmi:
        return 'Info Resmi';
      case NotifType.pengingat:
        return 'Pengingat';
      case NotifType.statusLaporan:
        return 'Status Laporan';
      case NotifType.aktivitasDiri:
        return 'Aktivitas';
    }
  }

  /// Membuat salinan item dengan field yang diperbarui.
  NotificationItem copyWith({
    String? id,
    NotifType? type,
    String? title,
    String? body,
    DateTime? timestamp,
    bool? isRead,
    String? reportId,
  }) {
    return NotificationItem(
      id: id ?? this.id,
      type: type ?? this.type,
      title: title ?? this.title,
      body: body ?? this.body,
      timestamp: timestamp ?? this.timestamp,
      isRead: isRead ?? this.isRead,
      reportId: reportId ?? this.reportId,
    );
  }

  /// Membuat [NotificationItem] dari Map / SQLite / JSON.
  factory NotificationItem.fromMap(Map<String, dynamic> map) {
    NotifType parseType(String? typeStr) {
      return NotifType.values.firstWhere(
        (e) => e.name == typeStr,
        orElse: () => NotifType.infoResmi,
      );
    }

    return NotificationItem(
      id: (map['id'] ?? '').toString(),
      type: parseType(map['type']),
      title: (map['title'] ?? '').toString(),
      body: (map['body'] ?? '').toString(),
      timestamp: DateTime.tryParse(map['timestamp']?.toString() ?? '') ?? DateTime.now(),
      isRead: map['is_read'] ?? map['isRead'] ?? false,
      reportId: map['report_id'] ?? map['reportId'],
    );
  }

  /// Alias [fromMap] untuk JSON.
  factory NotificationItem.fromJson(Map<String, dynamic> json) => NotificationItem.fromMap(json);

  /// Mengonversi [NotificationItem] ke Map (SQLite).
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'type': type.name,
      'title': title,
      'body': body,
      'timestamp': timestamp.toIso8601String(),
      'is_read': isRead,
      'report_id': reportId,
    };
  }

  /// Mengonversi [NotificationItem] ke JSON (alias [toMap]).
  Map<String, dynamic> toJson() => toMap();
}
