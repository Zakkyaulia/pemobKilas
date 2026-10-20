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


/// Halaman khusus untuk melihat seluruh laporan mahasiswa secara penuh (Daftar Lengkap).
/// Menggunakan kerangka frosted-glass header bar yang konsisten dengan desain utama.
class AllReportsScreen extends StatefulWidget {
  const AllReportsScreen({super.key});

  @override
  State<AllReportsScreen> createState() => _AllReportsScreenState();
}

class _AllReportsScreenState extends State<AllReportsScreen> {
  String _searchQuery = '';
  String _selectedFilter = 'Semua';

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
          final myReports = allReports
              .where((r) => r.authorUsername == '@ghezz')
              .where((r) {
            if (_selectedFilter == 'Kondisi Kampus') {
              return r.badgeLabel == 'Kondisi Kampus';
            }
            if (_selectedFilter == 'Info Penting') {
              return r.badgeLabel == 'Info Penting';
            }
            return true;
          }).where((r) {
            if (_searchQuery.trim().isEmpty) return true;
            final query = _searchQuery.toLowerCase();
            final title = (r.title ?? '').toLowerCase();
            final desc = (r.description ?? '').toLowerCase();
            return title.contains(query) || desc.contains(query);
          }).toList();

          return Stack(
            children: [
              // ── Scrollable list konten ──────────────────────────────
              ListView(
                padding: EdgeInsets.fromLTRB(
                  AppSpacing.lg,
                  topPadding + 64 + 16,
                  AppSpacing.lg,
                  40,
                ),
                children: [
                  // Search & Filter bar
                  TextField(
                    onChanged: (val) => setState(() => _searchQuery = val),
                    style: HomeTextStyles.bodyMd.copyWith(
                      color: AppPalette.textPrimary(context),
                    ),
                    decoration: InputDecoration(
                      hintText: 'Cari dalam ${myReports.length} laporan saya...',
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

                  const SizedBox(height: 12),

                  // Filter Chips
                  SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      children: ['Semua', 'Kondisi Kampus', 'Info Penting'].map((cat) {
                        final isSelected = _selectedFilter == cat;
                        return Padding(
                          padding: const EdgeInsets.only(right: 8),
                          child: FilterChip(
                            label: Text(cat),
                            labelStyle: HomeTextStyles.labelSm.copyWith(
                              color: isSelected
                                  ? Colors.white
                                  : AppPalette.textSecondary(context),
                              fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                            ),
                            selected: isSelected,
                            onSelected: (_) => setState(() => _selectedFilter = cat),
                            backgroundColor: AppPalette.surface(context),
                            selectedColor: HomeColors.primaryContainer,
                            checkmarkColor: Colors.white,
                            side: BorderSide(
                              color: isSelected
                                  ? HomeColors.primaryContainer
                                  : AppPalette.divider(context),
                            ),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(999),
                            ),
                          ),
                        );
                      }).toList(),
                    ),
                  ),

                  const SizedBox(height: 16),

                  if (myReports.isEmpty)
                    Container(
                      padding: const EdgeInsets.symmetric(vertical: 60),
                      alignment: Alignment.center,
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.assignment_outlined,
                            size: 48,
                            color: AppPalette.textSecondary(context).withValues(alpha: 0.5),
                          ),
                          const SizedBox(height: 12),
                          Text(
                            'Tidak ada laporan yang cocok',
                            style: HomeTextStyles.headlineSm.copyWith(
                              color: AppPalette.textPrimary(context),
                            ),
                          ),
                          const SizedBox(height: 6),
                          Text(
                            'Coba ganti kata kunci pencarian atau filter kategori.',
                            style: HomeTextStyles.bodySm.copyWith(
                              color: AppPalette.textSecondary(context),
                            ),
                          ),
                        ],
                      ),
                    )
                  else
                    ...myReports.map((report) => _buildReportItem(context, report, isDark)),
                ],
              ),

              // ── Header frosted glass ─────────────────────────────────
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
                                    'Semua Laporan Saya',
                                    style: HomeTextStyles.headlineSm.copyWith(
                                      color: AppPalette.textPrimary(context),
                                      fontWeight: FontWeight.w700,
                                    ),
                                  ),
                                  Text(
                                    'Total ${myReports.length} laporan diterbitkan',
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

  Widget _buildReportItem(BuildContext context, ReportModel item, bool isDark) {
    final isCondition = item.badgeLabel == 'Kondisi Kampus';

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: AppPalette.surface(context),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppPalette.divider(context), width: 1),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: isDark ? 0.2 : 0.04),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => ReportDetailScreen(report: item),
              ),
            );
          },
          child: Padding(
            padding: const EdgeInsets.all(14),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
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
                                color: isCondition
                                    ? const Color(0xFFD97706)
                                    : HomeColors.primaryContainer,
                                fontWeight: FontWeight.w700,
                                fontSize: 10,
                              ),
                            ),
                          ),
                          const Spacer(),
                          Text(
                            item.timeAgoDisplay,
                            style: HomeTextStyles.labelSm.copyWith(
                              color: AppPalette.textSecondary(context),
                              fontSize: 11,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 6),
                      Text(
                        item.title ?? 'Laporan Tanpa Judul',
                        style: HomeTextStyles.labelLg.copyWith(
                          color: AppPalette.textPrimary(context),
                          fontWeight: FontWeight.w700,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 4),
                      Text(
                        item.description ?? '',
                        style: HomeTextStyles.bodySm.copyWith(
                          color: AppPalette.textSecondary(context),
                        ),
                        maxLines: 2,
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
