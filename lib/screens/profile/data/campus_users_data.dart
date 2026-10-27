import 'package:flutter/material.dart';

import '../../../theme/home_colors.dart';
import '../../home/models/report_model.dart';

/// Model pengguna kampus Universitas Andalas untuk fitur pencarian (FR-15 & FR-B4).
class CampusUserItem {
  final String userId;
  final String name;
  final String username;
  final String? nim;
  final String? avatarUrl;
  final String initials;
  final String jurusan;
  final String fakultas;
  final String bio;
  final bool isVerified;
  final Color avatarBgColor;
  final Color avatarFgColor;
  final int reportCount;
  final int totalUpvotes;

  const CampusUserItem({
    required this.userId,
    required this.name,
    required this.username,
    this.nim,
    this.avatarUrl,
    required this.initials,
    this.jurusan = 'Sistem Informasi',
    this.fakultas = 'Fakultas Teknologi Informasi',
    this.bio = 'Mahasiswa aktif Universitas Andalas.',
    this.isVerified = false,
    this.avatarBgColor = HomeColors.surfaceVariant,
    this.avatarFgColor = HomeColors.primary,
    this.reportCount = 0,
    this.totalUpvotes = 0,
  });

  CampusUserItem copyWithStats({
    required int reportCount,
    required int totalUpvotes,
  }) {
    return CampusUserItem(
      userId: userId,
      name: name,
      username: username,
      nim: nim,
      avatarUrl: avatarUrl,
      initials: initials,
      jurusan: jurusan,
      fakultas: fakultas,
      bio: bio,
      isVerified: isVerified,
      avatarBgColor: avatarBgColor,
      avatarFgColor: avatarFgColor,
      reportCount: reportCount,
      totalUpvotes: totalUpvotes,
    );
  }
}

/// Katalog data pengguna kampus UNAND terdaftar dan sinkronisasi dinamis
/// dengan [ReportRepository] (FR-15 & FR-B4).
class CampusUsersData {
  const CampusUsersData._();

  static const List<CampusUserItem> _baseUsers = [
    CampusUserItem(
      userId: 'usr-2411522036',
      name: 'Ghezy Pramudinata .B',
      username: '@ghezz',
      nim: '2411522036',
      initials: 'Gh',
      jurusan: 'Sistem Informasi \'24',
      fakultas: 'Fakultas Teknologi Informasi',
      bio: 'Aktif melaporkan fasilitas dan situasi di lingkungan kampus Limau Manis UNAND.',
      avatarBgColor: Color(0xFFE0E7FF),
      avatarFgColor: Color(0xFF4338CA),
      avatarUrl:
          'https://images.unsplash.com/photo-1534528741775-53994a69daeb?auto=format&fit=crop&w=400&q=80',
    ),
    CampusUserItem(
      userId: 'usr-2311512004',
      name: 'Ahmad Fauzan .S',
      username: '@ahmadfauzan',
      nim: '2311512004',
      initials: 'AF',
      jurusan: 'Teknik Komputer \'23',
      fakultas: 'Fakultas Teknologi Informasi',
      bio: 'Aktif mengabarkan info pemeliharaan server, jaringan Wi-Fi, dan lab komputer UNAND.',
      avatarBgColor: Color(0xFFDBEAFE),
      avatarFgColor: Color(0xFF1D4ED8),
      avatarUrl:
          'https://images.unsplash.com/photo-1535713875002-d1d0cf377fde?auto=format&fit=crop&w=400&q=80',
    ),
    CampusUserItem(
      userId: 'usr-2310912015',
      name: 'Aziz Hakim',
      username: '@aziz_hakim',
      nim: '2310912015',
      initials: 'AH',
      jurusan: 'Teknik Mesin \'23',
      fakultas: 'Fakultas Teknik',
      bio: 'Suka berbagi laporan sarana prasarana, parkiran, dan kelancaran lalu lintas kampus.',
      avatarBgColor: Color(0xFFFEF3C7),
      avatarFgColor: Color(0xFFB45309),
    ),
    CampusUserItem(
      userId: 'usr-2210921008',
      name: 'Fadhil Ramadhan',
      username: '@fadhil_r',
      nim: '2210921008',
      initials: 'FR',
      jurusan: 'Teknik Sipil \'22',
      fakultas: 'Fakultas Teknik',
      bio: 'Pemerhati infrastruktur jalan, drainase air, dan keamanan gedung kuliah.',
      avatarBgColor: Color(0xFFE0F2FE),
      avatarFgColor: Color(0xFF0369A1),
    ),
    CampusUserItem(
      userId: 'usr-2411013012',
      name: 'Putri Anisa',
      username: '@putrianisa',
      nim: '2411013012',
      initials: 'PA',
      jurusan: 'Farmasi \'24',
      fakultas: 'Fakultas Farmasi',
      bio: 'Pemberi info kesehatan lingkungan, kebersihan kafetaria, dan poliklinik UNAND.',
      avatarBgColor: Color(0xFFFCE7F3),
      avatarFgColor: Color(0xFFBE185D),
    ),
    CampusUserItem(
      userId: 'usr-2310811044',
      name: 'Diki Pratama',
      username: '@dikipratama',
      nim: '2310811044',
      initials: 'DP',
      jurusan: 'Ilmu Hukum \'23',
      fakultas: 'Fakultas Hukum',
      bio: 'Menjunjung transparansi informasi fasilitas dan ketertiban mahasiswa kampus.',
      avatarBgColor: Color(0xFFF3E8FF),
      avatarFgColor: Color(0xFF7E22CE),
    ),
    CampusUserItem(
      userId: 'usr-2310312019',
      name: 'Siti Rahma',
      username: '@sitirahma',
      nim: '2310312019',
      initials: 'SR',
      jurusan: 'Pendidikan Dokter \'23',
      fakultas: 'Fakultas Kedokteran',
      bio: 'Siaga informasi kesehatan civitas akademika dan sanitasi fasilitas kampus.',
      avatarBgColor: Color(0xFFDCFCE7),
      avatarFgColor: Color(0xFF15803D),
    ),
    CampusUserItem(
      userId: 'usr-2210611022',
      name: 'Rian Saputra',
      username: '@riansaputra',
      nim: '2210611022',
      initials: 'RS',
      jurusan: 'Peternakan \'22',
      fakultas: 'Fakultas Peternakan',
      bio: 'Sering membagikan info fasilitas riset, kandang percobaan, dan lingkungan alam kampus.',
      avatarBgColor: Color(0xFFFEF9C3),
      avatarFgColor: Color(0xFFA16207),
    ),
    CampusUserItem(
      userId: 'usr-2410421005',
      name: 'Ilham Pratama',
      username: '@ilham_p',
      nim: '2410421005',
      initials: 'IP',
      jurusan: 'Biologi \'24',
      fakultas: 'FMIPA',
      bio: 'Peduli kelestarian flora fauna, laboratorium sains, dan ekosistem kampus Limau Manis.',
      avatarBgColor: Color(0xFFECFDF5),
      avatarFgColor: Color(0xFF047857),
    ),
    CampusUserItem(
      userId: 'usr-2310522031',
      name: 'Nabila Khairunisa',
      username: '@nabilakh',
      nim: '2310522031',
      initials: 'NK',
      jurusan: 'Manajemen \'23',
      fakultas: 'Fakultas Ekonomi dan Bisnis',
      bio: 'Aktif di kegiatan organisasi mahasiswa, ruang seminar, dan pusat kegiatan belajar.',
      avatarBgColor: Color(0xFFFFEDD5),
      avatarFgColor: Color(0xFFC2410C),
    ),
    CampusUserItem(
      userId: 'usr-unand-official',
      name: 'Humas Universitas Andalas',
      username: '@unand_official',
      initials: 'UN',
      jurusan: 'Lembaga Resmi Kampus',
      fakultas: 'Universitas Andalas',
      bio: 'Kanal publikasi resmi, kebijakan, dan klarifikasi informasi kampus Universitas Andalas.',
      isVerified: true,
      avatarBgColor: Color(0xFFDBEAFE),
      avatarFgColor: Color(0xFF1E40AF),
    ),
  ];

