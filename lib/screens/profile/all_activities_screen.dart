import 'dart:ui';
import 'package:flutter/material.dart';

import '../../theme/app_palette.dart';
import '../../theme/app_spacing.dart';
import '../../theme/home_colors.dart';
import '../../theme/home_shadows.dart';
import '../../theme/home_text_styles.dart';
import '../home/data/report_repository.dart';
import '../home/report_detail_screen.dart';
import 'data/user_profile_repository.dart';
import 'models/user_profile_model.dart';
import '../../utils/time_utils.dart';

/// Halaman khusus untuk melihat seluruh riwayat aktivitas akun mahasiswa secara penuh.
class AllActivitiesScreen extends StatefulWidget {
  const AllActivitiesScreen({super.key});

  @override
  State<AllActivitiesScreen> createState() => _AllActivitiesScreenState();
}

class _AllActivitiesScreenState extends State<AllActivitiesScreen> {
  String _selectedFilter = 'Semua';

  void _confirmClearAll(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppPalette.surface(context),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text(
          'Hapus Semua Riwayat?',
          style: HomeTextStyles.headlineSm.copyWith(
            fontWeight: FontWeight.w700,
            color: AppPalette.textPrimary(context),
          ),
        ),
        content: Text(
          'Seluruh catatan log aktivitas Anda akan dihapus permanen dari perangkat.',
          style: HomeTextStyles.bodyMd.copyWith(
            color: AppPalette.textSecondary(context),
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
              UserProfileRepository.instance.clearActivities();
              Navigator.pop(ctx);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(
                    'Riwayat aktivitas berhasil dibersihkan.',
                    style: HomeTextStyles.labelMd.copyWith(color: Colors.white),
                  ),
                  backgroundColor: const Color(0xFF1E293B),
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
    final isDark = AppPalette.isDark(context);

    return Scaffold(
      backgroundColor: AppPalette.canvas(context),
      body: ListenableBuilder(
        listenable: UserProfileRepository.instance,
        builder: (context, _) {
          final allActivities = UserProfileRepository.instance.activities;
          final activities = allActivities.where((item) {
            if (_selectedFilter == 'Laporan') {
              return item.actionType == ActivityActionType.buatLaporan ||
                  item.actionType == ActivityActionType.ubahLaporan ||
                  item.actionType == ActivityActionType.hapusLaporan;
            }
            if (_selectedFilter == 'Upvote') {
              return item.actionType == ActivityActionType.upvote;
            }
            if (_selectedFilter == 'Bookmark') {
              return item.actionType == ActivityActionType.bookmark;
            }
            return true;
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
                  // Filter Chips
                  SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      children: ['Semua', 'Laporan', 'Upvote', 'Bookmark'].map((cat) {
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

                  if (activities.isEmpty)
                    Container(
                      padding: const EdgeInsets.symmetric(vertical: 60),
                      alignment: Alignment.center,
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.history_toggle_off_rounded,
                            size: 48,
                            color: AppPalette.textSecondary(context).withValues(alpha: 0.5),
                          ),
                          const SizedBox(height: 12),
                          Text(
                            'Belum Ada Catatan Riwayat',
                            style: HomeTextStyles.headlineSm.copyWith(
                              color: AppPalette.textPrimary(context),
                            ),
                          ),
                          const SizedBox(height: 6),
                          Text(
                            'Aktivitas seperti upvote, simpan bookmark, dan lapor akan dicatat otomatis di sini.',
                            style: HomeTextStyles.bodySm.copyWith(
                              color: AppPalette.textSecondary(context),
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ],
                      ),
                    )
                  else
                    ...activities.map((item) => _buildActivityItem(context, item, isDark)),
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
                              Expanded(
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      'Semua Riwayat Aktivitas',
                                      style: HomeTextStyles.headlineSm.copyWith(
                                        color: AppPalette.textPrimary(context),
                                        fontWeight: FontWeight.w700,
                                      ),
                                    ),
                                    Text(
                                      'Total ${activities.length} aktivitas tercatat',
                                      style: HomeTextStyles.labelSm.copyWith(
                                        color: AppPalette.textSecondary(context),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              if (allActivities.isNotEmpty)
                                TextButton.icon(
                                  onPressed: () => _confirmClearAll(context),
                                  icon: const Icon(
                                    Icons.delete_sweep_outlined,
                                    size: 16,
                                    color: Color(0xFFEF4444),
                                  ),
                                  label: Text(
                                    'Hapus',
                                    style: HomeTextStyles.labelSm.copyWith(
                                      color: const Color(0xFFEF4444),
                                      fontWeight: FontWeight.w700,
                                    ),
                                  ),
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

  Widget _buildActivityItem(BuildContext context, ActivityLogItem item, bool isDark) {
    Color iconBg;
    Color iconColor;
    IconData icon;

    switch (item.actionType) {
      case ActivityActionType.buatLaporan:
        iconBg = const Color(0xFF1E60FF).withValues(alpha: 0.12);
        iconColor = const Color(0xFF1E60FF);
        icon = Icons.add_circle_outline_rounded;
        break;
      case ActivityActionType.ubahLaporan:
        iconBg = const Color(0xFF006A61).withValues(alpha: 0.12);
        iconColor = const Color(0xFF006A61);
        icon = Icons.edit_note_rounded;
        break;
      case ActivityActionType.hapusLaporan:
        iconBg = const Color(0xFFEF4444).withValues(alpha: 0.12);
        iconColor = const Color(0xFFEF4444);
        icon = Icons.delete_outline_rounded;
        break;
      case ActivityActionType.upvote:
        iconBg = const Color(0xFFF59E0B).withValues(alpha: 0.12);
        iconColor = const Color(0xFFF59E0B);
        icon = Icons.arrow_upward_rounded;
        break;
      case ActivityActionType.bookmark:
        iconBg = const Color(0xFF8B5CF6).withValues(alpha: 0.12);
        iconColor = const Color(0xFF8B5CF6);
        icon = Icons.bookmark_added_outlined;
        break;
    }

    final timeAgo = TimeUtils.formatTimeAgo(item.timestamp);

    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      decoration: BoxDecoration(
        color: AppPalette.surface(context),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppPalette.divider(context), width: 1),
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 4),
        leading: Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: iconBg,
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(icon, color: iconColor, size: 20),
        ),
        title: Row(
          children: [
            Expanded(
              child: Text(
                item.title,
                style: HomeTextStyles.labelMd.copyWith(
                  fontWeight: FontWeight.w700,
                  color: AppPalette.textPrimary(context),
                ),
              ),
            ),
            Text(
              timeAgo,
              style: HomeTextStyles.labelSm.copyWith(
                fontSize: 11,
                color: AppPalette.textSecondary(context),
              ),
            ),
          ],
        ),
        subtitle: Padding(
          padding: const EdgeInsets.only(top: 3),
          child: Text(
            item.description,
            style: HomeTextStyles.bodySm.copyWith(
              color: AppPalette.textSecondary(context),
            ),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
        ),
        onTap: () {
          if (item.reportId != null) {
            final repoReport = ReportRepository.instance.reports
                .where((r) => r.id == item.reportId)
                .firstOrNull;
            if (repoReport != null) {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => ReportDetailScreen(report: repoReport),
                ),
              );
            }
          }
        },
      ),
    );
  }
}
