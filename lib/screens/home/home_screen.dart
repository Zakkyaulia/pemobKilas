import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../theme/app_palette.dart';
import '../../theme/app_spacing.dart';
import '../../theme/home_colors.dart';
import '../../theme/home_text_styles.dart';
import '../../widgets/home/home_app_bar.dart';
import '../../widgets/home/report_card.dart';
import '../../widgets/home/report_card_header.dart';
import '../../widgets/home/status_badge.dart';
import '../../widgets/home/user_avatar.dart';
import '../profile/data/user_profile_repository.dart';
import '../profile/models/user_profile_model.dart';
import '../search/search_filter_screen.dart';
import 'data/report_repository.dart';
import 'models/report_model.dart';
import 'report_detail_screen.dart';
import '../profile/public_profile_screen.dart';

/// Toast icon size (HTML `text-[18px]`).
const double _kToastIconSize = 18;

/// Toast gap between icon and text (Tailwind `gap-2` = 8px).
const double _kToastGap = 8;

/// Toast vertical padding (Tailwind `py-2.5` = 10px).
const double _kToastVPadding = 10;

/// Bottom margin to position toast above nav (HTML `bottom-20` = 80px).
const double _kToastBottomMargin = 80;

/// Horizontal margin for the toast pill.
const double _kToastHMargin = 40;

/// Jarak sisa scroll (px) ke bawah sebelum halaman berikutnya dimuat.
const double _kLoadMoreThreshold = 400;

