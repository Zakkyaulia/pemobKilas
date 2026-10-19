import 'dart:io';
import 'package:flutter/material.dart';

import '../../../theme/app_palette.dart';
import '../../../theme/app_spacing.dart';
import '../../../theme/home_colors.dart';
import '../../../theme/home_text_styles.dart';
import '../../home/data/report_repository.dart';
import '../../home/models/report_model.dart';
import '../../home/report_detail_screen.dart';
import '../all_reports_screen.dart';
import '../data/user_profile_repository.dart';
import '../models/user_profile_model.dart';

/// Tab tampilan daftar laporan milik pengguna sendiri (FR-05 & FR-06).
///
/// Pengguna dapat mengedit laporan (caption & kategori dengan penanda "diedit")
/// serta menghapus laporan miliknya setelah konfirmasi dialog.
class ProfileReportsTab extends StatelessWidget {
  const ProfileReportsTab({
    super.key,
    required this.reports,
  });

  final List<ReportModel> reports;

  void _showEditReportDialog(BuildContext context, ReportModel report) {
    final titleController = TextEditingController(text: report.title ?? '');
    final descController = TextEditingController(text: report.description ?? '');
    String selectedCategory = report.badgeLabel;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) {
        return StatefulBuilder(
          builder: (ctx, setSheetState) {
            final bottomInset = MediaQuery.of(ctx).viewInsets.bottom;
            return Container(
              decoration: BoxDecoration(
                color: AppPalette.surface(ctx),
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
                          color: const Color(0xFFCBD5E1),
                          borderRadius: BorderRadius.circular(2),
                        ),
                      ),
                    ),
                    const SizedBox(height: AppSpacing.lg),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Edit Laporan Saya',
                          style: HomeTextStyles.headlineSm.copyWith(
                            fontWeight: FontWeight.w700,
                            color: AppPalette.textPrimary(ctx),
                          ),
                        ),
                        IconButton(
                          icon: const Icon(Icons.close_rounded),
                          onPressed: () => Navigator.pop(ctx),
                        ),
                      ],
                    ),
                    const SizedBox(height: AppSpacing.md),
                    Text(
                      'Kategori Laporan',
                      style: HomeTextStyles.labelMd.copyWith(
                        color: AppPalette.textPrimary(ctx),
                      ),
                    ),
                    const SizedBox(height: 6),
                    Row(
                      children: [
                        Expanded(
                          child: ChoiceChip(
                            label: const Text('Kondisi Kampus'),
                            selected: selectedCategory == 'Kondisi Kampus',
                            onSelected: (val) {
                              if (val) {
                                setSheetState(() => selectedCategory = 'Kondisi Kampus');
                              }
                            },
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: ChoiceChip(
                            label: const Text('Info Penting'),
                            selected: selectedCategory == 'Info Penting',
                            onSelected: (val) {
                              if (val) {
                                setSheetState(() => selectedCategory = 'Info Penting');
                              }
                            },
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: AppSpacing.md),
                    Text(
                      'Judul Laporan',
                      style: HomeTextStyles.labelMd.copyWith(
                        color: AppPalette.textPrimary(ctx),
                      ),
                    ),
                    const SizedBox(height: 6),
                    TextField(
                      controller: titleController,
                      style: HomeTextStyles.bodyMd.copyWith(
                        color: AppPalette.textPrimary(ctx),
                      ),
                      decoration: InputDecoration(
                        filled: true,
                        fillColor: AppPalette.canvas(ctx),
                        contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                      ),
                    ),
                    const SizedBox(height: AppSpacing.md),
                    Text(
                      'Keterangan / Caption',
                      style: HomeTextStyles.labelMd.copyWith(
                        color: AppPalette.textPrimary(ctx),
                      ),
                    ),
                    const SizedBox(height: 6),
                    TextField(
                      controller: descController,
                      maxLines: 3,
                      style: HomeTextStyles.bodyMd.copyWith(
                        color: AppPalette.textPrimary(ctx),
                      ),
                      decoration: InputDecoration(
                        filled: true,
                        fillColor: AppPalette.canvas(ctx),
                        contentPadding: const EdgeInsets.all(12),
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                      ),
                    ),
                    const SizedBox(height: AppSpacing.xl),
                    SizedBox(
                      width: double.infinity,
                      height: 46,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: HomeColors.primaryContainer,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        ),
                        onPressed: () {
                          final updated = report.copyWith(
                            title: titleController.text.trim(),
                            description: descController.text.trim(),
                            badgeLabel: selectedCategory,
                            timestamp: '${report.timestamp ?? "Baru saja"} (diedit)',
                          );
                          ReportRepository.instance.updateById(report.id, updated);
                          UserProfileRepository.instance.addActivity(
                            actionType: ActivityActionType.ubahLaporan,
                            title: 'Mengubah Laporan',
                            description: updated.title ?? 'Laporan diedit',
                            reportId: report.id,
                          );
                          Navigator.pop(ctx);
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text(
                                'Laporan berhasil diperbarui dengan penanda "diedit".',
                                style: HomeTextStyles.labelMd.copyWith(color: Colors.white),
                              ),
                              backgroundColor: const Color(0xFF10B981),
                            ),
                          );
                        },
                        child: Text(
                          'Simpan Perubahan',
                          style: HomeTextStyles.labelMd.copyWith(
                            color: Colors.white,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  void _showDeleteConfirmation(BuildContext context, ReportModel report) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppPalette.surface(context),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text(
          'Hapus Laporan Ini?',
          style: HomeTextStyles.headlineSm.copyWith(
            fontWeight: FontWeight.w700,
            color: AppPalette.textPrimary(context),
          ),
        ),
        content: Text(
          'Laporan "${report.title ?? "Laporan"}" akan dihapus permanen dari Timeline dan Peta Kampus.',
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
              ReportRepository.instance.deleteById(report.id);
              UserProfileRepository.instance.addActivity(
                actionType: ActivityActionType.hapusLaporan,
                title: 'Menghapus Laporan',
                description: report.title ?? 'Laporan dihapus',
              );
              Navigator.pop(ctx);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(
                    'Laporan berhasil dihapus.',
                    style: HomeTextStyles.labelMd.copyWith(color: Colors.white),
                  ),
                  backgroundColor: const Color(0xFFEF4444),
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

  @override
  Widget build(BuildContext context) {
    final isDark = AppPalette.isDark(context);

    if (reports.isEmpty) {
      return Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.lg,
          vertical: 32,
        ),
        child: Center(
          child: Column(
            children: [
              Icon(
                Icons.post_add_rounded,
                size: 48,
                color: AppPalette.textSecondary(context).withValues(alpha: 0.5),
              ),
              const SizedBox(height: 12),
              Text(
                'Belum Ada Laporan Dibuat',
                style: HomeTextStyles.headlineSm.copyWith(
                  fontWeight: FontWeight.w700,
                  color: AppPalette.textPrimary(context),
                ),
              ),
              const SizedBox(height: 4),
              Text(
                'Tekan tombol (+) di bilah bawah untuk melaporkan kondisi kampus.',
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

    final displayList = reports.length > 3 ? reports.take(3).toList() : reports;

    final listWidget = ListView.separated(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: displayList.length,
            separatorBuilder: (context, index) => const SizedBox(height: 10),
            itemBuilder: (context, index) {
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
            padding: const EdgeInsets.all(12),
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
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Thumbnail foto atau ikon
                ClipRRect(
                  borderRadius: BorderRadius.circular(10),
                  child: Container(
                    width: 72,
                    height: 72,
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
                const SizedBox(width: 12),
                // Konten teks
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                            decoration: BoxDecoration(
                              color: isCondition
                                  ? (isDark ? const Color(0xFF332205) : const Color(0xFFFEF3DC))
                                  : (isDark ? const Color(0xFF162544) : const Color(0xFFE5EEFF)),
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: Text(
                              item.badgeLabel,
                              style: HomeTextStyles.labelSm.copyWith(
                                fontSize: 9.5,
                                fontWeight: FontWeight.w700,
                                color: isCondition
                                    ? (isDark ? const Color(0xFFFFB95F) : const Color(0xFF9C6200))
                                    : (isDark ? const Color(0xFF60A5FA) : HomeColors.primaryContainer),
                              ),
                            ),
                          ),
                          const Spacer(),
                          Text(
                            item.timestamp?.split('•').first.trim() ?? 'Baru saja',
                            style: HomeTextStyles.labelSm.copyWith(
                              fontSize: 10,
                              color: AppPalette.textSecondary(context),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 5),
                      Text(
                        item.title ?? 'Laporan Insiden',
                        style: HomeTextStyles.labelMd.copyWith(
                          fontWeight: FontWeight.w700,
                          color: AppPalette.textPrimary(context),
                          height: 1.2,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 3),
                      Text(
                        item.description ?? '',
                        style: HomeTextStyles.bodySm.copyWith(
                          fontSize: 11,
                          color: AppPalette.textSecondary(context),
                          height: 1.3,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 6),
                      Row(
                        children: [
                          Icon(
                            Icons.thumb_up_alt_rounded,
                            size: 13,
                            color: isDark ? const Color(0xFF60A5FA) : HomeColors.primaryContainer,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            '${item.upvoteCount} Dukungan',
                            style: HomeTextStyles.labelSm.copyWith(
                              fontSize: 11,
                              fontWeight: FontWeight.w700,
                              color: isDark ? const Color(0xFF60A5FA) : HomeColors.primaryContainer,
                            ),
                          ),
                          const Spacer(),
                          // Tombol Edit
                          GestureDetector(
                            onTap: () => _showEditReportDialog(context, item),
                            child: Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 4),
                              child: Icon(
                                Icons.edit_note_rounded,
                                size: 18,
                                color: AppPalette.textSecondary(context),
                              ),
                            ),
                          ),
                          const SizedBox(width: 4),
                          // Tombol Hapus
                          GestureDetector(
                            onTap: () => _showDeleteConfirmation(context, item),
                            child: const Padding(
                              padding: EdgeInsets.symmetric(horizontal: 4),
                              child: Icon(
                                Icons.delete_outline_rounded,
                                size: 17,
                                color: Color(0xFFEF4444),
                              ),
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
    );

    if (reports.length > 3) {
      return Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.lg,
          vertical: AppSpacing.sm,
        ),
        child: Column(
          children: [
            listWidget,
            const SizedBox(height: 10),
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
                      builder: (context) => const AllReportsScreen(),
                    ),
                  );
                },
                icon: const Icon(
                  Icons.list_alt_rounded,
                  color: HomeColors.primaryContainer,
                  size: 18,
                ),
                label: Text(
                  'Lihat Semua Laporan (${reports.length}) →',
                  style: HomeTextStyles.labelMd.copyWith(
                    color: HomeColors.primaryContainer,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ),
          ],
        ),
      );
    }

    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.lg,
        vertical: AppSpacing.sm,
      ),
      child: listWidget,
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
