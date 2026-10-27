import 'package:flutter/material.dart';

import '../../../theme/app_palette.dart';
import '../../../theme/app_spacing.dart';
import '../../../theme/home_colors.dart';
import '../../../theme/home_text_styles.dart';
import '../all_activities_screen.dart';
import '../data/user_profile_repository.dart';
import '../models/user_profile_model.dart';
import '../../../../utils/time_utils.dart';

/// Tab Riwayat Aktivitas Pribadi (FR-24 & FR-C6).
///
/// Fitur:
/// - Filter berdasarkan jenis aktivitas (Semua, Laporan, Upvote, Bookmark).
/// - Filter rentang waktu (Semua, Hari Ini, 7 Hari Terakhir).
/// - Hapus item riwayat per satu atau hapus seluruh riwayat dengan dialog konfirmasi.
class ProfileActivityTab extends StatefulWidget {
  const ProfileActivityTab({super.key});

  @override
  State<ProfileActivityTab> createState() => _ProfileActivityTabState();
}

class _ProfileActivityTabState extends State<ProfileActivityTab> {
  String _selectedFilter = 'Semua';
  String _dateFilter = 'Semua Waktu';

  final List<String> _typeFilters = const [
    'Semua',
    'Laporan',
    'Upvote',
    'Bookmark',
  ];

  final List<String> _dateFilters = const [
    'Semua Waktu',
    'Hari Ini',
    '7 Hari Terakhir',
  ];


  bool _matchesType(ActivityLogItem item) {
    if (_selectedFilter == 'Semua') return true;
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
  }

  bool _matchesDate(ActivityLogItem item) {
    if (_dateFilter == 'Semua Waktu') return true;
    final now = DateTime.now();
    final diff = now.difference(item.timestamp);
    if (_dateFilter == 'Hari Ini') {
      return diff.inHours < 24 && item.timestamp.day == now.day;
    }
    if (_dateFilter == '7 Hari Terakhir') {
      return diff.inDays <= 7;
    }
    return true;
  }

