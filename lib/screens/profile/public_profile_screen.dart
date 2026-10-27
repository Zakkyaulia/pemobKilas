import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:qr_flutter/qr_flutter.dart';

import '../../theme/app_palette.dart';
import '../../theme/app_spacing.dart';
import '../../theme/home_colors.dart';
import '../../theme/home_shadows.dart';
import '../../theme/home_text_styles.dart';
import '../home/data/report_repository.dart';
import '../home/models/report_model.dart';
import '../home/report_detail_screen.dart';

import 'data/campus_users_data.dart';
import '../../utils/app_snackbar.dart';
import '../../widgets/profile/stat_metric_card.dart';

/// Halaman Profil Publik Mahasiswa (FR-16 & FR-B5).
///
/// Ditampilkan saat:
/// 1. Memindai QR profil mahasiswa lain dari pemindai QR.
/// 2. Menekan avatar/nama pengirim laporan pada Feed beranda atau Detail Laporan.
///
/// Karakteristik Profil Publik sesuai PRD:
/// - Menampilkan identitas publik: Foto profil, nama lengkap, username, fakultas/jurusan, bio, status verifikasi.
/// - Menampilkan metrik kontribusi publik: Jumlah laporan terbitan, total upvote diterima.
/// - Menampilkan daftar laporan yang dipublikasikan oleh mahasiswa tersebut.
/// - Tombol interaktif untuk menyalin tautan profil dan menampilkan QR publik.
/// - Menjamin privasi: TIDAK menampilkan tab bookmark (privat biometrik), riwayat aktivitas pribadi (audit log), atau tombol edit/pengaturan akun.
class PublicProfileScreen extends StatelessWidget {
  const PublicProfileScreen({
    super.key,
    required this.name,
    required this.username,
    this.nim,
    this.avatarUrl,
    this.initials,
    this.jurusan = 'Sistem Informasi',
    this.fakultas = 'Fakultas Teknologi Informasi',
    this.bio = 'Mahasiswa aktif Universitas Andalas.',
    this.isVerified = false,
    this.avatarBgColor,
    this.avatarFgColor,
  });

  /// Factory untuk membuat [PublicProfileScreen] dari sebuah [ReportModel].
  factory PublicProfileScreen.fromReport(ReportModel report) {
    final cleanUsername = report.authorUsername ??
        '@${report.authorName.toLowerCase().replaceAll(' ', '')}';
    return PublicProfileScreen(
      name: report.authorName,
      username: cleanUsername,
      avatarUrl: report.authorAvatarUrl,
      initials: report.authorInitials,
      jurusan: report.isVerified
          ? 'Institusi Resmi Kampus'
          : 'Sistem Informasi UNAND',
      fakultas: report.isVerified
          ? 'Universitas Andalas'
          : 'Fakultas Teknologi Informasi',
      bio: report.isVerified
          ? 'Akun dan kanal informasi resmi terverifikasi Universitas Andalas.'
          : 'Mahasiswa aktif berkontribusi melaporkan fasilitas kampus demi kenyamanan bersama di UNAND.',
      isVerified: report.isVerified,
      avatarBgColor: report.avatarBgColor,
      avatarFgColor: report.avatarFgColor,
    );
  }

  /// Factory untuk membuat [PublicProfileScreen] dari sebuah [CampusUserItem].
  factory PublicProfileScreen.fromCampusUser(CampusUserItem user) {
    return PublicProfileScreen(
      name: user.name,
      username: user.username,
      nim: user.nim,
      avatarUrl: user.avatarUrl,
      initials: user.initials,
      jurusan: user.jurusan,
      fakultas: user.fakultas,
      bio: user.bio,
      isVerified: user.isVerified,
      avatarBgColor: user.avatarBgColor,
      avatarFgColor: user.avatarFgColor,
    );
  }

  final String name;
  final String username;
  final String? nim;
  final String? avatarUrl;
  final String? initials;
  final String jurusan;
  final String fakultas;
  final String bio;
  final bool isVerified;
  final Color? avatarBgColor;
  final Color? avatarFgColor;

