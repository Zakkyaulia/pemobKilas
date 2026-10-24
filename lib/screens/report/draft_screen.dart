import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../theme/app_palette.dart';
import '../../theme/app_spacing.dart';
import '../../theme/home_colors.dart';
import '../../theme/home_shadows.dart';
import '../../theme/home_text_styles.dart';
import '../../utils/time_utils.dart';
import 'create_report_screen.dart';
import 'data/draft_repository.dart';
import 'models/draft_model.dart';

/// Konstanta styling header konsisten dengan HomeScreen & NotificationScreen.
const double _kBarHeight = 64;
const double _kBlurSigma = 24;

/// Halaman Draft Laporan KILAS UNAND.
///
/// Menampilkan daftar seluruh draf laporan yang disimpan pengguna secara lokal.
/// Memungkinkan pengguna melanjutkan penulisan (membuka [CreateReportScreen]),
/// menghapus draft tertentu, atau menghapus seluruh draf.
class DraftScreen extends StatelessWidget {
  const DraftScreen({super.key});

  void _openDraft(BuildContext context, DraftModel draft) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => CreateReportScreen(initialDraft: draft),
      ),
    );
  }

  void _confirmDeleteSingle(BuildContext context, DraftModel draft) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppPalette.surface(context),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text(
          'Hapus Draft Ini?',
          style: HomeTextStyles.headlineSm.copyWith(
            fontWeight: FontWeight.w700,
            color: AppPalette.textPrimary(context),
          ),
        ),
        content: Text(
          'Draft "${draft.displayTitle}" akan dihapus permanen dari perangkat.',
          style: HomeTextStyles.bodyMd.copyWith(
            color: AppPalette.textSecondary(context),
            height: 1.4,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text(
              'Batal',
              style: HomeTextStyles.labelMd.copyWith(
                color: AppPalette.textSecondary(context),
              ),
            ),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFEF4444),
              elevation: 0,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
            ),
            onPressed: () {
              DraftRepository.instance.deleteDraft(draft.id);
              Navigator.pop(ctx);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(
                    'Draft berhasil dihapus.',
                    style: HomeTextStyles.labelMd.copyWith(color: Colors.white),
                  ),
                  backgroundColor: const Color(0xFFEF4444),
                  behavior: SnackBarBehavior.floating,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  margin: const EdgeInsets.all(AppSpacing.lg),
                ),
              );
            },
            child: Text(
              'Hapus',
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

  void _confirmClearAll(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppPalette.surface(context),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text(
          'Hapus Semua Draft?',
          style: HomeTextStyles.headlineSm.copyWith(
            fontWeight: FontWeight.w700,
            color: AppPalette.textPrimary(context),
          ),
        ),
        content: Text(
          'Semua draft laporan yang tersimpan secara lokal akan dihapus permanen. Tindakan ini tidak dapat dibatalkan.',
          style: HomeTextStyles.bodyMd.copyWith(
            color: AppPalette.textSecondary(context),
            height: 1.4,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text(
              'Batal',
              style: HomeTextStyles.labelMd.copyWith(
                color: AppPalette.textSecondary(context),
              ),
            ),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFEF4444),
              elevation: 0,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
            ),
            onPressed: () {
              DraftRepository.instance.clearAll();
              Navigator.pop(ctx);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(
                    'Semua draft berhasil dihapus.',
                    style: HomeTextStyles.labelMd.copyWith(color: Colors.white),
                  ),
                  backgroundColor: const Color(0xFFEF4444),
                  behavior: SnackBarBehavior.floating,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  margin: const EdgeInsets.all(AppSpacing.lg),
                ),
              );
            },
            child: Text(
              'Hapus Semua',
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

  @override
  Widget build(BuildContext context) {
    final topPadding = MediaQuery.of(context).padding.top;
    final bottomPadding = MediaQuery.of(context).padding.bottom;
    final headerHeight = topPadding + _kBarHeight;

    return Scaffold(
      backgroundColor: AppPalette.canvas(context),
      body: Stack(
        children: [
          // ── Scrollable Content ─────────────────────────────────────────────
          ListenableBuilder(
            listenable: DraftRepository.instance,
            builder: (context, _) {
              final drafts = DraftRepository.instance.drafts;

              if (drafts.isEmpty) {
                return _DraftEmptyView(
                  headerHeight: headerHeight,
                  bottomPadding: bottomPadding,
                );
              }

              return ListView.separated(
                physics: const BouncingScrollPhysics(),
                padding: EdgeInsets.only(
                  top: headerHeight + AppSpacing.md,
                  bottom: bottomPadding + AppSpacing.xxl,
                  left: AppSpacing.lg,
                  right: AppSpacing.lg,
                ),
                itemCount: drafts.length + 1, // +1 untuk info banner
                separatorBuilder: (context, index) => const SizedBox(height: AppSpacing.md),
                itemBuilder: (context, index) {
                  if (index == 0) {
                    return _InfoBanner(draftCount: drafts.length);
                  }
                  final draft = drafts[index - 1];
                  return _DraftCard(
                    draft: draft,
                    onTap: () => _openDraft(context, draft),
                    onDelete: () => _confirmDeleteSingle(context, draft),
                  );
                },
              );
            },
          ),

          // ── Frosted Glass App Bar ──────────────────────────────────────────
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: _DraftAppBar(
              onClearAll: () => _confirmClearAll(context),
            ),
          ),
        ],
      ),
    );
  }
}

