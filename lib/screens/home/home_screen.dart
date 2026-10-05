import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../theme/app_spacing.dart';
import '../../theme/home_colors.dart';
import '../../theme/home_text_styles.dart';
import '../../widgets/home/home_app_bar.dart';
import '../../widgets/home/home_bottom_nav.dart';
import '../../widgets/home/official_info_card.dart';
import '../../widgets/home/pull_to_refresh_hint.dart';
import '../../widgets/home/report_card.dart';
import '../../widgets/home/report_card_header.dart';
import '../../widgets/home/status_badge.dart';
import '../../widgets/home/user_avatar.dart';
import 'data/mock_reports.dart';
import 'models/report_model.dart';
import 'report_detail_screen.dart';

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
  late List<ReportModel> _reports;

  @override
  void initState() {
    super.initState();
    _reports = List<ReportModel>.from(mockReports);
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
      setState(() {
        final index = _reports.indexWhere((r) => r.id == updatedReport.id);
        if (index != -1) {
          _reports[index] = updatedReport;
        }
      });
    }
  }

  void _handleFeedUpvote(int index, bool isUpvoted, int count) {
    setState(() {
      _reports[index] = _reports[index].copyWith(
        isUpvoted: isUpvoted,
        upvoteCount: count,
      );
    });

    // 4. Feedback: SnackBar
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          content: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                isUpvoted ? Icons.thumb_up : Icons.thumb_up_alt_outlined,
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

  void _handleFeedBookmark(int index, bool isBookmarked) {
    setState(() {
      _reports[index] = _reports[index].copyWith(
        isBookmarked: isBookmarked,
      );
    });

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

  @override
  Widget build(BuildContext context) {
    final topPadding = MediaQuery.of(context).padding.top;
    final bottomPadding = MediaQuery.of(context).padding.bottom;

    // Header = status bar + 64px bar height.
    final headerHeight = topPadding + 64;
    // Bottom nav = 64px bar + safe area + extra space for FAB overflow.
    final bottomNavHeight = 64 + bottomPadding + 20;

    return Scaffold(
      backgroundColor: HomeColors.canvasBase,
      body: Stack(
        children: [
          // ── Scrollable feed ──────────────────────────────────────
          RefreshIndicator(
            color: HomeColors.primaryContainer,
            onRefresh: () => Future<void>.delayed(const Duration(seconds: 1)),
            child: ListView(
              padding: EdgeInsets.only(
                top: headerHeight,
                bottom: bottomNavHeight,
              ),
              children: [
                Container(
                  color: HomeColors.surfacePure,
                  child: Column(
                    children: [
                      const PullToRefreshHint(),
                      for (int i = 0; i < _reports.length; i++) ...[
                        if (i > 0)
                          const Divider(
                            height: 1,
                            thickness: 1,
                            color: HomeColors.surfaceContainer,
                          ),
                        _FeedItem(
                          report: _reports[i],
                          onTap: () => _navigateToDetail(_reports[i]),
                          onUpvoteChanged: (isUpvoted, count) =>
                              _handleFeedUpvote(i, isUpvoted, count),
                          onBookmarkChanged: (isBookmarked) =>
                              _handleFeedBookmark(i, isBookmarked),
                          onSharePressed: () =>
                              _showShareToast(context, _reports[i].id),
                        ),
                      ],
                    ],
                  ),
                ),
              ],
            ),
          ),

          // ── Fixed header ─────────────────────────────────────────
          const Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: HomeAppBar(),
          ),

          // ── Fixed bottom nav ─────────────────────────────────────
          const Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: HomeBottomNav(),
          ),
        ],
      ),
    );
  }
}

/// Maps a [ReportModel] to the appropriate card widget
/// ([ReportCard] or [OfficialInfoCard]).
class _FeedItem extends StatelessWidget {
  const _FeedItem({
    required this.report,
    this.onTap,
    this.onUpvoteChanged,
    this.onBookmarkChanged,
    this.onSharePressed,
  });

  final ReportModel report;
  final VoidCallback? onTap;
  final void Function(bool isUpvoted, int count)? onUpvoteChanged;
  final void Function(bool isBookmarked)? onBookmarkChanged;
  final VoidCallback? onSharePressed;

  @override
  Widget build(BuildContext context) {
    final header = _buildHeader();

    if (report.cardType == CardType.official) {
      return OfficialInfoCard(
        header: header,
        contentIcon: report.contentIcon!,
        contentTitle: report.contentTitle!,
        contentDescription: report.contentDescription!,
        upvoteCount: report.upvoteCount,
        isUpvoted: report.isUpvoted,
        isBookmarked: report.isBookmarked,
        onTap: onTap,
        onUpvoteChanged: onUpvoteChanged,
        onBookmarkChanged: onBookmarkChanged,
        onSharePressed: onSharePressed,
      );
    }

    return ReportCard(
      header: header,
      title: report.title!,
      description: report.description!,
      imageUrl: report.imageUrl,
      imageHeight: report.imageHeight ?? 224,
      aspectRatio: report.aspectRatio,
      imageSemanticLabel: report.imageSemanticLabel,
      upvoteCount: report.upvoteCount,
      isUpvoted: report.isUpvoted,
      isBookmarked: report.isBookmarked,
      onTap: onTap,
      onUpvoteChanged: onUpvoteChanged,
      onBookmarkChanged: onBookmarkChanged,
      onSharePressed: onSharePressed,
    );
  }

  ReportCardHeader _buildHeader() {
    final Widget avatar = report.authorInitials != null
        ? UserAvatar(
            initials: report.authorInitials,
            backgroundColor: report.avatarBgColor,
            foregroundColor: report.avatarFgColor,
          )
        : UserAvatar(
            icon: report.authorIcon,
            backgroundColor: report.avatarBgColor,
            foregroundColor: report.avatarFgColor,
          );

    final Widget badge = report.badgeVariant == BadgeVariant.dot
        ? StatusBadge.dot(
            label: report.badgeLabel,
            dotColor: report.badgeDotColor!,
            backgroundColor: report.badgeBgColor,
            textColor: report.badgeTextColor,
          )
        : StatusBadge.icon(
            label: report.badgeLabel,
            icon: report.badgeIcon!,
            backgroundColor: report.badgeBgColor,
            textColor: report.badgeTextColor,
          );

    return ReportCardHeader(
      avatar: avatar,
      displayName: report.authorName,
      username: report.authorUsername,
      isVerified: report.isVerified,
      metaIcon: report.metaIcon,
      metaIconColor: report.metaIconColor,
      metaText: report.metaText,
      badge: badge,
    );
  }
}
