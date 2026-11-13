/// Model untuk response autentikasi dari backend KILAS.
///
/// Cocok dengan shape `{ token, user }` yang dikembalikan
/// oleh endpoint `POST /api/auth/login` dan `POST /api/auth/register`.
class AuthResult {
  final String token;
  final AuthUser user;

  const AuthResult({required this.token, required this.user});

  factory AuthResult.fromJson(Map<String, dynamic> json) {
    return AuthResult(
      token: json['token'] as String,
      user: AuthUser.fromJson(json['user'] as Map<String, dynamic>),
    );
  }
}

/// Data user yang dikembalikan bersama token autentikasi.
///
/// Field sesuai `toOwnUser()` di `userMapper.js` backend.
class AuthUser {
  final String userId;
  final String email;
  final String username;
  final String nama;
  final String? bio;
  final String? fotoProfil;
  final String? fakultas;
  final String? jurusan;
  final bool pengingatAktif;

  const AuthUser({
    required this.userId,
    required this.email,
    required this.username,
    required this.nama,
    this.bio,
    this.fotoProfil,
    this.fakultas,
    this.jurusan,
    required this.pengingatAktif,
  });

  factory AuthUser.fromJson(Map<String, dynamic> json) {
    return AuthUser(
      userId: json['user_id'] as String,
      email: json['email'] as String,
      username: json['username'] as String,
      nama: json['nama'] as String,
      bio: json['bio'] as String?,
      fotoProfil: json['foto_profil'] as String?,
      fakultas: json['fakultas'] as String?,
      jurusan: json['jurusan'] as String?,
      pengingatAktif: json['pengingat_aktif'] as bool? ?? false,
    );
  }
}

