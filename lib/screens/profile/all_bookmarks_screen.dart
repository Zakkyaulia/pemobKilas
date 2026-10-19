import 'dart:io';
import 'dart:ui';
import 'package:flutter/material.dart';

import '../../theme/app_palette.dart';
import '../../theme/app_spacing.dart';
import '../../theme/home_colors.dart';
import '../../theme/home_shadows.dart';
import '../../theme/home_text_styles.dart';
import '../home/data/report_repository.dart';
import '../home/models/report_model.dart';
import '../home/report_detail_screen.dart';
import 'data/user_profile_repository.dart';
import 'models/user_profile_model.dart';

/// Halaman khusus untuk melihat seluruh koleksi Bookmark mahasiswa (Daftar Lengkap).
class AllBookmarksScreen extends StatefulWidget {
  const AllBookmarksScreen({super.key});

  @override
  State<AllBookmarksScreen> createState() => _AllBookmarksScreenState();
}

class _AllBookmarksScreenState extends State<AllBookmarksScreen> {
  String _searchQuery = '';

  void _removeBookmark(ReportModel report) {
    final updated = report.copyWith(isBookmarked: false);
    ReportRepository.instance.updateById(report.id, updated);
    UserProfileRepository.instance.addActivity(
      actionType: ActivityActionType.bookmark,
      title: 'Menghapus Bookmark',
      description: 'Menghapus "${report.title ?? "Laporan"}" dari koleksi',
      reportId: report.id,
    );

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          'Laporan dihapus dari bookmark.',
          style: HomeTextStyles.labelMd.copyWith(color: Colors.white),
        ),
        backgroundColor: const Color(0xFF1E293B),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final topPadding = MediaQuery.of(context).padding.top;
    final isDark = AppPalette.isDark(context);

    return Scaffold(
      backgroundColor: AppPalette.canvas(context),
      body: ListenableBuilder(
        listenable: ReportRepository.instance,
        builder: (context, _) {
          final allReports = ReportRepository.instance.reports;
          final bookmarks = allReports
              .where((r) => r.isBookmarked)
              .where((r) {
            if (_searchQuery.trim().isEmpty) return true;
            final query = _searchQuery.toLowerCase();
            final title = (r.title ?? '').toLowerCase();
            final desc = (r.description ?? '').toLowerCase();
            return title.contains(query) || desc.contains(query);
          }).toList();

          return Stack(
            children: [
              ListView(
                padding: EdgeInsets.fromLTRB(
                  AppSpacing.lg,
                  topPadding + 64 + 16,
                  AppSpacing.lg,
                  40,
                ),
                children: [
                  // Search Box
                  TextField(
                    onChanged: (val) => setState(() => _searchQuery = val),
                    style: HomeTextStyles.bodyMd.copyWith(
                      color: AppPalette.textPrimary(context),
                    ),
                    decoration: InputDecoration(
                      hintText: 'Cari dalam ${bookmarks.length} bookmark tersimpan...',
                      hintStyle: HomeTextStyles.bodySm.copyWith(
                        color: AppPalette.textSecondary(context),
                      ),
                      prefixIcon: Icon(
                        Icons.search,
                        color: AppPalette.textSecondary(context),
                        size: 20,
                      ),
                      filled: true,
                      fillColor: AppPalette.surface(context),
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 12,
                      ),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide(color: AppPalette.divider(context)),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide(color: AppPalette.divider(context)),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: const BorderSide(
                          color: HomeColors.primaryContainer,
                          width: 1.5,
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(height: 16),

                  if (bookmarks.isEmpty)
                    Container(
                      padding: const EdgeInsets.symmetric(vertical: 60),
                      alignment: Alignment.center,
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.bookmark_border_rounded,
                            size: 48,
                            color: AppPalette.textSecondary(context).withValues(alpha: 0.5),
                          ),
                          const SizedBox(height: 12),
                          Text(
                            'Belum ada bookmark yang cocok',
                            style: HomeTextStyles.headlineSm.copyWith(
                              color: AppPalette.textPrimary(context),
                            ),
                          ),
                          const SizedBox(height: 6),
                          Text(
                            'Simpan laporan penting dari Beranda agar mudah dibuka kembali.',
                            style: HomeTextStyles.bodySm.copyWith(
                              color: AppPalette.textSecondary(context),
                            ),
                          ),
                        ],
                      ),
                    )
                  else
                    GridView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 2,
                        crossAxisSpacing: 12,
                        mainAxisSpacing: 12,
                        childAspectRatio: 0.72,
                      ),
                      itemCount: bookmarks.length,
                      itemBuilder: (context, i) {
                        final item = bookmarks[i];
                        final isCondition = item.badgeLabel == 'Kondisi Kampus';

                        return Container(
                          decoration: BoxDecoration(
                            color: AppPalette.surface(context),
                            borderRadius: BorderRadius.circular(14),
                            border: Border.all(
                              color: AppPalette.divider(context),
                              width: 1,
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withValues(alpha: isDark ? 0.2 : 0.04),
                                blurRadius: 8,
                                offset: const Offset(0, 2),
                              ),
                            ],
                          ),
                          child: InkWell(
                            borderRadius: BorderRadius.circular(14),
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => ReportDetailScreen(report: item),
                                ),
                              );
                            },
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Stack(
                                  children: [
                                    ClipRRect(
                                      borderRadius: const BorderRadius.vertical(top: Radius.circular(13)),
                                      child: Container(
                                        height: 100,
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
                                            size: 15,
                                            color: Colors.white,
                                          ),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                                Padding(
                                  padding: const EdgeInsets.all(10),
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        item.title ?? 'Laporan',
                                        style: HomeTextStyles.labelMd.copyWith(
                                          fontWeight: FontWeight.w700,
                                          color: AppPalette.textPrimary(context),
                                        ),
                                        maxLines: 2,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                      const SizedBox(height: 4),
                                      Text(
                                        item.locationName ?? 'Kampus Limau Manis',
                                        style: HomeTextStyles.bodySm.copyWith(
                                          fontSize: 11,
                                          color: AppPalette.textSecondary(context),
                                        ),
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                      const SizedBox(height: 6),
                                      Row(
                                        children: [
                                          Icon(
                                            Icons.thumb_up_alt_rounded,
                                            size: 12,
                                            color: HomeColors.primaryContainer,
                                          ),
                                          const SizedBox(width: 4),
                                          Text(
                                            '${item.upvoteCount} Dukungan',
                                            style: HomeTextStyles.labelSm.copyWith(
                                              fontSize: 10.5,
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
                ],
              ),

              // Header frosted glass
              Positioned(
                top: 0,
                left: 0,
                right: 0,
                child: ClipRect(
                  child: BackdropFilter(
                    filter: ImageFilter.blur(sigmaX: 24, sigmaY: 24),
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
                        height: 64,
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
                          child: Row(
                            children: [
                              IconButton(
                                icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 20),
                                color: AppPalette.textPrimary(context),
                                onPressed: () => Navigator.pop(context),
                              ),
                              const SizedBox(width: 8),
                              Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Semua Bookmark Saya',
                                    style: HomeTextStyles.headlineSm.copyWith(
                                      color: AppPalette.textPrimary(context),
                                      fontWeight: FontWeight.w700,
                                    ),
                                  ),
                                  Text(
                                    'Total ${bookmarks.length} laporan disimpan',
                                    style: HomeTextStyles.labelSm.copyWith(
                                      color: AppPalette.textSecondary(context),
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          );
        },
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
