import 'dart:io';
import 'package:flutter/material.dart';

import '../../../theme/app_palette.dart';
import '../../../theme/app_spacing.dart';
import '../../../theme/home_colors.dart';
import '../../../theme/home_text_styles.dart';
import '../../home/data/report_repository.dart';
import '../../home/models/report_model.dart';
import '../all_bookmarks_screen.dart';
import '../data/user_profile_repository.dart';
import '../models/user_profile_model.dart';
import '../../home/report_detail_screen.dart';

/// Tab tampilan Koleksi Bookmark berbentuk Grid di Profil (FR-10).
///
/// Syarat Wajib PRD: Halaman ini WAJIB melewati Local Authentication
/// (Sidik Jari / PIN) terlebih dahulu sebelum menampilkan grid laporan bookmark.
class ProfileBookmarksTab extends StatefulWidget {
  const ProfileBookmarksTab({
    super.key,
    required this.bookmarks,
  });

  final List<ReportModel> bookmarks;

  @override
  State<ProfileBookmarksTab> createState() => _ProfileBookmarksTabState();
}

class _ProfileBookmarksTabState extends State<ProfileBookmarksTab> {
  final TextEditingController _pinController = TextEditingController();
  bool _isAuthenticating = false;

  @override
  void dispose() {
    _pinController.dispose();
    super.dispose();
  }