/// Header frosted glass dengan judul, count, dan tombol Hapus Semua.
class _DraftAppBar extends StatelessWidget {
  const _DraftAppBar({required this.onClearAll});

  final VoidCallback onClearAll;

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
              padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
              child: Row(
                children: [
                  // Tombol kembali
                  IconButton(
                    icon: Icon(
                      Icons.arrow_back_rounded,
                      color: AppPalette.textPrimary(context),
                      size: 24,
                    ),
                    onPressed: () => Navigator.of(context).pop(),
                  ),
                  const SizedBox(width: AppSpacing.xs),
                  // Judul & Subtitle
                  Expanded(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Draft Laporan',
                          style: HomeTextStyles.headlineSm.copyWith(
                            color: AppPalette.textPrimary(context),
                            fontWeight: FontWeight.w700,
                            letterSpacing: -0.3,
                            height: 1.1,
                          ),
                        ),
                        const SizedBox(height: 2),
                        ListenableBuilder(
                          listenable: DraftRepository.instance,
                          builder: (context, _) {
                            final count = DraftRepository.instance.draftCount;
                            return Text(
                              count == 0 ? 'Tidak ada draft' : '$count draft tersimpan',
                              style: HomeTextStyles.bodySm.copyWith(
                                color: AppPalette.textSecondary(context),
                                height: 1.0,
                              ),
                            );
                          },
                        ),
                      ],
                    ),
                  ),
                  // Tombol Hapus Semua (hanya muncul bila ada draft)
                  ListenableBuilder(
                    listenable: DraftRepository.instance,
                    builder: (context, _) {
                      if (!DraftRepository.instance.hasDrafts) {
                        return const SizedBox.shrink();
                      }
                      return TextButton.icon(
                        style: TextButton.styleFrom(
                          foregroundColor: const Color(0xFFEF4444),
                          padding: const EdgeInsets.symmetric(
                            horizontal: AppSpacing.sm,
                            vertical: AppSpacing.xs,
                          ),
                        ),
                        onPressed: onClearAll,
                        icon: const Icon(Icons.delete_sweep_outlined, size: 18),
                        label: Text(
                          'Hapus Semua',
                          style: GoogleFonts.plusJakartaSans(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      );
                    },
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

/// Banner informatif tentang sifat penyimpanan lokal draft.
class _InfoBanner extends StatelessWidget {
  const _InfoBanner({required this.draftCount});

  final int draftCount;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: HomeColors.primaryContainer.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: HomeColors.primaryContainer.withValues(alpha: 0.2),
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(
            Icons.info_outline_rounded,
            size: 20,
            color: HomeColors.primaryContainer,
          ),
          const SizedBox(width: AppSpacing.sm),
          Expanded(
            child: Text(
              'Draft tersimpan secara offline di perangkat Anda. Ketuk draft untuk melanjutkan penulisan dan mengirimkannya.',
              style: HomeTextStyles.bodySm.copyWith(
                color: AppPalette.textPrimary(context),
                height: 1.4,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// Kartu tampilan per item draft.
class _DraftCard extends StatelessWidget {
  const _DraftCard({
    required this.draft,
    required this.onTap,
    required this.onDelete,
  });

  final DraftModel draft;
  final VoidCallback onTap;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context) {
    final isCondition = draft.selectedCategory == 'Kondisi Kampus';

    // Badge styling matching KILAS category design
    final badgeBg = isCondition ? const Color(0xFFFEF3DC) : const Color(0xFFE5EEFF);
    final badgeTextColor = isCondition ? const Color(0xFFB45309) : const Color(0xFF1D4ED8);
    final badgeBorderColor = isCondition ? const Color(0xFFFDE68A) : const Color(0xFFBFDBFE);

    final timeAgo = TimeUtils.formatTimeAgo(draft.updatedAt, isShort: false);

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.all(AppSpacing.md),
        decoration: BoxDecoration(
          color: AppPalette.surface(context),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppPalette.divider(context)),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.04),
              blurRadius: 10,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Baris atas: Kategori & Waktu Terakhir Diedit
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(
                    color: badgeBg,
                    borderRadius: BorderRadius.circular(6),
                    border: Border.all(color: badgeBorderColor),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        isCondition ? Icons.warning_amber_rounded : Icons.info_outline_rounded,
                        size: 13,
                        color: badgeTextColor,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        draft.selectedCategory,
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 11,
                          fontWeight: FontWeight.w700,
                          color: badgeTextColor,
                        ),
                      ),
                    ],
                  ),
                ),
                const Spacer(),
                Icon(
                  Icons.schedule_rounded,
                  size: 14,
                  color: AppPalette.textSecondary(context),
                ),
                const SizedBox(width: 4),
                Text(
                  timeAgo,
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 11,
                    color: AppPalette.textSecondary(context),
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),

            const SizedBox(height: 10),

            // Judul draft
            Text(
              draft.displayTitle,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: HomeTextStyles.headlineSm.copyWith(
                fontWeight: FontWeight.w700,
                fontSize: 15,
                color: draft.title != null && draft.title!.trim().isNotEmpty
                    ? AppPalette.textPrimary(context)
                    : AppPalette.textSecondary(context),
                fontStyle: draft.title == null || draft.title!.trim().isEmpty
                    ? FontStyle.italic
                    : FontStyle.normal,
              ),
            ),

            const SizedBox(height: 6),

            // Cuplikan keterangan
            Text(
              draft.displayDescription,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: HomeTextStyles.bodySm.copyWith(
                color: AppPalette.textSecondary(context),
                height: 1.4,
              ),
            ),

            const SizedBox(height: 12),

            // Indikator Media & Lokasi (jika tersedia)
            Wrap(
              spacing: 8,
              runSpacing: 6,
              children: [
                if (draft.hasMedia)
                  _MediaChip(
                    mediaPath: draft.mediaFilePath!,
                    isVideo: draft.isVideo,
                  ),
                if (draft.locationName != null && draft.locationName!.isNotEmpty)
                  _LocationChip(locationName: draft.locationName!),
              ],
            ),

            const SizedBox(height: 12),
            const Divider(height: 1, thickness: 1),
            const SizedBox(height: 10),

            // Baris Tombol Aksi Bawah
            Row(
              children: [
                // Tombol Lanjutkan Menulis
                Expanded(
                  child: ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: HomeColors.primaryContainer,
                      foregroundColor: Colors.white,
                      elevation: 0,
                      padding: const EdgeInsets.symmetric(vertical: 10),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    onPressed: onTap,
                    icon: const Icon(Icons.edit_note_rounded, size: 18),
                    label: Text(
                      'Lanjutkan Menulis',
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 13,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: AppSpacing.sm),
                // Tombol Hapus Draft
                IconButton(
                  style: IconButton.styleFrom(
                    backgroundColor: const Color(0xFFEF4444).withValues(alpha: 0.08),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                    padding: const EdgeInsets.all(10),
                  ),
                  icon: const Icon(
                    Icons.delete_outline_rounded,
                    color: Color(0xFFEF4444),
                    size: 20,
                  ),
                  tooltip: 'Hapus Draft',
                  onPressed: onDelete,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

/// Chip indikator media terlampir pada draft.
class _MediaChip extends StatelessWidget {
  const _MediaChip({
    required this.mediaPath,
    required this.isVideo,
  });

  final String mediaPath;
  final bool isVideo;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: AppPalette.surfaceSubtle(context),
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: AppPalette.divider(context)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            isVideo ? Icons.videocam_rounded : Icons.image_rounded,
            size: 14,
            color: HomeColors.primaryContainer,
          ),
          const SizedBox(width: 4),
          Text(
            isVideo ? 'Video Terlampir' : 'Foto Terlampir',
            style: GoogleFonts.plusJakartaSans(
              fontSize: 11,
              fontWeight: FontWeight.w600,
              color: AppPalette.textPrimary(context),
            ),
          ),
        ],
      ),
    );
  }
}

/// Chip indikator lokasi GPS tersimpan pada draft.
class _LocationChip extends StatelessWidget {
  const _LocationChip({required this.locationName});

  final String locationName;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: AppPalette.surfaceSubtle(context),
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: AppPalette.divider(context)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(
            Icons.location_on_outlined,
            size: 14,
            color: Color(0xFF10B981),
          ),
          const SizedBox(width: 4),
          ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 160),
            child: Text(
              locationName,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: GoogleFonts.plusJakartaSans(
                fontSize: 11,
                fontWeight: FontWeight.w500,
                color: AppPalette.textSecondary(context),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// Tampilan jika tidak ada draft yang tersimpan (Empty State).
class _DraftEmptyView extends StatelessWidget {
  const _DraftEmptyView({
    required this.headerHeight,
    required this.bottomPadding,
  });

  final double headerHeight;
  final double bottomPadding;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        padding: EdgeInsets.only(
          top: headerHeight + AppSpacing.xl,
          bottom: bottomPadding + AppSpacing.xl,
          left: AppSpacing.xxl,
          right: AppSpacing.xxl,
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Lingkaran ikon draft
            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                color: HomeColors.primaryContainer.withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.drafts_outlined,
                size: 40,
                color: HomeColors.primaryContainer,
              ),
            ),
            const SizedBox(height: AppSpacing.lg),

            Text(
              'Belum Ada Draft Tersimpan',
              textAlign: TextAlign.center,
              style: HomeTextStyles.headlineSm.copyWith(
                fontWeight: FontWeight.w700,
                color: AppPalette.textPrimary(context),
              ),
            ),
            const SizedBox(height: AppSpacing.sm),

            Text(
              'Laporan yang Anda simpan saat menulis atau saat keluar dari pembuatan laporan akan muncul di sini untuk Anda lanjutkan nanti.',
              textAlign: TextAlign.center,
              style: HomeTextStyles.bodyMd.copyWith(
                color: AppPalette.textSecondary(context),
                height: 1.5,
              ),
            ),
            const SizedBox(height: AppSpacing.xl),

            ElevatedButton.icon(
              style: ElevatedButton.styleFrom(
                backgroundColor: HomeColors.primaryContainer,
                foregroundColor: Colors.white,
                elevation: 0,
                padding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.xl,
                  vertical: 14,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              onPressed: () {
                Navigator.of(context).pushReplacement(
                  MaterialPageRoute(builder: (_) => const CreateReportScreen()),
                );
              },
              icon: const Icon(Icons.add_circle_outline_rounded, size: 20),
              label: Text(
                'Mulai Buat Laporan',
                style: GoogleFonts.plusJakartaSans(
                  fontWeight: FontWeight.w700,
                  fontSize: 14,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
