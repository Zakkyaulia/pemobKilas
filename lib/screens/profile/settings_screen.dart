import 'dart:ui';

import 'package:flutter/material.dart';

import '../../theme/app_palette.dart';
import '../../theme/app_spacing.dart';
import '../../theme/app_theme_controller.dart';
import '../../theme/home_colors.dart';
import '../../theme/home_shadows.dart';
import '../../theme/home_text_styles.dart';
import '../../services/auth_session_service.dart';
import '../auth/login_screen.dart';
import 'data/user_profile_repository.dart';

/// Header bar height matching HomeScreen / ProfileScreen (64px).
const double _kBarHeight = 64;

/// Backdrop blur sigma matching Tailwind `backdrop-blur-xl` (24px).
const double _kBlurSigma = 24;

/// Halaman Pengaturan KILAS — berisi seluruh menu pengaturan
/// yang sebelumnya berada di laman Profil (ProfileQuickSettings).
///
/// Menu yang tersedia:
/// - Pengingat Laporan Harian (FR-18 / FR-B7)
/// - Goyang HP untuk Buka Draft (FR-23 / FR-C5)
/// - Mode Gelap / Terang
/// - Keluar dari Akun KILAS (FR-02)
///
/// Desain menggunakan frosted-glass header bar yang identik
/// dengan [HomeAppBar] dan [ProfileAppBar] untuk konsistensi visual.
class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final topPadding = MediaQuery.of(context).padding.top;
    final headerHeight = topPadding + _kBarHeight;

    return Scaffold(
      backgroundColor: AppPalette.canvas(context),
      body: Stack(
        children: [
          // ── Scrollable settings content ──────────────────────────
          SingleChildScrollView(
            physics: const BouncingScrollPhysics(),
            padding: EdgeInsets.only(
              top: headerHeight + 16,
              bottom: 40,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Grup 1: Preferensi Aplikasi
                _SectionLabel(label: 'PREFERENSI APLIKASI'),
                const SizedBox(height: AppSpacing.sm),
                _SettingsGroup(
                  children: [
                    _ReminderTile(),
                    _ShakeDraftTile(),
                    _DarkModeTile(),
                  ],
                ),

                const SizedBox(height: 24),

                // Grup 2: Tentang & Info
                _SectionLabel(label: 'TENTANG APLIKASI'),
                const SizedBox(height: AppSpacing.sm),
                _SettingsGroup(
                  children: [
                    _InfoTile(
                      icon: Icons.info_outline_rounded,
                      iconColor: const Color(0xFF06B6D4),
                      title: 'Versi Aplikasi',
                      subtitle: 'KILAS UNAND v2.0',
                    ),
                    _InfoTile(
                      icon: Icons.shield_outlined,
                      iconColor: const Color(0xFF10B981),
                      title: 'Kebijakan Privasi',
                      subtitle: 'Perlindungan data mahasiswa',
                    ),
                    _InfoTile(
                      icon: Icons.description_outlined,
                      iconColor: const Color(0xFF6366F1),
                      title: 'Syarat & Ketentuan',
                      subtitle: 'Aturan penggunaan layanan KILAS',
                    ),
                  ],
                ),

                const SizedBox(height: 24),

                // Tombol Keluar
                _LogoutButton(),

                const SizedBox(height: 24),

                // Footer
                Center(
                  child: Text(
                    'KILAS UNAND v2.0 • Limau Manis Civic Tech',
                    style: HomeTextStyles.labelSm.copyWith(
                      fontWeight: FontWeight.w500,
                      color: AppPalette.textSecondary(context)
                          .withValues(alpha: 0.6),
                    ),
                  ),
                ),
              ],
            ),
          ),

          // ── Fixed frosted header bar ─────────────────────────────
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: _SettingsAppBar(),
          ),
        ],
      ),
    );
  }
}

// ════════════════════════════════════════════════════════════════════
// Header Bar
// ════════════════════════════════════════════════════════════════════

