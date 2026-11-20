import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart';

import '../config/app_config.dart';
import '../screens/home/models/report_model.dart';
import 'auth_session_service.dart';

/// Exception yang dilempar saat request API laporan gagal.
class ReportException implements Exception {
  final String message;
  const ReportException(this.message);

  @override
  String toString() => message;
}

/// Satu halaman hasil `GET /api/reports` (untuk infinite scroll).
class ReportPage {
  const ReportPage({required this.items, required this.hasMore, this.total});

  final List<ReportModel> items;

  /// Jumlah seluruh laporan yang cocok dengan filter (`total` dari server).
  final int? total;

  /// `has_more` dari server: masih ada halaman berikutnya atau tidak.
  final bool hasMore;
}

/// Service layer HTTP untuk berinteraksi dengan REST API backend KILAS (`/api/reports`).
abstract final class ReportApiService {
  static String get _baseUrl => AppConfig.baseUrl;

  /// MIME type media berdasarkan ekstensi file (sesuai yang diterima backend).
  static MediaType? _mediaTypeOf(String path) {
    final ext = path.split('.').last.toLowerCase();
    switch (ext) {
      case 'jpg':
      case 'jpeg':
        return MediaType('image', 'jpeg');
      case 'png':
        return MediaType('image', 'png');
      case 'webp':
        return MediaType('image', 'webp');
      case 'mp4':
        return MediaType('video', 'mp4');
      case 'mov':
        return MediaType('video', 'quicktime');
      default:
        return null; // biarkan backend yang menolak dengan pesan jelas
    }
  }

  static Future<Map<String, String>> _authHeaders({bool json = true}) async {
    final token = await AuthSessionService.getToken();
    final headers = <String, String>{
      'Accept': 'application/json',
    };
    if (json) {
      headers['Content-Type'] = 'application/json';
    }
    if (token != null && token.isNotEmpty) {
      headers['Authorization'] = 'Bearer $token';
    }
    return headers;
  }

  static void _checkResponse(http.Response response, Map<String, dynamic> body) {
    if (response.statusCode >= 200 && response.statusCode < 300) {
      return;
    }

    final error = body['error'] as Map<String, dynamic>?;
    final message = error?['message'] as String? ??
        _defaultErrorMessage(response.statusCode);
    throw ReportException(message);
  }

  static String _defaultErrorMessage(int statusCode) {
    return switch (statusCode) {
      400 => 'Data laporan tidak valid.',
      401 => 'Silakan masuk terlebih dahulu.',
      403 => 'Akses ditolak atau batas waktu edit telah habis.',
      404 => 'Laporan tidak ditemukan.',
      413 => 'Ukuran berkas media terlalu besar.',
      422 => 'Data laporan tidak memenuhi ketentuan kampus.',
      500 => 'Terjadi kendala pada server. Coba lagi nanti.',
      _ => 'Terjadi kesalahan (kode $statusCode).',
    };
  }

  // ── 1. Ambil Feed Laporan (GET /api/reports) ────────────────────────────────

  /// Mengambil satu halaman laporan dari backend dengan opsi filter dan sortir.
  static Future<ReportPage> getReports({
    String? category,
    String? q,
    String? sort,
    DateTime? from,
    DateTime? to,
    int page = 1,
    int limit = 20,
    String? username,
    bool? bookmarked,
  }) async {
    final params = <String, String>{
      'page': page.toString(),
      'limit': limit.toString(),
    };
    if (category != null && category.isNotEmpty) {
      params['category'] = category;
    }
    if (q != null && q.isNotEmpty) {
      params['q'] = q;
    }
    if (sort != null && sort.isNotEmpty) {
      params['sort'] = sort;
    }
    if (from != null) params['from'] = from.toUtc().toIso8601String();
    if (to != null) params['to'] = to.toUtc().toIso8601String();
    if (username != null && username.isNotEmpty) {
      params['username'] = username;
    }
    if (bookmarked == true) {
      params['bookmarked'] = 'true';
    }

    final uri = Uri.parse('$_baseUrl/api/reports').replace(queryParameters: params);
    final headers = await _authHeaders(json: false);

    try {
      final response = await http
          .get(uri, headers: headers)
          .timeout(AppConfig.requestTimeout);

      final body = jsonDecode(response.body) as Map<String, dynamic>;
      _checkResponse(response, body);

      final data = body['data'];
      final items = (data is Map && data['items'] is List)
          ? data['items'] as List
          : (data is List ? data : <dynamic>[]);

      final reports = items
          .map((item) => ReportModel.fromMap(item as Map<String, dynamic>))
          .toList();
      // Jika server tidak mengirim has_more, anggap masih ada bila halaman penuh.
      final hasMore = (data is Map && data['has_more'] is bool)
          ? data['has_more'] as bool
          : reports.length >= limit;
      final total = (data is Map && data['total'] is int) ? data['total'] as int : null;
      return ReportPage(items: reports, hasMore: hasMore, total: total);
    } on ReportException {
      rethrow;
    } catch (e) {
      throw ReportException('Tidak dapat memuat laporan dari server: $e');
    }
  }

