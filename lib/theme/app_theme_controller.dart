import 'package:flutter/material.dart';

/// Controller state global untuk mengelola tema aplikasi (Light & Dark Mode).
abstract final class AppThemeController {
  /// Notifier tema yang didengarkan oleh MaterialApp.
  static final ValueNotifier<ThemeMode> themeMode =
      ValueNotifier<ThemeMode>(ThemeMode.light);

  /// Status apakah saat ini aktif dark mode.
  static bool get isDark => themeMode.value == ThemeMode.dark;

  /// Toggle antara mode terang dan mode gelap secara instan.
  static void toggle() {
    themeMode.value =
        themeMode.value == ThemeMode.light ? ThemeMode.dark : ThemeMode.light;
  }
}
