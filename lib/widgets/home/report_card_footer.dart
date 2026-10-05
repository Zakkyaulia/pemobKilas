import 'package:flutter/material.dart';

import '../../theme/app_spacing.dart';
import 'bookmark_button.dart';
import 'share_button.dart';
import 'upvote_button.dart';

/// Gap between bookmark and share buttons (Tailwind `gap-1` = 4px).
const double _kActionGap = 4;

/// Footer row for report and info cards containing
/// upvote pill, bookmark toggle, and share button.
class ReportCardFooter extends StatelessWidget {
  const ReportCardFooter({
    super.key,
    required this.upvoteCount,
    this.isUpvoted = false,
    this.isBookmarked = false,
    this.onUpvoteChanged,
    this.onBookmarkChanged,
    this.onSharePressed,
  });

  /// Initial upvote count displayed in the pill.
  final int upvoteCount;

  /// Whether the upvote starts in active state.
  final bool isUpvoted;

  /// Whether the bookmark starts in active state.
  final bool isBookmarked;

  /// Called when the upvote state changes.
  final void Function(bool isUpvoted, int count)? onUpvoteChanged;

  /// Called when the bookmark state changes.
  final void Function(bool isBookmarked)? onBookmarkChanged;

  /// Called when the share button is tapped.
  final VoidCallback? onSharePressed;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: AppSpacing.xs),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          UpvoteButton(
            initialCount: upvoteCount,
            initialIsUpvoted: isUpvoted,
            onChanged: onUpvoteChanged,
          ),
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              BookmarkButton(
                initialIsBookmarked: isBookmarked,
                onChanged: onBookmarkChanged,
              ),
              const SizedBox(width: _kActionGap),
              ShareButton(onPressed: onSharePressed),
            ],
          ),
        ],
      ),
    );
  }
}
