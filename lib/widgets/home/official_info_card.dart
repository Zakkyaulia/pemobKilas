import 'package:flutter/material.dart';

import '../../theme/app_spacing.dart';
import 'official_content_box.dart';
import 'report_card_footer.dart';

/// Vertical gap between major sections (Tailwind `gap-3` = 12px).
const double _kSectionGap = 12;

/// Full-width official information card for the home feed.
///
/// Similar to [ReportCard] but replaces the title/image area with
/// an [OfficialContentBox] (icon + title + description on a
/// tinted background).
class OfficialInfoCard extends StatelessWidget {
  const OfficialInfoCard({
    super.key,
    required this.header,
    required this.contentIcon,
    required this.contentTitle,
    required this.contentDescription,
    required this.upvoteCount,
    this.isUpvoted = false,
    this.onUpvoteChanged,
    this.onBookmarkChanged,
    this.onSharePressed,
    this.onTap,
  });

  /// Pre-built [ReportCardHeader] widget.
  final Widget header;

  /// Icon for the [OfficialContentBox] (e.g. [Icons.elevator]).
  final IconData contentIcon;

  /// Title shown inside the content box.
  final String contentTitle;

  /// Description shown inside the content box (2-line clamp).
  final String contentDescription;

  /// Upvote count for the footer pill.
  final int upvoteCount;

  /// Whether the upvote starts active.
  final bool isUpvoted;

  /// Upvote state change callback.
  final void Function(bool isUpvoted, int count)? onUpvoteChanged;

  /// Bookmark state change callback.
  final void Function(bool isBookmarked)? onBookmarkChanged;

  /// Share button callback.
  final VoidCallback? onSharePressed;

  /// Tapped anywhere on the card (navigates to detail).
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.lg),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            header,
            const SizedBox(height: _kSectionGap),
            OfficialContentBox(
              icon: contentIcon,
              title: contentTitle,
              description: contentDescription,
            ),
            const SizedBox(height: _kSectionGap),
            ReportCardFooter(
              upvoteCount: upvoteCount,
              isUpvoted: isUpvoted,
              onUpvoteChanged: onUpvoteChanged,
              onBookmarkChanged: onBookmarkChanged,
              onSharePressed: onSharePressed,
            ),
          ],
        ),
      ),
    );
  }
}
