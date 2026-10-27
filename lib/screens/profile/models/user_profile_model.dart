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
}