/// Frosted-glass header bar konsisten dengan ProfileAppBar / HomeAppBar.
class _SettingsAppBar extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final topPadding = MediaQuery.of(context).padding.top;
    return ClipRect(
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: _kBlurSigma, sigmaY: _kBlurSigma),
        child: Container(
          padding: EdgeInsets.only(top: topPadding),
          decoration: BoxDecoration(
            color: AppPalette.glassBackground(context),
            boxShadow: HomeShadows.headerGlass,
            border: Border(
              bottom: BorderSide(color: AppPalette.divider(context)),
            ),
          ),
          child: SizedBox(
            height: _kBarHeight,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 4),
              child: Row(
                children: [
                  // Tombol kembali ke profil
                  IconButton(
                    onPressed: () => Navigator.pop(context),
                    icon: Icon(
                      Icons.arrow_back_ios_new_rounded,
                      size: 20,
                      color: AppPalette.textPrimary(context),
                    ),
                    tooltip: 'Kembali ke Profil',
                  ),
                  const SizedBox(width: 4),
                  Expanded(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Pengaturan',
                          style: HomeTextStyles.headlineSm.copyWith(
                            color: AppPalette.textPrimary(context),
                            height: 1.0,
                            letterSpacing: -0.3,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          'Preferensi & konfigurasi aplikasi',
                          style: HomeTextStyles.labelSm.copyWith(
                            color: AppPalette.textSecondary(context),
                            height: 1.0,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

// ════════════════════════════════════════════════════════════════════
// Section Label
// ════════════════════════════════════════════════════════════════════

class _SectionLabel extends StatelessWidget {
  const _SectionLabel({required this.label});
  final String label;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
      child: Text(
        label,
        style: HomeTextStyles.labelSm.copyWith(
          letterSpacing: 0.8,
          color: AppPalette.textSecondary(context),
        ),
      ),
    );
  }
}

// ════════════════════════════════════════════════════════════════════
// Settings Group Container
// ════════════════════════════════════════════════════════════════════

class _SettingsGroup extends StatelessWidget {
  const _SettingsGroup({required this.children});
  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
      child: Container(
        decoration: BoxDecoration(
          color: AppPalette.surface(context),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: AppPalette.divider(context),
            width: 1,
          ),
        ),
        child: Column(
          children: [
            for (int i = 0; i < children.length; i++) ...[
              if (i > 0)
                Divider(
                  height: 1,
                  indent: 64,
                  color: AppPalette.divider(context),
                ),
              children[i],
            ],
          ],
        ),
      ),
    );
  }
}

// ════════════════════════════════════════════════════════════════════
// Setting Tiles
// ════════════════════════════════════════════════════════════════════

/// Pengingat Laporan Harian (FR-18 / FR-B7).
class _ReminderTile extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: UserProfileRepository.instance,
      builder: (context, _) {
        final profile = UserProfileRepository.instance.profile;
        return ListTile(
          contentPadding:
              const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
          leading: _SettingIcon(
            icon: Icons.alarm_rounded,
            color: const Color(0xFF3B82F6),
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
        );
      },
    );
  }
}

/// Goyang HP untuk Buka Draft (FR-23 / FR-C5).
class _ShakeDraftTile extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: UserProfileRepository.instance,
      builder: (context, _) {
        final profile = UserProfileRepository.instance.profile;
        return ListTile(
          contentPadding:
              const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
          leading: _SettingIcon(
            icon: Icons.vibration_rounded,
            color: const Color(0xFF8B5CF6),
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
        );
      },
    );
  }
}

/// Mode Gelap / Terang.
class _DarkModeTile extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: AppThemeController.themeMode,
      builder: (context, _) {
        final isDarkMode = AppThemeController.isDark;
        return ListTile(
          contentPadding:
              const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
          leading: _SettingIcon(
            icon: isDarkMode
                ? Icons.dark_mode_rounded
                : Icons.light_mode_rounded,
            color: isDarkMode
                ? const Color(0xFFFBBF24)
                : const Color(0xFF475569),
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
        );
      },
    );
  }
}

/// Tile informasi (non-interaktif) untuk Tentang Aplikasi.
class _InfoTile extends StatelessWidget {
  const _InfoTile({
    required this.icon,
    required this.iconColor,
    required this.title,
    required this.subtitle,
  });

  final IconData icon;
  final Color iconColor;
  final String title;
  final String subtitle;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      contentPadding:
          const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      leading: _SettingIcon(icon: icon, color: iconColor),
      title: Text(
        title,
        style: HomeTextStyles.labelLg.copyWith(
          color: AppPalette.textPrimary(context),
        ),
      ),
      subtitle: Text(
        subtitle,
        style: HomeTextStyles.bodySm.copyWith(
          color: AppPalette.textSecondary(context),
        ),
      ),
      trailing: Icon(
        Icons.chevron_right_rounded,
        color: AppPalette.textSecondary(context),
        size: 22,
      ),
    );
  }
}

// ════════════════════════════════════════════════════════════════════
// Setting Icon Box
// ════════════════════════════════════════════════════════════════════

class _SettingIcon extends StatelessWidget {
  const _SettingIcon({required this.icon, required this.color});
  final IconData icon;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 38,
      height: 38,
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Icon(icon, color: color, size: 20),
    );
  }
}

// ════════════════════════════════════════════════════════════════════
// Logout Button
// ════════════════════════════════════════════════════════════════════

class _LogoutButton extends StatelessWidget {
  void _confirmLogout(BuildContext context) {
    showDialog<void>(
      context: context,
      builder: (dialogCtx) {
        return AlertDialog(
          backgroundColor: AppPalette.surface(context),
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
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
      child: SizedBox(
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
    );
  }
}
