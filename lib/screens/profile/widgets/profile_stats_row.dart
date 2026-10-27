import 'package:flutter/material.dart';

import '../../../theme/app_palette.dart';
import '../../../theme/app_spacing.dart';
import '../../../theme/home_colors.dart';
import '../../../theme/home_text_styles.dart';
import '../../../widgets/profile/stat_metric_card.dart';
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
                child: StatMetricCard(
                  icon: Icons.campaign_outlined,
                  iconBg: const Color(0xFFE0E7FF),
                  iconColor: const Color(0xFF4338CA),
                  value: '$totalReports',
                  label: 'Laporan Dibuat',
                  isDark: isDark,
                  onTap: () => _navigateToDashboard(context),
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
                  onTap: () => _navigateToDashboard(context),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: StatMetricCard(
                  icon: Icons.calendar_today_rounded,
                  iconBg: const Color(0xFFFEF3C7),
                  iconColor: const Color(0xFFB45309),
                  value: '$reportsThisMonth',
                  label: 'Bulan Ini',
                  isDark: isDark,
                  onTap: () => _navigateToDashboard(context),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