/// Home screen — Beranda feed assembling header, cards, and bottom nav.
///
/// Mengelola state feed laporan lokal `_reports` dan menangani navigasi
/// ke [ReportDetailScreen] serta menerima data return (pop result).
class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final ReportRepository _repo = ReportRepository.instance;

  /// Filter terakhir yang diterapkan di halaman Cari & Filter (disimpan di memori).
  SearchFilterResult? _lastFilter;

  final ScrollController _scrollController = ScrollController();

  /// Pesan error saat halaman pertama gagal dimuat (feed masih kosong).
  String? _initialError;

  @override
  void initState() {
    super.initState();
    // Listen to repository changes (e.g. from detail screen) to rebuild feed
    _repo.addListener(_onRepoChanged);
    _scrollController.addListener(_onScroll);
    WidgetsBinding.instance.addPostFrameCallback((_) => _refreshFeed());
  }

  @override
  void dispose() {
    _repo.removeListener(_onRepoChanged);
    _scrollController
      ..removeListener(_onScroll)
      ..dispose();
    super.dispose();
  }

  void _onRepoChanged() {
    if (mounted) setState(() {});
  }

  /// Infinite scroll: saat mendekati bawah, muat 20 laporan berikutnya.
  void _onScroll() {
    if (!_scrollController.hasClients) return;
    // Setelah gagal, muat ulang hanya lewat tombol "Coba lagi" (cegah spam request).
    if (_repo.loadMoreError != null) return;
    if (_scrollController.position.extentAfter < _kLoadMoreThreshold) {
      _repo.loadMore();
    }
  }

  /// Muat ulang feed dari laporan terbaru (buka Home & pull-to-refresh).
  Future<void> _refreshFeed() async {
    try {
      await _repo.refresh();
      if (mounted) setState(() => _initialError = null);
    } catch (e) {
      if (!mounted) return;
      if (_repo.length == 0) {
        setState(() => _initialError = e.toString());
      } else {
        // Feed lama tetap ditampilkan; cukup beri tahu bahwa refresh gagal.
        ScaffoldMessenger.of(context)
          ..hideCurrentSnackBar()
          ..showSnackBar(
            const SnackBar(
              content: Text('Gagal memperbarui laporan. Periksa koneksi lalu coba lagi.'),
              behavior: SnackBarBehavior.floating,
            ),
          );
      }
    }
  }

  /// Kembali ke feed tanpa filter (semua laporan, terbaru di atas).
  Future<void> _clearFilter() async {
    setState(() => _lastFilter = null);
    try {
      await _repo.refresh(filter: ReportFilter.none);
    } catch (_) {
      if (!mounted) return;
      ScaffoldMessenger.of(context)
        ..hideCurrentSnackBar()
        ..showSnackBar(
          const SnackBar(
            content: Text('Gagal memuat ulang laporan. Periksa koneksi lalu coba lagi.'),
            behavior: SnackBarBehavior.floating,
          ),
        );
    }
  }

  /// Bar di atas feed yang menandakan filter sedang aktif.
  Widget _buildActiveFilterBar(BuildContext context) {
    final summary = _lastFilter?.summary ?? '';
    final total = _repo.totalCount;
    return Container(
      margin: const EdgeInsets.fromLTRB(AppSpacing.lg, AppSpacing.sm, AppSpacing.lg, AppSpacing.sm),
      padding: const EdgeInsets.only(left: 12),
      decoration: BoxDecoration(
        color: HomeColors.primaryContainer.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: HomeColors.primaryContainer.withValues(alpha: 0.3)),
      ),
      child: Row(
        children: [
          const Icon(Icons.filter_list, size: 18, color: HomeColors.primaryContainer),
          const SizedBox(width: 8),
          Expanded(
            child: GestureDetector(
              onTap: _navigateToSearch,
              child: Text(
                [
                  'Filter aktif',
                  if (summary.isNotEmpty) summary,
                  if (total != null) '$total laporan',
                ].join(' · '),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: HomeTextStyles.labelMd.copyWith(
                  color: AppPalette.textPrimary(context),
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
          TextButton(
            onPressed: _clearFilter,
            child: const Text('Hapus'),
          ),
        ],
      ),
    );
  }

  /// Baris paling bawah feed: loading, error, kosong, atau "sudah semua".
  Widget _buildFeedFooter(BuildContext context) {
    final secondary = AppPalette.textSecondary(context);
    Widget message(String text, {IconData? icon, Widget? action}) => Padding(
          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xl, vertical: 32),
          child: Column(
            children: [
              if (icon != null) ...[
                Icon(icon, size: 40, color: secondary),
                const SizedBox(height: 12),
              ],
              Text(
                text,
                textAlign: TextAlign.center,
                style: HomeTextStyles.bodySm.copyWith(color: secondary, height: 1.4),
              ),
              ?action,
            ],
          ),
        );

    // Halaman pertama belum pernah berhasil dimuat
    if (!_repo.hasLoadedOnce) {
      if (_repo.isLoading || _initialError == null) {
        return const Padding(
          padding: EdgeInsets.symmetric(vertical: 48),
          child: Center(child: CircularProgressIndicator()),
        );
      }
      return message(
        'Gagal memuat laporan. Tarik ke bawah untuk mencoba lagi.',
        icon: Icons.cloud_off_rounded,
      );
    }

    if (_repo.length == 0) {
      if (_repo.activeFilter.isActive) {
        return message(
          'Tidak ada laporan yang cocok dengan filter ini.',
          icon: Icons.search_off_rounded,
          action: TextButton(onPressed: _clearFilter, child: const Text('Hapus filter')),
        );
      }
      return message(
        'Belum ada laporan. Jadilah yang pertama melaporkan kondisi kampus!',
        icon: Icons.inbox_outlined,
      );
    }

    if (_repo.isLoadingMore) {
      return const Padding(
        padding: EdgeInsets.symmetric(vertical: 24),
        child: Center(
          child: SizedBox(width: 24, height: 24, child: CircularProgressIndicator(strokeWidth: 2.5)),
        ),
      );
    }

    if (_repo.loadMoreError != null) {
      return message(
        'Gagal memuat laporan berikutnya.',
        action: TextButton(
          onPressed: _repo.loadMore,
          child: const Text('Coba lagi'),
        ),
      );
    }

    if (!_repo.hasMore) {
      return message('Semua laporan sudah ditampilkan');
    }

    return const SizedBox(height: 48);
  }

  /// 5. Navigation / Result Workflow:
  /// Berpindah ke [ReportDetailScreen] membawa objek data [ReportModel],
  /// lalu menunggu (await) nilai result yang dikembalikan saat user kembali.
  Future<void> _navigateToDetail(ReportModel report) async {
    final updatedReport = await Navigator.push<ReportModel>(
      context,
      MaterialPageRoute(
        builder: (context) => ReportDetailScreen(report: report),
      ),
    );

    // Jika ada hasil perubahan data dari halaman detail, perbarui state feed
    if (updatedReport != null && mounted) {
      _repo.updateById(updatedReport.id, updatedReport);
    }
  }

  /// Navigasi ke halaman Cari & Filter, lalu terima hasil filter dari pop result.
  /// Ini mendemonstrasikan Navigation/Result workflow: mengirim data antar screen.
  Future<void> _navigateToSearch() async {
    final filterResult = await Navigator.push<SearchFilterResult>(
      context,
      MaterialPageRoute(
        // Kirim filter terakhir ke screen berikutnya agar pilihan user tidak reset
        builder: (context) => SearchFilterScreen(initialFilter: _lastFilter),
      ),
    );

    // 5. Navigation/Result: Terima data result dari screen Cari & Filter
    // (null berarti user kembali tanpa menekan "Terapkan filter")
    if (filterResult != null && mounted) {
      // Feed sudah difilter oleh layar Cari & Filter (repository yang sama).
      setState(() => _lastFilter = filterResult.isActive ? filterResult : null);

      ScaffoldMessenger.of(context)
        ..hideCurrentSnackBar()
        ..showSnackBar(
          SnackBar(
            content: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.filter_list,
                    size: _kToastIconSize, color: Colors.blueAccent),
                const SizedBox(width: _kToastGap),
                Flexible(
                  child: Text(
                    'Filter diterapkan: ${filterResult.resultCount} laporan',
                    style: HomeTextStyles.labelMd.copyWith(
                      color: HomeColors.inverseOnSurface,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
            backgroundColor: HomeColors.inverseSurface,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(9999),
            ),
            elevation: 20,
            padding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.lg,
              vertical: _kToastVPadding,
            ),
            margin: const EdgeInsets.fromLTRB(
              _kToastHMargin,
              0,
              _kToastHMargin,
              _kToastBottomMargin,
            ),
            duration: const Duration(seconds: 2),
          ),
        );
    }
  }

  void _handleFeedUpvote(int index, bool isUpvoted, int count) {
    final report = _repo[index];
    _repo.syncUpvote(report.id, isUpvoted, count);

    if (isUpvoted) {
      UserProfileRepository.instance.addActivity(
        actionType: ActivityActionType.upvote,
        title: 'Memberikan Upvote',
        description: 'Upvote pada laporan "${report.title ?? "Laporan Kampus"}"',
        reportId: report.id,
      );
    }

    // 4. Feedback: SnackBar
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          content: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.arrow_upward_rounded,
                size: _kToastIconSize,
                color: isUpvoted ? Colors.greenAccent : Colors.orangeAccent,
              ),
              const SizedBox(width: _kToastGap),
              Text(
                isUpvoted ? 'Upvote ditambahkan (+1)' : 'Upvote ditarik (-1)',
                style: HomeTextStyles.labelMd.copyWith(
                  color: HomeColors.inverseOnSurface,
                ),
              ),
            ],
          ),
          backgroundColor: HomeColors.inverseSurface,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(9999),
          ),
          elevation: 20,
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.lg,
            vertical: _kToastVPadding,
          ),
          margin: const EdgeInsets.fromLTRB(
            _kToastHMargin,
            0,
            _kToastHMargin,
            _kToastBottomMargin,
          ),
          duration: const Duration(seconds: 2),
        ),
      );
  }

  /// 3. Validation & 4. Feedback (Feed Level):
  /// Memberikan feedback ketika tap upvote di feed dilakukan terlalu cepat (< 2 detik).
  void _handleFeedUpvoteCooldown() {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          content: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(
                Icons.hourglass_empty_rounded,
                size: _kToastIconSize,
                color: HomeColors.statusCondition,
              ),
              const SizedBox(width: _kToastGap),
              Flexible(
                child: Text(
                  'Tunggu sebentar sebelum vote lagi',
                  style: HomeTextStyles.labelMd.copyWith(
                    color: HomeColors.inverseOnSurface,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
          backgroundColor: HomeColors.inverseSurface,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(9999),
          ),
          elevation: 20,
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.lg,
            vertical: _kToastVPadding,
          ),
          margin: const EdgeInsets.fromLTRB(
            _kToastHMargin,
            0,
            _kToastHMargin,
            _kToastBottomMargin,
          ),
          duration: const Duration(milliseconds: 1500),
        ),
      );
  }

  void _handleFeedBookmark(int index, bool isBookmarked) {
    final report = _repo[index];
    _repo.syncBookmark(report.id, isBookmarked);

    UserProfileRepository.instance.addActivity(
      actionType: ActivityActionType.bookmark,
      title: isBookmarked ? 'Menyimpan ke Bookmark' : 'Menghapus Bookmark',
      description: isBookmarked
          ? 'Menyimpan laporan "${report.title ?? "Laporan Kampus"}"'
          : 'Menghapus laporan "${report.title ?? "Laporan Kampus"}" dari koleksi',
      reportId: report.id,
    );

    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          content: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                isBookmarked ? Icons.bookmark : Icons.bookmark_border,
                size: _kToastIconSize,
                color: isBookmarked ? Colors.blueAccent : Colors.white,
              ),
              const SizedBox(width: _kToastGap),
              Text(
                isBookmarked
                    ? 'Laporan disimpan ke bookmark'
                    : 'Laporan dihapus dari bookmark',
                style: HomeTextStyles.labelMd.copyWith(
                  color: HomeColors.inverseOnSurface,
                ),
              ),
            ],
          ),
          backgroundColor: HomeColors.inverseSurface,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(9999),
          ),
          elevation: 20,
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.lg,
            vertical: _kToastVPadding,
          ),
          margin: const EdgeInsets.fromLTRB(
            _kToastHMargin,
            0,
            _kToastHMargin,
            _kToastBottomMargin,
          ),
          duration: const Duration(seconds: 2),
        ),
      );
  }

  Future<void> _showShareToast(BuildContext context, String reportId) async {
    // Menyalin tautan unik laporan secara nyata ke clipboard perangkat
    await Clipboard.setData(
      ClipboardData(text: 'https://kilas.app/p/$reportId'),
    );

    if (!context.mounted) return;

    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          content: Row(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(
                Icons.check_circle,
                size: _kToastIconSize,
                color: HomeColors.statusResolved,
              ),
              const SizedBox(width: _kToastGap),
              Text(
                'Tautan disalin ke clipboard',
                style: HomeTextStyles.labelMd.copyWith(
                  color: HomeColors.inverseOnSurface,
                ),
              ),
            ],
          ),
          backgroundColor: HomeColors.inverseSurface,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(9999),
          ),
          elevation: 20,
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.lg,
            vertical: _kToastVPadding,
          ),
          margin: const EdgeInsets.fromLTRB(
            _kToastHMargin,
            0,
            _kToastHMargin,
            _kToastBottomMargin,
          ),
          duration: const Duration(seconds: 2),
        ),
      );
  }

  void _navigateToPublicProfile(ReportModel report) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => PublicProfileScreen.fromReport(report),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final topPadding = MediaQuery.of(context).padding.top;
    final bottomPadding = MediaQuery.of(context).padding.bottom;

    // Header = status bar + 64px bar height.
    final headerHeight = topPadding + 64;
    // Bottom nav = 64px bar + safe area + extra space for FAB overflow.
    final bottomNavHeight = 64 + bottomPadding + 20;

    return Scaffold(
      backgroundColor: AppPalette.canvas(context),
      body: Stack(
        children: [
          // ── Scrollable feed ──────────────────────────────────────
          RefreshIndicator(
            color: HomeColors.primaryContainer,
            // Pull-to-refresh: ulang dari laporan terbaru (halaman 1).
            onRefresh: _refreshFeed,
            // Infinite scroll: item dibangun saat terlihat, +1 baris footer.
            child: ListView.builder(
              controller: _scrollController,
              physics: const AlwaysScrollableScrollPhysics(),
              padding: EdgeInsets.only(
                top: headerHeight,
                bottom: bottomNavHeight,
              ),
              itemCount: _repo.length + 1 + (_repo.activeFilter.isActive ? 1 : 0),
              itemBuilder: (context, index) {
                final hasFilterBar = _repo.activeFilter.isActive;
                if (hasFilterBar && index == 0) return _buildActiveFilterBar(context);
                final i = hasFilterBar ? index - 1 : index;
                if (i == _repo.length) return _buildFeedFooter(context);
                final report = _repo[i];
                return ColoredBox(
                  color: AppPalette.surface(context),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      if (i > 0)
                        Divider(
                          height: 1,
                          thickness: 1,
                          color: AppPalette.divider(context),
                        ),
                      _FeedItem(
                        key: ValueKey(report.id),
                        report: report,
                        onTap: () => _navigateToDetail(report),
                        onAuthorTap: () => _navigateToPublicProfile(report),
                        onUpvoteChanged: (isUpvoted, count) =>
                            _handleFeedUpvote(i, isUpvoted, count),
                        onUpvoteCooldown: _handleFeedUpvoteCooldown,
                        onBookmarkChanged: (isBookmarked) =>
                            _handleFeedBookmark(i, isBookmarked),
                        onSharePressed: () => _showShareToast(context, report.id),
                      ),
                    ],
                  ),
                );
              },
            ),
          ),

          // ── Fixed header ─────────────────────────────────────────
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: HomeAppBar(onSearchPressed: _navigateToSearch),
          ),
        ],
      ),
    );
  }
}

