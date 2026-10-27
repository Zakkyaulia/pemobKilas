import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Controller state global untuk mengelola tema aplikasi (Light & Dark Mode)
/// dengan persistensi lokal via SharedPreferences.
abstract final class AppThemeController {
  static const String _prefKey = 'kilas_dark_mode';

  /// Notifier tema yang didengarkan oleh MaterialApp.
  static final ValueNotifier<ThemeMode> themeMode =
      ValueNotifier<ThemeMode>(ThemeMode.light);

  /// Status apakah saat ini aktif dark mode.
  static bool get isDark => themeMode.value == ThemeMode.dark;

  /// Memuat preferensi tema yang tersimpan di SharedPreferences saat aplikasi pertama dibuka.
  static Future<void> init() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final isDarkSaved = prefs.getBool(_prefKey) ?? false;
      themeMode.value = isDarkSaved ? ThemeMode.dark : ThemeMode.light;
    } catch (_) {
      // Default tetap light jika gagal membaca storage
    }
  }

  /// Toggle antara mode terang dan mode gelap secara instan serta menyimpannya permanen.
  static Future<void> toggle() async {
    final nextIsDark = themeMode.value != ThemeMode.dark;
    themeMode.value = nextIsDark ? ThemeMode.dark : ThemeMode.light;
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool(_prefKey, nextIsDark);
    } catch (_) {
      // Abaikan error jika storage tidak tersedia
    }
  }
}
