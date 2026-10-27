import 'package:flutter/material.dart';

import '../../theme/app_palette.dart';
import '../../theme/home_text_styles.dart';

/// Komponen kartu metrik statistik kontribusi yang reusable.
/// Digunakan pada [ProfileStatsRow] dan [PublicProfileScreen].
class StatMetricCard extends StatelessWidget {
  const StatMetricCard({
    super.key,
    required this.icon,
    required this.iconBg,
    required this.iconColor,
    required this.value,
    required this.label,
    required this.isDark,
    this.valueFontSize,
    this.labelFontSize,
    this.onTap,
  });

  final IconData icon;
  final Color iconBg;
  final Color iconColor;
  final String value;
  final String label;
  final bool isDark;
  final double? valueFontSize;
  final double? labelFontSize;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final cardContent = Container(
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
              fontSize: valueFontSize,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            label,
            style: HomeTextStyles.labelSm.copyWith(
              color: AppPalette.textSecondary(context),
              fontWeight: FontWeight.w600,
              fontSize: labelFontSize,
              height: 1.2,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );

    if (onTap != null) {
      return GestureDetector(
        onTap: onTap,
        behavior: HitTestBehavior.opaque,
        child: cardContent,
      );
    }

    return cardContent;
  }
}
