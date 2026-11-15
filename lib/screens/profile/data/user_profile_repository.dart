import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;

import '../../../config/app_config.dart';
import '../../../services/auth_session_service.dart';
import '../models/user_profile_model.dart';

/// Singleton repository untuk mengelola state profil pengguna dan log aktivitas pribadi.
class UserProfileRepository extends ChangeNotifier {
  UserProfileRepository._() {
    _profile = const UserProfileModel(
      userId: '',
      email: '',
      username: '',
      nama: 'Pengguna KILAS',
      bio: 'Mahasiswa aktif Universitas Andalas.',
      fotoProfil: null,
      pengingatAktif: true,
      fakultas: null,
      jurusan: null,
    );

    _activities = [
      ActivityLogItem(
        id: 'act-1',
        actionType: ActivityActionType.buatLaporan,
        title: 'Menerbitkan Laporan',
        description: 'AC Ruang Kuliah GKB C 204 bocor & tidak dingin',
        timestamp: DateTime.now().subtract(const Duration(minutes: 15)),
        reportId: 'post-1',
      ),
      ActivityLogItem(
        id: 'act-2',
        actionType: ActivityActionType.upvote,
        title: 'Memberikan Upvote',
        description: 'Upvote pada laporan Bundaran PKM UNAND',
        timestamp: DateTime.now().subtract(const Duration(hours: 2)),
        reportId: 'post-2',
      ),
      ActivityLogItem(
        id: 'act-3',
        actionType: ActivityActionType.bookmark,
        title: 'Menyimpan ke Bookmark',
        description: 'Menyimpan laporan Jadwal Pemadaman Listrik Gedung FTI',
        timestamp: DateTime.now().subtract(const Duration(hours: 5)),
        reportId: 'post-6',
      ),
      ActivityLogItem(
        id: 'act-4',
        actionType: ActivityActionType.ubahLaporan,
        title: 'Memperbarui Laporan',
        description: 'Menambahkan keterangan detail pada laporan fasilitas parkir',
        timestamp: DateTime.now().subtract(const Duration(days: 1)),
        reportId: 'post-1',
      ),
      ActivityLogItem(
        id: 'act-5',
        actionType: ActivityActionType.upvote,
        title: 'Memberikan Upvote',
        description: 'Upvote pada laporan Pipa Air Toilet Bocor Gedung C',
        timestamp: DateTime.now().subtract(const Duration(days: 2)),
        reportId: 'post-4',
      ),
    ];

    // Inisialisasi otomatis jika ada sesi aktif
    initFromSession();
  }

  static final UserProfileRepository _instance = UserProfileRepository._();
  static UserProfileRepository get instance => _instance;

  late UserProfileModel _profile;
  late List<ActivityLogItem> _activities;

  UserProfileModel get profile => _profile;
  UserProfileModel get currentUser => _profile;
  List<ActivityLogItem> get activities => List.unmodifiable(_activities);

  /// Mengatur data profil pengguna (misalnya setelah login / register).
  void setProfile(UserProfileModel model) {
    _profile = model;
    notifyListeners();
  }

  /// Memulihkan profil pengguna dari penyimpanan sesi lokal dan memvalidasi ke backend.
  Future<void> initFromSession() async {
    final savedData = await AuthSessionService.getSavedUser();
    if (savedData != null) {
      _profile = UserProfileModel.fromMap(savedData);
      notifyListeners();
    }
    await fetchProfileFromBackend();
  }

  /// Memuat profil pengguna saat ini dari backend /api/auth/me jika ada token aktif.
  Future<void> fetchProfileFromBackend() async {
    try {
      final token = await AuthSessionService.getToken();
      if (token == null || token.isEmpty) return;

      final uri = Uri.parse('${AppConfig.baseUrl}/api/auth/me');
      final response = await http.get(
        uri,
        headers: {
          'Accept': 'application/json',
          'Authorization': 'Bearer $token',
        },
      ).timeout(AppConfig.requestTimeout);

      if (response.statusCode >= 200 && response.statusCode < 300) {
        final body = jsonDecode(response.body) as Map<String, dynamic>;
        final data = body['data'];
        if (data is Map<String, dynamic>) {
          final userJson = data['user'] is Map<String, dynamic>
              ? data['user'] as Map<String, dynamic>
              : data;
          _profile = UserProfileModel.fromMap(userJson);
          await AuthSessionService.saveSession(
            identifier: _profile.email,
            userData: userJson,
          );
          notifyListeners();
        }
      }
    } catch (_) {
      // Abaikan jika offline / koneksi timeout
    }
  }


  /// Mengubah data profil pengguna (FR-03).
  void updateProfile({
    String? nama,
    String? username,
    String? bio,
    String? fakultas,
    String? jurusan,
    String? fotoProfil,
  }) {
    _profile = _profile.copyWith(
      nama: nama,
      username: username,
      bio: bio,
      fakultas: fakultas,
      jurusan: jurusan,
      fotoProfil: fotoProfil,
    );
    notifyListeners();
  }

  /// Mengaktifkan / mematikan saklar pengingat harian (FR-18 / FR-B7).
  void togglePengingatHarian(bool value) {
    _profile = _profile.copyWith(pengingatAktif: value);
    notifyListeners();
  }

  /// Menambahkan riwayat aktivitas baru (FR-24 & FR-C6).
  void addActivity({
    required ActivityActionType actionType,
    required String title,
    required String description,
    String? reportId,
  }) {
    _activities.insert(
      0,
      ActivityLogItem(
        id: 'act-${DateTime.now().millisecondsSinceEpoch}',
        actionType: actionType,
        title: title,
        description: description,
        timestamp: DateTime.now(),
        reportId: reportId,
      ),
    );
    notifyListeners();
  }

  /// Menghapus seluruh riwayat aktivitas pribadi (FR-C6).
  void clearActivities() {
    _activities.clear();
    notifyListeners();
  }

  /// Menghapus satu item riwayat aktivitas pribadi (FR-C6).
  void removeActivity(String id) {
    _activities.removeWhere((item) => item.id == id);
    notifyListeners();
  }

  /// Mengambil data profil pengguna secara asinkron dari API backend.
  Future<UserProfileModel> fetchProfile() async {
    // Slot untuk memanggil endpoint: GET /api/user/profile
    return _profile;
  }

  /// Sinkronisasi pembaharuan profil ke backend server.
  Future<bool> syncProfile(UserProfileModel updated) async {
    setProfile(updated);
    // Slot untuk memanggil endpoint: PUT /api/user/profile
    return true;
  }
}
