import 'package:flutter/material.dart';

import '../../../theme/home_colors.dart';
import '../models/report_model.dart';

/// Dummy feed data matching the three cards in the HTML reference.
const List<ReportModel> mockReports = [
  // ── Card 1: Zakky Aldrin — AC bocor ────────────────────────────────────
  ReportModel(
    id: 'post-1',
    cardType: CardType.report,
    authorName: 'Zakky Aldrin',
    authorUsername: '@zakkyaldrin',
    authorInitials: 'ZA',
    avatarBgColor: HomeColors.surfaceVariant,
    avatarFgColor: HomeColors.primary,
    metaIcon: Icons.location_on,
    metaIconColor: HomeColors.primary,
    metaText: 'Gedung GKB C, Lantai 2 • 15m lalu',
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
        'dapat ditempati mahasiswa...',
    imageUrl:
        'https://lh3.googleusercontent.com/aida-public/AB6AXuCQjRXiN2w4dCPIVQhWlufSduDBSOqq2UCDygQfUyfqSojlTedSVb-jV0eQv01FkURvr7Qgez_9haHqOHRzyrTMm3-zTxvYqLoT_9pOnwvzbpXntLaJrl15dn9w9LqHV6h_Q-VTAArbnGCIPrkLxKjPYJlR_v1VSLY4KUOIjrOZXQlOZdLstSB2MYxJK3RiWV-7pjLLrSMmfoav9T6019ykOx4WMX3P7hAfHAQKUCS_DHnrVSu8_buT',
    imageHeight: 224,
    imageSemanticLabel: 'AC Rusak GKB C',
    upvoteCount: 42,
    isUpvoted: true,
  ),

  // ── Card 2: Aziz Hakim — Genangan air ──────────────────────────────────
  ReportModel(
    id: 'post-2',
    cardType: CardType.report,
    authorName: 'Aziz Hakim',
    authorUsername: '@aziz_hakim',
    authorInitials: 'AH',
    avatarBgColor: HomeColors.secondaryContainer,
    avatarFgColor: HomeColors.onSecondaryContainer,
    metaIcon: Icons.location_on,
    metaIconColor: HomeColors.statusCondition,
    metaText: 'Bundaran PKM UNAND • 1 jam lalu',
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
        'berhamburan...',
    imageUrl:
        'https://lh3.googleusercontent.com/aida-public/AB6AXuCh051Xy-xSPGUBXughAzyxvFCY8F_VsQmhDKBKpmVdKsTq5YdmlMKYGzGxc3cwpg2fC4gu5aHhImH4s6--pDRRzEdF6TuTNm89AinPn6UwPbeZkOobIT8DlUgAvdtKpsBo1yWT9c5OfNWMbQufHfEWLFkcK5FoVJpYapGXFC9YSEx0H06v1c8ayEl60Ip2kEne1PDSjakNj0oLwzr7n8KBFOtC_GIPiLzftS2S72nkUya3Nk08RIfh',
    imageHeight: 208,
    imageSemanticLabel: 'Jalan PKM UNAND',
    upvoteCount: 28,
    isUpvoted: false,
  ),

  // ── Card 3: Biro Umum UNAND — Maintenance Lift ─────────────────────────
  ReportModel(
    id: 'post-3',
    cardType: CardType.official,
    authorName: 'Biro Umum UNAND',
    authorIcon: Icons.verified,
    avatarBgColor: HomeColors.surfaceContainerHigh,
    avatarFgColor: HomeColors.primary,
    isVerified: true,
    metaIcon: Icons.schedule,
    metaIconColor: HomeColors.primary,
    metaText: 'Gedung Rektorat • 2 jam lalu',
    badgeLabel: 'Info Penting',
    badgeVariant: BadgeVariant.icon,
    badgeIcon: Icons.campaign,
    badgeBgColor: HomeColors.surfaceContainerHigh,
    badgeTextColor: HomeColors.primary,
    contentIcon: Icons.elevator,
    contentTitle: 'Maintenance Lift Gedung Rektorat Sayap Kanan',
    contentDescription:
        'Pemeriksaan berkala kabel suspensi hingga pukul 16:00 WIB. '
        'Akses dialihkan ke tangga darurat dan lift sayap kiri '
        'untuk keselamatan operasional...',
    upvoteCount: 15,
    isUpvoted: false,
  ),
];
