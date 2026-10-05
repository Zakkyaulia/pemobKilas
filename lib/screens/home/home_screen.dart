import 'package:flutter/material.dart';

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
/// ```
/// Scaffold
///  └── Stack
///       ├── RefreshIndicator + ListView (scrollable feed)
///       ├── HomeAppBar (fixed top, frosted glass)
///       └── HomeBottomNav (fixed bottom, frosted glass)
/// ```
class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  void _showShareToast(BuildContext context) {
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
                      for (int i = 0; i < mockReports.length; i++) ...[
                        if (i > 0)
                          const Divider(
                            height: 1,
                            thickness: 1,
                            color: HomeColors.surfaceContainer,
                          ),
                        _FeedItem(
                          report: mockReports[i],
                          onSharePressed: () => _showShareToast(context),
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
    this.onSharePressed,
  });

  final ReportModel report;
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
        onSharePressed: onSharePressed,
      );
    }

    return ReportCard(
      header: header,
      title: report.title!,
      description: report.description!,
      imageUrl: report.imageUrl,
      imageHeight: report.imageHeight ?? 224,
      imageSemanticLabel: report.imageSemanticLabel,
      upvoteCount: report.upvoteCount,
      isUpvoted: report.isUpvoted,
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
