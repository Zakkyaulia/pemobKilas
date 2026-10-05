import 'package:flutter/material.dart';

import '../../../theme/home_colors.dart';
import '../models/report_model.dart';

/// Dummy feed data with 18 realistic campus reports, strictly using 2 categories:
/// 1. "Kondisi Kampus" (dot badge)
/// 2. "Info Penting" (icon badge)
/// All location icons consistently use [HomeColors.primary] (blue).
const List<ReportModel> mockReports = [
  // ── Card 1: Ghezy — AC Ruang Kuliah (16:9) ──────────────────────────────
  ReportModel(
    id: 'post-1',
    cardType: CardType.report,
    authorName: 'Ghezy Pramudinata .B',
    authorUsername: '@ghezz',
    authorInitials: 'Gh',
    avatarBgColor: HomeColors.surfaceVariant,
    avatarFgColor: HomeColors.primary,
    metaIcon: Icons.location_on,
    metaIconColor: HomeColors.primary,
    metaText: 'Gedung GKB C • 15m lalu',
    locationName: 'Gedung GKB C UNAND',
    locationDetail: '-0.914203, 100.461021',
    timestamp: '15 menit yang lalu • 14:20 WIB',
    badgeLabel: 'Kondisi Kampus',
    badgeVariant: BadgeVariant.dot,
    badgeDotColor: HomeColors.statusCondition,
    badgeBgColor: HomeColors.tertiaryFixed,
    badgeTextColor: HomeColors.onTertiaryFixedVariant,
    title: 'AC Ruang Kuliah GKB C 204 bocor & tidak dingin',
    description:
        'Air menetes deras tepat di deretan bangku tengah. '
        'Suasana kelas sangat gerah saat kuliah statistika '
        'berlangsung, sehingga beberapa baris kursi tidak '
        'dapat ditempati mahasiswa. Mohon pihak terkait segera '
        'memperbaiki demi kenyamanan belajar bersama.',
    imageUrl:
        'https://lh3.googleusercontent.com/aida-public/AB6AXuCQjRXiN2w4dCPIVQhWlufSduDBSOqq2UCDygQfUyfqSojlTedSVb-jV0eQv01FkURvr7Qgez_9haHqOHRzyrTMm3-zTxvYqLoT_9pOnwvzbpXntLaJrl15dn9w9LqHV6h_Q-VTAArbnGCIPrkLxKjPYJlR_v1VSLY4KUOIjrOZXQlOZdLstSB2MYxJK3RiWV-7pjLLrSMmfoav9T6019ykOx4WMX3P7hAfHAQKUCS_DHnrVSu8_buT',
    aspectRatio: 16 / 9,
    imageSemanticLabel: 'AC Rusak GKB C',
    upvoteCount: 42,
    isUpvoted: true,
  ),

  // ── Card 2: Aziz Hakim — Genangan air (4:3) ──────────────────────────────
  ReportModel(
    id: 'post-2',
    cardType: CardType.report,
    authorName: 'Aziz Hakim',
    authorUsername: '@aziz_hakim',
    authorInitials: 'AH',
    avatarBgColor: HomeColors.secondaryContainer,
    avatarFgColor: HomeColors.onSecondaryContainer,
    metaIcon: Icons.location_on,
    metaIconColor: HomeColors.primary,
    metaText: 'Bundaran PKM UNAND • 1 jam lalu',
    locationName: 'Bundaran PKM UNAND',
    locationDetail: '-0.913540, 100.458920',
    timestamp: '1 jam yang lalu • 13:35 WIB',
    badgeLabel: 'Kondisi Kampus',
    badgeVariant: BadgeVariant.dot,
    badgeDotColor: HomeColors.statusCondition,
    badgeBgColor: HomeColors.tertiaryFixed,
    badgeTextColor: HomeColors.onTertiaryFixedVariant,
    title: 'Genangan air hujan & dahan patah menutup bahu jalan PKM',
    description:
        'Pengendara motor harap pelan-pelan saat melintas '
        'dari arah gerbang utama menuju gedung kegiatan '
        'mahasiswa karena jalan licin dan ranting pohon '
        'berhamburan setelah hujan lebat siang tadi. '
        'Dikhawatirkan membahayakan pengendara roda dua.',
    imageUrl:
        'https://lh3.googleusercontent.com/aida-public/AB6AXuCh051Xy-xSPGUBXughAzyxvFCY8F_VsQmhDKBKpmVdKsTq5YdmlMKYGzGxc3cwpg2fC4gu5aHhImH4s6--pDRRzEdF6TuTNm89AinPn6UwPbeZkOobIT8DlUgAvdtKpsBo1yWT9c5OfNWMbQufHfEWLFkcK5FoVJpYapGXFC9YSEx0H06v1c8ayEl60Ip2kEne1PDSjakNj0oLwzr7n8KBFOtC_GIPiLzftS2S72nkUya3Nk08RIfh',
    aspectRatio: 4 / 3,
    imageSemanticLabel: 'Jalan PKM UNAND',
    upvoteCount: 28,
    isUpvoted: false,
  ),

  // ── Card 3: Biro Umum UNAND — Maintenance Lift (16:9) ───────────────────
  ReportModel(
    id: 'post-3',
    cardType: CardType.report,
    authorName: 'Biro Umum UNAND',
    authorIcon: Icons.verified,
    avatarBgColor: HomeColors.surfaceContainerHigh,
    avatarFgColor: HomeColors.primary,
    isVerified: true,
    metaIcon: Icons.location_on,
    metaIconColor: HomeColors.primary,
    metaText: 'Gedung Rektorat • 2 jam lalu',
    locationName: 'Gedung Rektorat Sayap Kanan',
    locationDetail: '-0.914820, 100.460115',
    timestamp: '2 jam yang lalu • 12:45 WIB',
    badgeLabel: 'Info Penting',
    badgeVariant: BadgeVariant.icon,
    badgeIcon: Icons.campaign,
    badgeBgColor: HomeColors.surfaceContainerHigh,
    badgeTextColor: HomeColors.primary,
    title: 'Maintenance Lift Gedung Rektorat Sayap Kanan',
    description:
        'Pemeriksaan berkala kabel suspensi hingga pukul 16:00 WIB. '
        'Akses dialihkan ke tangga darurat dan lift sayap kiri '
        'untuk keselamatan operasional seluruh staf dan sivitas akademika.',
    imageUrl:
        'https://images.unsplash.com/photo-1581092160607-ee22621dd758?q=80&w=800&auto=format&fit=crop',
    aspectRatio: 16 / 9,
    imageSemanticLabel: 'Maintenance Lift Rektorat',
    upvoteCount: 15,
    isUpvoted: false,
  ),

  // ── Card 4: Fadhil Rahman — Lampu Jalan Padam (1:1 Square) ──────────────
  ReportModel(
    id: 'post-4',
    cardType: CardType.report,
    authorName: 'Fadhil Rahman',
    authorUsername: '@fadhil_r',
    authorInitials: 'FR',
    avatarBgColor: HomeColors.surfaceVariant,
    avatarFgColor: HomeColors.primary,
    metaIcon: Icons.location_on,
    metaIconColor: HomeColors.primary,
    metaText: 'Jalur Gedung FTI • 3 jam lalu',
    locationName: 'Depan Gedung Dekanat FTI',
    locationDetail: '-0.915512, 100.457890',
    timestamp: '3 jam yang lalu • 11:15 WIB',
    badgeLabel: 'Kondisi Kampus',
    badgeVariant: BadgeVariant.dot,
    badgeDotColor: HomeColors.statusCondition,
    badgeBgColor: HomeColors.tertiaryFixed,
    badgeTextColor: HomeColors.onTertiaryFixedVariant,
    title: 'Lampu penerangan jalan utama dekat FTI mati total',
    description:
        'Penerangan jalan di tikungan samping dekanat Fakultas Teknologi Informasi '
        'sudah dua malam padam. Kondisi jalan sangat gelap dan rawan kecelakaan '
        'bagi mahasiswa yang pulang praktikum malam.',
    imageUrl:
        'https://images.unsplash.com/photo-1517646287270-a5a9ca602e5c?q=80&w=800&auto=format&fit=crop',
    aspectRatio: 1.0,
    imageSemanticLabel: 'Lampu Jalan Padam',
    upvoteCount: 56,
    isUpvoted: false,
  ),

  // ── Card 5: Putri Anisa — Proyektor Rusak (16:9) ─────────────────────────
  ReportModel(
    id: 'post-5',
    cardType: CardType.report,
    authorName: 'Putri Anisa',
    authorUsername: '@putrianisa',
    authorInitials: 'PA',
    avatarBgColor: HomeColors.secondaryContainer,
    avatarFgColor: HomeColors.onSecondaryContainer,
    metaIcon: Icons.location_on,
    metaIconColor: HomeColors.primary,
    metaText: 'Gedung E Lantai 1 • 4 jam lalu',
    locationName: 'Ruang Seminar Gedung E 102',
    locationDetail: '-0.914102, 100.459340',
    timestamp: '4 jam yang lalu • 10:20 WIB',
    badgeLabel: 'Kondisi Kampus',
    badgeVariant: BadgeVariant.dot,
    badgeDotColor: HomeColors.statusCondition,
    badgeBgColor: HomeColors.tertiaryFixed,
    badgeTextColor: HomeColors.onTertiaryFixedVariant,
    title: 'Kabel HDMI & Proyektor Ruang E 102 rusak bergaris',
    description:
        'Proyektor di ruang kuliah E 102 menampilkan warna hijau bergaris-garis '
        'dan sering mati mendadak saat perkuliahan presentasi kelompok. '
        'Mohon bantuan teknisi sarpras untuk pengecekan kabel.',
    imageUrl:
        'https://images.unsplash.com/photo-1517245386807-bb43f82c33c4?q=80&w=800&auto=format&fit=crop',
    aspectRatio: 16 / 9,
    imageSemanticLabel: 'Proyektor Rusak',
    upvoteCount: 19,
    isUpvoted: true,
  ),

  // ── Card 6: Diki Pratama — Sampah Kantin (4:3) ───────────────────────────
  ReportModel(
    id: 'post-6',
    cardType: CardType.report,
    authorName: 'Diki Pratama',
    authorUsername: '@dikipratama',
    authorInitials: 'DP',
    avatarBgColor: HomeColors.tertiaryFixed,
    avatarFgColor: HomeColors.onTertiaryFixedVariant,
    metaIcon: Icons.location_on,
    metaIconColor: HomeColors.primary,
    metaText: 'Kantin Gedung I • 5 jam lalu',
    locationName: 'Kantin Belakang Gedung I',
    locationDetail: '-0.916210, 100.462150',
    timestamp: '5 jam yang lalu • 09:30 WIB',
    badgeLabel: 'Kondisi Kampus',
    badgeVariant: BadgeVariant.dot,
    badgeDotColor: HomeColors.statusCondition,
    badgeBgColor: HomeColors.tertiaryFixed,
    badgeTextColor: HomeColors.onTertiaryFixedVariant,
    title: 'Tempat sampah kantin penuh dan meluap ke area makan',
    description:
        'Kondisi bak sampah di samping kantin Gedung I sudah menumpuk sejak kemarin sore '
        'dan menimbulkan bau tidak sedap. Mohon petugas kebersihan mengangkut sampah '
        'agar lingkungan kantin tetap bersih dan higienis.',
    imageUrl:
        'https://images.unsplash.com/photo-1532996122724-e3c354a0b15b?q=80&w=800&auto=format&fit=crop',
    aspectRatio: 4 / 3,
    imageSemanticLabel: 'Sampah Menumpuk',
    upvoteCount: 34,
    isUpvoted: false,
  ),

  // ── Card 7: BEM KM UNAND — Jadwal Bus Kampus (16:9) ──────────────────────
  ReportModel(
    id: 'post-7',
    cardType: CardType.report,
    authorName: 'BEM KM UNAND',
    authorIcon: Icons.verified,
    avatarBgColor: HomeColors.surfaceContainerHigh,
    avatarFgColor: HomeColors.primary,
    isVerified: true,
    metaIcon: Icons.location_on,
    metaIconColor: HomeColors.primary,
    metaText: 'Halte Gerbang Utama • 6 jam lalu',
    locationName: 'Halte Bus Kampus Limau Manis',
    locationDetail: '-0.912450, 100.456780',
    timestamp: '6 jam yang lalu • 08:00 WIB',
    badgeLabel: 'Info Penting',
    badgeVariant: BadgeVariant.icon,
    badgeIcon: Icons.campaign,
    badgeBgColor: HomeColors.surfaceContainerHigh,
    badgeTextColor: HomeColors.primary,
    title: 'Penambahan Rute & Jam Operasional Bus Kampus UNAND',
    description:
        'Mulai pekan ini armada bus kampus beroperasi mulai pukul 06.30 WIB '
        'dengan titik kumpul di Halte Gerbang Utama dan Pasar Baru. '
        'Mahasiswa diimbau mengantre dengan tertib demi kelancaran bersama.',
    imageUrl:
        'https://images.unsplash.com/photo-1544620347-c4fd4a3d5957?q=80&w=800&auto=format&fit=crop',
    aspectRatio: 16 / 9,
    imageSemanticLabel: 'Bus Kampus UNAND',
    upvoteCount: 89,
    isUpvoted: true,
    isBookmarked: true,
  ),

  // ── Card 8: Rian Saputra — Kran Air Toilet (1:1 Square) ─────────────────
  ReportModel(
    id: 'post-8',
    cardType: CardType.report,
    authorName: 'Rian Saputra',
    authorUsername: '@riansaputra',
    authorInitials: 'RS',
    avatarBgColor: HomeColors.surfaceVariant,
    avatarFgColor: HomeColors.primary,
    metaIcon: Icons.location_on,
    metaIconColor: HomeColors.primary,
    metaText: 'Perpustakaan Pusat • 7 jam lalu',
    locationName: 'Toilet Pria Lantai 2 Perpustakaan',
    locationDetail: '-0.913980, 100.460890',
    timestamp: '7 jam yang lalu • 07:15 WIB',
    badgeLabel: 'Kondisi Kampus',
    badgeVariant: BadgeVariant.dot,
    badgeDotColor: HomeColors.statusCondition,
    badgeBgColor: HomeColors.tertiaryFixed,
    badgeTextColor: HomeColors.onTertiaryFixedVariant,
    title: 'Kran wastafel toilet patah dan air terus mengalir',
    description:
        'Kran air wastafel di toilet pria lantai 2 gedung perpustakaan patah '
        'sehingga air terbuang deras membanjiri lantai toilet. '
        'Perlu perbaikan segera agar tidak memicu pemborosan air dan lantai licin.',
    imageUrl:
        'https://images.unsplash.com/photo-1584622650111-993a426fbf0a?q=80&w=800&auto=format&fit=crop',
    aspectRatio: 1.0,
    imageSemanticLabel: 'Kran Rusak Toilet',
    upvoteCount: 22,
    isUpvoted: false,
  ),

  // ── Card 9: Siti Rahma — Jalan Berlubang (16:9) ───────────────────────────
  ReportModel(
    id: 'post-9',
    cardType: CardType.report,
    authorName: 'Siti Rahma',
    authorUsername: '@sitirahma',
    authorInitials: 'SR',
    avatarBgColor: HomeColors.secondaryContainer,
    avatarFgColor: HomeColors.onSecondaryContainer,
    metaIcon: Icons.location_on,
    metaIconColor: HomeColors.primary,
    metaText: 'Jalur Asrama Maninjau • 8 jam lalu',
    locationName: 'Jalan Menuju Asrama Maninjau',
    locationDetail: '-0.917120, 100.458210',
    timestamp: '8 jam yang lalu • 06:40 WIB',
    badgeLabel: 'Kondisi Kampus',
    badgeVariant: BadgeVariant.dot,
    badgeDotColor: HomeColors.statusCondition,
    badgeBgColor: HomeColors.tertiaryFixed,
    badgeTextColor: HomeColors.onTertiaryFixedVariant,
    title: 'Lubang cukup dalam di tikungan asrama putri',
    description:
        'Terdapat lubang aspal yang tertutup genangan air saat hujan di dekat Asrama Maninjau. '
        'Sudah ada 2 pengendara motor yang hampir terjatuh saat melintas di malam hari.',
    imageUrl:
        'https://images.unsplash.com/photo-1515162816999-a0c47dc192f7?q=80&w=800&auto=format&fit=crop',
    aspectRatio: 16 / 9,
    imageSemanticLabel: 'Jalan Berlubang Asrama',
    upvoteCount: 63,
    isUpvoted: true,
  ),

  // ── Card 10: UPT Perpustakaan — Jadwal Bebas Pustaka (16:9) ──────────────
  ReportModel(
    id: 'post-10',
    cardType: CardType.report,
    authorName: 'UPT Perpustakaan UNAND',
    authorIcon: Icons.verified,
    avatarBgColor: HomeColors.surfaceContainerHigh,
    avatarFgColor: HomeColors.primary,
    isVerified: true,
    metaIcon: Icons.location_on,
    metaIconColor: HomeColors.primary,
    metaText: 'Gedung Perpustakaan • 9 jam lalu',
    locationName: 'Layanan Sirkulasi Lantai 1',
    locationDetail: '-0.913890, 100.460750',
    timestamp: '9 jam yang lalu • 05:30 WIB',
    badgeLabel: 'Info Penting',
    badgeVariant: BadgeVariant.icon,
    badgeIcon: Icons.campaign,
    badgeBgColor: HomeColors.surfaceContainerHigh,
    badgeTextColor: HomeColors.primary,
    title: 'Pelayanan Bebas Pustaka & Unggah Mandiri Skripsi Online',
    description:
        'Bagi mahasiswa tingkat akhir calon wisudawan Periode IV, pengurusan surat '
        'keterangan bebas pustaka dan penyerahan softcopy skripsi kini dapat diakses '
        'secara daring melalui portal resmi perpustakaan.',
    imageUrl:
        'https://images.unsplash.com/photo-1521587760476-6c12a4b040da?q=80&w=800&auto=format&fit=crop',
    aspectRatio: 16 / 9,
    imageSemanticLabel: 'Layanan Perpustakaan',
    upvoteCount: 47,
    isUpvoted: false,
  ),

  // ── Card 11: Ilham Pratama — Kerusakan Stopkontak Lab (4:3) ───────────────
  ReportModel(
    id: 'post-11',
    cardType: CardType.report,
    authorName: 'Ilham Pratama',
    authorUsername: '@ilham_p',
    authorInitials: 'IP',
    avatarBgColor: HomeColors.surfaceVariant,
    avatarFgColor: HomeColors.primary,
    metaIcon: Icons.location_on,
    metaIconColor: HomeColors.primary,
    metaText: 'Lab Komputer Gedung F • 10 jam lalu',
    locationName: 'Laboratorium Rekayasa Perangkat Lunak',
    locationDetail: '-0.914990, 100.457630',
    timestamp: '10 jam yang lalu • Kemarin',
    badgeLabel: 'Kondisi Kampus',
    badgeVariant: BadgeVariant.dot,
    badgeDotColor: HomeColors.statusCondition,
    badgeBgColor: HomeColors.tertiaryFixed,
    badgeTextColor: HomeColors.onTertiaryFixedVariant,
    title: 'Stopkontak meja baris ketiga Lab F-203 korslet',
    description:
        'Soket listrik meja komputer baris 3 mengeluarkan percikan api saat dihubungkan '
        'dengan charger laptop mahasiswa. Demi keselamatan sementara aliran kabel telah dicabut.',
    imageUrl:
        'https://images.unsplash.com/photo-1544716278-ca5e3f4abd8c?q=80&w=800&auto=format&fit=crop',
    aspectRatio: 4 / 3,
    imageSemanticLabel: 'Stopkontak Korslet',
    upvoteCount: 38,
    isUpvoted: false,
  ),

  // ── Card 12: Nabila Khairani — Pintu Rusak Toilet (1:1 Square) ───────────
  ReportModel(
    id: 'post-12',
    cardType: CardType.report,
    authorName: 'Nabila Khairani',
    authorUsername: '@nabilakh',
    authorInitials: 'NK',
    avatarBgColor: HomeColors.secondaryContainer,
    avatarFgColor: HomeColors.onSecondaryContainer,
    metaIcon: Icons.location_on,
    metaIconColor: HomeColors.primary,
    metaText: 'Gedung Kuliah Pancasila • 11 jam lalu',
    locationName: 'Gedung Perkuliahan Pancasila Lt. 2',
    locationDetail: '-0.913210, 100.459800',
    timestamp: '11 jam yang lalu • Kemarin',
    badgeLabel: 'Kondisi Kampus',
    badgeVariant: BadgeVariant.dot,
    badgeDotColor: HomeColors.statusCondition,
    badgeBgColor: HomeColors.tertiaryFixed,
    badgeTextColor: HomeColors.onTertiaryFixedVariant,
    title: 'Kunci selot pintu toilet wanita bilik 1 lepas',
    description:
        'Selot kunci pintu bilik nomor 1 toilet wanita lantai 2 Gedung Pancasila lepas '
        'dan pintu tidak bisa tertutup rapat. Mohon segera dipasang kembali.',
    imageUrl:
        'https://images.unsplash.com/photo-1584622650111-993a426fbf0a?q=80&w=800&auto=format&fit=crop',
    aspectRatio: 1.0,
    imageSemanticLabel: 'Pintu Toilet Rusak',
    upvoteCount: 29,
    isUpvoted: true,
  ),

  // ── Card 13: Tim Medis KSR — Donor Darah Sukarela (16:9) ─────────────────
  ReportModel(
    id: 'post-13',
    cardType: CardType.report,
    authorName: 'KSR PMI Unit UNAND',
    authorIcon: Icons.verified,
    avatarBgColor: HomeColors.surfaceContainerHigh,
    avatarFgColor: HomeColors.primary,
    isVerified: true,
    metaIcon: Icons.location_on,
    metaIconColor: HomeColors.primary,
    metaText: 'Gedung PKM Lantai 1 • 12 jam lalu',
    locationName: 'Hall Gedung PKM Kampus Limau Manis',
    locationDetail: '-0.913480, 100.458850',
    timestamp: '12 jam yang lalu • Kemarin',
    badgeLabel: 'Info Penting',
    badgeVariant: BadgeVariant.icon,
    badgeIcon: Icons.campaign,
    badgeBgColor: HomeColors.surfaceContainerHigh,
    badgeTextColor: HomeColors.primary,
    title: 'Aksi Donor Darah Sukarela Dies Natalis UNAND',
    description:
        'KSR PMI Unit UNAND bekerja sama dengan PMI Kota Padang menyelenggarakan '
        'kegiatan donor darah sukarela terbuka untuk seluruh mahasiswa, dosen, dan staf. '
        'Tersedia suplemen vitamin dan bingkisan menarik.',
    imageUrl:
        'https://images.unsplash.com/photo-1615461066841-6116e61058f4?q=80&w=800&auto=format&fit=crop',
    aspectRatio: 16 / 9,
    imageSemanticLabel: 'Aksi Donor Darah',
    upvoteCount: 112,
    isUpvoted: true,
    isBookmarked: true,
  ),

  // ── Card 14: Bayu Setiawan — Pohon Tumbang Dekat Lapangan (16:9) ─────────
  ReportModel(
    id: 'post-14',
    cardType: CardType.report,
    authorName: 'Bayu Setiawan',
    authorUsername: '@bayusetia',
    authorInitials: 'BS',
    avatarBgColor: HomeColors.tertiaryFixed,
    avatarFgColor: HomeColors.onTertiaryFixedVariant,
    metaIcon: Icons.location_on,
    metaIconColor: HomeColors.primary,
    metaText: 'Lapangan Futsal UNAND • 14 jam lalu',
    locationName: 'Area Lapangan Olahraga Kampus',
    locationDetail: '-0.916800, 100.459990',
    timestamp: '14 jam yang lalu • Kemarin',
    badgeLabel: 'Kondisi Kampus',
    badgeVariant: BadgeVariant.dot,
    badgeDotColor: HomeColors.statusCondition,
    badgeBgColor: HomeColors.tertiaryFixed,
    badgeTextColor: HomeColors.onTertiaryFixedVariant,
    title: 'Dahan pohon kelapa patah menimpa pagar pembatas lapangan',
    description:
        'Angin kencang tadi malam menyebabkan dahan pohon kelapa roboh dan menimpa '
        'jaring kawat pengaman lapangan futsal luar ruangan.',
    imageUrl:
        'https://images.unsplash.com/photo-1448375240586-882707db888b?q=80&w=800&auto=format&fit=crop',
    aspectRatio: 16 / 9,
    imageSemanticLabel: 'Pohon Tumbang Lapangan',
    upvoteCount: 31,
    isUpvoted: false,
  ),

  // ── Card 15: Tari Wulandari — Air Keruh di Gedung H (4:3) ─────────────────
  ReportModel(
    id: 'post-15',
    cardType: CardType.report,
    authorName: 'Tari Wulandari',
    authorUsername: '@tariwulan',
    authorInitials: 'TW',
    avatarBgColor: HomeColors.surfaceVariant,
    avatarFgColor: HomeColors.primary,
    metaIcon: Icons.location_on,
    metaIconColor: HomeColors.primary,
    metaText: 'Gedung H Lantai 3 • 16 jam lalu',
    locationName: 'Tempat Wudhu Gedung Kuliah H',
    locationDetail: '-0.914560, 100.461900',
    timestamp: '16 jam yang lalu • Kemarin',
    badgeLabel: 'Kondisi Kampus',
    badgeVariant: BadgeVariant.dot,
    badgeDotColor: HomeColors.statusCondition,
    badgeBgColor: HomeColors.tertiaryFixed,
    badgeTextColor: HomeColors.onTertiaryFixedVariant,
    title: 'Air kran wudhu gedung H berwarna kecokelatan',
    description:
        'Pasokan air di tempat wudhu lantai 3 Gedung H agak keruh dan bercampur endapan tanah. '
        'Diduga ada perbaikan pipa tandon air utama.',
    imageUrl:
        'https://images.unsplash.com/photo-1541888946425-d0fbb18086f6?q=80&w=800&auto=format&fit=crop',
    aspectRatio: 4 / 3,
    imageSemanticLabel: 'Air Keruh Wudhu',
    upvoteCount: 45,
    isUpvoted: false,
  ),

  // ── Card 16: LPPM UNAND — Pendanaan Riset Mahasiswa (16:9) ────────────────
  ReportModel(
    id: 'post-16',
    cardType: CardType.report,
    authorName: 'LPPM Universitas Andalas',
    authorIcon: Icons.verified,
    avatarBgColor: HomeColors.surfaceContainerHigh,
    avatarFgColor: HomeColors.primary,
    isVerified: true,
    metaIcon: Icons.location_on,
    metaIconColor: HomeColors.primary,
    metaText: 'Gedung Rektorat Lt. 2 • 18 jam lalu',
    locationName: 'Kantor LPPM Gedung Rektorat',
    locationDetail: '-0.914750, 100.460200',
    timestamp: '18 jam yang lalu • Kemarin',
    badgeLabel: 'Info Penting',
    badgeVariant: BadgeVariant.icon,
    badgeIcon: Icons.campaign,
    badgeBgColor: HomeColors.surfaceContainerHigh,
    badgeTextColor: HomeColors.primary,
    title: 'Pembukaan Proposal Hibah Riset & Pengabdian Kolaboratif',
    description:
        'Lembaga Penelitian dan Pengabdian kepada Masyarakat (LPPM) membuka '
        'penerimaan proposal riset mahasiswa dan dosen pembimbing untuk skema '
        'Inovasi Berkelanjutan Kampus Hijau tahun 2026.',
    imageUrl:
        'https://images.unsplash.com/photo-1434030216411-0b793f4b4173?q=80&w=800&auto=format&fit=crop',
    aspectRatio: 16 / 9,
    imageSemanticLabel: 'Sosialisasi Hibah Riset',
    upvoteCount: 74,
    isUpvoted: false,
  ),

  // ── Card 17: Kevin Sanjaya — Wifi Rusak di Plaza Andalas (1:1 Square) ──────
  ReportModel(
    id: 'post-17',
    cardType: CardType.report,
    authorName: 'Kevin Sanjaya',
    authorUsername: '@kevinsanjaya',
    authorInitials: 'KS',
    avatarBgColor: HomeColors.secondaryContainer,
    avatarFgColor: HomeColors.onSecondaryContainer,
    metaIcon: Icons.location_on,
    metaIconColor: HomeColors.primary,
    metaText: 'Plaza UNAND • 20 jam lalu',
    locationName: 'Gazebo Plaza Belajar Mahasiswa',
    locationDetail: '-0.913700, 100.459500',
    timestamp: '20 jam yang lalu • 2 hari lalu',
    badgeLabel: 'Kondisi Kampus',
    badgeVariant: BadgeVariant.dot,
    badgeDotColor: HomeColors.statusCondition,
    badgeBgColor: HomeColors.tertiaryFixed,
    badgeTextColor: HomeColors.onTertiaryFixedVariant,
    title: 'Access Point wifi @unand.ac.id di Plaza tidak ada koneksi',
    description:
        'Sinyal wifi unand di gazebo plaza luar tampak penuh tetapi mengalami '
        'no internet connection saat login SSO. Mohon tim TIK melakukan restart router.',
    imageUrl:
        'https://images.unsplash.com/photo-1544197150-b99a580bb7a8?q=80&w=800&auto=format&fit=crop',
    aspectRatio: 1.0,
    imageSemanticLabel: 'Wifi Rusak Plaza',
    upvoteCount: 52,
    isUpvoted: true,
  ),

  // ── Card 18: LPTIK UNAND — Maintenance Server Portal Akademik (16:9) ─────
  ReportModel(
    id: 'post-18',
    cardType: CardType.report,
    authorName: 'LPTIK UNAND',
    authorIcon: Icons.verified,
    avatarBgColor: HomeColors.surfaceContainerHigh,
    avatarFgColor: HomeColors.primary,
    isVerified: true,
    metaIcon: Icons.location_on,
    metaIconColor: HomeColors.primary,
    metaText: 'Data Center LPTIK • 1 hari lalu',
    locationName: 'Gedung LPTIK Kampus Limau Manis',
    locationDetail: '-0.915200, 100.458600',
    timestamp: '1 hari yang lalu • 2 hari lalu',
    badgeLabel: 'Info Penting',
    badgeVariant: BadgeVariant.icon,
    badgeIcon: Icons.campaign,
    badgeBgColor: HomeColors.surfaceContainerHigh,
    badgeTextColor: HomeColors.primary,
    title: 'Jadwal Pemeliharaan Rutin Server Portal Portal Akademik & SIA',
    description:
        'Diberitahukan kepada seluruh mahasiswa bahwa portal akademik dan i-Learn '
        'akan mengalami downtime sementara pada Sabtu dini hari pukul 00.00 - 04.00 WIB '
        'untuk upgrade kapasitas database.',
    imageUrl:
        'https://images.unsplash.com/photo-1558494949-ef010cbdcc31?q=80&w=800&auto=format&fit=crop',
    aspectRatio: 16 / 9,
    imageSemanticLabel: 'Maintenance Server LPTIK',
    upvoteCount: 95,
    isUpvoted: false,
    isBookmarked: true,
  ),
];