  // ── 2. Ambil Detail Laporan (GET /api/reports/:id) ─────────────────────────

  static Future<ReportModel> getReportById(String reportId) async {
    final uri = Uri.parse('$_baseUrl/api/reports/$reportId');
    final headers = await _authHeaders(json: false);

    try {
      final response = await http
          .get(uri, headers: headers)
          .timeout(AppConfig.requestTimeout);

      final body = jsonDecode(response.body) as Map<String, dynamic>;
      _checkResponse(response, body);

      return ReportModel.fromMap(body['data'] as Map<String, dynamic>);
    } on ReportException {
      rethrow;
    } catch (e) {
      throw ReportException('Gagal memuat detail laporan: $e');
    }
  }

  // ── 3. Buat Laporan Baru Multipart (POST /api/reports) ─────────────────────

  /// FR-A1: Mengunggah laporan baru beserta bukti media foto/video.
  static Future<ReportModel> createReport({
    required String title,
    required String description,
    required String category,
    required double latitude,
    required double longitude,
    String? locationName,
    required List<String> mediaPaths,
  }) async {
    final uri = Uri.parse('$_baseUrl/api/reports');
    final token = await AuthSessionService.getToken();

    final request = http.MultipartRequest('POST', uri);
    if (token != null && token.isNotEmpty) {
      request.headers['Authorization'] = 'Bearer $token';
    }
    request.headers['Accept'] = 'application/json';

    // Tambah field teks
    request.fields['title'] = title;
    request.fields['description'] = description;
    request.fields['category'] = category;
    request.fields['latitude'] = latitude.toString();
    request.fields['longitude'] = longitude.toString();
    if (locationName != null && locationName.isNotEmpty) {
      request.fields['location_name'] = locationName;
    }

    // Tambah berkas media
    for (final path in mediaPaths) {
      if (File(path).existsSync()) {
        // Wajib kirim content type: tanpa ini http mengirim application/octet-stream
        // dan backend menolak file (Format file tidak didukung).
        request.files.add(
          await http.MultipartFile.fromPath('media', path, contentType: _mediaTypeOf(path)),
        );
      }
    }

    try {
      final streamedResponse = await request.send().timeout(const Duration(seconds: 40));
      final response = await http.Response.fromStream(streamedResponse);

      final body = jsonDecode(response.body) as Map<String, dynamic>;
      _checkResponse(response, body);

      return ReportModel.fromMap(body['data'] as Map<String, dynamic>);
    } on ReportException {
      rethrow;
    } catch (e) {
      throw ReportException('Gagal mengirim laporan ke server: $e');
    }
  }

  // ── 4. Ubah Laporan Sendiri (PUT /api/reports/:id) ─────────────────────────

