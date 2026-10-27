import 'dart:ui';

import 'package:flutter/material.dart';

import '../../theme/app_palette.dart';
import '../../theme/app_spacing.dart';
import '../../theme/home_colors.dart';
import '../../theme/home_shadows.dart';
import '../../theme/home_text_styles.dart';
import '../../utils/time_utils.dart';
import 'data/notification_repository.dart';
import 'models/notification_model.dart';

/// Header bar height konsisten dengan layar lain (64px).
const double _kBarHeight = 64.0;

/// Blur sigma backdrop glass, identik dengan HomeAppBar.
const double _kBlurSigma = 24.0;

/// Halaman Notifikasi KILAS.
///
/// Menampilkan daftar notifikasi in-app yang dikelompokkan berdasarkan waktu:
/// - Hari ini
/// - Kemarin
/// - Lebih lama
///
/// Fitur:
/// - Badge unread (dot merah) per item
/// - Swipe to dismiss untuk menghapus satu notifikasi
/// - Tombol "Tandai semua dibaca"
/// - Tombol "Hapus semua" di action sheet
/// - Empty state bergaya saat tidak ada notifikasi
/// - Tap untuk menandai sebagai dibaca (navigasi akan ditambahkan saat backend tersedia)
class NotificationScreen extends StatefulWidget {
  const NotificationScreen({super.key});

  @override
  State<NotificationScreen> createState() => _NotificationScreenState();
}

class _NotificationScreenState extends State<NotificationScreen> {
  /// Filter yang sedang aktif. Null berarti tampilkan semua.
  NotifType? _activeFilter;

  List<NotificationItem> _filteredItems(List<NotificationItem> all) {
    if (_activeFilter == null) return all;
    return all.where((n) => n.type == _activeFilter).toList();
  }

  /// Grouping: hari ini / kemarin / lebih lama.
  Map<String, List<NotificationItem>> _groupItems(List<NotificationItem> items) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final yesterday = today.subtract(const Duration(days: 1));

    final result = <String, List<NotificationItem>>{
      'Hari Ini': [],
      'Kemarin': [],
      'Lebih Lama': [],
    };

    for (final item in items) {
      final d = DateTime(item.timestamp.year, item.timestamp.month, item.timestamp.day);
      if (d == today) {
        result['Hari Ini']!.add(item);
      } else if (d == yesterday) {
        result['Kemarin']!.add(item);
      } else {
        result['Lebih Lama']!.add(item);
      }
    }

    // Hapus grup kosong agar tidak ada header gantung.
    result.removeWhere((_, v) => v.isEmpty);
    return result;
  }

  void _showClearConfirm() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (_) => _ClearAllSheet(
        onConfirm: () {
          NotificationRepository.instance.clearAll();
          Navigator.pop(context);
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final topPadding = MediaQuery.of(context).padding.top;
    final headerHeight = topPadding + _kBarHeight;
    final bottomPadding = MediaQuery.of(context).padding.bottom;

    return Scaffold(
      backgroundColor: AppPalette.canvas(context),
      body: Stack(
        children: [
          // ── Konten scroll ───────────────────────────────────────────
          ListenableBuilder(
            listenable: NotificationRepository.instance,
            builder: (context, _) {
              final repo = NotificationRepository.instance;
              final filtered = _filteredItems(repo.items);
              final grouped = _groupItems(filtered);

              return CustomScrollView(
                physics: const BouncingScrollPhysics(),
                slivers: [
                  // Spacer untuk header
                  SliverToBoxAdapter(
                    child: SizedBox(height: headerHeight + AppSpacing.sm),
                  ),

                  // Filter chips
                  SliverToBoxAdapter(
                    child: _FilterChips(
                      activeFilter: _activeFilter,
                      onFilterChanged: (f) => setState(() => _activeFilter = f),
                    ),
                  ),

                  const SliverToBoxAdapter(child: SizedBox(height: AppSpacing.sm)),

                  // Konten utama
                  if (filtered.isEmpty)
                    SliverFillRemaining(
                      hasScrollBody: false,
                      child: _EmptyState(isFiltered: _activeFilter != null),
                    )
                  else ...[
                    for (final entry in grouped.entries) ...[
                      // Header grup
                      SliverToBoxAdapter(
                        child: _GroupHeader(label: entry.key),
                      ),
                      // List item dalam grup
                      SliverList(
                        delegate: SliverChildBuilderDelegate(
                          (context, i) {
                            final item = entry.value[i];
                            return _DismissibleNotifTile(
                              item: item,
                              onDismissed: () => NotificationRepository.instance.remove(item.id),
                              onTap: () => NotificationRepository.instance.markAsRead(item.id),
                            );
                          },
                          childCount: entry.value.length,
                        ),
                      ),
                    ],
                    SliverToBoxAdapter(
                      child: SizedBox(height: bottomPadding + 96),
                    ),
                  ],
                ],
              );
            },
          ),

          // ── Frosted glass header ─────────────────────────────────────
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: _NotifAppBar(
              onClearAll: _showClearConfirm,
            ),
          ),
        ],
      ),
    );
  }
}

