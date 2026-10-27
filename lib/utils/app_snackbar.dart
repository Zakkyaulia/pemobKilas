import 'package:flutter/material.dart';

import '../theme/app_spacing.dart';
import '../theme/home_colors.dart';
import '../theme/home_text_styles.dart';

/// Utility untuk menampilkan floating SnackBar yang konsisten di seluruh aplikasi KILAS.
class AppSnackbar {
  AppSnackbar._();

  /// Menampilkan SnackBar mengambang dengan icon dan teks terstandarisasi.
  static void show(
    BuildContext context, {
    required String message,
    IconData icon = Icons.check_circle_rounded,
    Color iconColor = Colors.white,
    Color backgroundColor = HomeColors.inverseSurface,
    Duration duration = const Duration(seconds: 2),
    SnackBarAction? action,
  }) {
    final messenger = ScaffoldMessenger.maybeOf(context);
    if (messenger == null) return;

    messenger
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          content: Row(
            children: [
              Icon(icon, color: iconColor, size: 20),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  message,
                  style: HomeTextStyles.labelMd.copyWith(color: Colors.white),
                ),
              ),
            ],
          ),
          backgroundColor: backgroundColor,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          margin: const EdgeInsets.all(AppSpacing.lg),
          duration: duration,
          action: action,
        ),
      );
  }

  /// Shortcut untuk pesan sukses (centang hijau / putih)
  static void showSuccess(BuildContext context, String message) {
    show(
      context,
      message: message,
      icon: Icons.check_circle_rounded,
      iconColor: Colors.white,
    );
  }

  /// Shortcut untuk pesan info / salin teks
  static void showInfo(BuildContext context, String message) {
    show(
      context,
      message: message,
      icon: Icons.info_outline_rounded,
      iconColor: Colors.white,
    );
  }

  /// Shortcut untuk pesan error / peringatan
  static void showError(BuildContext context, String message) {
    show(
      context,
      message: message,
      icon: Icons.error_outline_rounded,
      iconColor: Colors.white,
      backgroundColor: const Color(0xFFBA1A1A),
    );
  }
}
