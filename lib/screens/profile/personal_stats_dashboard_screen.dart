import 'dart:io';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../theme/app_palette.dart';
import '../../theme/app_spacing.dart';
import '../../theme/home_colors.dart';
import '../../theme/home_text_styles.dart';
import '../home/data/report_repository.dart';
import '../home/models/report_model.dart';
import '../home/report_detail_screen.dart';
import 'data/achievements_data.dart';
import 'data/user_profile_repository.dart';

/// Pilihan filter periode statistik pribadi (FR-17).
enum StatsPeriod {
  semuaWaktu,
  bulanIni,
  mingguIni,
}

/// Halaman Dashboard Statistik Pribadi & Lencana Mahasiswa (FR-17 & FR-B6).
///
/// Menyajikan secara komprehensif:
/// 1. Ringkasan Metrik Kontribusi Mahasiswa (Total Laporan, Upvote, Rasio Dampak).
/// 2. Filter Periode Dinamis ("Semua Waktu", "Bulan Ini", "Minggu Ini").
/// 3. Visualisasi Rasio Kategori (Kondisi Kampus vs Info Penting).
/// 4. Laporan Terpopuler Milik Sendiri (Most Upvoted Report dengan navigasi ke detail).
/// 5. Koleksi Lencana & Prestasi Mahasiswa (Achievement entity: kode_lencana, dibuka_pada, progress).
class PersonalStatsDashboardScreen extends StatefulWidget {
  const PersonalStatsDashboardScreen({super.key});

  @override
  State<PersonalStatsDashboardScreen> createState() =>
      _PersonalStatsDashboardScreenState();
}