// ════════════════════════════════════════════════════════════════════════════
// App Bar
// ════════════════════════════════════════════════════════════════════════════

class _NotifAppBar extends StatelessWidget {
  const _NotifAppBar({required this.onClearAll});

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
              padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
              child: Row(
                children: [
                  // Ikon notif
                  Container(
                    width: 36,
                    height: 36,
                    decoration: BoxDecoration(
                      color: HomeColors.primaryContainer.withValues(alpha: 0.12),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.notifications_rounded,
                      size: 20,
                      color: HomeColors.primaryContainer,
                    ),
                  ),
                  const SizedBox(width: AppSpacing.md),
                  // Title + subtitle
                  Expanded(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Notifikasi',
                          style: HomeTextStyles.headlineSm.copyWith(
                            color: AppPalette.textPrimary(context),
                            height: 1.0,
                            letterSpacing: -0.3,
                          ),
                        ),
                        const SizedBox(height: 2),
                        ListenableBuilder(
                          listenable: NotificationRepository.instance,
                          builder: (context, _) {
                            final count = NotificationRepository.instance.unreadCount;
                            return Text(
                              count > 0
                                  ? '$count notifikasi belum dibaca'
                                  : 'Semua sudah dibaca',
                              style: HomeTextStyles.labelSm.copyWith(
                                color: count > 0
                                    ? HomeColors.primaryContainer
                                    : AppPalette.textSecondary(context),
                                height: 1.0,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            );
                          },
                        ),
                      ],
                    ),
                  ),
                  // Aksi: tandai semua dibaca
                  ListenableBuilder(
                    listenable: NotificationRepository.instance,
                    builder: (context, _) {
                      final hasUnread = NotificationRepository.instance.hasUnread;
                      if (!hasUnread) return const SizedBox.shrink();
                      return IconButton(
                        onPressed: NotificationRepository.instance.markAllAsRead,
                        tooltip: 'Tandai semua dibaca',
                        icon: Icon(
                          Icons.done_all_rounded,
                          size: 22,
                          color: HomeColors.primaryContainer,
                        ),
                      );
                    },
                  ),
                  // Aksi: hapus semua
                  ListenableBuilder(
                    listenable: NotificationRepository.instance,
                    builder: (context, _) {
                      if (NotificationRepository.instance.items.isEmpty) {
                        return const SizedBox.shrink();
                      }
                      return IconButton(
                        onPressed: onClearAll,
                        tooltip: 'Hapus semua notifikasi',
                        icon: Icon(
                          Icons.delete_sweep_rounded,
                          size: 22,
                          color: AppPalette.textSecondary(context),
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

// ════════════════════════════════════════════════════════════════════════════
// Filter Chips
// ════════════════════════════════════════════════════════════════════════════

class _FilterChips extends StatelessWidget {
  const _FilterChips({
    required this.activeFilter,
    required this.onFilterChanged,
  });

  final NotifType? activeFilter;
  final void Function(NotifType?) onFilterChanged;

  static const _filters = [
    (null, 'Semua', Icons.apps_rounded),
    (NotifType.upvote, 'Upvote', Icons.arrow_upward_rounded),
    (NotifType.infoResmi, 'Info Resmi', Icons.campaign_rounded),
    (NotifType.pengingat, 'Pengingat', Icons.alarm_rounded),
    (NotifType.statusLaporan, 'Status', Icons.check_circle_outline_rounded),
    (NotifType.aktivitasDiri, 'Aktivitas', Icons.edit_note_rounded),
  ];

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 40,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
        itemCount: _filters.length,
        separatorBuilder: (_, _) => const SizedBox(width: AppSpacing.xs),
        itemBuilder: (context, i) {
          final (type, label, icon) = _filters[i];
          final isActive = activeFilter == type;
          return GestureDetector(
            onTap: () => onFilterChanged(type),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 180),
              curve: Curves.easeInOut,
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                color: isActive
                    ? HomeColors.primaryContainer
                    : AppPalette.surface(context),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: isActive
                      ? HomeColors.primaryContainer
                      : AppPalette.divider(context),
                ),
                boxShadow: isActive ? HomeShadows.sm : [],
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    icon,
                    size: 14,
                    color: isActive
                        ? HomeColors.onPrimary
                        : AppPalette.textSecondary(context),
                  ),
                  const SizedBox(width: 4),
                  Text(
                    label,
                    style: HomeTextStyles.labelMd.copyWith(
                      color: isActive
                          ? HomeColors.onPrimary
                          : AppPalette.textSecondary(context),
                      fontWeight: isActive ? FontWeight.w700 : FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}

// ════════════════════════════════════════════════════════════════════════════
// Group Header
// ════════════════════════════════════════════════════════════════════════════

class _GroupHeader extends StatelessWidget {
  const _GroupHeader({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.lg,
        AppSpacing.lg,
        AppSpacing.lg,
        AppSpacing.xs,
      ),
      child: Row(
        children: [
          Text(
            label.toUpperCase(),
            style: HomeTextStyles.labelSm.copyWith(
              color: AppPalette.textSecondary(context),
              letterSpacing: 0.8,
            ),
          ),
          const SizedBox(width: AppSpacing.sm),
          Expanded(
            child: Divider(
              height: 1,
              color: AppPalette.divider(context),
            ),
          ),
        ],
      ),
    );
  }
}

// ════════════════════════════════════════════════════════════════════════════
// Dismissible Notification Tile
// ════════════════════════════════════════════════════════════════════════════

class _DismissibleNotifTile extends StatelessWidget {
  const _DismissibleNotifTile({
    required this.item,
    required this.onDismissed,
    required this.onTap,
  });

  final NotificationItem item;
  final VoidCallback onDismissed;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Dismissible(
      key: ValueKey(item.id),
      direction: DismissDirection.endToStart,
      background: _DismissBackground(),
      onDismissed: (_) => onDismissed(),
      child: _NotifTile(item: item, onTap: onTap),
    );
  }
}

/// Background merah yang muncul saat swipe dismiss.
class _DismissBackground extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      alignment: Alignment.centerRight,
      padding: const EdgeInsets.only(right: AppSpacing.xl),
      color: HomeColors.statusFacility.withValues(alpha: 0.12),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.delete_outline_rounded,
            color: HomeColors.statusFacility,
            size: 22,
          ),
          const SizedBox(width: 6),
          Text(
            'Hapus',
            style: HomeTextStyles.labelMd.copyWith(
              color: HomeColors.statusFacility,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }
}

// ════════════════════════════════════════════════════════════════════════════
// Notification Tile
// ════════════════════════════════════════════════════════════════════════════

class _NotifTile extends StatelessWidget {
  const _NotifTile({required this.item, required this.onTap});

  final NotificationItem item;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final isUnread = !item.isRead;

    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        decoration: BoxDecoration(
          color: isUnread
              ? HomeColors.primaryContainer.withValues(alpha: 0.04)
              : Colors.transparent,
          border: Border(
            bottom: BorderSide(
              color: AppPalette.divider(context),
              width: 0.5,
            ),
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.lg,
            vertical: AppSpacing.md,
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ── Ikon kategori ──────────────────────────────────────
              Stack(
                clipBehavior: Clip.none,
                children: [
                  Container(
                    width: 44,
                    height: 44,
                    decoration: BoxDecoration(
                      color: item.iconBgColor,
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      item.icon,
                      size: 22,
                      color: item.accentColor,
                    ),
                  ),
                  if (isUnread)
                    Positioned(
                      top: 0,
                      right: 0,
                      child: Container(
                        width: 10,
                        height: 10,
                        decoration: BoxDecoration(
                          color: HomeColors.primaryContainer,
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: AppPalette.canvas(context),
                            width: 1.5,
                          ),
                        ),
                      ),
                    ),
                ],
              ),

              const SizedBox(width: AppSpacing.md),

              // ── Konten teks ────────────────────────────────────────
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Baris pertama: kategori chip + timestamp
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 6,
                            vertical: 2,
                          ),
                          decoration: BoxDecoration(
                            color: item.iconBgColor,
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Text(
                            item.categoryLabel,
                            style: HomeTextStyles.labelSm.copyWith(
                              color: item.accentColor,
                              letterSpacing: 0.2,
                            ),
                          ),
                        ),
                        const Spacer(),
                        Text(
                          TimeUtils.formatTimeAgo(
                            item.timestamp,
                            isShort: true,
                          ),
                          style: HomeTextStyles.labelSm.copyWith(
                            color: AppPalette.textSecondary(context),
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: AppSpacing.xs),

                    // Judul
                    Text(
                      item.title,
                      style: HomeTextStyles.labelLg.copyWith(
                        color: AppPalette.textPrimary(context),
                        fontWeight: isUnread ? FontWeight.w700 : FontWeight.w600,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),

                    const SizedBox(height: 2),

                    // Deskripsi
                    Text(
                      item.body,
                      style: HomeTextStyles.bodySm.copyWith(
                        color: AppPalette.textSecondary(context),
                        height: 1.5,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),

                    // Garis aksen bawah jika ada reportId
                    if (item.reportId != null) ...[
                      const SizedBox(height: AppSpacing.xs),
                      Row(
                        children: [
                          Icon(
                            Icons.arrow_forward_ios_rounded,
                            size: 10,
                            color: item.accentColor,
                          ),
                          const SizedBox(width: 3),
                          Text(
                            'Lihat laporan',
                            style: HomeTextStyles.labelSm.copyWith(
                              color: item.accentColor,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ════════════════════════════════════════════════════════════════════════════
// Empty State
// ════════════════════════════════════════════════════════════════════════════

class _EmptyState extends StatelessWidget {
  const _EmptyState({required this.isFiltered});

  final bool isFiltered;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(AppSpacing.xxxl),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Ilustrasi ikon
          Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              color: HomeColors.primaryContainer.withValues(alpha: 0.08),
              shape: BoxShape.circle,
            ),
            child: Icon(
              isFiltered
                  ? Icons.filter_list_off_rounded
                  : Icons.notifications_none_rounded,
              size: 40,
              color: HomeColors.primaryContainer.withValues(alpha: 0.5),
            ),
          ),
          const SizedBox(height: AppSpacing.xl),
          Text(
            isFiltered ? 'Tidak ada notifikasi\ndalam kategori ini' : 'Belum ada notifikasi',
            textAlign: TextAlign.center,
            style: HomeTextStyles.headlineSm.copyWith(
              color: AppPalette.textPrimary(context),
              height: 1.4,
            ),
          ),
          const SizedBox(height: AppSpacing.sm),
          Text(
            isFiltered
                ? 'Coba pilih kategori lain atau lihat semua notifikasi.'
                : 'Notifikasi tentang laporan, upvote, dan pengumuman kampus akan muncul di sini.',
            textAlign: TextAlign.center,
            style: HomeTextStyles.bodyMd.copyWith(
              color: AppPalette.textSecondary(context),
              height: 1.6,
            ),
          ),
        ],
      ),
    );
  }
}

// ════════════════════════════════════════════════════════════════════════════
// Clear All Bottom Sheet
// ════════════════════════════════════════════════════════════════════════════

class _ClearAllSheet extends StatelessWidget {
  const _ClearAllSheet({required this.onConfirm});

  final VoidCallback onConfirm;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.only(
        left: AppSpacing.lg,
        right: AppSpacing.lg,
        bottom: MediaQuery.of(context).padding.bottom + AppSpacing.lg,
      ),
      decoration: BoxDecoration(
        color: AppPalette.surface(context),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppPalette.divider(context)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Handle
          Padding(
            padding: const EdgeInsets.only(top: 12),
            child: Container(
              width: 36,
              height: 4,
              decoration: BoxDecoration(
                color: AppPalette.divider(context),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(AppSpacing.xl),
            child: Column(
              children: [
                // Ikon peringatan
                Container(
                  width: 56,
                  height: 56,
                  decoration: BoxDecoration(
                    color: HomeColors.statusFacility.withValues(alpha: 0.10),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    Icons.delete_sweep_rounded,
                    size: 28,
                    color: HomeColors.statusFacility,
                  ),
                ),
                const SizedBox(height: AppSpacing.lg),
                Text(
                  'Hapus Semua Notifikasi?',
                  style: HomeTextStyles.headlineSm.copyWith(
                    color: AppPalette.textPrimary(context),
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: AppSpacing.sm),
                Text(
                  'Semua notifikasi akan dihapus secara permanen dan tidak bisa dikembalikan.',
                  style: HomeTextStyles.bodyMd.copyWith(
                    color: AppPalette.textSecondary(context),
                    height: 1.5,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: AppSpacing.xl),
                Row(
                  children: [
                    // Batal
                    Expanded(
                      child: GestureDetector(
                        onTap: () => Navigator.pop(context),
                        child: Container(
                          height: 48,
                          decoration: BoxDecoration(
                            color: AppPalette.surfaceSubtle(context),
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: AppPalette.divider(context)),
                          ),
                          alignment: Alignment.center,
                          child: Text(
                            'Batal',
                            style: HomeTextStyles.labelLg.copyWith(
                              color: AppPalette.textPrimary(context),
                            ),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: AppSpacing.md),
                    // Hapus
                    Expanded(
                      child: GestureDetector(
                        onTap: onConfirm,
                        child: Container(
                          height: 48,
                          decoration: BoxDecoration(
                            color: HomeColors.statusFacility,
                            borderRadius: BorderRadius.circular(12),
                            boxShadow: [
                              BoxShadow(
                                color: HomeColors.statusFacility.withValues(alpha: 0.3),
                                blurRadius: 12,
                                offset: const Offset(0, 4),
                              ),
                            ],
                          ),
                          alignment: Alignment.center,
                          child: Text(
                            'Hapus Semua',
                            style: HomeTextStyles.labelLg.copyWith(
                              color: HomeColors.onPrimary,
                            ),
                          ),
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
    );
  }
}