/// Maps a [ReportModel] to a uniform [ReportCard] widget.
class _FeedItem extends StatelessWidget {
  const _FeedItem({
    super.key,
    required this.report,
    this.onTap,
    this.onAuthorTap,
    this.onUpvoteChanged,
    this.onUpvoteCooldown,
    this.onBookmarkChanged,
    this.onSharePressed,
  });

  final ReportModel report;
  final VoidCallback? onTap;
  final VoidCallback? onAuthorTap;
  final void Function(bool isUpvoted, int count)? onUpvoteChanged;
  final VoidCallback? onUpvoteCooldown;
  final void Function(bool isBookmarked)? onBookmarkChanged;
  final VoidCallback? onSharePressed;

  @override
  Widget build(BuildContext context) {
    return ReportCard(
      header: _buildHeader(),
      title: report.title ?? report.contentTitle ?? '',
      description: report.description ?? report.contentDescription ?? '',
      imageUrl: report.imageUrl,
      media: report.media,
      imageHeight: report.imageHeight ?? 224,
      aspectRatio: report.aspectRatio,
      imageSemanticLabel: report.imageSemanticLabel,
      upvoteCount: report.upvoteCount,
      isUpvoted: report.isUpvoted,
      isBookmarked: report.isBookmarked,
      timestamp: report.timeAgoDisplay,
      isEdited: report.isEdited,
      onTap: onTap,
      onUpvoteChanged: onUpvoteChanged,
      onUpvoteCooldown: onUpvoteCooldown,
      onBookmarkChanged: onBookmarkChanged,
      onSharePressed: onSharePressed,
    );
  }

