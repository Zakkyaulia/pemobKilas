import 'package:flutter/material.dart';

import '../../../theme/app_colors.dart';
import '../../../theme/app_palette.dart';
import '../../../theme/app_spacing.dart';
import '../../../theme/home_colors.dart';
import '../../../theme/home_text_styles.dart';
import '../data/user_profile_repository.dart';

/// Modal dialog untuk mengubah informasi profil pengguna (FR-03).
///
/// Pengguna dapat memperbarui nama, username, bio, serta fakultas & jurusan (opsional).
class EditProfileDialog extends StatefulWidget {
  const EditProfileDialog({super.key});

  static Future<void> show(BuildContext context) {
    return showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => const EditProfileDialog(),
    );
  }

  @override
  State<EditProfileDialog> createState() => _EditProfileDialogState();
}

class _EditProfileDialogState extends State<EditProfileDialog> {
  late final TextEditingController _namaController;
  late final TextEditingController _usernameController;
  late final TextEditingController _bioController;
  late final TextEditingController _jurusanController;
  late final TextEditingController _fakultasController;

  @override
  void initState() {
    super.initState();
    final profile = UserProfileRepository.instance.profile;
    _namaController = TextEditingController(text: profile.nama);
    _usernameController = TextEditingController(text: profile.username);
    _bioController = TextEditingController(text: profile.bio);
    _jurusanController = TextEditingController(text: profile.jurusan ?? '');
    _fakultasController = TextEditingController(text: profile.fakultas ?? '');
  }

  @override
  void dispose() {
    _namaController.dispose();
    _usernameController.dispose();
    _bioController.dispose();
    _jurusanController.dispose();
    _fakultasController.dispose();
    super.dispose();
  }

  void _saveProfile() {
    final nama = _namaController.text.trim();
    final username = _usernameController.text.trim();
    final bio = _bioController.text.trim();
    final jurusan = _jurusanController.text.trim();
    final fakultas = _fakultasController.text.trim();

    void showError(String message) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            message,
            style: HomeTextStyles.labelMd.copyWith(color: Colors.white),
          ),
          backgroundColor: AppColors.error,
        ),
      );
    }

    if (nama.isEmpty) {
      showError('Nama tidak boleh kosong.');
      return;
    }

    // Username boleh diganti (QR profil ikut username baru); aturan sama dengan register.
    final cleanUsername = username.replaceFirst('@', '');
    if (!RegExp(r'^[a-zA-Z0-9_.]{3,30}$').hasMatch(cleanUsername)) {
      showError('Username 3–30 karakter: huruf, angka, titik, atau garis bawah.');
      return;
    }

    UserProfileRepository.instance.updateProfile(
      nama: nama,
      username: '@${cleanUsername.toLowerCase()}',
      bio: bio,
      // String kosong = dikosongkan (fakultas & jurusan opsional).
      fakultas: fakultas,
      jurusan: jurusan,
    );

    Navigator.pop(context);

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.check_circle_rounded, color: Colors.white, size: 20),
            const SizedBox(width: 8),
            Text(
              'Profil berhasil diperbarui.',
              style: HomeTextStyles.labelMd.copyWith(color: Colors.white),
            ),
          ],
        ),
        backgroundColor: const Color(0xFF10B981),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = AppPalette.isDark(context);
    final bottomInset = MediaQuery.of(context).viewInsets.bottom;

    return Container(
      decoration: BoxDecoration(
        color: AppPalette.surface(context),
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
      ),
      padding: EdgeInsets.fromLTRB(
        AppSpacing.lg,
        AppSpacing.lg,
        AppSpacing.lg,
        AppSpacing.xl + bottomInset,
      ),
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: isDark ? const Color(0xFF334155) : const Color(0xFFCBD5E1),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const SizedBox(height: AppSpacing.lg),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Edit Profil',
                  style: HomeTextStyles.headlineSm.copyWith(
                    fontWeight: FontWeight.w700,
                    color: AppPalette.textPrimary(context),
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.close_rounded),
                  color: AppPalette.textSecondary(context),
                  onPressed: () => Navigator.pop(context),
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.lg),
            _buildField(
              context: context,
              label: 'Nama Lengkap',
              controller: _namaController,
              hint: 'Nama Lengkap Anda',
            ),
            const SizedBox(height: AppSpacing.md),
            _buildField(
              context: context,
              label: 'Username',
              controller: _usernameController,
              hint: '@username',
            ),
            const SizedBox(height: AppSpacing.md),
            _buildField(
              context: context,
              label: 'Fakultas (opsional)',
              controller: _fakultasController,
              hint: 'Contoh: Fakultas Teknologi Informasi',
            ),
            const SizedBox(height: AppSpacing.md),
            _buildField(
              context: context,
              label: 'Jurusan / Program Studi (opsional)',
              controller: _jurusanController,
              hint: 'Contoh: Sistem Informasi UNAND \'24',
            ),
            const SizedBox(height: AppSpacing.md),
            _buildField(
              context: context,
              label: 'Bio Singkat',
              controller: _bioController,
              hint: 'Tuliskan deskripsi singkat profil Anda...',
              maxLines: 3,
            ),
            const SizedBox(height: AppSpacing.xl),
            SizedBox(
              width: double.infinity,
              height: 48,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: HomeColors.primaryContainer,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  elevation: 0,
                ),
                onPressed: _saveProfile,
                child: Text(
                  'Simpan Perubahan',
                  style: HomeTextStyles.labelLg.copyWith(
                    fontWeight: FontWeight.w700,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildField({
    required BuildContext context,
    required String label,
    required TextEditingController controller,
    required String hint,
    int maxLines = 1,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: HomeTextStyles.labelMd.copyWith(
            fontWeight: FontWeight.w600,
            color: AppPalette.textPrimary(context),
          ),
        ),
        const SizedBox(height: 6),
        TextField(
          controller: controller,
          maxLines: maxLines,
          style: HomeTextStyles.bodyMd.copyWith(
            color: AppPalette.textPrimary(context),
          ),
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: HomeTextStyles.bodySm.copyWith(
              color: AppPalette.textSecondary(context),
            ),
            filled: true,
            fillColor: AppPalette.canvas(context),
            contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: BorderSide(color: AppPalette.divider(context)),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: const BorderSide(color: HomeColors.primaryContainer, width: 1.5),
            ),
          ),
        ),
      ],
    );
  }
}
