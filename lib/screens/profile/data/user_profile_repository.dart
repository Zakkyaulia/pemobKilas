import 'package:flutter/foundation.dart';
import '../models/user_profile_model.dart';

/// Singleton repository untuk mengelola state profil pengguna dan log aktivitas pribadi.
class UserProfileRepository extends ChangeNotifier {
  UserProfileRepository._() {
    _profile = const UserProfileModel(
      userId: 'usr-2411522036',
      email: 'ghezy.briliantama@student.unand.ac.id',
      username: '@ghezz',
      nama: 'Ghezy Pramudinata .B',
      bio: 'Aktif melaporkan kondisi fasilitas dan situasi di lingkungan kampus Limau Manis UNAND.',
      fotoProfil:
          'https://images.unsplash.com/photo-1534528741775-53994a69daeb?auto=format&fit=crop&w=400&q=80',
      pengingatAktif: true,
      fakultas: 'Fakultas Teknologi Informasi',
      jurusan: 'Sistem Informasi UNAND \'24',
      shakeToDraftAktif: true,
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
  }

  static final UserProfileRepository _instance = UserProfileRepository._();
  static UserProfileRepository get instance => _instance;

  late UserProfileModel _profile;
  late List<ActivityLogItem> _activities;

  /// Status autentikasi biometrik/PIN lokal untuk membuka koleksi Bookmark (FR-10).
  bool _isBookmarkUnlocked = false;

  UserProfileModel get profile => _profile;
  UserProfileModel get currentUser => _profile;
  List<ActivityLogItem> get activities => List.unmodifiable(_activities);
  bool get isBookmarkUnlocked => _isBookmarkUnlocked;

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

  /// Mengaktifkan / mematikan fitur shake to open draft (FR-23 / FR-C5).
  void toggleShakeToDraft(bool value) {
    _profile = _profile.copyWith(shakeToDraftAktif: value);
    notifyListeners();
  }

  /// Membuka kunci koleksi bookmark setelah verifikasi biometrik / PIN berhasil (FR-10).
  void unlockBookmark() {
    _isBookmarkUnlocked = true;
    notifyListeners();
  }

  /// Mengunci kembali koleksi bookmark.
  void lockBookmark() {
    _isBookmarkUnlocked = false;
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
}
