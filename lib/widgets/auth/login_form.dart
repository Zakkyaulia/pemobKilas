import 'package:flutter/material.dart';

import '../../theme/app_colors.dart';
import '../../theme/app_radius.dart';
import '../../theme/app_spacing.dart';
import '../../utils/validators.dart';
import 'auth_text_field.dart';
import 'login_method_toggle.dart';

/// The authentication form card for the Login screen.
///
/// Contains:
/// - Login method toggle (Email / NIM)
/// - Conditional fields based on selected method
/// - Submit button with loading state
///
/// This widget manages its own form state (controllers, validation,
/// form key) and delegates the login action to the [onSubmit] callback.
///
/// Form validation follows PRD and reusable Validators:
/// - Email: domain @student.unand.ac.id
/// - NIM: numeric and non-empty
/// - Password: minimum 8 characters
class LoginForm extends StatefulWidget {
  const LoginForm({super.key, this.onSubmit});

  /// Called when the form is valid and the user taps "Masuk".
  ///
  /// Receives a map with keys:
  /// - `method`: 'email' or 'nim'
  /// - `email`: email address (only for email method)
  /// - `nim`: NIM string (only for NIM method)
  /// - `password`: password string
  final void Function(Map<String, String> data)? onSubmit;

  @override
  State<LoginForm> createState() => _LoginFormState();
}

class _LoginFormState extends State<LoginForm> {
  // (1) key untuk Form dan controller untuk setiap field
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _nimController = TextEditingController();

  LoginMethod _selectedMethod = LoginMethod.email;
  bool _isLoading = false;

  // (2) buang controller saat layar ditutup
  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _nimController.dispose();
    super.dispose();
  }

  void _onMethodChanged(LoginMethod method) {
    setState(() {
      _selectedMethod = method;
      _formKey.currentState?.reset();
    });
  }

  // (3) dijalankan saat tombol Masuk ditekan dengan try/finally & mounted check
  Future<void> _handleSubmit() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      final data = <String, String>{
        'method': _selectedMethod == LoginMethod.email ? 'email' : 'nim',
        'password': _passwordController.text.trim(),
      };

      if (_selectedMethod == LoginMethod.email) {
        data['email'] = _emailController.text.trim();
      } else {
        data['nim'] = _nimController.text.trim();
      }

      // Simulasi delay asinkron sebelum login
      await Future.delayed(const Duration(seconds: 1));

      if (!mounted) return;

      widget.onSubmit?.call(data);
    } finally {
      // Matikan loading di blok finally sesuai ketentuan teknis
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.xxl),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: AppRadius.largeAll,
        boxShadow: [
          BoxShadow(
            color: AppColors.textPrimary.withValues(alpha: 0.04),
            blurRadius: 16,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Form(
        key: _formKey,
        autovalidateMode: AutovalidateMode.onUserInteraction,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // ── Login Method Toggle ─────────────────────────────────────
            LoginMethodToggle(
              selected: _selectedMethod,
              onChanged: _onMethodChanged,
            ),
            const SizedBox(height: AppSpacing.xxl),

            // ── Conditional Fields ──────────────────────────────────────
            AnimatedSwitcher(
              duration: const Duration(milliseconds: 250),
              child: _selectedMethod == LoginMethod.email
                  ? AuthTextField(
                      key: const ValueKey('email'),
                      label: 'Email',
                      hintText: 'nama@student.unand.ac.id',
                      controller: _emailController,
                      keyboardType: TextInputType.emailAddress,
                      validator: Validators.studentEmail,
                      prefixIcon: Icons.email_outlined,
                    )
                  : AuthTextField(
                      key: const ValueKey('nim'),
                      label: 'NIM',
                      hintText: 'Masukkan NIM Anda',
                      controller: _nimController,
                      keyboardType: TextInputType.number,
                      validator: Validators.nim,
                      prefixIcon: Icons.badge_outlined,
                    ),
            ),
            const SizedBox(height: AppSpacing.lg),

            // ── Password Field ──────────────────────────────────────────
            AuthTextField(
              label: 'Password',
              hintText: 'Masukkan password',
              controller: _passwordController,
              isPassword: true,
              textInputAction: TextInputAction.done,
              validator: Validators.password,
              prefixIcon: Icons.lock_outline_rounded,
            ),
            const SizedBox(height: AppSpacing.xxl),

            // ── Submit Button ───────────────────────────────────────────
            SizedBox(
              height: 52,
              child: ElevatedButton(
                onPressed: _isLoading ? null : _handleSubmit,
                child: _isLoading
                    ? const SizedBox(
                        width: 24,
                        height: 24,
                        child: CircularProgressIndicator(
                          strokeWidth: 2.5,
                          valueColor: AlwaysStoppedAnimation<Color>(
                            AppColors.onPrimary,
                          ),
                        ),
                      )
                    : const Text('Masuk'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