  String get _displayInitials {
    if (initials != null && initials!.isNotEmpty) return initials!;
    if (name.isNotEmpty) {
      return name
          .trim()
          .split(' ')
          .map((w) => w.isNotEmpty ? w[0] : '')
          .take(2)
          .join()
          .toUpperCase();
    }
    return 'UN';
  }

  void _handleCopyProfileLink(BuildContext context) {
    final link = 'https://kilas.app/u/${username.replaceAll('@', '')}';
    Clipboard.setData(ClipboardData(text: link));

    AppSnackbar.showSuccess(
      context,
      'Tautan profil $username berhasil disalin!',
    );
  }

  void _showQrDialog(BuildContext context) {
    final isDark = AppPalette.isDark(context);
    showDialog<void>(
      context: context,
      builder: (ctx) => Dialog(
        backgroundColor: AppPalette.surface(context),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        insetPadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
        child: Container(
          width: 320,
          padding: const EdgeInsets.fromLTRB(24, 24, 24, 20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.08),
                      blurRadius: 16,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: RepaintBoundary(
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(10),
                    child: QrImageView(
                      data: 'https://kilas.app/u/${username.replaceAll('@', '')}',
                      version: QrVersions.auto,
                      size: 180.0,
                      backgroundColor: Colors.white,
                      padding: const EdgeInsets.all(8),
                      eyeStyle: const QrEyeStyle(
                        eyeShape: QrEyeShape.square,
                        color: Color(0xFF0F172A),
                      ),
                      dataModuleStyle: const QrDataModuleStyle(
                        dataModuleShape: QrDataModuleShape.square,
                        color: Color(0xFF0F172A),
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Text(
                name,
                textAlign: TextAlign.center,
                style: HomeTextStyles.headlineSm.copyWith(
                  fontWeight: FontWeight.w700,
                  color: AppPalette.textPrimary(context),
                ),
              ),
              const SizedBox(height: 2),
              Text(
                username,
                style: HomeTextStyles.labelMd.copyWith(
                  fontWeight: FontWeight.w700,
                  color: isDark
                      ? const Color(0xFF60A5FA)
                      : HomeColors.primaryContainer,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Pindai QR ini melalui aplikasi KILAS untuk membuka profil mahasiswa ini secara cepat.',
                textAlign: TextAlign.center,
                style: HomeTextStyles.bodySm.copyWith(
                  color: AppPalette.textSecondary(context),
                  fontSize: 12,
                ),
              ),
              const SizedBox(height: 18),
              SizedBox(
                width: double.infinity,
                height: 44,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: HomeColors.primaryContainer,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    elevation: 0,
                  ),
                  onPressed: () => Navigator.pop(ctx),
                  child: Text(
                    'Tutup',
                    style: HomeTextStyles.labelMd.copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final topPadding = MediaQuery.of(context).padding.top;
    final isDark = AppPalette.isDark(context);

    return Scaffold(
      backgroundColor: AppPalette.canvas(context),
      body: ListenableBuilder(
        listenable: ReportRepository.instance,
        builder: (context, _) {
          final allReports = ReportRepository.instance.reports;

          // Filter laporan yang dipublikasikan oleh user ini
          final userReports = allReports.where((r) {
            final matchUsername = r.authorUsername != null &&
                r.authorUsername!.toLowerCase() == username.toLowerCase();
            final matchName =
                r.authorName.toLowerCase() == name.toLowerCase();
            return matchUsername || matchName;
          }).toList();

          // Akumulasi total upvote yang didapatkan
          final totalUpvotes = userReports.fold<int>(
            0,
            (acc, curr) => acc + curr.upvoteCount,
          );

          return Stack(
            children: [
              // ── Scrollable Body Konten ─────────────────────────────
              ListView(
                physics: const BouncingScrollPhysics(),
                padding: EdgeInsets.fromLTRB(
                  AppSpacing.lg,
                  topPadding + 64 + 16,
                  AppSpacing.lg,
                  40,
                ),
                children: [
                  // 1. Kartu Identitas Publik Utama
                  _buildProfileHeroCard(context, isDark),

                  const SizedBox(height: 16),

                  // 2. Baris Statistik Kontribusi Publik (FR-17 & FR-B5)
                  _buildContributionStatsRow(
                    context,
                    totalReports: userReports.length,
                    totalUpvotes: totalUpvotes,
                    isDark: isDark,
                  ),

                  const SizedBox(height: 24),

                  // 3. Header Bagian Laporan Terbitan
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          Text(
                            'LAPORAN TERBITAN',
                            style: HomeTextStyles.labelSm.copyWith(
                              letterSpacing: 0.8,
                              color: AppPalette.textSecondary(context),
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          const SizedBox(width: 8),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 2,
                            ),
                            decoration: BoxDecoration(
                              color: HomeColors.primaryContainer.withValues(alpha: 0.12),
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Text(
                              '${userReports.length}',
                              style: HomeTextStyles.labelSm.copyWith(
                                color: isDark
                                    ? const Color(0xFF60A5FA)
                                    : HomeColors.primaryContainer,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ),
                        ],
                      ),
                      Text(
                        'Publik',
                        style: HomeTextStyles.labelSm.copyWith(
                          color: AppPalette.textSecondary(context),
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 12),

                  // 4. Daftar Laporan Publik atau Empty State
                  if (userReports.isEmpty)
                    _buildEmptyReportsState(context, isDark)
                  else
                    ...userReports.map((report) => _buildReportItem(context, report, isDark)),

                  const SizedBox(height: 20),

                  // 5. Banner Jaminan Privasi (Klausul PRD)
                  _buildPrivacyBanner(context, isDark),
                ],
              ),

              // ── Header Bar Frosted Glass ───────────────────────────
              Positioned(
                top: 0,
                left: 0,
                right: 0,
                child: ClipRect(
                  child: BackdropFilter(
                    filter: ImageFilter.blur(sigmaX: 24, sigmaY: 24),
                    child: Container(
                      padding: EdgeInsets.only(top: topPadding),
                      decoration: BoxDecoration(
                        color: AppPalette.glassBackground(context),
                        boxShadow: HomeShadows.headerGlass,
                        border: Border(
                          bottom: BorderSide(color: AppPalette.divider(context)),
                        ),
                      ),
                      child: SizedBox(
                        height: 64,
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
                          child: Row(
                            children: [
                              IconButton(
                                icon: const Icon(
                                  Icons.arrow_back_ios_new_rounded,
                                  size: 20,
                                ),
                                color: AppPalette.textPrimary(context),
                                onPressed: () => Navigator.pop(context),
                              ),
                              const SizedBox(width: 6),
                              Expanded(
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      children: [
                                        Flexible(
                                          child: Text(
                                            'Profil Mahasiswa',
                                            style: HomeTextStyles.headlineSm.copyWith(
                                              color: AppPalette.textPrimary(context),
                                              fontWeight: FontWeight.w700,
                                              fontSize: 16,
                                            ),
                                            maxLines: 1,
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                        ),
                                        if (isVerified) ...[
                                          const SizedBox(width: 4),
                                          const Icon(
                                            Icons.verified_rounded,
                                            size: 16,
                                            color: HomeColors.primaryContainer,
                                          ),
                                        ],
                                      ],
                                    ),
                                    Text(
                                      username,
                                      style: HomeTextStyles.labelSm.copyWith(
                                        color: AppPalette.textSecondary(context),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              IconButton(
                                tooltip: 'Salin Tautan Profil',
                                icon: const Icon(Icons.share_outlined, size: 21),
                                color: AppPalette.textPrimary(context),
                                onPressed: () => _handleCopyProfileLink(context),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  /// Kartu Hero Profil Mahasiswa
  Widget _buildProfileHeroCard(BuildContext context, bool isDark) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.lg),
      decoration: BoxDecoration(
        color: AppPalette.surface(context),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppPalette.divider(context), width: 1),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: isDark ? 0.25 : 0.04),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Avatar Profil
              Container(
                width: 76,
                height: 76,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: HomeColors.primaryContainer,
                    width: 2.5,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: HomeColors.primaryContainer.withValues(alpha: 0.18),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: ClipOval(
                  child: _buildAvatar(context),
                ),
              ),
              const SizedBox(width: 16),
              // Nama, NIM/Username, Jurusan
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Flexible(
                          child: Text(
                            name,
                            style: HomeTextStyles.headlineSm.copyWith(
                              fontWeight: FontWeight.w700,
                              color: AppPalette.textPrimary(context),
                              height: 1.2,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        if (isVerified) ...[
                          const SizedBox(width: 4),
                          const Icon(
                            Icons.verified_rounded,
                            size: 16,
                            color: HomeColors.primaryContainer,
                          ),
                        ],
                      ],
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        Text(
                          username,
                          style: HomeTextStyles.labelMd.copyWith(
                            color: isDark
                                ? const Color(0xFF60A5FA)
                                : HomeColors.primaryContainer,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        if (nim != null && nim!.isNotEmpty) ...[
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 6),
                            child: Text(
                              '•',
                              style: HomeTextStyles.bodySm.copyWith(
                                color: AppPalette.textSecondary(context),
                              ),
                            ),
                          ),
                          Flexible(
                            child: Text(
                              nim!,
                              style: HomeTextStyles.bodySm.copyWith(
                                color: AppPalette.textSecondary(context),
                                fontWeight: FontWeight.w500,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '$jurusan 🎓',
                      style: HomeTextStyles.labelSm.copyWith(
                        color: AppPalette.textSecondary(context),
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      fakultas,
                      style: HomeTextStyles.bodySm.copyWith(
                        color: AppPalette.textSecondary(context),
                        fontSize: 11.5,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          // Bio
          Text(
            bio,
            style: HomeTextStyles.bodySm.copyWith(
              color: AppPalette.textPrimary(context),
              height: 1.45,
            ),
          ),
          const SizedBox(height: 16),
          // Tombol Salin Tautan & QR Profil
          Row(
            children: [
              Expanded(
                child: SizedBox(
                  height: 40,
                  child: OutlinedButton.icon(
                    style: OutlinedButton.styleFrom(
                      side: BorderSide(color: AppPalette.divider(context)),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                      padding: const EdgeInsets.symmetric(horizontal: 10),
                    ),
                    onPressed: () => _handleCopyProfileLink(context),
                    icon: const Icon(Icons.link_rounded, size: 16),
                    label: Text(
                      'Salin Tautan',
                      style: HomeTextStyles.labelMd.copyWith(
                        fontWeight: FontWeight.w600,
                        color: AppPalette.textPrimary(context),
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: SizedBox(
                  height: 40,
                  child: ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: HomeColors.primaryContainer,
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                      padding: const EdgeInsets.symmetric(horizontal: 10),
                    ),
                    onPressed: () => _showQrDialog(context),
                    icon: const Icon(
                      Icons.qr_code_2_rounded,
                      size: 17,
                      color: Colors.white,
                    ),
                    label: Text(
                      'QR Mahasiswa',
                      style: HomeTextStyles.labelMd.copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  /// Baris Kartu Statistik Kontribusi Publik (FR-17 & FR-B5)
  Widget _buildContributionStatsRow(
    BuildContext context, {
    required int totalReports,
    required int totalUpvotes,
    required bool isDark,
  }) {
    return Row(
      children: [
        Expanded(
          child: StatMetricCard(
            icon: Icons.campaign_outlined,
            iconBg: const Color(0xFFE0E7FF),
            iconColor: const Color(0xFF4338CA),
            value: '$totalReports',
            label: 'Laporan Publik',
            isDark: isDark,
            valueFontSize: 18,
            labelFontSize: 11,
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: StatMetricCard(
            icon: Icons.arrow_upward_rounded,
            iconBg: const Color(0xFFDBEAFE),
            iconColor: const Color(0xFF1D4ED8),
            value: '$totalUpvotes',
            label: 'Upvote Didapat',
            isDark: isDark,
            valueFontSize: 18,
            labelFontSize: 11,
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: StatMetricCard(
            icon: Icons.verified_user_outlined,
            iconBg: const Color(0xFFD1FAE5),
            iconColor: const Color(0xFF059669),
            value: isVerified ? 'Resmi' : 'Aktif',
            label: 'Status Akun',
            isDark: isDark,
            valueFontSize: 18,
            labelFontSize: 11,
          ),
        ),
      ],
    );
  }

  /// Item Kartu Laporan Publik Mahasiswa
  Widget _buildReportItem(BuildContext context, ReportModel item, bool isDark) {
    final isCondition = item.badgeLabel == 'Kondisi Kampus';

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: AppPalette.surface(context),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppPalette.divider(context), width: 1),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: isDark ? 0.2 : 0.04),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => ReportDetailScreen(report: item),
              ),
            );
          },
          child: Padding(
            padding: const EdgeInsets.all(14),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(10),
                  child: Container(
                    width: 72,
                    height: 72,
                    color: isDark
                        ? const Color(0xFF13203A)
                        : const Color(0xFFE2E8F0),
                    child: item.imageUrl != null && item.imageUrl!.isNotEmpty
                        ? _buildAdaptiveImage(item.imageUrl!, isCondition)
                        : Icon(
                            isCondition
                                ? Icons.apartment_rounded
                                : Icons.campaign_rounded,
                            color: HomeColors.primaryContainer,
                            size: 32,
                          ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 6,
                              vertical: 2,
                            ),
                            decoration: BoxDecoration(
                              color: isCondition
                                  ? (isDark
                                      ? const Color(0xFF332205)
                                      : const Color(0xFFFEF3DC))
                                  : (isDark
                                      ? const Color(0xFF162544)
                                      : const Color(0xFFE5EEFF)),
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: Text(
                              item.badgeLabel,
                              style: HomeTextStyles.labelSm.copyWith(
                                color: isCondition
                                    ? const Color(0xFFD97706)
                                    : HomeColors.primaryContainer,
                                fontWeight: FontWeight.w700,
                                fontSize: 10,
                              ),
                            ),
                          ),
                          const Spacer(),
                          Text(
                            item.timeAgoDisplay,
                            style: HomeTextStyles.bodySm.copyWith(
                              color: AppPalette.textSecondary(context),
                              fontSize: 11,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 6),
                      Text(
                        item.title ?? item.contentTitle ?? 'Laporan Kampus',
                        style: HomeTextStyles.labelMd.copyWith(
                          color: AppPalette.textPrimary(context),
                          fontWeight: FontWeight.w700,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 6),
                      Row(
                        children: [
                          Icon(
                            item.metaIcon,
                            size: 13,
                            color: item.metaIconColor,
                          ),
                          const SizedBox(width: 4),
                          Expanded(
                            child: Text(
                              item.locationDisplay,
                              style: HomeTextStyles.bodySm.copyWith(
                                color: AppPalette.textSecondary(context),
                                fontSize: 11.5,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          const SizedBox(width: 8),
                          Row(
                            children: [
                              Icon(
                                Icons.arrow_upward_rounded,
                                size: 13,
                                color: item.isUpvoted
                                    ? HomeColors.primaryContainer
                                    : AppPalette.textSecondary(context),
                              ),
                              const SizedBox(width: 4),
                              Text(
                                '${item.upvoteCount}',
                                style: HomeTextStyles.labelSm.copyWith(
                                  color: item.isUpvoted
                                      ? HomeColors.primaryContainer
                                      : AppPalette.textSecondary(context),
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  /// Empty State jika mahasiswa belum memiliki laporan terbitan
  Widget _buildEmptyReportsState(BuildContext context, bool isDark) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 36),
      decoration: BoxDecoration(
        color: AppPalette.surface(context),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppPalette.divider(context)),
      ),
      alignment: Alignment.center,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 56,
            height: 56,
            decoration: BoxDecoration(
              color: HomeColors.primaryContainer.withValues(alpha: 0.1),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.assignment_outlined,
              size: 28,
              color: HomeColors.primaryContainer,
            ),
          ),
          const SizedBox(height: 12),
          Text(
            'Belum Ada Laporan Terbitan',
            style: HomeTextStyles.headlineSm.copyWith(
              color: AppPalette.textPrimary(context),
              fontWeight: FontWeight.w700,
              fontSize: 16,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            'Mahasiswa ini belum menerbitkan laporan publik fasilitas kampus saat ini.',
            textAlign: TextAlign.center,
            style: HomeTextStyles.bodySm.copyWith(
              color: AppPalette.textSecondary(context),
              height: 1.4,
            ),
          ),
        ],
      ),
    );
  }

  /// Banner Penjelasan Privasi Sesuai PRD
  Widget _buildPrivacyBanner(BuildContext context, bool isDark) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF13203A) : const Color(0xFFF1F5F9),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppPalette.divider(context)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(
            Icons.shield_outlined,
            size: 18,
            color: isDark ? const Color(0xFF93C5FD) : HomeColors.primaryContainer,
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Privasi Mahasiswa Dilindungi',
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                    color: AppPalette.textPrimary(context),
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  'Data privat seperti nomor telepon, bookmark terkunci, riwayat aktivitas akun, dan edit profil tidak ditampilkan pada tampilan profil publik ini.',
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 11,
                    color: AppPalette.textSecondary(context),
                    height: 1.35,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAvatar(BuildContext context) {
    if (avatarUrl != null && avatarUrl!.isNotEmpty) {
      if (avatarUrl!.startsWith('http://') || avatarUrl!.startsWith('https://')) {
        return Image.network(
          avatarUrl!,
          fit: BoxFit.cover,
          errorBuilder: (_, _, _) => _buildInitialsFallback(context),
        );
      }
      if (avatarUrl!.startsWith('assets/')) {
        return Image.asset(
          avatarUrl!,
          fit: BoxFit.cover,
          errorBuilder: (_, _, _) => _buildInitialsFallback(context),
        );
      }
    }
    return _buildInitialsFallback(context);
  }

  Widget _buildInitialsFallback(BuildContext context) {
    return Container(
      color: avatarBgColor ?? const Color(0xFFDCE9FF),
      alignment: Alignment.center,
      child: Text(
        _displayInitials,
        style: HomeTextStyles.headlineMd.copyWith(
          fontWeight: FontWeight.w800,
          color: avatarFgColor ?? HomeColors.primaryContainer,
        ),
      ),
    );
  }

  Widget _buildAdaptiveImage(String pathOrUrl, bool isCondition) {
    if (pathOrUrl.startsWith('http://') || pathOrUrl.startsWith('https://')) {
      return Image.network(
        pathOrUrl,
        fit: BoxFit.cover,
        errorBuilder: (_, _, _) => Icon(
          isCondition ? Icons.apartment_rounded : Icons.campaign_rounded,
          color: HomeColors.primaryContainer,
        ),
      );
    }
    if (pathOrUrl.startsWith('assets/')) {
      return Image.asset(
        pathOrUrl,
        fit: BoxFit.cover,
        errorBuilder: (_, _, _) => Icon(
          isCondition ? Icons.apartment_rounded : Icons.campaign_rounded,
          color: HomeColors.primaryContainer,
        ),
      );
    }
    return Icon(
      isCondition ? Icons.apartment_rounded : Icons.campaign_rounded,
      color: HomeColors.primaryContainer,
    );
  }
}