  /// Mengambil seluruh data pengguna kampus terdaftar, dan menghitung jumlah
  /// laporan serta total upvotes secara live dari list laporan [reports].
  static List<CampusUserItem> getCampusUsers({
    required List<ReportModel> reports,
  }) {
    final Map<String, CampusUserItem> userMap = {};

    // 1. Masukkan pengguna terdaftar dasar
    for (final u in _baseUsers) {
      userMap[u.username.toLowerCase()] = u;
    }

    // 2. Deteksi penulis unik dari laporan jika ada pengguna baru
    for (final report in reports) {
      final uname = report.authorUsername?.toLowerCase() ??
          '@${report.authorName.toLowerCase().replaceAll(' ', '')}';
      if (!userMap.containsKey(uname)) {
        userMap[uname] = CampusUserItem(
          userId: 'usr-${uname.replaceAll('@', '')}',
          name: report.authorName,
          username: report.authorUsername ?? uname,
          initials: report.authorInitials ??
              (report.authorName.isNotEmpty ? report.authorName[0] : 'U'),
          jurusan: report.isVerified ? 'Institusi Resmi' : 'Sistem Informasi',
          fakultas: report.isVerified
              ? 'Universitas Andalas'
              : 'Fakultas Teknologi Informasi',
          bio: 'Mahasiswa aktif Universitas Andalas.',
          isVerified: report.isVerified,
          avatarBgColor: report.avatarBgColor,
          avatarFgColor: report.avatarFgColor,
          avatarUrl: report.authorAvatarUrl,
        );
      }
    }

    // 3. Hitung metrik dinamis (reportCount & totalUpvotes) untuk masing-masing pengguna
    final List<CampusUserItem> result = [];
    for (final user in userMap.values) {
      final userReports = reports.where((r) {
        final matchUsername = r.authorUsername != null &&
            r.authorUsername!.toLowerCase() == user.username.toLowerCase();
        final matchName = r.authorName.toLowerCase() == user.name.toLowerCase();
        return matchUsername || matchName;
      }).toList();

      final upvotes = userReports.fold<int>(
        0,
        (acc, curr) => acc + curr.upvoteCount,
      );

      result.add(user.copyWithStats(
        reportCount: userReports.length,
        totalUpvotes: upvotes,
      ));
    }

    // Urutkan berdasarkan total upvotes terbanyak, kemudian jumlah laporan
    result.sort((a, b) {
      final cmpUpvote = b.totalUpvotes.compareTo(a.totalUpvotes);
      if (cmpUpvote != 0) return cmpUpvote;
      return b.reportCount.compareTo(a.reportCount);
    });

    return result;
  }
}
