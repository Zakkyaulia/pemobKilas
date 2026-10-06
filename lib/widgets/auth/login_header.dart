import 'package:flutter/material.dart';

import '../../theme/app_colors.dart';
import '../../theme/app_radius.dart';
import '../../theme/app_spacing.dart';
import '../../theme/app_text_styles.dart';

/// The header section of the Login screen.
///
/// Displays:
/// - App logo / mascot placeholder [MISSING ASSET]
/// - "KILAS" title (26px, w700)
/// - Campus status micro-banner [ASSUMPTION: static UI]
/// - Supporting description text
///
/// Layout follows the Figma design hierarchy:
/// ```
/// Column (center aligned)
///   ├── Logo placeholder
///   ├── "KILAS" heading
///   ├── Campus status badge
///   └── Description text
/// ```
class LoginHeader extends StatelessWidget {
  const LoginHeader({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        const SizedBox(height: AppSpacing.xxl),

        // ── Logo / Mascot ─────────────────────────────────────────────
        Container(
          width: 80,
          height: 80,
          decoration: const BoxDecoration(
            color: AppColors.accentCyan,
            shape: BoxShape.circle,
          ),
          child: ClipOval(
            child: Image.asset(
              'assets/icons/app_logo.png',
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) => const Icon(Icons.school, color: AppColors.primaryBlue, size: 40),
            ),
          ),
        ),
        const SizedBox(height: AppSpacing.lg),

        // ── App Title ─────────────────────────────────────────────────
        Text(
          'KILAS',
          style: AppTextStyles.heading.copyWith(
            color: AppColors.textPrimary,
          ),
        ),
        const SizedBox(height: AppSpacing.sm),

        // ── Campus Status Micro-Banner ────────────────────────────────
        Container(
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.md,
            vertical: AppSpacing.xs,
          ),
          decoration: BoxDecoration(
            color: AppColors.surfaceLightBlue,
            borderRadius: AppRadius.fullAll,
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'Kabar Lintas Andalas',
                style: AppTextStyles.bodySmall.copyWith(
                  color: AppColors.primaryBlue,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(width: AppSpacing.xs),
              const Text('•', style: TextStyle(color: AppColors.textMuted, fontSize: 12)),
              const SizedBox(width: AppSpacing.xs),
              Text(
                'Limau Manis',
                style: AppTextStyles.bodySmall.copyWith(
                  color: AppColors.accentBrownGold,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: AppSpacing.md),

        // ── Supporting Description ────────────────────────────────────
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
          child: Text(
            'Sistem Terpadu Pelaporan Insiden & Titik\nHotspot Kampus UNAND',
            style: AppTextStyles.body.copyWith(
              color: AppColors.textSecondary,
              height: 1.4,
            ),
            textAlign: TextAlign.center,
          ),
        ),
        const SizedBox(height: AppSpacing.xxl),
      ],
    );
  }
}
