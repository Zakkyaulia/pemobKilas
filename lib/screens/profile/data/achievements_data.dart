import 'package:flutter/material.dart';

import '../../home/models/report_model.dart';

/// Model representasi Lencana / Pencapaian Mahasiswa (FR-17 & FR-B6).
///
/// Menyimpan:
/// - [kodeLencana]: Kode unik lencana (identik dengan entitas database)
/// - [nama]: Nama lencana prestasi
/// - [deskripsi]: Syarat dan penjelasan pencapaian
/// - [icon]: Ikon visual lencana
/// - [iconColor]: Warna aksen lencana
/// - [iconBg]: Warna latar belakang lingkaran ikon
/// - [isUnlocked]: Status apakah lencana sudah terbuka
/// - [dibukaPada]: Tanggal saat lencana berhasil diraih (null jika terkunci)
/// - [progress]: Rasio kemajuan (0.0 sampai 1.0)
/// - [progressLabel]: Teks keterangan kemajuan (misal: "3 / 5 Laporan")
class AchievementBadge {
  final String kodeLencana;
  final String nama;
  final String deskripsi;
  final IconData icon;
  final Color iconColor;
  final Color iconBg;
  final bool isUnlocked;
  final String? dibukaPada;
  final double progress;
  final String progressLabel;

  const AchievementBadge({
    required this.kodeLencana,
    required this.nama,
    required this.deskripsi,
    required this.icon,
    required this.iconColor,
    required this.iconBg,
    required this.isUnlocked,
    this.dibukaPada,
    required this.progress,
    required this.progressLabel,
  });
}

/// Helper untuk menghitung status lencana prestasi mahasiswa KILAS UNAND
/// berdasarkan daftar laporan terbitan pengguna saat ini.
class AchievementsData {
  const AchievementsData._();

  /// Menghasilkan 6 lencana resmi mahasiswa sesuai spesifikasi FR-B6.
  static List<AchievementBadge> calculateBadges({
    required List<ReportModel> myReports,
    required int totalUpvotes,
  }) {
    final totalReports = myReports.length;
    final conditionReports = myReports
        .where((r) => r.badgeLabel == 'Kondisi Kampus')
        .length;
    // Hitung laporan dalam 30 hari terakhir
    final now = DateTime.now();
    final reportsThisMonth = myReports.where((r) {
      if (r.createdAt == null) return true;
      final diff = now.difference(r.createdAt!);
      return diff.inDays <= 30;
    }).length;

    return [
      // 1. Pelapor Perdana
      AchievementBadge(
        kodeLencana: 'FIRST_REPORT',
        nama: 'Pelapor Perdana',
        deskripsi: 'Menerbitkan laporan fasilitas atau informasi pertama di KILAS UNAND.',
        icon: Icons.flag_rounded,
        iconColor: const Color(0xFF2563EB),
        iconBg: const Color(0xFFEFF6FF),
        isUnlocked: totalReports >= 1,
        dibukaPada: totalReports >= 1 ? '12 Okt 2026' : null,
        progress: (totalReports / 1).clamp(0.0, 1.0),
        progressLabel: totalReports >= 1 ? 'Selesai (1/1)' : '0 / 1 Laporan',
      ),

      // 2. Pahlawan Kampus
      AchievementBadge(
        kodeLencana: 'CAMPUS_HERO',
        nama: 'Pahlawan Kampus',
        deskripsi: 'Meraih akumulasi minimal 10 dukungan upvote dari mahasiswa lain.',
        icon: Icons.thumb_up_alt_rounded,
        iconColor: const Color(0xFF10B981),
        iconBg: const Color(0xFFECFDF5),
        isUnlocked: totalUpvotes >= 10,
        dibukaPada: totalUpvotes >= 10 ? '18 Okt 2026' : null,
        progress: (totalUpvotes / 10).clamp(0.0, 1.0),
        progressLabel: totalUpvotes >= 10
            ? 'Selesai ($totalUpvotes/10)'
            : '$totalUpvotes / 10 Upvotes',
      ),

      // 3. Mata Elang
      AchievementBadge(
        kodeLencana: 'EAGLE_EYE',
        nama: 'Mata Elang',
        deskripsi: 'Peduli dan melaporkan setidaknya 2 kondisi sarana fisik kampus.',
        icon: Icons.remove_red_eye_rounded,
        iconColor: const Color(0xFFF59E0B),
        iconBg: const Color(0xFFFEF3C7),
        isUnlocked: conditionReports >= 2,
        dibukaPada: conditionReports >= 2 ? '24 Okt 2026' : null,
        progress: (conditionReports / 2).clamp(0.0, 1.0),
        progressLabel: conditionReports >= 2
            ? 'Selesai ($conditionReports/2)'
            : '$conditionReports / 2 Kondisi',
      ),

      // 4. Warga Aktif
      AchievementBadge(
        kodeLencana: 'ACTIVE_CITIZEN',
        nama: 'Warga Aktif',
        deskripsi: 'Menerbitkan laporan kampus dalam periode 30 hari terakhir.',
        icon: Icons.bolt_rounded,
        iconColor: const Color(0xFF8B5CF6),
        iconBg: const Color(0xFFF5F3FF),
        isUnlocked: reportsThisMonth >= 1,
        dibukaPada: reportsThisMonth >= 1 ? 'Bulan Ini' : null,
        progress: (reportsThisMonth / 1).clamp(0.0, 1.0),
        progressLabel: reportsThisMonth >= 1
            ? 'Aktif ($reportsThisMonth laporan)'
            : '0 / 1 Laporan Bulan Ini',
      ),

      // 5. Suara Kritis
      AchievementBadge(
        kodeLencana: 'VOICE_OF_CAMPUS',
        nama: 'Suara Kritis',
        deskripsi: 'Memperoleh total 30+ upvotes akumulatif atas laporan bermanfaat.',
        icon: Icons.campaign_rounded,
        iconColor: const Color(0xFFEC4899),
        iconBg: const Color(0xFFFDF2F8),
        isUnlocked: totalUpvotes >= 30,
        dibukaPada: totalUpvotes >= 30 ? '26 Okt 2026' : null,
        progress: (totalUpvotes / 30).clamp(0.0, 1.0),
        progressLabel: totalUpvotes >= 30
            ? 'Selesai ($totalUpvotes/30)'
            : '$totalUpvotes / 30 Upvotes',
      ),

      // 6. Master Pelapor
      AchievementBadge(
        kodeLencana: 'MASTER_REPORTER',
        nama: 'Master Pelapor',
        deskripsi: 'Mempublikasikan total 5 laporan kampus yang membantu sivitas UNAND.',
        icon: Icons.military_tech_rounded,
        iconColor: const Color(0xFF0D9488),
        iconBg: const Color(0xFFCCFBF1),
        isUnlocked: totalReports >= 5,
        dibukaPada: totalReports >= 5 ? '27 Okt 2026' : null,
        progress: (totalReports / 5).clamp(0.0, 1.0),
        progressLabel: totalReports >= 5
            ? 'Selesai ($totalReports/5)'
            : '$totalReports / 5 Laporan',
      ),
    ];
  }
}
