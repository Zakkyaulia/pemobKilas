import 'package:flutter/material.dart';

import '../../models/auth_result.dart';
import '../../services/auth_api_service.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_palette.dart';
import '../../theme/app_radius.dart';
import '../../theme/app_spacing.dart';
import 'auth_text_field.dart';

/// Form registrasi akun civitas UNAND: Nama, Username, Email, dan Password.
class RegisterForm extends StatefulWidget {
  const RegisterForm({super.key, this.onSubmit});

  /// Called when registrasi berhasil. Menerima [AuthResult] dari backend.
  final void Function(AuthResult result)? onSubmit;

  @override
  State<RegisterForm> createState() => _RegisterFormState();
}

class _RegisterFormState extends State<RegisterForm> {
  final _formKey = GlobalKey<FormState>();
  final _namaController = TextEditingController();
  final _emailController = TextEditingController();
  final _usernameController = TextEditingController();
  final _passwordController = TextEditingController();

  bool _isLoading = false;
  String? _errorMessage; // pesan error inline dari API

  @override
  void dispose() {
    _namaController.dispose();
    _emailController.dispose();
    _usernameController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _handleSubmit() async {
    // Reset error sebelumnya
    if (_errorMessage != null) setState(() => _errorMessage = null);
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      final result = await AuthApiService.register(
        nama: _namaController.text.trim(),
        username: _usernameController.text.trim().replaceFirst('@', '').toLowerCase(),
        email: _emailController.text.trim(),
        password: _passwordController.text.trim(),
      );

      if (mounted) {
        setState(() => _isLoading = false);
        widget.onSubmit?.call(result);
      }
    } on AuthException catch (e) {
      if (mounted) {
        setState(() {
          _isLoading = false;
          _errorMessage = e.message;
        });
      }
    }
  }

  String? _validateEmail(String? value) {
    if (value == null || value.trim().isEmpty) return 'Email tidak boleh kosong';
    if (!RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$').hasMatch(value.trim())) {
      return 'Format email tidak valid (harus mengandung "@")';
    }
    return null;
  }

  String? _validateNama(String? value) {
    final v = value?.trim() ?? '';
    if (v.isEmpty) return 'Nama tidak boleh kosong';
    if (v.length < 2) return 'Nama minimal 2 karakter';
    if (v.length > 100) return 'Nama maksimal 100 karakter';
    return null;
  }

  /// Sama dengan aturan backend: 3–30 karakter, huruf/angka/titik/garis bawah.
  String? _validateUsername(String? value) {
    final v = (value ?? '').trim().replaceFirst('@', '');
    if (v.isEmpty) return 'Username tidak boleh kosong';
    if (!RegExp(r'^[a-zA-Z0-9_.]{3,30}$').hasMatch(v)) {
      return 'Username 3–30 karakter: huruf, angka, titik, atau garis bawah';
    }
    return null;
  }

  String? _validatePassword(String? value) {
    if (value == null || value.trim().isEmpty) return 'Password tidak boleh kosong';
    if (value.trim().length < 8) return 'Password minimal 8 karakter';
    return null;
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.xxl),
      decoration: BoxDecoration(
        color: AppPalette.surface(context),
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
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            AuthTextField(
              label: 'Nama',
              hintText: 'Masukkan nama lengkap',
              controller: _namaController,
              keyboardType: TextInputType.name,
              validator: _validateNama,
              prefixIcon: Icons.badge_outlined,
            ),
            const SizedBox(height: AppSpacing.lg),

            AuthTextField(
              label: 'Username',
              hintText: 'Masukkan username',
              controller: _usernameController,
              validator: _validateUsername,
              prefixIcon: Icons.alternate_email_rounded,
            ),
            const SizedBox(height: AppSpacing.lg),

            AuthTextField(
              label: 'Email',
              hintText: 'Masukkan alamat email',
              controller: _emailController,
              keyboardType: TextInputType.emailAddress,
              validator: _validateEmail,
              prefixIcon: Icons.email_outlined,
            ),
            const SizedBox(height: AppSpacing.lg),

            AuthTextField(
              label: 'Password',
              hintText: 'Buat password',
              controller: _passwordController,
              isPassword: true,
              textInputAction: TextInputAction.done,
              validator: _validatePassword,
              prefixIcon: Icons.lock_outline_rounded,
            ),
            const SizedBox(height: AppSpacing.xxl),

            // ── Error Message dari API ──────────────────────────────────
            if (_errorMessage != null) ...[
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.lg,
                  vertical: AppSpacing.md,
                ),
                decoration: BoxDecoration(
                  color: Colors.red.shade50,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.red.shade200),
                ),
                child: Row(
                  children: [
                    Icon(Icons.error_outline, color: Colors.red.shade700, size: 18),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        _errorMessage!,
                        style: TextStyle(
                          color: Colors.red.shade700,
                          fontSize: 13,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: AppSpacing.lg),
            ],

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
                    : const Text('Daftar Akun'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
