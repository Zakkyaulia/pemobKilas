import 'package:flutter/material.dart';

import '../../theme/app_colors.dart';
import '../../theme/app_radius.dart';
import '../../theme/app_spacing.dart';
import 'auth_text_field.dart';

class RegisterForm extends StatefulWidget {
  const RegisterForm({super.key, this.onSubmit});

  final void Function(Map<String, String> data)? onSubmit;

  @override
  State<RegisterForm> createState() => _RegisterFormState();
}

class _RegisterFormState extends State<RegisterForm> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _usernameController = TextEditingController();
  final _nimController = TextEditingController();
  final _passwordController = TextEditingController();

  bool _isLoading = false;

  @override
  void dispose() {
    _emailController.dispose();
    _usernameController.dispose();
    _nimController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _handleSubmit() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    final data = <String, String>{
      'email': _emailController.text.trim(),
      'username': _usernameController.text.trim(),
      'nim': _nimController.text.trim(),
      'password': _passwordController.text.trim(),
    };

    // Simulasi delay API
    await Future.delayed(const Duration(seconds: 1));

    if (mounted) {
      setState(() => _isLoading = false);
    }

    widget.onSubmit?.call(data);
  }

  String? _validateEmail(String? value) {
    if (value == null || value.trim().isEmpty) return 'Email tidak boleh kosong';
    if (!RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$').hasMatch(value.trim())) {
      return 'Format email tidak valid (harus mengandung "@")';
    }
    return null;
  }

  String? _validateRequired(String? value, String label) {
    if (value == null || value.trim().isEmpty) return '$label tidak boleh kosong';
    return null;
  }

  String? _validateNim(String? value) {
    if (value == null || value.trim().isEmpty) return 'NIM tidak boleh kosong';
    if (!RegExp(r'^\d+$').hasMatch(value.trim())) return 'NIM hanya boleh berisi angka';
    return null;
  }

  String? _validatePassword(String? value) {
    if (value == null || value.trim().isEmpty) return 'Password tidak boleh kosong';
    if (value.trim().length < 6) return 'Password minimal 6 karakter';
    return null;
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
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            AuthTextField(
              label: 'Username',
              hintText: 'Masukkan username',
              controller: _usernameController,
              validator: (v) => _validateRequired(v, 'Username'),
              prefixIcon: Icons.person_outline,
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
              label: 'NIM (Kelengkapan Profil)',
              hintText: 'Masukkan NIM',
              controller: _nimController,
              keyboardType: TextInputType.number,
              validator: _validateNim,
              prefixIcon: Icons.badge_outlined,
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
