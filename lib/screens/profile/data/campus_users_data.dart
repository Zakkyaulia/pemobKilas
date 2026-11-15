import 'package:flutter/material.dart';

import '../../../theme/home_colors.dart';

/// Model pengguna kampus Universitas Andalas untuk fitur pencarian (FR-15 & FR-B4).
class CampusUserItem {
  final String userId;
  final String name;
  final String username;
  final String? avatarUrl;
  final String initials;
  final String? jurusan;
  final String? fakultas;
  final String bio;
  final Color avatarBgColor;
  final Color avatarFgColor;
  final int reportCount;
  final int totalUpvotes;

  const CampusUserItem({
    required this.userId,
    required this.name,
    required this.username,
    this.avatarUrl,
    required this.initials,
    this.jurusan,
    this.fakultas,
    this.bio = 'Mahasiswa aktif Universitas Andalas.',
    this.avatarBgColor = HomeColors.surfaceVariant,
    this.avatarFgColor = HomeColors.primary,
    this.reportCount = 0,
    this.totalUpvotes = 0,
  });

  /// Factory untuk membuat [CampusUserItem] dari JSON response backend Express API.
  factory CampusUserItem.fromJson(Map<String, dynamic> json) {
    final name = json['nama'] as String? ?? 'Mahasiswa';
    final rawUsername = json['username'] as String? ?? '';
    final username = rawUsername.startsWith('@') ? rawUsername : '@$rawUsername';

    // Buat inisial dari nama
    final parts = name.trim().split(RegExp(r'\s+'));
    final initials = parts.length > 1
        ? '${parts[0].isNotEmpty ? parts[0][0] : ''}${parts[1].isNotEmpty ? parts[1][0] : ''}'.toUpperCase()
        : (name.isNotEmpty ? name.substring(0, name.length >= 2 ? 2 : 1).toUpperCase() : 'U');

    // Palet warna avatar pastel otomatis berdasarkan hash username
    final hash = username.hashCode.abs();
    final colors = [
      (const Color(0xFFE0E7FF), const Color(0xFF4338CA)), // Indigo
      (const Color(0xFFDBEAFE), const Color(0xFF1D4ED8)), // Blue
      (const Color(0xFFFEF3C7), const Color(0xFFB45309)), // Amber
      (const Color(0xFFDCFCE7), const Color(0xFF15803D)), // Green
      (const Color(0xFFFCE7F3), const Color(0xFFBE185D)), // Pink
      (const Color(0xFFF3E8FF), const Color(0xFF7E22CE)), // Purple
      (const Color(0xFFFFEDD5), const Color(0xFFC2410C)), // Orange
    ];
    final selectedColor = colors[hash % colors.length];

    return CampusUserItem(
      userId: json['user_id'] as String? ?? '',
      name: name,
      username: username,
      avatarUrl: json['foto_profil'] as String?,
      initials: initials,
      jurusan: json['jurusan'] as String?,
      fakultas: json['fakultas'] as String?,
      bio: json['bio'] as String? ?? 'Mahasiswa aktif Universitas Andalas.',
      avatarBgColor: selectedColor.$1,
      avatarFgColor: selectedColor.$2,
      reportCount: (json['report_count'] as num?)?.toInt() ?? 0,
      totalUpvotes: (json['total_upvotes'] as num?)?.toInt() ?? 0,
    );
  }

  CampusUserItem copyWithStats({
    required int reportCount,
    required int totalUpvotes,
  }) {
    return CampusUserItem(
      userId: userId,
      name: name,
      username: username,
      avatarUrl: avatarUrl,
      initials: initials,
      jurusan: jurusan,
      fakultas: fakultas,
      bio: bio,
      avatarBgColor: avatarBgColor,
      avatarFgColor: avatarFgColor,
      reportCount: reportCount,
      totalUpvotes: totalUpvotes,
    );
  }
}
