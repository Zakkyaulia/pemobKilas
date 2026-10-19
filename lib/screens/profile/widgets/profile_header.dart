import 'dart:io';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';

import '../../../theme/app_palette.dart';
import '../../../theme/app_spacing.dart';
import '../../../theme/home_colors.dart';
import '../../../theme/home_text_styles.dart';
import '../data/user_profile_repository.dart';
import '../models/user_profile_model.dart';
import 'edit_profile_dialog.dart';
import 'qr_profile_sheet.dart';

/// Bagian header informasi profil pengguna.
///
/// Menampilkan: Foto profil (bisa diubah dari galeri dengan dialog izin privasi),
/// Nama lengkap, Username, Program Studi/Fakultas, Bio, serta dua tombol aksi
/// utama: [Edit Profil] dan [QR Profil].
class ProfileHeader extends StatelessWidget {
  const ProfileHeader({
    super.key,
    required this.user,
  });

  final UserProfileModel user;

  Future<void> _handleChangePhoto(BuildContext context) async {
    // 1. Tampilkan Dialog Izin Akses & Privasi (konsisten dengan halaman upload laporan)
    final accepted = await showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (ctx) {
        return AlertDialog(
          backgroundColor: AppPalette.surface(context),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          titlePadding: const EdgeInsets.fromLTRB(20, 20, 20, 12),
          contentPadding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
          actionsPadding: const EdgeInsets.fromLTRB(20, 0, 20, 16),
          title: Row(
            children: [
              Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  color: HomeColors.primaryContainer.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(
                  Icons.security_rounded,
                  color: HomeColors.primaryContainer,
                  size: 20,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  'Izin Akses & Privasi',
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    color: AppPalette.textPrimary(context),
                    height: 1.2,
                  ),
                ),
              ),
            ],
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 4),
              Text(
                'Aplikasi KILAS memerlukan izin untuk mengakses Galeri perangkat Anda guna memilih foto profil identitas mahasiswa.',
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 13,
                  color: AppPalette.textSecondary(context),
                  height: 1.4,
                ),
              ),
              const SizedBox(height: 14),
              _buildPolicyItem(
                context: context,
                icon: Icons.shield_outlined,
                title: 'Kerahasiaan & Keamanan',
                subtitle:
                    'Foto profil disimpan secara aman pada perangkat dan hanya digunakan untuk identitas akun pelaporan kampus Anda.',
              ),
              const SizedBox(height: 10),
              _buildPolicyItem(
                context: context,
                icon: Icons.gavel_outlined,
                title: 'Ketentuan & Etika Konten',
                subtitle:
                    'Dilarang menggunakan foto yang melanggar norma kesusilaan, hak cipta, atau mencemarkan nama baik institusi.',
              ),
            ],
          ),
          actions: [
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    style: OutlinedButton.styleFrom(
                      side: BorderSide(color: AppPalette.divider(context)),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                      padding: const EdgeInsets.symmetric(vertical: 12),
                    ),
                    onPressed: () => Navigator.pop(ctx, false),
                    child: Text(
                      'Tolak',
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: AppPalette.textSecondary(context),
                        height: 1.1,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: HomeColors.primaryContainer,
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                      padding: const EdgeInsets.symmetric(vertical: 12),
                    ),
                    onPressed: () => Navigator.pop(ctx, true),
                    child: Text(
                      'Setuju & Izinkan',
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 13,
                        fontWeight: FontWeight.w700,
                        color: Colors.white,
                        height: 1.1,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        );
      },
    );

    if (accepted != true) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Akses galeri dibatalkan karena izin belum disetujui.',
              style: HomeTextStyles.labelMd.copyWith(color: Colors.white),
            ),
            backgroundColor: const Color(0xFF334155),
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
      return;
    }

    // 2. Buka Galeri foto via image_picker
    try {
      final picker = ImagePicker();
      final picked = await picker.pickImage(
        source: ImageSource.gallery,
        maxWidth: 1080,
        maxHeight: 1080,
        imageQuality: 85,
      );

      if (picked != null) {
        UserProfileRepository.instance.updateProfile(
          fotoProfil: picked.path,
        );

        UserProfileRepository.instance.addActivity(
          actionType: ActivityActionType.ubahLaporan,
          title: 'Memperbarui Foto Profil',
          description: 'Foto profil mahasiswa berhasil diperbarui dari galeri',
        );

        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Row(
                children: [
                  const Icon(Icons.check_circle, color: Colors.white, size: 20),
                  const SizedBox(width: 8),
                  Text(
                    'Foto profil berhasil diperbarui!',
                    style: HomeTextStyles.labelMd.copyWith(color: Colors.white),
                  ),
                ],
              ),
              backgroundColor: HomeColors.primaryContainer,
              behavior: SnackBarBehavior.floating,
            ),
          );
        }
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Gagal memilih foto: $e',
              style: HomeTextStyles.labelMd.copyWith(color: Colors.white),
            ),
            backgroundColor: const Color(0xFFEF4444),
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    }
  }

  Widget _buildPolicyItem({
    required BuildContext context,
    required IconData icon,
    required String title,
    required String subtitle,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(
          icon,
          size: 18,
          color: HomeColors.primaryContainer,
        ),
        const SizedBox(width: 10),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 12.5,
                  fontWeight: FontWeight.w700,
                  color: AppPalette.textPrimary(context),
                  height: 1.2,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                subtitle,
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 11.5,
                  color: AppPalette.textSecondary(context),
                  height: 1.35,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = AppPalette.isDark(context);

    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.lg,
        vertical: AppSpacing.lg,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Avatar interaktif (bisa ditekan untuk ganti foto dari galeri)
              GestureDetector(
                onTap: () => _handleChangePhoto(context),
                child: Stack(
                  children: [
                    Container(
                      width: 80,
                      height: 80,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: HomeColors.primaryContainer,
                          width: 2.5,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: HomeColors.primaryContainer.withValues(alpha: 0.18),
                            blurRadius: 10,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: ClipOval(
                        child: user.fotoProfil != null && user.fotoProfil!.isNotEmpty
                            ? _buildAvatarImage(user.fotoProfil!, context)
                            : _buildInitialsAvatar(context),
                      ),
                    ),
                    // Badge ikon kamera kecil di pojok kanan bawah avatar
                    Positioned(
                      bottom: 0,
                      right: 0,
                      child: Container(
                        width: 26,
                        height: 26,
                        decoration: BoxDecoration(
                          color: HomeColors.primaryContainer,
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: isDark ? const Color(0xFF0F172A) : Colors.white,
                            width: 2,
                          ),
                          boxShadow: const [
                            BoxShadow(
                              color: Colors.black26,
                              blurRadius: 4,
                            ),
                          ],
                        ),
                        alignment: Alignment.center,
                        child: const Icon(
                          Icons.camera_alt_rounded,
                          size: 13,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: AppSpacing.lg),
              // Nama, username, jurusan, bio
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      user.nama,
                      style: HomeTextStyles.headlineSm.copyWith(
                        fontWeight: FontWeight.w700,
                        color: AppPalette.textPrimary(context),
                        height: 1.2,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: AppSpacing.xs),
                    Row(
                      children: [
                        Text(
                          user.username,
                          style: HomeTextStyles.labelMd.copyWith(
                            color: isDark
                                ? const Color(0xFF60A5FA)
                                : HomeColors.primaryContainer,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 6),
                          child: Text(
                            '•',
                            style: HomeTextStyles.bodySm.copyWith(
                              color: AppPalette.textSecondary(context),
                            ),
                          ),
                        ),
                        Flexible(
                          child: Text(
                            user.userId.replaceAll('usr-', ''),
                            style: HomeTextStyles.bodySm.copyWith(
                              color: AppPalette.textSecondary(context),
                              fontWeight: FontWeight.w500,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: AppSpacing.xs),
                    Text(
                      '${user.jurusan} 🎓',
                      style: HomeTextStyles.labelSm.copyWith(
                        color: AppPalette.textSecondary(context),
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      user.bio,
                      style: HomeTextStyles.bodySm.copyWith(
                        color: AppPalette.textSecondary(context),
                        height: 1.35,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.lg),
          // Tombol aksi Edit Profil & QR Profil (diperbaiki agar teks tidak tenggelam)
          Row(
            children: [
              Expanded(
                child: SizedBox(
                  height: 42,
                  child: OutlinedButton.icon(
                    style: OutlinedButton.styleFrom(
                      backgroundColor: isDark
                          ? const Color(0xFF13203A)
                          : const Color(0xFFF1F5F9),
                      side: BorderSide(
                        color: isDark
                            ? const Color(0xFF1E2D4A)
                            : const Color(0xFFE2E8F0),
                        width: 1.2,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                      padding: const EdgeInsets.symmetric(horizontal: 10),
                      alignment: Alignment.center,
                    ),
                    onPressed: () => EditProfileDialog.show(context),
                    icon: Icon(
                      Icons.edit_outlined,
                      size: 16,
                      color: isDark
                          ? const Color(0xFF60A5FA)
                          : HomeColors.primaryContainer,
                    ),
                    label: Text(
                      'Edit Profil',
                      style: HomeTextStyles.labelMd.copyWith(
                        color: AppPalette.textPrimary(context),
                        fontWeight: FontWeight.w600,
                        height: 1.0,
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: SizedBox(
                  height: 42,
                  child: ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: HomeColors.primaryContainer,
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                      padding: const EdgeInsets.symmetric(horizontal: 10),
                      alignment: Alignment.center,
                    ),
                    onPressed: () => QrProfileSheet.show(context),
                    icon: const Icon(
                      Icons.qr_code_2_rounded,
                      size: 17,
                      color: Colors.white,
                    ),
                    label: Text(
                      'QR Profil',
                      style: HomeTextStyles.labelMd.copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.w600,
                        height: 1.0,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildAvatarImage(String pathOrUrl, BuildContext context) {
    if (pathOrUrl.startsWith('http://') || pathOrUrl.startsWith('https://')) {
      return Image.network(
        pathOrUrl,
        fit: BoxFit.cover,
        errorBuilder: (_, _, _) => _buildInitialsAvatar(context),
      );
    }
    if (pathOrUrl.startsWith('assets/')) {
      return Image.asset(
        pathOrUrl,
        fit: BoxFit.cover,
        errorBuilder: (_, _, _) => _buildInitialsAvatar(context),
      );
    }
    return Image.file(
      File(pathOrUrl),
      fit: BoxFit.cover,
      errorBuilder: (_, _, _) => _buildInitialsAvatar(context),
    );
  }

  Widget _buildInitialsAvatar(BuildContext context) {
    final initials = user.nama.isNotEmpty
        ? user.nama
            .trim()
            .split(' ')
            .map((w) => w.isNotEmpty ? w[0] : '')
            .take(2)
            .join()
        : 'GH';
    return Container(
      color: const Color(0xFFDCE9FF),
      alignment: Alignment.center,
      child: Text(
        initials.toUpperCase(),
        style: HomeTextStyles.headlineMd.copyWith(
          fontWeight: FontWeight.w800,
          color: HomeColors.primaryContainer,
        ),
      ),
    );
  }
}