  void _confirmClearAll(BuildContext context) {
    final isDark = AppPalette.isDark(context);
    showDialog<void>(
      context: context,
      builder: (dialogCtx) {
        return AlertDialog(
          backgroundColor: AppPalette.surface(context),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
          title: Text(
            'Hapus Seluruh Riwayat?',
            style: HomeTextStyles.headlineSm.copyWith(
              fontWeight: FontWeight.w700,
              color: AppPalette.textPrimary(context),
            ),
          ),
          content: Text(
            'Semua catatan aktivitas pribadi Anda akan dibersihkan. Tindakan ini tidak dapat dibatalkan.',
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
              onPressed: () {
                Navigator.of(dialogCtx).pop();
                UserProfileRepository.instance.clearActivities();
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    backgroundColor: isDark
                        ? const Color(0xFF1E293B)
                        : const Color(0xFF0F172A),
                    behavior: SnackBarBehavior.floating,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    content: Text(
                      'Riwayat aktivitas berhasil dibersihkan',
                      style: HomeTextStyles.labelMd.copyWith(
                        color: Colors.white,
                      ),
                    ),
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
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = AppPalette.isDark(context);

    return AnimatedBuilder(
      animation: UserProfileRepository.instance,
      builder: (context, _) {
        final allActivities = UserProfileRepository.instance.activities;
        final filteredList = allActivities
            .where((item) => _matchesType(item) && _matchesDate(item))
            .toList();

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Filter Bar
            Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: AppSpacing.lg,
                vertical: AppSpacing.sm,
              ),
              child: Row(
                children: [
                  Expanded(
                    child: SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      physics: const BouncingScrollPhysics(),
                      child: Row(
                        children: _typeFilters.map((type) {
                          final isSelected = _selectedFilter == type;
                          return Padding(
                            padding: const EdgeInsets.only(right: 8),
                            child: ChoiceChip(
                              label: Text(type),
                              selected: isSelected,
                              labelStyle: HomeTextStyles.labelSm.copyWith(
                                fontWeight: isSelected
                                    ? FontWeight.w700
                                    : FontWeight.w500,
                                color: isSelected
                                    ? Colors.white
                                    : AppPalette.textSecondary(context),
                              ),
                              selectedColor: HomeColors.primaryContainer,
                              backgroundColor: isDark
                                  ? const Color(0xFF1E293B)
                                  : const Color(0xFFF1F5F9),
                              side: BorderSide.none,
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 4, vertical: 0),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(20),
                              ),
                              onSelected: (val) {
                                if (val) setState(() => _selectedFilter = type);
                              },
                            ),
                          );
                        }).toList(),
                      ),
                    ),
                  ),
                  if (allActivities.isNotEmpty)
                    IconButton(
                      tooltip: 'Hapus Semua Riwayat',
                      icon: const Icon(
                        Icons.delete_sweep_rounded,
                        color: Color(0xFFEF4444),
                        size: 22,
                      ),
                      onPressed: () => _confirmClearAll(context),
                    ),
                ],
              ),
            ),

            // Date quick filter chips
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
              child: SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                physics: const BouncingScrollPhysics(),
                child: Row(
                  children: _dateFilters.map((date) {
                    final isSelected = _dateFilter == date;
                    return Padding(
                      padding: const EdgeInsets.only(right: 6, bottom: 8),
                      child: ActionChip(
                        avatar: Icon(
                          Icons.calendar_today_rounded,
                          size: 13,
                          color: isSelected
                              ? HomeColors.primaryContainer
                              : AppPalette.textSecondary(context),
                        ),
                        label: Text(date),
                        labelStyle: HomeTextStyles.labelSm.copyWith(
                          fontWeight: isSelected
                              ? FontWeight.w700
                              : FontWeight.w500,
                          color: isSelected
                              ? (isDark
                                  ? const Color(0xFF93C5FD)
                                  : HomeColors.primaryContainer)
                              : AppPalette.textSecondary(context),
                        ),
                        backgroundColor: isSelected
                            ? (isDark
                                ? const Color(0xFF1E3A8A).withValues(alpha: 0.35)
                                : const Color(0xFFEFF6FF))
                            : Colors.transparent,
                        side: BorderSide(
                          color: isSelected
                              ? HomeColors.primaryContainer.withValues(alpha: 0.5)
                              : AppPalette.divider(context),
                          width: 1,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                        onPressed: () {
                          setState(() => _dateFilter = date);
                        },
                      ),
                    );
                  }).toList(),
                ),
              ),
            ),

            const SizedBox(height: AppSpacing.xs),

            if (filteredList.isEmpty)
              Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(vertical: 40, horizontal: AppSpacing.lg),
                child: Column(
                  children: [
                    Icon(
                      Icons.history_rounded,
                      size: 48,
                      color: AppPalette.textSecondary(context).withValues(alpha: 0.4),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      'Belum ada riwayat aktivitas',
                      style: HomeTextStyles.labelLg.copyWith(
                        fontWeight: FontWeight.w600,
                        color: AppPalette.textPrimary(context),
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Tindakan membuat laporan, upvote, dan bookmark akan tercatat di sini.',
                      textAlign: TextAlign.center,
                      style: HomeTextStyles.bodySm.copyWith(
                        color: AppPalette.textSecondary(context),
                      ),
                    ),
                  ],
                ),
              )
            else ...[
              Builder(
                builder: (context) {
                  final displayList = filteredList.length > 5
                      ? filteredList.take(5).toList()
                      : filteredList;

                  return ListView.separated(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg, vertical: 4),
                    itemCount: displayList.length,
                    separatorBuilder: (context, index) => const SizedBox(height: 10),
                    itemBuilder: (context, index) {
                      final item = displayList[index];
                  return Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: AppPalette.surface(context),
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(
                        color: AppPalette.divider(context),
                        width: 1,
                      ),
                    ),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Action Icon Container
                        Container(
                          width: 38,
                          height: 38,
                          decoration: BoxDecoration(
                            color: item.color.withValues(alpha: 0.12),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Icon(
                            item.icon,
                            color: item.color,
                            size: 20,
                          ),
                        ),
                        const SizedBox(width: 12),
                        // Details
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Text(
                                    item.title,
                                    style: HomeTextStyles.labelMd.copyWith(
                                      fontWeight: FontWeight.w700,
                                      color: AppPalette.textPrimary(context),
                                    ),
                                  ),
                                  const Spacer(),
                                  Text(
                                    TimeUtils.formatTimeAgo(item.timestamp),
                                    style: HomeTextStyles.labelSm.copyWith(
                                      fontWeight: FontWeight.w500,
                                      color: AppPalette.textSecondary(context),
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 4),
                              Text(
                                item.description,
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                                style: HomeTextStyles.bodySm.copyWith(
                                  color: AppPalette.textSecondary(context),
                                  height: 1.3,
                                ),
                              ),
                            ],
                          ),
                        ),
                        // Delete item button
                        IconButton(
                          padding: EdgeInsets.zero,
                          constraints: const BoxConstraints(minWidth: 28, minHeight: 28),
                          icon: Icon(
                            Icons.close_rounded,
                            size: 16,
                            color: AppPalette.textSecondary(context).withValues(alpha: 0.5),
                          ),
                          onPressed: () {
                            UserProfileRepository.instance.removeActivity(item.id);
                          },
                        ),
                      ],
                    ),
                  );
                },
              );
            },
          ),
          if (filteredList.length > 5)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg, vertical: 8),
              child: SizedBox(
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
                        builder: (context) => const AllActivitiesScreen(),
                      ),
                    );
                  },
                  icon: const Icon(
                    Icons.history_rounded,
                    color: HomeColors.primaryContainer,
                    size: 18,
                  ),
                  label: Text(
                    'Buka Seluruh Riwayat Aktivitas (${filteredList.length}) →',
                    style: HomeTextStyles.labelMd.copyWith(
                      color: HomeColors.primaryContainer,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ),
            ),
        ],
          ],
        );
      },
    );
  }
}