class _PersonalStatsDashboardScreenState
    extends State<PersonalStatsDashboardScreen> {
  StatsPeriod _selectedPeriod = StatsPeriod.semuaWaktu;

  @override
  Widget build(BuildContext context) {
    final topPadding = MediaQuery.of(context).padding.top;
    final isDark = AppPalette.isDark(context);

    return Scaffold(
      backgroundColor: AppPalette.canvas(context),
      body: AnimatedBuilder(
        animation: Listenable.merge([
          UserProfileRepository.instance,
          ReportRepository.instance,
        ]),
        builder: (context, _) {
          final profile = UserProfileRepository.instance.profile;
          final allReports = ReportRepository.instance.reports;

          // Filter semua laporan milik user saat ini
          final myAllReports = allReports.where((r) {
            final matchUsername = r.authorUsername != null &&
                r.authorUsername!.toLowerCase() ==
                    profile.username.toLowerCase();
            final matchName =
                r.authorName.toLowerCase() == profile.nama.toLowerCase();
            return matchUsername || matchName;
          }).toList();

          // Filter laporan berdasarkan periode yang dipilih
          final now = DateTime.now();
          final filteredReports = myAllReports.where((r) {
            switch (_selectedPeriod) {
              case StatsPeriod.semuaWaktu:
                return true;
              case StatsPeriod.bulanIni:
                if (r.createdAt == null) return true;
                return now.difference(r.createdAt!).inDays <= 30;
              case StatsPeriod.mingguIni:
                if (r.createdAt == null) return true;
                return now.difference(r.createdAt!).inDays <= 7;
            }
          }).toList();

          // Metrik-metrik terhitung
          final totalReports = filteredReports.length;
          final totalUpvotes = filteredReports.fold<int>(
            0,
            (acc, curr) => acc + curr.upvoteCount,
          );
          final avgUpvotes =
              totalReports > 0 ? (totalUpvotes / totalReports) : 0.0;

          // Laporan terpopuler milik sendiri
          ReportModel? mostUpvotedReport;
          if (filteredReports.isNotEmpty) {
            final sortedByUpvotes = List<ReportModel>.from(filteredReports)
              ..sort((a, b) => b.upvoteCount.compareTo(a.upvoteCount));
            mostUpvotedReport = sortedByUpvotes.first;
          }

          // Rasio kategori
          final conditionReports = filteredReports
              .where((r) => r.badgeLabel == 'Kondisi Kampus')
              .length;
          final infoReports = filteredReports
              .where((r) => r.badgeLabel == 'Info Penting')
              .length;

          // Lencana mahasiswa (dihitung dari seluruh rekam jejak)
          final badges = AchievementsData.calculateBadges(
            myReports: myAllReports,
            totalUpvotes: myAllReports.fold<int>(
              0,
              (acc, curr) => acc + curr.upvoteCount,
            ),
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
                  48,
                ),
                children: [
                  // 1. Selector Periode Waktu
                  _buildPeriodSelector(context, isDark),

                  const SizedBox(height: 16),

                  // 2. Kartu Metrik Utama
                  _buildPrimaryMetrics(
                    context: context,
                    isDark: isDark,
                    totalReports: totalReports,
                    totalUpvotes: totalUpvotes,
                    avgUpvotes: avgUpvotes,
                  ),

                  const SizedBox(height: 20),

                  // 3. Distribusi & Rasio Kategori Laporan
                  _buildCategoryRatioSection(
                    context: context,
                    isDark: isDark,
                    conditionCount: conditionReports,
                    infoCount: infoReports,
                    total: totalReports,
                  ),

                  const SizedBox(height: 20),

                  // 4. Laporan Terpopuler Milik Sendiri (FR-17)
                  _buildMostUpvotedReportCard(
                    context: context,
                    isDark: isDark,
                    topReport: mostUpvotedReport,
                  ),

                  const SizedBox(height: 24),

                  // 5. Koleksi Lencana Mahasiswa (FR-B6)
                  _buildBadgesSection(
                    context: context,
                    isDark: isDark,
                    badges: badges,
                  ),
                ],
              ),

              // ── Frosted-Glass App Bar Header ───────────────────────
              Positioned(
                top: 0,
                left: 0,
                right: 0,
                child: ClipRect(
                  child: BackdropFilter(
                    filter: ImageFilter.blur(sigmaX: 24, sigmaY: 24),
                    child: Container(
                      height: topPadding + 64,
                      color: AppPalette.surface(context).withValues(
                        alpha: isDark ? 0.85 : 0.90,
                      ),
                      child: SafeArea(
                        bottom: false,
                        child: Padding(
                          padding: const EdgeInsets.symmetric(
                            horizontal: AppSpacing.lg,
                          ),
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
                              const SizedBox(width: 8),
                              Expanded(
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      'Statistik & Lencana',
                                      style: HomeTextStyles.headlineSm.copyWith(
                                        color: AppPalette.textPrimary(context),
                                        fontWeight: FontWeight.w700,
                                      ),
                                    ),
                                    Text(
                                      'Dashboard Kontribusi @${profile.username.replaceAll('@', '')}',
                                      style: HomeTextStyles.labelSm.copyWith(
                                        color:
                                            AppPalette.textSecondary(context),
                                      ),
                                    ),
                                  ],
                                ),
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

  // ═════════════════════════════════════════════════════════════════════════
  // Komponen Sub-Widgets
  // ═════════════════════════════════════════════════════════════════════════

  Widget _buildPeriodSelector(BuildContext context, bool isDark) {
    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: AppPalette.surface(context),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppPalette.divider(context), width: 1),
      ),
      child: Row(
        children: [
          _buildPeriodChip(
            label: 'Semua Waktu',
            period: StatsPeriod.semuaWaktu,
            isDark: isDark,
          ),
          _buildPeriodChip(
            label: 'Bulan Ini',
            period: StatsPeriod.bulanIni,
            isDark: isDark,
          ),
          _buildPeriodChip(
            label: 'Minggu Ini',
            period: StatsPeriod.mingguIni,
            isDark: isDark,
          ),
        ],
      ),
    );
  }

  Widget _buildPeriodChip({
    required String label,
    required StatsPeriod period,
    required bool isDark,
  }) {
    final isSelected = _selectedPeriod == period;

    return Expanded(
      child: GestureDetector(
        onTap: () => setState(() => _selectedPeriod = period),
        behavior: HitTestBehavior.opaque,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.symmetric(vertical: 8),
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: isSelected
                ? (isDark ? const Color(0xFF1D4ED8) : HomeColors.primary)
                : Colors.transparent,
            borderRadius: BorderRadius.circular(10),
            boxShadow: isSelected
                ? [
                    BoxShadow(
                      color: HomeColors.primary.withValues(alpha: 0.25),
                      blurRadius: 6,
                      offset: const Offset(0, 2),
                    ),
                  ]
                : null,
          ),
          child: Text(
            label,
            style: GoogleFonts.plusJakartaSans(
              fontSize: 13,
              fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
              color: isSelected
                  ? Colors.white
                  : AppPalette.textSecondary(context),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildPrimaryMetrics({
    required BuildContext context,
    required bool isDark,
    required int totalReports,
    required int totalUpvotes,
    required double avgUpvotes,
  }) {
    return Column(
      children: [
        Row(
          children: [
            Expanded(
              child: _buildMetricTile(
                context: context,
                isDark: isDark,
                title: 'Laporan Terbit',
                value: '$totalReports',
                unit: 'Laporan',
                icon: Icons.campaign_rounded,
                iconColor: const Color(0xFF2563EB),
                iconBg: const Color(0xFFEFF6FF),
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: _buildMetricTile(
                context: context,
                isDark: isDark,
                title: 'Total Upvote',
                value: '$totalUpvotes',
                unit: 'Upvote',
                icon: Icons.arrow_upward_rounded,
                iconColor: const Color(0xFF10B981),
                iconBg: const Color(0xFFECFDF5),
              ),
            ),
          ],
        ),
        const SizedBox(height: 10),
        Row(
          children: [
            Expanded(
              child: _buildMetricTile(
                context: context,
                isDark: isDark,
                title: 'Rerata Upvote',
                value: avgUpvotes.toStringAsFixed(1),
                unit: 'per laporan',
                icon: Icons.trending_up_rounded,
                iconColor: const Color(0xFFF59E0B),
                iconBg: const Color(0xFFFEF3C7),
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: _buildMetricTile(
                context: context,
                isDark: isDark,
                title: 'Status',
                value: totalReports >= 3 ? 'Aktif' : 'Pemula',
                unit: totalReports >= 3 ? 'Teladan' : 'Warga Kampus',
                icon: Icons.military_tech_rounded,
                iconColor: const Color(0xFF8B5CF6),
                iconBg: const Color(0xFFF5F3FF),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildMetricTile({
    required BuildContext context,
    required bool isDark,
    required String title,
    required String value,
    required String unit,
    required IconData icon,
    required Color iconColor,
    required Color iconBg,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
      decoration: BoxDecoration(
        color: AppPalette.surface(context),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppPalette.divider(context), width: 1),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: isDark ? 0.2 : 0.03),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  title,
                  style: HomeTextStyles.labelSm.copyWith(
                    color: AppPalette.textSecondary(context),
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              const SizedBox(width: 4),
              Container(
                width: 28,
                height: 28,
                decoration: BoxDecoration(
                  color: isDark ? iconColor.withValues(alpha: 0.15) : iconBg,
                  shape: BoxShape.circle,
                ),
                child: Icon(icon, color: iconColor, size: 16),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            value,
            style: GoogleFonts.plusJakartaSans(
              fontSize: 22,
              fontWeight: FontWeight.w700,
              color: AppPalette.textPrimary(context),
            ),
          ),
          const SizedBox(height: 2),
          Text(
            unit,
            style: HomeTextStyles.labelSm.copyWith(
              color: AppPalette.textSecondary(context),
              fontSize: 11,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }

  Widget _buildCategoryRatioSection({
    required BuildContext context,
    required bool isDark,
    required int conditionCount,
    required int infoCount,
    required int total,
  }) {
    final conditionPct = total > 0 ? (conditionCount / total) : 0.0;
    final infoPct = total > 0 ? (infoCount / total) : 0.0;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppPalette.surface(context),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppPalette.divider(context), width: 1),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: isDark ? 0.2 : 0.03),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'DISTRIBUSI KATEGORI',
                style: HomeTextStyles.labelSm.copyWith(
                  letterSpacing: 0.8,
                  color: AppPalette.textSecondary(context),
                  fontWeight: FontWeight.w700,
                ),
              ),
              Text(
                'Total $total laporan',
                style: HomeTextStyles.labelSm.copyWith(
                  color: AppPalette.textSecondary(context),
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),

          // Stacked Progress Bar
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: Container(
              height: 12,
              color: AppPalette.divider(context),
              child: Row(
                children: [
                  if (conditionCount > 0)
                    Expanded(
                      flex: conditionCount,
                      child: Container(
                        color: HomeColors.statusCondition,
                      ),
                    ),
                  if (infoCount > 0)
                    Expanded(
                      flex: infoCount,
                      child: Container(
                        color: HomeColors.primary,
                      ),
                    ),
                ],
              ),
            ),
          ),

          const SizedBox(height: 14),

          // Detail Kategori Legenda
          Row(
            children: [
              Expanded(
                child: Row(
                  children: [
                    Container(
                      width: 10,
                      height: 10,
                      decoration: const BoxDecoration(
                        color: HomeColors.statusCondition,
                        shape: BoxShape.circle,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Kondisi Kampus',
                            style: HomeTextStyles.bodySm.copyWith(
                              color: AppPalette.textPrimary(context),
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          Text(
                            '$conditionCount laporan (${(conditionPct * 100).toStringAsFixed(0)}%)',
                            style: HomeTextStyles.labelSm.copyWith(
                              color: AppPalette.textSecondary(context),
                              fontSize: 11,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: Row(
                  children: [
                    Container(
                      width: 10,
                      height: 10,
                      decoration: const BoxDecoration(
                        color: HomeColors.primary,
                        shape: BoxShape.circle,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Info Penting',
                            style: HomeTextStyles.bodySm.copyWith(
                              color: AppPalette.textPrimary(context),
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          Text(
                            '$infoCount laporan (${(infoPct * 100).toStringAsFixed(0)}%)',
                            style: HomeTextStyles.labelSm.copyWith(
                              color: AppPalette.textSecondary(context),
                              fontSize: 11,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildMostUpvotedReportCard({
    required BuildContext context,
    required bool isDark,
    required ReportModel? topReport,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppPalette.surface(context),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: const Color(0xFFF59E0B).withValues(alpha: 0.5),
          width: 1.5,
        ),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFFF59E0B).withValues(alpha: isDark ? 0.15 : 0.06),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: const Color(0xFFFEF3C7),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(
                      Icons.emoji_events_rounded,
                      color: Color(0xFFB45309),
                      size: 14,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      'Laporan Terpopuler Saya',
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                        color: const Color(0xFFB45309),
                      ),
                    ),
                  ],
                ),
              ),
              const Spacer(),
              if (topReport != null)
                Text(
                  '${topReport.upvoteCount} Upvotes',
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                    color: const Color(0xFF10B981),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 12),
          if (topReport == null)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 8),
              child: Text(
                'Belum ada laporan yang diterbitkan pada periode ini. Bagikan kondisi atau info kampus untuk menjadi laporan terpopuler!',
                style: HomeTextStyles.bodySm.copyWith(
                  color: AppPalette.textSecondary(context),
                ),
              ),
            )
          else
            GestureDetector(
              onTap: () {
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (_) => ReportDetailScreen(report: topReport),
                  ),
                );
              },
              behavior: HitTestBehavior.opaque,
              child: Row(
                children: [
                  // Thumbnail gambar laporan jika ada
                  if (topReport.imageUrl != null)
                    ClipRRect(
                      borderRadius: BorderRadius.circular(10),
                      child: SizedBox(
                        width: 72,
                        height: 72,
                        child: _buildAdaptiveImage(
                          topReport.imageUrl!,
                          topReport.badgeLabel == 'Kondisi Kampus',
                        ),
                      ),
                    )
                  else
                    Container(
                      width: 72,
                      height: 72,
                      decoration: BoxDecoration(
                        color: HomeColors.surfaceVariant,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: const Icon(
                        Icons.campaign_rounded,
                        color: HomeColors.primary,
                        size: 32,
                      ),
                    ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          topReport.title ?? 'Laporan Tanpa Judul',
                          style: HomeTextStyles.labelLg.copyWith(
                            color: AppPalette.textPrimary(context),
                            fontWeight: FontWeight.w700,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 4),
                        Row(
                          children: [
                            const Icon(
                              Icons.location_on,
                              size: 13,
                              color: HomeColors.primary,
                            ),
                            const SizedBox(width: 3),
                            Expanded(
                              child: Text(
                                topReport.locationName ?? 'UNAND',
                                style: HomeTextStyles.labelSm.copyWith(
                                  color: AppPalette.textSecondary(context),
                                  fontSize: 11,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 6),
                        Row(
                          children: [
                            Text(
                              'Buka Detail Laporan',
                              style: GoogleFonts.plusJakartaSans(
                                fontSize: 11,
                                fontWeight: FontWeight.w600,
                                color: HomeColors.primary,
                              ),
                            ),
                            const SizedBox(width: 4),
                            const Icon(
                              Icons.arrow_forward_rounded,
                              size: 12,
                              color: HomeColors.primary,
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildBadgesSection({
    required BuildContext context,
    required bool isDark,
    required List<AchievementBadge> badges,
  }) {
    final unlockedCount = badges.where((b) => b.isUnlocked).length;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'LENCANA & PENCAPAIAN',
              style: HomeTextStyles.labelSm.copyWith(
                letterSpacing: 0.8,
                color: AppPalette.textSecondary(context),
                fontWeight: FontWeight.w700,
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
              decoration: BoxDecoration(
                color: isDark
                    ? const Color(0xFF1E293B)
                    : const Color(0xFFF1F5F9),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                '$unlockedCount / ${badges.length} Terbuka',
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                  color: isDark ? const Color(0xFF94A3B8) : const Color(0xFF475569),
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            crossAxisSpacing: 10,
            mainAxisSpacing: 10,
            mainAxisExtent: 168,
          ),
          itemCount: badges.length,
          itemBuilder: (context, index) {
            final badge = badges[index];
            return _buildBadgeCard(context, isDark, badge);
          },
        ),
      ],
    );
  }

  Widget _buildBadgeCard(
    BuildContext context,
    bool isDark,
    AchievementBadge badge,
  ) {
    return GestureDetector(
      onTap: () => _showBadgeDetail(context, isDark, badge),
      behavior: HitTestBehavior.opaque,
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: AppPalette.surface(context),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: badge.isUnlocked
                ? badge.iconColor.withValues(alpha: 0.4)
                : AppPalette.divider(context),
            width: badge.isUnlocked ? 1.5 : 1.0,
          ),
          boxShadow: [
            BoxShadow(
              color: badge.isUnlocked
                  ? badge.iconColor.withValues(alpha: isDark ? 0.15 : 0.05)
                  : Colors.black.withValues(alpha: isDark ? 0.1 : 0.02),
              blurRadius: 6,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Container(
                  width: 36,
                  height: 36,
                  decoration: BoxDecoration(
                    color: badge.isUnlocked
                        ? (isDark
                            ? badge.iconColor.withValues(alpha: 0.2)
                            : badge.iconBg)
                        : (isDark
                            ? const Color(0xFF1E293B)
                            : const Color(0xFFF1F5F9)),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    badge.icon,
                    size: 20,
                    color: badge.isUnlocked
                        ? badge.iconColor
                        : AppPalette.textSecondary(context),
                  ),
                ),
                if (badge.isUnlocked)
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 6,
                      vertical: 2,
                    ),
                    decoration: BoxDecoration(
                      color: const Color(0xFFECFDF5),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(
                          Icons.check_circle_rounded,
                          size: 11,
                          color: Color(0xFF10B981),
                        ),
                        const SizedBox(width: 3),
                        Text(
                          'Diraih',
                          style: GoogleFonts.plusJakartaSans(
                            fontSize: 10,
                            fontWeight: FontWeight.w700,
                            color: const Color(0xFF047857),
                          ),
                        ),
                      ],
                    ),
                  )
                else
                  const Icon(
                    Icons.lock_outline_rounded,
                    size: 16,
                    color: Color(0xFF94A3B8),
                  ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              badge.nama,
              style: HomeTextStyles.labelLg.copyWith(
                color: AppPalette.textPrimary(context),
                fontWeight: FontWeight.w700,
                fontSize: 13,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 3),
            Text(
              badge.deskripsi,
              style: HomeTextStyles.bodySm.copyWith(
                color: AppPalette.textSecondary(context),
                fontSize: 11,
                height: 1.25,
              ),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
            const Spacer(),
            // Progress Bar
            ClipRRect(
              borderRadius: BorderRadius.circular(4),
              child: LinearProgressIndicator(
                value: badge.progress,
                minHeight: 5,
                backgroundColor: isDark
                    ? const Color(0xFF334155)
                    : const Color(0xFFE2E8F0),
                valueColor: AlwaysStoppedAnimation<Color>(
                  badge.isUnlocked
                      ? badge.iconColor
                      : const Color(0xFF94A3B8),
                ),
              ),
            ),
            const SizedBox(height: 4),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  badge.progressLabel,
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 10,
                    fontWeight: FontWeight.w600,
                    color: AppPalette.textSecondary(context),
                  ),
                ),
                if (badge.dibukaPada != null)
                  Text(
                    badge.dibukaPada!,
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 10,
                      fontWeight: FontWeight.w500,
                      color: const Color(0xFF10B981),
                    ),
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  void _showBadgeDetail(
    BuildContext context,
    bool isDark,
    AchievementBadge badge,
  ) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (_) {
        return Container(
          padding: const EdgeInsets.fromLTRB(24, 16, 24, 32),
          decoration: BoxDecoration(
            color: AppPalette.surface(context),
            borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: AppPalette.divider(context),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(height: 20),
              Container(
                width: 64,
                height: 64,
                decoration: BoxDecoration(
                  color: badge.isUnlocked
                      ? (isDark
                          ? badge.iconColor.withValues(alpha: 0.2)
                          : badge.iconBg)
                      : const Color(0xFFE2E8F0),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  badge.icon,
                  size: 34,
                  color: badge.isUnlocked
                      ? badge.iconColor
                      : const Color(0xFF64748B),
                ),
              ),
              const SizedBox(height: 16),
              Text(
                badge.nama,
                style: HomeTextStyles.headlineSm.copyWith(
                  fontWeight: FontWeight.w700,
                  color: AppPalette.textPrimary(context),
                ),
              ),
              const SizedBox(height: 4),
              Text(
                'Lencana Prestasi Mahasiswa KILAS UNAND',
                style: HomeTextStyles.labelSm.copyWith(
                  color: AppPalette.textSecondary(context),
                ),
              ),
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: isDark
                      ? const Color(0xFF1E293B)
                      : const Color(0xFFF8FAFC),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: AppPalette.divider(context),
                  ),
                ),
                child: Text(
                  badge.deskripsi,
                  textAlign: TextAlign.center,
                  style: HomeTextStyles.bodyMd.copyWith(
                    color: AppPalette.textPrimary(context),
                    height: 1.4,
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    badge.isUnlocked
                        ? Icons.verified_rounded
                        : Icons.lock_outline_rounded,
                    size: 16,
                    color: badge.isUnlocked
                        ? const Color(0xFF10B981)
                        : const Color(0xFF94A3B8),
                  ),
                  const SizedBox(width: 6),
                  Text(
                    badge.isUnlocked
                        ? 'Telah Terbuka: ${badge.dibukaPada ?? "Bulan Ini"}'
                        : 'Belum Terbuka (${badge.progressLabel})',
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: badge.isUnlocked
                          ? const Color(0xFF10B981)
                          : AppPalette.textSecondary(context),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                child: FilledButton(
                  onPressed: () => Navigator.pop(context),
                  style: FilledButton.styleFrom(
                    backgroundColor: HomeColors.primary,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    padding: const EdgeInsets.symmetric(vertical: 14),
                  ),
                  child: Text(
                    'Tutup',
                    style: GoogleFonts.plusJakartaSans(
                      fontWeight: FontWeight.w600,
                      fontSize: 14,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      },
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
    return Image.file(
      File(pathOrUrl),
      fit: BoxFit.cover,
      errorBuilder: (_, _, _) => Icon(
        isCondition ? Icons.apartment_rounded : Icons.campaign_rounded,
        color: HomeColors.primaryContainer,
      ),
    );
  }
}
