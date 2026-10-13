import 'package:flutter/material.dart';

import 'home_colors.dart';

/// Semantic palette yang memetakan warna secara dinamis berdasarkan
/// mode tema aktif (Light / Dark), mencegah warna bertabrakan atau teks hilang.
abstract final class AppPalette {
  /// Cek apakah mode gelap sedang aktif.
  static bool isDark(BuildContext context) =>
      Theme.of(context).brightness == Brightness.dark;

  /// Background kanvas dasar aplikasi.
  static Color canvas(BuildContext context) =>
      isDark(context) ? const Color(0xFF081024) : HomeColors.canvasBase;

  /// Surface card atau kontainer feed utama.
  static Color surface(BuildContext context) =>
      isDark(context) ? const Color(0xFF0F1A30) : HomeColors.surfacePure;

  /// Warna teks utama (judul, headline, nama pelapor).
  static Color textPrimary(BuildContext context) =>
      isDark(context) ? const Color(0xFFF1F5F9) : HomeColors.onSurface;

  /// Warna teks sekunder (deskripsi, timestamp, metadata).
  static Color textSecondary(BuildContext context) =>
      isDark(context) ? const Color(0xFF94A3B8) : HomeColors.onSurfaceVariant;

  /// Warna garis pembatas / divider antar-kartu.
  static Color divider(BuildContext context) =>
      isDark(context) ? const Color(0xFF1E2D4A) : HomeColors.surfaceContainer;

  /// Warna kontainer aksen lembut (inactive upvote, card inset).
  static Color surfaceSubtle(BuildContext context) =>
      isDark(context) ? const Color(0xFF162544) : HomeColors.surfaceSubtle;

  /// Warna frosted-glass untuk AppBar dan BottomNav.
  static Color glassBackground(BuildContext context) =>
      isDark(context) ? const Color(0xD90A1124) : const Color(0xD9FFFFFF);
}
