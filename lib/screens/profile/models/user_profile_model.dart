import 'package:flutter/material.dart';

/// Jenis aksi dalam riwayat aktivitas pengguna (FR-24 & FR-C6).
enum ActivityActionType {
  buatLaporan,
  ubahLaporan,
  hapusLaporan,
  upvote,
  bookmark,
}

/// Item riwayat aktivitas pribadi pengguna (FR-24 & FR-C6).
class ActivityLogItem {
  const ActivityLogItem({
    required this.id,
    required this.actionType,
    required this.title,
    required this.description,
    required this.timestamp,
    this.reportId,
  });

  final String id;
  final ActivityActionType actionType;
  final String title;
  final String description;
  final DateTime timestamp;
  final String? reportId;

  String get actionLabel {
    switch (actionType) {
      case ActivityActionType.buatLaporan:
        return 'Laporan Baru';
      case ActivityActionType.ubahLaporan:
        return 'Edit Laporan';
      case ActivityActionType.hapusLaporan:
        return 'Hapus Laporan';
      case ActivityActionType.upvote:
        return 'Upvote';
      case ActivityActionType.bookmark:
        return 'Bookmark';
    }
  }

  IconData get icon {
    switch (actionType) {
      case ActivityActionType.buatLaporan:
        return Icons.add_circle_outline_rounded;
      case ActivityActionType.ubahLaporan:
        return Icons.edit_note_rounded;
      case ActivityActionType.hapusLaporan:
        return Icons.delete_outline_rounded;
      case ActivityActionType.upvote:
        return Icons.arrow_upward_rounded;
      case ActivityActionType.bookmark:
        return Icons.bookmark_added_rounded;
    }
  }

  Color get color {
    switch (actionType) {
      case ActivityActionType.buatLaporan:
        return const Color(0xFF10B981);
      case ActivityActionType.ubahLaporan:
        return const Color(0xFF3B82F6);
      case ActivityActionType.hapusLaporan:
        return const Color(0xFFEF4444);
      case ActivityActionType.upvote:
        return const Color(0xFFF59E0B);
      case ActivityActionType.bookmark:
        return const Color(0xFF8B5CF6);
    }
  }

  /// Membuat [ActivityLogItem] dari Map / SQLite / JSON.
  factory ActivityLogItem.fromMap(Map<String, dynamic> map) {
    ActivityActionType parseAction(String? typeStr) {
      return ActivityActionType.values.firstWhere(
        (e) => e.name == typeStr,
        orElse: () => ActivityActionType.buatLaporan,
      );
    }

    return ActivityLogItem(
      id: (map['id'] ?? '').toString(),
      actionType: parseAction(map['action_type'] ?? map['actionType']),
      title: (map['title'] ?? '').toString(),
      description: (map['description'] ?? '').toString(),
      timestamp: DateTime.tryParse(map['timestamp']?.toString() ?? '') ?? DateTime.now(),
      reportId: map['report_id'] ?? map['reportId'],
    );
  }

  /// Alias [fromMap] untuk format JSON.
  factory ActivityLogItem.fromJson(Map<String, dynamic> json) => ActivityLogItem.fromMap(json);

  /// Mengonversi [ActivityLogItem] ke format Map (SQLite).
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'action_type': actionType.name,
      'title': title,
      'description': description,
      'timestamp': timestamp.toIso8601String(),
      'report_id': reportId,
    };
  }

  /// Mengonversi [ActivityLogItem] ke format JSON.
  Map<String, dynamic> toJson() => toMap();
}

/// Model profil pengguna sesuai spesifikasi PRD (Entitas User).
///
/// Atribut: user_id, email, username, nama, bio, foto_profil,
/// pengingat_aktif, fakultas, jurusan.
class UserProfileModel {
  const UserProfileModel({
    required this.userId,
    required this.email,
    required this.username,
    required this.nama,
    required this.bio,
    this.fotoProfil,
    this.pengingatAktif = true,
    this.fakultas = 'Fakultas Teknologi Informasi',
    this.jurusan = 'Sistem Informasi UNAND \'24',
    this.shakeToDraftAktif = true,
  });

  final String userId;
  final String email;
  final String username;
  final String nama;
  final String bio;
  final String? fotoProfil;
  final bool pengingatAktif;
  final String fakultas;
  final String jurusan;
  final bool shakeToDraftAktif;

  UserProfileModel copyWith({
    String? userId,
    String? email,
    String? username,
    String? nama,
    String? bio,
    String? fotoProfil,
    bool? pengingatAktif,
    String? fakultas,
    String? jurusan,
    bool? shakeToDraftAktif,
  }) {
    return UserProfileModel(
      userId: userId ?? this.userId,
      email: email ?? this.email,
      username: username ?? this.username,
      nama: nama ?? this.nama,
      bio: bio ?? this.bio,
      fotoProfil: fotoProfil ?? this.fotoProfil,
      pengingatAktif: pengingatAktif ?? this.pengingatAktif,
      fakultas: fakultas ?? this.fakultas,
      jurusan: jurusan ?? this.jurusan,
      shakeToDraftAktif: shakeToDraftAktif ?? this.shakeToDraftAktif,
    );
  }

  /// Membuat [UserProfileModel] dari Map / SQLite / API Backend.
  factory UserProfileModel.fromMap(Map<String, dynamic> map) {
    return UserProfileModel(
      userId: (map['user_id'] ?? map['userId'] ?? '').toString(),
      email: (map['email'] ?? '').toString(),
      username: (map['username'] ?? '').toString(),
      nama: (map['nama'] ?? '').toString(),
      bio: (map['bio'] ?? '').toString(),
      fotoProfil: map['foto_profil'] ?? map['fotoProfil'],
      pengingatAktif: map['pengingat_aktif'] ?? map['pengingatAktif'] ?? true,
      fakultas: (map['fakultas'] ?? 'Fakultas Teknologi Informasi').toString(),
      jurusan: (map['jurusan'] ?? 'Sistem Informasi UNAND \'24').toString(),
      shakeToDraftAktif: map['shake_to_draft_aktif'] ?? map['shakeToDraftAktif'] ?? true,
    );
  }

  /// Alias [fromMap] untuk JSON backend.
  factory UserProfileModel.fromJson(Map<String, dynamic> json) => UserProfileModel.fromMap(json);

  /// Mengonversi [UserProfileModel] ke Map (untuk SQLite / Local Storage).
  Map<String, dynamic> toMap() {
    return {
      'user_id': userId,
      'email': email,
      'username': username,
      'nama': nama,
      'bio': bio,
      'foto_profil': fotoProfil,
      'pengingat_aktif': pengingatAktif,
      'fakultas': fakultas,
      'jurusan': jurusan,
      'shake_to_draft_aktif': shakeToDraftAktif,
    };
  }

  /// Mengonversi [UserProfileModel] ke JSON untuk sinkronisasi ke API.
  Map<String, dynamic> toJson() => toMap();
}
