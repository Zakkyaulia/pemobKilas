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
        // [MISSING ASSET] Logo/mascot belum tersedia di project.
        // Menggunakan placeholder container dengan icon.
        Container(
          width: 80,
          height: 80,
          decoration: BoxDecoration(
            color: AppColors.accentMint.withValues(alpha: 0.3),
            shape: BoxShape.circle,
          ),
          child: const Icon(
            Icons.school_rounded,
            size: 40,
            color: AppColors.primaryGreen,
          ),
        ),
        const SizedBox(height: AppSpacing.lg),

        // ── App Title ─────────────────────────────────────────────────
        Text(
          'KILAS',
          style: AppTextStyles.heading.copyWith(
            color: AppColors.primaryGreen,
            letterSpacing: 2,
          ),
        ),
        const SizedBox(height: AppSpacing.sm),

        // ── Campus Status Micro-Banner ────────────────────────────────
        // [ASSUMPTION] Diimplementasikan sebagai UI statis karena
        // tidak dijelaskan dalam PRD.
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
              Container(
                width: 8,
                height: 8,
                decoration: const BoxDecoration(
                  color: AppColors.primaryGreen,
                  shape: BoxShape.circle,
                ),
              ),
              const SizedBox(width: AppSpacing.sm),
              Text(
                'Universitas Andalas',
                style: AppTextStyles.bodySmall.copyWith(
                  color: AppColors.primaryGreen,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: AppSpacing.lg),

        // ── Supporting Description ────────────────────────────────────
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xxl),
          child: Text(
            'Kabar Lintas Andalas — Platform pelaporan kondisi kampus berbasis visual dan lokasi.',
            style: AppTextStyles.body,
            textAlign: TextAlign.center,
          ),
        ),
        const SizedBox(height: AppSpacing.xxxl),
      ],
    );
  }
}
