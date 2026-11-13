import 'dart:convert';
import 'package:http/http.dart' as http;

import '../config/app_config.dart';
import '../models/auth_result.dart';

/// Exception yang dilempar saat request auth gagal.
///
/// [message] berisi pesan yang aman untuk ditampilkan langsung ke pengguna.
class AuthException implements Exception {
  final String message;
  const AuthException(this.message);

  @override
  String toString() => message;
}

/// Service layer HTTP untuk endpoint autentikasi (`/api/auth`).
///
/// Semua komunikasi dengan backend terpusat di sini.
/// Screen dan widget tidak boleh langsung menggunakan [http].
abstract final class AuthApiService {
  static Uri get _loginUrl => Uri.parse('${AppConfig.baseUrl}/api/auth/login');
  static Uri get _registerUrl =>
      Uri.parse('${AppConfig.baseUrl}/api/auth/register');

  static const Map<String, String> _jsonHeaders = {
    'Content-Type': 'application/json',
    'Accept': 'application/json',
  };

  // ── Helpers ──────────────────────────────────────────────────────────────

  /// Parse body JSON dan lempar [AuthException] jika response bukan 2xx.
  static AuthResult _handleResponse(http.Response response) {
    final Map<String, dynamic> body;
    try {
      body = jsonDecode(response.body) as Map<String, dynamic>;
    } catch (_) {
      throw const AuthException('Respons server tidak valid. Coba lagi.');
    }

    if (response.statusCode >= 200 && response.statusCode < 300) {
      // Sukses: { success: true, data: { token, user } }
      final data = body['data'] as Map<String, dynamic>?;
      if (data == null) {
        throw const AuthException('Respons server tidak lengkap. Coba lagi.');
      }
      return AuthResult.fromJson(data);
    }

    // Gagal: { success: false, error: { code, message, details } }
    final error = body['error'] as Map<String, dynamic>?;
    final message = error?['message'] as String? ?? _defaultMessage(response.statusCode);

    // Untuk error validasi (422), gabungkan detail field jika ada
    if (response.statusCode == 422) {
      final details = error?['details'];
      if (details is List && details.isNotEmpty) {
        final firstDetail = details.first;
        if (firstDetail is Map && firstDetail['message'] != null) {
          throw AuthException(firstDetail['message'] as String);
        }
      }
    }

    throw AuthException(message);
  }

  static String _defaultMessage(int statusCode) {
    return switch (statusCode) {
      400 => 'Data yang dikirim tidak valid.',
      401 => 'Email atau password salah.',
      409 => 'Email atau username sudah terdaftar.',
      422 => 'Data yang dikirim tidak sesuai format.',
      500 => 'Terjadi kesalahan pada server. Coba lagi nanti.',
      _ => 'Terjadi kesalahan (kode $statusCode). Coba lagi.',
    };
  }

  // ── Public API ────────────────────────────────────────────────────────────

  /// Login dengan [email] dan [password].
  ///
  /// Mengembalikan [AuthResult] berisi token JWT dan data user.
  /// Melempar [AuthException] jika login gagal.
  static Future<AuthResult> login({
    required String email,
    required String password,
  }) async {
    try {
      final response = await http
          .post(
            _loginUrl,
            headers: _jsonHeaders,
            body: jsonEncode({'email': email, 'password': password}),
          )
          .timeout(
            AppConfig.requestTimeout,
            onTimeout: () => throw const AuthException(
              'Koneksi ke server timeout. Periksa koneksi internet kamu.',
            ),
          );
      return _handleResponse(response);
    } on AuthException {
      rethrow;
    } catch (_) {
      throw const AuthException(
        'Tidak dapat terhubung ke server. Pastikan kamu terhubung ke jaringan.',
      );
    }
  }

  /// Registrasi akun baru.
  ///
  /// Mengembalikan [AuthResult] berisi token JWT dan data user (auto-login).
  /// Melempar [AuthException] jika registrasi gagal.
  static Future<AuthResult> register({
    required String nama,
    required String username,
    required String email,
    required String password,
  }) async {
    try {
      final response = await http
          .post(
            _registerUrl,
            headers: _jsonHeaders,
            body: jsonEncode({
              'nama': nama,
              'username': username,
              'email': email,
              'password': password,
            }),
          )
          .timeout(
            AppConfig.requestTimeout,
            onTimeout: () => throw const AuthException(
              'Koneksi ke server timeout. Periksa koneksi internet kamu.',
            ),
          );
      return _handleResponse(response);
    } on AuthException {
      rethrow;
    } catch (_) {
      throw const AuthException(
        'Tidak dapat terhubung ke server. Pastikan kamu terhubung ke jaringan.',
      );
    }
  }
}