  /// FR-A2: Mengedit judul, keterangan, dan kategori laporan sendiri
  /// (maksimal 24 jam). Media tidak dapat diubah, jadi request berupa JSON biasa.
  static Future<ReportModel> updateReport({
    required String reportId,
    String? title,
    String? description,
    String? category,
  }) async {
    final uri = Uri.parse('$_baseUrl/api/reports/$reportId');
    final headers = await _authHeaders();

    final payload = <String, String>{
      'title': ?title,
      'description': ?description,
      'category': ?category,
    };

    try {
      final response = await http
          .put(uri, headers: headers, body: jsonEncode(payload))
          .timeout(const Duration(seconds: 20));

      final body = jsonDecode(response.body) as Map<String, dynamic>;
      _checkResponse(response, body);

      return ReportModel.fromMap(body['data'] as Map<String, dynamic>);
    } on ReportException {
      rethrow;
    } catch (e) {
      throw ReportException('Gagal memperbarui laporan: $e');
    }
  }

  // ── 5. Hapus Laporan (DELETE /api/reports/:id) ─────────────────────────────

  /// FR-A3: Menghapus laporan sendiri dari server.
  static Future<void> deleteReport(String reportId) async {
    final uri = Uri.parse('$_baseUrl/api/reports/$reportId');
    final headers = await _authHeaders(json: false);

    try {
      final response = await http
          .delete(uri, headers: headers)
          .timeout(AppConfig.requestTimeout);

      final body = jsonDecode(response.body) as Map<String, dynamic>;
      _checkResponse(response, body);
    } on ReportException {
      rethrow;
    } catch (e) {
      throw ReportException('Gagal menghapus laporan: $e');
    }
  }

  // ── 6. Toggle Upvote (POST /api/reports/:id/upvote) ─────────────────────────

  /// FR-A5 & FR-A8: Memberikan atau menarik upvote laporan.
  static Future<({bool isUpvoted, int upvoteCount})> toggleUpvote(String reportId) async {
    final uri = Uri.parse('$_baseUrl/api/reports/$reportId/upvote');
    final headers = await _authHeaders(json: false);

    try {
      final response = await http
          .post(uri, headers: headers)
          .timeout(AppConfig.requestTimeout);

      final body = jsonDecode(response.body) as Map<String, dynamic>;
      _checkResponse(response, body);

      final data = body['data'] as Map<String, dynamic>;
      return (
        isUpvoted: data['is_upvoted'] as bool? ?? false,
        upvoteCount: (data['upvote_count'] as num?)?.toInt() ?? 0,
      );
    } on ReportException {
      rethrow;
    } catch (e) {
      throw ReportException('Gagal memperbarui upvote: $e');
    }
  }

  // ── 7. Toggle Bookmark (POST /api/reports/:id/bookmark) ───────────────────

  /// FR-A6: Menyimpan atau menghapus laporan dari bookmark.
  static Future<bool> toggleBookmark(String reportId) async {
    final uri = Uri.parse('$_baseUrl/api/reports/$reportId/bookmark');
    final headers = await _authHeaders(json: false);

    try {
      final response = await http
          .post(uri, headers: headers)
          .timeout(AppConfig.requestTimeout);

      final body = jsonDecode(response.body) as Map<String, dynamic>;
      _checkResponse(response, body);

      final data = body['data'] as Map<String, dynamic>;
      return data['is_bookmarked'] as bool? ?? false;
    } on ReportException {
      rethrow;
    } catch (e) {
      throw ReportException('Gagal memperbarui bookmark: $e');
    }
  }

  // ── 8. Ambil Koleksi Bookmark (GET /api/reports/bookmarks) ────────────────

  /// FR-A7: Mengambil koleksi bookmark pengguna untuk grid profil.
  static Future<List<ReportModel>> getBookmarks({int page = 1, int limit = 30}) async {
    final uri = Uri.parse('$_baseUrl/api/reports/bookmarks?page=$page&limit=$limit');
    final headers = await _authHeaders(json: false);

    try {
      final response = await http
          .get(uri, headers: headers)
          .timeout(AppConfig.requestTimeout);

      final body = jsonDecode(response.body) as Map<String, dynamic>;
      _checkResponse(response, body);

      final data = body['data'];
      final items = (data is Map && data['items'] is List)
          ? data['items'] as List
          : (data is List ? data : <dynamic>[]);

      return items
          .map((item) => ReportModel.fromMap(item as Map<String, dynamic>))
          .toList();
    } on ReportException {
      rethrow;
    } catch (e) {
      throw ReportException('Gagal memuat koleksi bookmark: $e');
    }
  }
}
