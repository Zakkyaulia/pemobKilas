import 'package:flutter/material.dart';

import '../../theme/app_colors.dart';
import '../../theme/app_spacing.dart';
import '../../theme/app_text_styles.dart';

/// A biometric quick-login button section.
///
/// Displays a fingerprint icon with supporting text for quick authentication.
///
/// Design note:
/// [PRD/Figma MISMATCH] Figma shows biometric on the login screen,
/// but PRD (FR-04) specifies biometric only for securing the profile page.
/// This widget renders the UI as per Figma but does NOT implement
/// actual biometric authentication for login. The biometric flow should
/// be implemented in the profile module per PRD requirements.
class BiometricLoginButton extends StatelessWidget {
  const BiometricLoginButton({super.key, this.onTap});

  /// Called when the user taps the biometric area.
  /// Currently a no-op placeholder per PRD scope.
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // ── Divider with text ─────────────────────────────────────────
        Row(
          children: [
            const Expanded(child: Divider()),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
              child: Text('atau masuk dengan', style: AppTextStyles.caption),
            ),
            const Expanded(child: Divider()),
          ],
        ),
        const SizedBox(height: AppSpacing.xl),

        // ── Biometric button ──────────────────────────────────────────
        GestureDetector(
          onTap: onTap,
          child: Column(
            children: [
              Container(
                width: 56,
                height: 56,
                decoration: BoxDecoration(
                  color: AppColors.surfaceLightBlue,
                  shape: BoxShape.circle,
                  border: Border.all(color: AppColors.inputBorder, width: 1),
                ),
                child: const Icon(
                  Icons.fingerprint_rounded,
                  size: 28,
                  color: AppColors.primaryBlue,
                ),
              ),
              const SizedBox(height: AppSpacing.sm),
              Text(
                'Sidik Jari',
                style: AppTextStyles.caption.copyWith(
                  color: AppColors.textSecondary,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