  void _authenticateWithBiometrics() async {
    setState(() => _isAuthenticating = true);

    await Future.delayed(const Duration(milliseconds: 650));

    if (!mounted) return;
    setState(() => _isAuthenticating = false);

    UserProfileRepository.instance.unlockBookmark();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.fingerprint_rounded, color: Colors.white, size: 20),
            const SizedBox(width: 8),
            Text(
              'Autentikasi biometrik berhasil. Koleksi terbuka.',
              style: HomeTextStyles.labelMd.copyWith(color: Colors.white),
            ),
          ],
        ),
        backgroundColor: const Color(0xFF10B981),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  void _showPinDialog() {
    _pinController.clear();
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppPalette.surface(context),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
        title: Row(
          children: [
            const Icon(Icons.pin_rounded, color: HomeColors.primaryContainer, size: 22),
            const SizedBox(width: 8),
            Text(
              'Masukkan PIN',
              style: HomeTextStyles.headlineSm.copyWith(
                fontWeight: FontWeight.w700,
                color: AppPalette.textPrimary(context),
              ),
            ),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Masukkan 4 angka PIN keamanan perangkat Anda:',
              style: HomeTextStyles.bodySm.copyWith(
                color: AppPalette.textSecondary(context),
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _pinController,
              keyboardType: TextInputType.number,
              obscureText: true,
              maxLength: 6,
              autofocus: true,
              style: HomeTextStyles.headlineSm.copyWith(
                letterSpacing: 4,
                fontWeight: FontWeight.w700,
                color: AppPalette.textPrimary(context),
              ),
              decoration: InputDecoration(
                hintText: '• • • •',
                hintStyle: HomeTextStyles.headlineSm.copyWith(letterSpacing: 4),
                filled: true,
                fillColor: AppPalette.canvas(context),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text(
              'Batal',
              style: HomeTextStyles.labelMd.copyWith(color: AppPalette.textSecondary(context)),
            ),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: HomeColors.primaryContainer,
              elevation: 0,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
            ),
            onPressed: () {
              if (_pinController.text.trim().isNotEmpty) {
                Navigator.pop(ctx);
                UserProfileRepository.instance.unlockBookmark();
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(
                      'PIN terverifikasi. Koleksi bookmark terbuka.',
                      style: HomeTextStyles.labelMd.copyWith(color: Colors.white),
                    ),
                    backgroundColor: const Color(0xFF10B981),
                  ),
                );
              }
            },
            child: Text(
              'Verifikasi',
              style: HomeTextStyles.labelMd.copyWith(
                color: Colors.white,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _removeBookmark(ReportModel report) {
    final updated = report.copyWith(isBookmarked: false);
    ReportRepository.instance.updateById(report.id, updated);
    UserProfileRepository.instance.addActivity(
      actionType: ActivityActionType.bookmark,
      title: 'Menghapus Bookmark',
      description: report.title ?? 'Laporan dihapus dari bookmark',
      reportId: report.id,
    );
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          'Dihapus dari koleksi Bookmark.',
          style: HomeTextStyles.labelMd.copyWith(color: Colors.white),
        ),
        backgroundColor: const Color(0xFF1E293B),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = AppPalette.isDark(context);
    final isUnlocked = UserProfileRepository.instance.isBookmarkUnlocked;

    // Gerbang Keamanan Biometrik / PIN (FR-10)
    if (!isUnlocked) {
      return Container(
        margin: const EdgeInsets.symmetric(
          horizontal: AppSpacing.lg,
          vertical: AppSpacing.md,
        ),
        padding: const EdgeInsets.all(AppSpacing.xxl),
        decoration: BoxDecoration(
          color: AppPalette.surface(context),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: AppPalette.divider(context)),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: isDark ? 0.2 : 0.04),
              blurRadius: 10,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Column(
          children: [
            Container(
              width: 64,
              height: 64,
              decoration: BoxDecoration(
                color: isDark ? const Color(0xFF1E2D4A) : const Color(0xFFEFF4FF),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.lock_rounded,
                size: 32,
                color: HomeColors.primaryContainer,
              ),
            ),
            const SizedBox(height: AppSpacing.lg),
            Text(
              'Koleksi Bookmark Terkunci',
              style: HomeTextStyles.headlineSm.copyWith(
                fontWeight: FontWeight.w800,
                color: AppPalette.textPrimary(context),
              ),
            ),
            const SizedBox(height: 6),
            Text(
              'Sesuai ketentuan keamanan (FR-10), akses koleksi bookmark wajib diverifikasi dengan Local Authentication (sidik jari atau PIN).',
              textAlign: TextAlign.center,
              style: HomeTextStyles.bodySm.copyWith(
                color: AppPalette.textSecondary(context),
                height: 1.4,
              ),
            ),
            const SizedBox(height: AppSpacing.xl),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 4),
              child: ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  backgroundColor: HomeColors.primaryContainer,
                  foregroundColor: Colors.white,
                  minimumSize: const Size(double.infinity, 50),
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                  elevation: 2,
                ),
                onPressed: _isAuthenticating ? null : _authenticateWithBiometrics,
                icon: _isAuthenticating
                    ? const SizedBox(
                        width: 18,
                        height: 18,
                        child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                      )
                    : const Icon(Icons.fingerprint_rounded, size: 22, color: Colors.white),
                label: Text(
                  _isAuthenticating ? 'Memverifikasi...' : 'Buka Kunci dengan Sidik Jari',
                  style: HomeTextStyles.labelMd.copyWith(
                    fontWeight: FontWeight.w700,
                    color: Colors.white,
                    fontSize: 14,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 8),
            TextButton.icon(
              onPressed: _showPinDialog,
              icon: Icon(
                Icons.pin_rounded,
                size: 16,
                color: AppPalette.textSecondary(context),
              ),
              label: Text(
                'Gunakan PIN Keamanan',
                style: HomeTextStyles.labelMd.copyWith(
                  fontWeight: FontWeight.w600,
                  color: AppPalette.textSecondary(context),
                ),
              ),
            ),
          ],
        ),
      );
    }

    // Jika telah diautentikasi (Unlocked): Tampilkan Grid Bookmark
    if (widget.bookmarks.isEmpty) {
      return Padding(
        padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg, vertical: 28),
        child: Center(
          child: Column(
            children: [
              Icon(
                Icons.bookmark_border_rounded,
                size: 48,
                color: AppPalette.textSecondary(context).withValues(alpha: 0.5),
              ),
              const SizedBox(height: 12),
              Text(
                'Koleksi Bookmark Kosong',
                style: HomeTextStyles.headlineSm.copyWith(
                  fontWeight: FontWeight.w700,
                  color: AppPalette.textPrimary(context),
                ),
              ),
              const SizedBox(height: 4),
              Text(
                'Simpan laporan penting dari Beranda agar tersimpan di grid ini.',
                textAlign: TextAlign.center,
                style: HomeTextStyles.bodySm.copyWith(
                  color: AppPalette.textSecondary(context),
                ),
              ),
            ],
          ),
        ),
      );
    }

    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.lg,
        vertical: AppSpacing.sm,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Koleksi Bookmark (${widget.bookmarks.length})',
                style: HomeTextStyles.labelLg.copyWith(
                  fontWeight: FontWeight.w700,
                  color: AppPalette.textPrimary(context),
                ),
              ),
              GestureDetector(
                onTap: () {
                  UserProfileRepository.instance.lockBookmark();
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(
                        'Koleksi bookmark telah dikunci kembali.',
                        style: HomeTextStyles.labelMd.copyWith(color: Colors.white),
                      ),
                      backgroundColor: const Color(0xFF1E293B),
                    ),
                  );
                },
                child: Row(
                  children: [
                    const Icon(Icons.lock_outline_rounded, size: 14, color: Color(0xFFEF4444)),
                    const SizedBox(width: 4),
                    Text(
                      'Kunci Kembali',
                      style: HomeTextStyles.labelSm.copyWith(
                        fontWeight: FontWeight.w700,
                        color: const Color(0xFFEF4444),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          // Grid 2-kolom sesuai spesifikasi FR-10
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: (widget.bookmarks.length > 4 ? 4 : widget.bookmarks.length),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              crossAxisSpacing: 10,
              mainAxisSpacing: 10,
              childAspectRatio: 0.84,
            ),
            itemBuilder: (context, index) {
              final displayList = widget.bookmarks.length > 4
                  ? widget.bookmarks.take(4).toList()
                  : widget.bookmarks;
              final item = displayList[index];
              final isCondition = item.badgeLabel == 'Kondisi Kampus';

              return InkWell(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => ReportDetailScreen(report: item),
                    ),
                  );
                },
                borderRadius: BorderRadius.circular(14),
                child: Container(
                  decoration: BoxDecoration(
                    color: AppPalette.surface(context),
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(color: AppPalette.divider(context)),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: isDark ? 0.2 : 0.03),
                        blurRadius: 6,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Thumbnail
                      Stack(
                        children: [
                          ClipRRect(
                            borderRadius: const BorderRadius.vertical(top: Radius.circular(13)),
                            child: Container(
                              height: 96,
                              width: double.infinity,
                              color: isDark ? const Color(0xFF13203A) : const Color(0xFFE2E8F0),
                              child: item.imageUrl != null && item.imageUrl!.isNotEmpty
                                  ? _buildAdaptiveImage(item.imageUrl!, isCondition)
                                  : Icon(
                                      isCondition ? Icons.apartment_rounded : Icons.campaign_rounded,
                                      color: HomeColors.primaryContainer,
                                      size: 32,
                                    ),
                            ),
                          ),
                          Positioned(
                            top: 6,
                            right: 6,
                            child: GestureDetector(
                              onTap: () => _removeBookmark(item),
                              child: Container(
                                padding: const EdgeInsets.all(5),
                                decoration: const BoxDecoration(
                                  color: Colors.black54,
                                  shape: BoxShape.circle,
                                ),
                                child: const Icon(
                                  Icons.bookmark_remove_rounded,
                                  color: Colors.white,
                                  size: 14,
                                ),
                              ),
                            ),
                          ),
                          Positioned(
                            bottom: 6,
                            left: 6,
                            child: Container(
                              padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 2),
                              decoration: BoxDecoration(
                                color: isCondition
                                    ? const Color(0xFF9C6200)
                                    : HomeColors.primaryContainer,
                                borderRadius: BorderRadius.circular(4),
                              ),
                              child: Text(
                                item.badgeLabel,
                                style: HomeTextStyles.labelSm.copyWith(
                                  fontSize: 8.5,
                                  fontWeight: FontWeight.w700,
                                  color: Colors.white,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                      Padding(
                        padding: const EdgeInsets.all(8),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              item.title ?? 'Laporan',
                              style: HomeTextStyles.labelSm.copyWith(
                                fontSize: 11.5,
                                fontWeight: FontWeight.w700,
                                color: AppPalette.textPrimary(context),
                                height: 1.2,
                              ),
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                            ),
                            const SizedBox(height: 6),
                            Row(
                              children: [
                                Icon(
                                  Icons.thumb_up_alt_rounded,
                                  size: 11,
                                  color: isDark
                                      ? const Color(0xFF60A5FA)
                                      : HomeColors.primaryContainer,
                                ),
                                const SizedBox(width: 3),
                                Text(
                                  '${item.upvoteCount}',
                                  style: HomeTextStyles.labelSm.copyWith(
                                    fontWeight: FontWeight.w700,
                                    color: isDark
                                        ? const Color(0xFF60A5FA)
                                        : HomeColors.primaryContainer,
                                  ),
                                ),
                                const Spacer(),
                                Text(
                                  item.locationName?.split(' ').first ?? 'UNAND',
                                  style: HomeTextStyles.labelSm.copyWith(
                                    fontSize: 9.5,
                                    color: AppPalette.textSecondary(context),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
          if (widget.bookmarks.length > 4) ...[
            const SizedBox(height: 12),
            SizedBox(
              width: double.infinity,
              height: 44,
              child: OutlinedButton.icon(
                style: OutlinedButton.styleFrom(
                  side: BorderSide(
                    color: HomeColors.primaryContainer.withValues(alpha: 0.5),
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  backgroundColor: HomeColors.primaryContainer.withValues(alpha: 0.06),
                ),
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const AllBookmarksScreen(),
                    ),
                  );
                },
                icon: const Icon(
                  Icons.bookmarks_rounded,
                  color: HomeColors.primaryContainer,
                  size: 18,
                ),
                label: Text(
                  'Buka Semua Koleksi Bookmark (${widget.bookmarks.length}) →',
                  style: HomeTextStyles.labelMd.copyWith(
                    color: HomeColors.primaryContainer,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
  Widget _buildAdaptiveImage(String pathOrUrl, bool isCondition) {
    if (pathOrUrl.startsWith('http://') || pathOrUrl.startsWith('https://')) {
      return Image.network(
        pathOrUrl,
        fit: BoxFit.cover,
        errorBuilder: (_, _, _) => Icon(
          isCondition ? Icons.apartment_rounded : Icons.campaign_rounded,
          color: HomeColors.primaryContainer,
        ),
      );
    }
    if (pathOrUrl.startsWith('assets/')) {
      return Image.asset(
        pathOrUrl,
        fit: BoxFit.cover,
        errorBuilder: (_, _, _) => Icon(
          isCondition ? Icons.apartment_rounded : Icons.campaign_rounded,
          color: HomeColors.primaryContainer,
        ),
      );
    }
    return Image.file(
      File(pathOrUrl),
      fit: BoxFit.cover,
      errorBuilder: (_, _, _) => Icon(
        isCondition ? Icons.apartment_rounded : Icons.campaign_rounded,
        color: HomeColors.primaryContainer,
      ),
    );
  }
}