  ReportCardHeader _buildHeader() {
    final currentUser = UserProfileRepository.instance.currentUser;
    final isCurrentUser = report.authorName == currentUser.nama ||
        report.authorUsername == currentUser.username;
    final effectiveAvatar = isCurrentUser ? currentUser.fotoProfil : report.authorAvatarUrl;

    final Widget avatar = UserAvatar(
      avatarUrl: effectiveAvatar,
      initials: report.authorInitials,
      icon: report.authorIcon,
      backgroundColor: report.avatarBgColor,
      foregroundColor: report.avatarFgColor,
    );

    final Widget badge = report.badgeVariant == BadgeVariant.dot
        ? StatusBadge.dot(
            label: report.badgeLabel,
            dotColor: report.badgeDotColor ?? HomeColors.statusCondition,
            backgroundColor: report.badgeBgColor,
            textColor: report.badgeTextColor,
          )
        : StatusBadge.icon(
            label: report.badgeLabel,
            icon: report.badgeIcon ?? Icons.campaign,
            backgroundColor: report.badgeBgColor,
            textColor: report.badgeTextColor,
          );

    return ReportCardHeader(
      avatar: avatar,
      displayName: report.authorName,
      // Jangan tampilkan email/handle di feed agar header lapang dan tidak menumpuk
      username: null,
      metaIcon: report.metaIcon,
      metaIconColor: report.metaIconColor,
      // Hanya lokasi (waktu upload dipindah ke footer di bawah button upvote)
      metaText: report.locationDisplay,
      badge: badge,
      onAuthorTap: onAuthorTap,
    );
  }
}
