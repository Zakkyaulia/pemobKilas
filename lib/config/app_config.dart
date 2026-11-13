import 'package:flutter/foundation.dart';

/// Konfigurasi global aplikasi KILAS.
abstract final class AppConfig {
  /// Base URL backend Express.
  ///
  /// Otomatis mendeteksi platform:
  /// - Web (Chrome/Edge): `http://localhost:3000`
  /// - Android Emulator : `http://10.0.2.2:3000`
  /// - Windows / macOS  : `http://localhost:3000`
  /// - iOS Simulator    : `http://localhost:3000`
  ///
  /// Catatan jika menggunakan HP Android fisik (via Wi-Fi/Kabel):
  /// Ganti dengan IP lokal PC (misal: `http://192.168.1.10:3000`),
  /// atau jalankan `adb reverse tcp:3000 tcp:3000` di terminal.
  static String get baseUrl {
    if (kIsWeb) {
      return 'http://localhost:3000';
    }
    switch (defaultTargetPlatform) {
      case TargetPlatform.android:
        return 'http://10.0.2.2:3000';
      case TargetPlatform.iOS:
      case TargetPlatform.windows:
      case TargetPlatform.macOS:
      case TargetPlatform.linux:
      default:
        return 'http://localhost:3000';
    }
  }

  /// Timeout maksimal untuk setiap request API (detik).
  static const Duration requestTimeout = Duration(seconds: 15);
}
