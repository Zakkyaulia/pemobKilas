import 'package:flutter/material.dart';

import '../../../theme/app_palette.dart';
import '../../../theme/app_spacing.dart';
import '../../../theme/home_colors.dart';
import '../../../theme/home_text_styles.dart';
import '../personal_stats_dashboard_screen.dart';

/// Baris kartu metrik statistik pribadi pengguna (FR-17 & FR-B6).
///
/// Menampilkan:
/// 1. Laporan Dibuat (Total laporan terbitan user)
/// 2. Upvote Didapat (Akumulasi dukungan pada laporan user)
/// 3. Bulan Ini (Laporan yang diterbitkan dalam 30 hari terakhir)
///
/// Sesuai PRD 3.2 (Out of Scope): "Rank Kampus / Statistik tingkat kampus" ditiadakan
/// dan digantikan dengan metrik "Bulan Ini" sesuai klausul FR-B6 PRD.
class ProfileStatsRow extends StatelessWidget {
  const ProfileStatsRow({
    super.key,
    required this.totalReports,
    required this.totalUpvotes,
    required this.reportsThisMonth,
  });

  final int totalReports;
  final int totalUpvotes;
  final int reportsThisMonth;

  void _navigateToDashboard(BuildContext context) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => const PersonalStatsDashboardScreen(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = AppPalette.isDark(context);

    return Container(
      margin: const EdgeInsets.symmetric(
        horizontal: AppSpacing.lg,
        vertical: 6,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'STATISTIK KONTRIBUSI',
                style: HomeTextStyles.labelSm.copyWith(
                  letterSpacing: 0.8,
                  color: AppPalette.textSecondary(context),
                ),
              ),
              GestureDetector(
                onTap: () => _navigateToDashboard(context),
                behavior: HitTestBehavior.opaque,
                child: Row(
                  children: [
                    Text(
                      'Dashboard Lengkap',
                      style: HomeTextStyles.labelSm.copyWith(
                        color: HomeColors.primary,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(width: 2),
                    const Icon(
                      Icons.chevron_right_rounded,
                      size: 16,
                      color: HomeColors.primary,
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              Expanded(
                child: _buildStatCard(
                  context: context,
                  icon: Icons.campaign_outlined,
                  iconBg: const Color(0xFFE0E7FF),
                  iconColor: const Color(0xFF4338CA),
                  value: '$totalReports',
                  label: 'Laporan Dibuat',
                  isDark: isDark,
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: _buildStatCard(
                  context: context,
                  icon: Icons.thumb_up_alt_outlined,
                  iconBg: const Color(0xFFDBEAFE),
                  iconColor: const Color(0xFF1D4ED8),
                  value: '$totalUpvotes',
                  label: 'Upvote Didapat',
                  isDark: isDark,
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: _buildStatCard(
                  context: context,
                  icon: Icons.calendar_today_rounded,
                  iconBg: const Color(0xFFFEF3C7),
                  iconColor: const Color(0xFFB45309),
                  value: '$reportsThisMonth',
                  label: 'Bulan Ini',
                  isDark: isDark,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStatCard({
    required BuildContext context,
    required IconData icon,
    required Color iconBg,
    required Color iconColor,
    required String value,
    required String label,
    required bool isDark,
  }) {
    return GestureDetector(
      onTap: () => _navigateToDashboard(context),
      behavior: HitTestBehavior.opaque,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 12),
        decoration: BoxDecoration(
        color: AppPalette.surface(context),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: AppPalette.divider(context),
          width: 1,
        ),
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
          Container(
            width: 28,
            height: 28,
            decoration: BoxDecoration(
              color: isDark ? iconColor.withValues(alpha: 0.2) : iconBg,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(
              icon,
              size: 16,
              color: isDark ? const Color(0xFF93C5FD) : iconColor,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            value,
            style: HomeTextStyles.headlineMd.copyWith(
              color: AppPalette.textPrimary(context),
              height: 1.1,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            label,
            style: HomeTextStyles.labelSm.copyWith(
              color: AppPalette.textSecondary(context),
              fontWeight: FontWeight.w600,
              height: 1.2,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    ),
    );
  }
}
