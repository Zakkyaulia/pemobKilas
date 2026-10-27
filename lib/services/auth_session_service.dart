import 'package:shared_preferences/shared_preferences.dart';

/// Service untuk mengelola status sesi login pengguna menggunakan [SharedPreferences].
///
/// Menyediakan fitur "Keep Me Logged In" sehingga pengguna tidak perlu login
/// ulang setiap kali aplikasi dibuka.
abstract final class AuthSessionService {
  static const String _keyIsLoggedIn = 'kilas_is_logged_in';
  static const String _keyUserIdentifier = 'kilas_user_identifier';
  static const String _keyAuthToken = 'kilas_auth_token';

  /// Memeriksa apakah saat ini ada sesi pengguna aktif.
  static Future<bool> isLoggedIn() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      return prefs.getBool(_keyIsLoggedIn) ?? false;
    } catch (_) {
      return false;
    }
  }

  /// Menyimpan sesi login ke penyimpanan lokal perangkat.
  static Future<void> saveSession({
    required String identifier,
    String? token,
  }) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool(_keyIsLoggedIn, true);
      await prefs.setString(_keyUserIdentifier, identifier);
      if (token != null) {
        await prefs.setString(_keyAuthToken, token);
      }
    } catch (_) {
      // Abaikan jika storage gagal
    }
  }

  /// Menghapus sesi login saat pengguna logout.
  static Future<void> clearSession() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool(_keyIsLoggedIn, false);
      await prefs.remove(_keyUserIdentifier);
      await prefs.remove(_keyAuthToken);
    } catch (_) {
      // Abaikan jika storage gagal
    }
  }

  /// Mengambil data identitas pengguna yang tersimpan di sesi.
  static Future<String?> getSavedIdentifier() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      return prefs.getString(_keyUserIdentifier);
    } catch (_) {
      return null;
    }
  }
}
