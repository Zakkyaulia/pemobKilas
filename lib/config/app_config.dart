import 'package:flutter/foundation.dart';

/// Konfigurasi global aplikasi KILAS.
abstract final class AppConfig {
  /// Base URL backend Express.
  ///
  /// Panduan Koneksi:
  /// 1. **HP Fisik via Kabel USB (Rekomendasi)**:
  ///    Jalankan perintah ini di terminal:
  ///    `adb reverse tcp:3000 tcp:3000`
  ///    Lalu gunakan `http://localhost:3000`. HP akan mengakses backend laptop via kabel.
  ///
  /// 2. **Chrome / Web / Windows**:
  ///    Otomatis menggunakan `http://localhost:3000`.
  ///
  /// 3. **Android Emulator**:
  ///    Gunakan `http://10.0.2.2:3000`.
  ///
  /// 4. **HP Fisik via Wi-Fi (Tanpa Kabel)**:
  ///    Gunakan IP lokal Wi-Fi laptop (misal: `http://10.44.34.88:3000`).
  ///    Pastikan HP dan laptop terhubung ke Wi-Fi yang sama.
  static String get baseUrl {
    // 1. Cek jika di-override via flag CLI: `flutter run --dart-define=API_URL=http://...`
    const customUrl = String.fromEnvironment('API_URL');
    if (customUrl.isNotEmpty) {
      return customUrl;
    }

    if (kIsWeb) {
      return 'http://localhost:3000';
    }

    // Default untuk HP fisik dengan `adb reverse` dan Web/Desktop.
    // Jika menggunakan Android Emulator (bukan HP fisik), ganti ke 'http://10.0.2.2:3000'.
    return 'http://localhost:3000';
  }

  /// Timeout maksimal untuk setiap request API (detik).
  static const Duration requestTimeout = Duration(seconds: 15);
}
