import 'package:flutter/material.dart';

import '../../theme/app_colors.dart';
import '../../theme/app_spacing.dart';
import '../../theme/app_text_styles.dart';
import '../../widgets/auth/biometric_login_button.dart';
import '../../widgets/auth/login_form.dart';
import '../../widgets/auth/login_header.dart';
import '../../widgets/auth/student_guide_link.dart';

/// The Login screen for KILAS — Mahasiswa authentication.
///
/// This is the entry point for user authentication. It orchestrates
/// the login UI layout composed of modular child widgets:
///
/// ```
/// Scaffold
///  └── SafeArea
///       └── SingleChildScrollView (keyboard-safe)
///            └── ConstrainedBox (min full height)
///                 └── Padding
///                      └── Column
///                           ├── LoginHeader
///                           ├── LoginForm
///                           ├── Registration link
///                           ├── BiometricLoginButton
///                           └── StudentGuideLink
/// ```
///
/// The screen is fully scrollable to prevent overflow when the
/// soft keyboard is displayed. Layout is responsive and centers
/// content within a max-width constraint for larger devices.
class LoginScreen extends StatelessWidget {
  const LoginScreen({super.key});

  void _handleLogin(BuildContext context, Map<String, String> data) {
    // [MISSING API] Login API integration goes here.
    // For now, show a snackbar with the submitted data.
    final method = data['method'] ?? 'unknown';
    final identifier = method == 'email'
        ? data['email'] ?? ''
        : data['nim'] ?? '';

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Login: $method — $identifier'),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      ),
    );
  }

  void _handleBiometric(BuildContext context) {
    // [PRD/Figma MISMATCH] Biometric is for profile access, not login.
    // This is a placeholder per Figma UI.
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Text(
          'Fitur sidik jari tersedia untuk keamanan halaman profil.',
        ),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final viewInsets = MediaQuery.of(context).viewInsets;
    final screenHeight = MediaQuery.of(context).size.height;

    return Scaffold(
      backgroundColor: AppColors.backgroundPrimary,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: EdgeInsets.only(bottom: viewInsets.bottom),
          physics: const ClampingScrollPhysics(),
          child: ConstrainedBox(
            constraints: BoxConstraints(
              minHeight:
                  screenHeight -
                  MediaQuery.of(context).padding.top -
                  MediaQuery.of(context).padding.bottom,
            ),
            child: Center(
              child: ConstrainedBox(
                // Cap width for tablets / landscape — login card stays readable.
                constraints: const BoxConstraints(maxWidth: 440),
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppSpacing.xxl,
                  ),
                  child: Column(
                    children: [
                      // ── Header ──────────────────────────────────────
                      const LoginHeader(),

                      // ── Login Form Card ─────────────────────────────
                      LoginForm(
                        onSubmit: (data) => _handleLogin(context, data),
                      ),
                      const SizedBox(height: AppSpacing.xl),

                      // ── Registration Link ───────────────────────────
                      _buildRegistrationLink(context),
                      const SizedBox(height: AppSpacing.xxl),

                      // ── Biometric Quick Login ───────────────────────
                      BiometricLoginButton(
                        onTap: () => _handleBiometric(context),
                      ),

                      // ── Student Guide Link ──────────────────────────
                      const StudentGuideLink(),
                      const SizedBox(height: AppSpacing.lg),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildRegistrationLink(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text('Belum punya akun? ', style: AppTextStyles.body),
        GestureDetector(
          onTap: () {
            // TODO: Navigate to registration screen when implemented.
          },
          child: Text('Daftar', style: AppTextStyles.link),
        ),
      ],
    );
  }
}
