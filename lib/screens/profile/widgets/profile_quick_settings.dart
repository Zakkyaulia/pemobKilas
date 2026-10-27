import 'package:flutter/material.dart';

import '../../../theme/app_palette.dart';
import '../../../theme/app_spacing.dart';
import '../../../theme/app_theme_controller.dart';
import '../../../theme/home_colors.dart';
import '../../../services/auth_session_service.dart';
import '../../../theme/home_text_styles.dart';
import '../../auth/login_screen.dart';
import '../data/user_profile_repository.dart';

/// Bagian Pengaturan & Fitur Cepat pada Profil (FR-18, FR-23, FR-02).
///
/// Fitur:
/// - Pengingat Laporan Harian (Switch FR-18 / FR-B7).
/// - Goyang HP untuk Buka Draft (Switch & Shortcut FR-23 / FR-C5).
/// - Tampilan Mode Gelap / Terang (AppThemeController).
/// - Tombol Keluar dari Akun KILAS dengan Dialog Konfirmasi (FR-02).
class ProfileQuickSettings extends StatelessWidget {
  const ProfileQuickSettings({super.key});

  void _confirmLogout(BuildContext context) {
    showDialog<void>(
      context: context,
      builder: (dialogCtx) {
        return AlertDialog(
          backgroundColor: AppPalette.surface(context),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
          title: Text(
            'Keluar dari Akun KILAS?',
            style: HomeTextStyles.headlineSm.copyWith(
              fontWeight: FontWeight.w700,
              color: AppPalette.textPrimary(context),
            ),
          ),
          content: Text(
            'Sesi token login Anda akan diakhiri. Anda perlu memasukkan email dan kata sandi kembali untuk masuk.',
            style: HomeTextStyles.bodyMd.copyWith(
              color: AppPalette.textSecondary(context),
              height: 1.4,
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(dialogCtx).pop(),
              child: Text(
                'Batal',
                style: HomeTextStyles.labelMd.copyWith(
                  color: AppPalette.textSecondary(context),
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            FilledButton(
              style: FilledButton.styleFrom(
                backgroundColor: const Color(0xFFEF4444),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              onPressed: () async {
                Navigator.of(dialogCtx).pop();
                // Hapus sesi login lokal via SharedPreferences
                await AuthSessionService.clearSession();
                // Kunci kembali bookmark saat logout
                UserProfileRepository.instance.lockBookmark();

                // Navigasi ke LoginScreen & bersihkan riwayat stack
                if (!context.mounted) return;
                Navigator.of(context).pushAndRemoveUntil(
                  MaterialPageRoute(builder: (_) => const LoginScreen()),
                  (route) => false,
                );
              },
              child: Text(
                'Keluar',
                style: HomeTextStyles.labelMd.copyWith(
                  color: Colors.white,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = AppPalette.isDark(context);

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'PENGATURAN & FITUR CEPAT',
            style: HomeTextStyles.labelSm.copyWith(
              letterSpacing: 0.8,
              color: AppPalette.textSecondary(context),
            ),
          ),
          const SizedBox(height: AppSpacing.md),

          // Container Grup Pengaturan
          Container(
            decoration: BoxDecoration(
              color: AppPalette.surface(context),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: AppPalette.divider(context),
                width: 1,
              ),
            ),
            child: AnimatedBuilder(
              animation: Listenable.merge([
                UserProfileRepository.instance,
                AppThemeController.themeMode,
              ]),
              builder: (context, _) {
                final profile = UserProfileRepository.instance.profile;
                final isDarkMode = AppThemeController.isDark;

                return Column(
                  children: [
                    // 1. Pengingat Harian (FR-18)
                    ListTile(
                      leading: Container(
                        width: 38,
                        height: 38,
                        decoration: BoxDecoration(
                          color: const Color(0xFF3B82F6).withValues(alpha: 0.12),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: const Icon(
                          Icons.alarm_rounded,
                          color: Color(0xFF3B82F6),
                          size: 20,
                        ),
                      ),
                      title: Text(
                        'Pengingat Laporan Harian',
                        style: HomeTextStyles.labelLg.copyWith(
                          color: AppPalette.textPrimary(context),
                        ),
                      ),
                      subtitle: Text(
                        'Notifikasi pengingat lapor jam 16:00 WIB',
                        style: HomeTextStyles.bodySm.copyWith(
                          color: AppPalette.textSecondary(context),
                        ),
                      ),
                      trailing: Switch.adaptive(
                        value: profile.pengingatAktif,
                        activeTrackColor: HomeColors.primaryContainer,
                        onChanged: (val) {
                          UserProfileRepository.instance.togglePengingatHarian(val);
                        },
                      ),
                    ),

                    Divider(
                      height: 1,
                      indent: 64,
                      color: AppPalette.divider(context),
                    ),

                    // 2. Shake HP untuk Draft (FR-23)
                    ListTile(
                      leading: Container(
                        width: 38,
                        height: 38,
                        decoration: BoxDecoration(
                          color: const Color(0xFF8B5CF6).withValues(alpha: 0.12),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: const Icon(
                          Icons.vibration_rounded,
                          color: Color(0xFF8B5CF6),
                          size: 20,
                        ),
                      ),
                      title: Text(
                        'Goyang HP untuk Buka Draft',
                        style: HomeTextStyles.labelLg.copyWith(
                          color: AppPalette.textPrimary(context),
                        ),
                      ),
                      subtitle: Text(
                        'Deteksi guncangan accelerometer aktif',
                        style: HomeTextStyles.bodySm.copyWith(
                          color: AppPalette.textSecondary(context),
                        ),
                      ),
                      trailing: Switch.adaptive(
                        value: profile.shakeToDraftAktif,
                        activeTrackColor: const Color(0xFF8B5CF6),
                        onChanged: (val) {
                          UserProfileRepository.instance.toggleShakeToDraft(val);
                        },
                      ),
                    ),

                    Divider(
                      height: 1,
                      indent: 64,
                      color: AppPalette.divider(context),
                    ),

                    // 3. Tampilan Mode Gelap
                    ListTile(
                      leading: Container(
                        width: 38,
                        height: 38,
                        decoration: BoxDecoration(
                          color: (isDarkMode
                                  ? const Color(0xFFFBBF24)
                                  : const Color(0xFF475569))
                              .withValues(alpha: 0.12),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Icon(
                          isDarkMode
                              ? Icons.dark_mode_rounded
                              : Icons.light_mode_rounded,
                          color: isDarkMode
                              ? const Color(0xFFFBBF24)
                              : const Color(0xFF475569),
                          size: 20,
                        ),
                      ),
                      title: Text(
                        'Mode Gelap',
                        style: HomeTextStyles.labelLg.copyWith(
                          color: AppPalette.textPrimary(context),
                        ),
                      ),
                      subtitle: Text(
                        isDarkMode
                            ? 'Tema gelap nyaman di mata'
                            : 'Tema terang kontras optimal',
                        style: HomeTextStyles.bodySm.copyWith(
                          color: AppPalette.textSecondary(context),
                        ),
                      ),
                      trailing: Switch.adaptive(
                        value: isDarkMode,
                        activeTrackColor: const Color(0xFFFBBF24),
                        onChanged: (_) {
                          AppThemeController.toggle();
                        },
                      ),
                    ),
                  ],
                );
              },
            ),
          ),

          const SizedBox(height: AppSpacing.lg),

          // Tombol Keluar dari Akun KILAS (FR-02)
          SizedBox(
            width: double.infinity,
            height: 48,
            child: OutlinedButton.icon(
              style: OutlinedButton.styleFrom(
                backgroundColor: isDark
                    ? const Color(0xFF450A0A).withValues(alpha: 0.3)
                    : const Color(0xFFFEE2E2),
                side: BorderSide(
                  color: isDark
                      ? const Color(0xFF7F1D1D)
                      : const Color(0xFFFECACA),
                  width: 1,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
              ),
              icon: const Icon(
                Icons.logout_rounded,
                color: Color(0xFFEF4444),
                size: 19,
              ),
              label: Text(
                'Keluar dari Akun KILAS',
                style: HomeTextStyles.labelLg.copyWith(
                  fontWeight: FontWeight.w700,
                  color: const Color(0xFFEF4444),
                ),
              ),
              onPressed: () => _confirmLogout(context),
            ),
          ),

          const SizedBox(height: AppSpacing.lg),

          // Footer Versi Aplikasi
          Center(
            child: Text(
              'KILAS UNAND v2.0 • Limau Manis Civic Tech',
              style: HomeTextStyles.labelSm.copyWith(
                fontWeight: FontWeight.w500,
                color: AppPalette.textSecondary(context).withValues(alpha: 0.6),
              ),
            ),
          ),
          const SizedBox(height: 100), // Spasi aman untuk bottom bar
        ],
      ),
    );
  }
}
