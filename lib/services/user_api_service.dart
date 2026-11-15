import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;

import '../config/app_config.dart';
import '../screens/profile/data/campus_users_data.dart';
import 'auth_session_service.dart';

/// Hasil pencarian detail user via [UserApiService.getUserByUsername].
sealed class UserLookupResult {
  const UserLookupResult();
}

class UserLookupSuccess extends UserLookupResult {
  final CampusUserItem user;
  const UserLookupSuccess(this.user);
}

class UserLookupNotFound extends UserLookupResult {
  final String username;
  const UserLookupNotFound(this.username);
}

class UserLookupNetworkError extends UserLookupResult {
  final String message;
  const UserLookupNetworkError(this.message);
}

class UserLookupError extends UserLookupResult {
  final String message;
  const UserLookupError(this.message);
}

/// Service HTTP client untuk pemanggilan API endpoint `/api/users`.
abstract final class UserApiService {
  /// Mencari pengguna berdasarkan username, nama, atau jurusan melalui backend Express.
  ///
  /// Mengembalikan list [CampusUserItem] dari database MySQL.
  /// Jika [query] kosong, mengembalikan list kosong (awal pencarian kosong).
  static Future<List<CampusUserItem>> searchUsers(String query) async {
    final cleanQuery = query.trim();
    if (cleanQuery.isEmpty) {
      return [];
    }

    try {
      final token = await AuthSessionService.getToken();
      final headers = {
        'Accept': 'application/json',
        if (token != null && token.isNotEmpty) 'Authorization': 'Bearer $token',
      };

      final uri = Uri.parse('${AppConfig.baseUrl}/api/users/search')
          .replace(queryParameters: {'q': cleanQuery});

      final response = await http
          .get(uri, headers: headers)
          .timeout(AppConfig.requestTimeout);

      if (response.statusCode >= 200 && response.statusCode < 300) {
        final body = jsonDecode(response.body) as Map<String, dynamic>;
        final data = body['data'];
        if (data is List) {
          return data
              .whereType<Map<String, dynamic>>()
              .map((item) => CampusUserItem.fromJson(item))
              .toList();
        }
        return [];
      }

      return [];
    } catch (_) {
      // Jika terjadi error jaringan / server offline, kembalikan list kosong
      return [];
    }
  }

  /// Mengambil data profil publik pengguna berdasarkan username dari backend.
  ///
  /// Mengembalikan [UserLookupResult] dengan rincian sukses, tidak ditemukan, atau error jaringan.
  static Future<UserLookupResult> getUserByUsername(String username) async {
    final cleanUsername = username.replaceAll('@', '').trim();
    if (cleanUsername.isEmpty) {
      return const UserLookupError('Username tidak valid atau kosong.');
    }

    try {
      final token = await AuthSessionService.getToken();
      final headers = {
        'Accept': 'application/json',
        if (token != null && token.isNotEmpty) 'Authorization': 'Bearer $token',
      };

      final uri = Uri.parse('${AppConfig.baseUrl}/api/users/$cleanUsername');
      final response = await http
          .get(uri, headers: headers)
          .timeout(AppConfig.requestTimeout);

      if (response.statusCode >= 200 && response.statusCode < 300) {
        final body = jsonDecode(response.body) as Map<String, dynamic>;
        final data = body['data'];
        if (data is Map<String, dynamic>) {
          return UserLookupSuccess(CampusUserItem.fromJson(data));
        }
      }

      if (response.statusCode == 404) {
        return UserLookupNotFound(cleanUsername);
      }

      return UserLookupError('Server mengembalikan kode status ${response.statusCode}.');
    } on SocketException {
      return const UserLookupNetworkError(
        'Tidak dapat terhubung ke server backend (port 3000). Pastikan backend aktif dan adb reverse berjalan.',
      );
    } on TimeoutException {
      return const UserLookupNetworkError('Waktu tunggu koneksi ke server habis (timeout).');
    } catch (e) {
      return UserLookupNetworkError('Gagal menghubungi server: $e');
    }
  }
}

