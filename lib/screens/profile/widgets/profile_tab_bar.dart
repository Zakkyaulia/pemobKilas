import 'package:flutter/material.dart';

import '../../../theme/app_palette.dart';
import '../../../theme/app_spacing.dart';
import '../../../theme/home_colors.dart';
import '../../../theme/home_text_styles.dart';

/// Segmented tab bar untuk berpindah antara:
/// 0. Laporan (laporan milik pengguna sendiri)
/// 1. 🔒 Bookmark (koleksi bookmark terkunci biometrik, FR-10)
/// 2. Riwayat (log aktivitas pribadi, FR-24 / FR-C6)
class ProfileTabBar extends StatelessWidget {
  const ProfileTabBar({
    super.key,
    required this.selectedIndex,
    required this.onTabChanged,
    required this.reportCount,
    required this.isBookmarkUnlocked,
  });

  final int selectedIndex;
  final ValueChanged<int> onTabChanged;
  final int reportCount;
  final bool isBookmarkUnlocked;

  @override
  Widget build(BuildContext context) {
    final isDark = AppPalette.isDark(context);

    return Container(
      margin: const EdgeInsets.symmetric(
        horizontal: AppSpacing.lg,
        vertical: AppSpacing.sm,
      ),
      padding: const EdgeInsets.all(AppSpacing.xs),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF0F1A30) : const Color(0xFFF1F5F9),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppPalette.divider(context)),
      ),
      child: Row(
        children: [
          _buildTabItem(
            context: context,
            index: 0,
            label: 'Laporan',
            badge: '$reportCount',
            icon: Icons.article_outlined,
          ),
          _buildTabItem(
            context: context,
            index: 1,
            label: 'Bookmark',
            icon: isBookmarkUnlocked
                ? Icons.bookmark_added_rounded
                : Icons.lock_outline_rounded,
          ),
          _buildTabItem(
            context: context,
            index: 2,
            label: 'Riwayat',
            icon: Icons.history_rounded,
          ),
        ],
      ),
    );
  }

  Widget _buildTabItem({
    required BuildContext context,
    required int index,
    required String label,
    required IconData icon,
    String? badge,
  }) {
    final isSelected = selectedIndex == index;

    return Expanded(
      child: GestureDetector(
        onTap: () => onTabChanged(index),
        behavior: HitTestBehavior.opaque,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 180),
          padding: const EdgeInsets.symmetric(vertical: 8),
          decoration: BoxDecoration(
            color: isSelected ? HomeColors.primaryContainer : Colors.transparent,
            borderRadius: BorderRadius.circular(10),
            boxShadow: isSelected
                ? [
                    BoxShadow(
                      color: HomeColors.primaryContainer.withValues(alpha: 0.3),
                      blurRadius: 6,
                      offset: const Offset(0, 2),
                    ),
                  ]
                : null,
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                icon,
                size: 14,
                color: isSelected ? Colors.white : AppPalette.textSecondary(context),
              ),
              const SizedBox(width: 5),
              Text(
                label,
                style: HomeTextStyles.labelMd.copyWith(
                  fontWeight: FontWeight.w700,
                  color: isSelected ? Colors.white : AppPalette.textSecondary(context),
                ),
              ),
              if (badge != null) ...[
                const SizedBox(width: 5),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 1),
                  decoration: BoxDecoration(
                    color: isSelected
                        ? Colors.white.withValues(alpha: 0.25)
                        : HomeColors.primaryContainer.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    badge,
                    style: HomeTextStyles.labelSm.copyWith(
                      color: isSelected ? Colors.white : HomeColors.primaryContainer,
                    ),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
