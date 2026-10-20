import 'package:flutter/material.dart';

import '../../theme/app_palette.dart';
import '../../theme/app_spacing.dart';
import '../../theme/home_text_styles.dart';
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
    this.onUpvoteCooldown,
    this.onBookmarkChanged,
    this.onSharePressed,
    this.timestamp,
    this.timestampAlignment = CrossAxisAlignment.start,
  });

  /// Initial upvote count displayed in the pill.
  final int upvoteCount;

  /// Whether the upvote starts in active state.
  final bool isUpvoted;

  /// Whether the bookmark starts in active state.
  final bool isBookmarked;

  /// Called when the upvote state changes.
  final void Function(bool isUpvoted, int count)? onUpvoteChanged;

  /// Called when upvote tap is rejected due to cooldown (validation feedback).
  final VoidCallback? onUpvoteCooldown;

  /// Called when the bookmark state changes.
  final void Function(bool isBookmarked)? onBookmarkChanged;

  /// Called when the share button is tapped.
  final VoidCallback? onSharePressed;

  /// Upload timestamp / relative time (e.g. "15m lalu" or "15 menit yang lalu").
  final String? timestamp;

  /// Alignment of the timestamp below the actions (default: start / below upvote).
  final CrossAxisAlignment timestampAlignment;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: AppSpacing.xs),
      child: Column(
        crossAxisAlignment: timestampAlignment,
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              UpvoteButton(
                initialCount: upvoteCount,
                initialIsUpvoted: isUpvoted,
                onChanged: onUpvoteChanged,
                onCooldownTriggered: onUpvoteCooldown,
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
          if (timestamp != null && timestamp!.isNotEmpty) ...[
            const SizedBox(height: 8),
            Padding(
              padding: const EdgeInsets.only(left: 2, right: 2),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.access_time_rounded,
                    size: 13,
                    color: AppPalette.textSecondary(context),
                  ),
                  const SizedBox(width: 4),
                  Text(
                    timestamp!,
                    style: HomeTextStyles.labelSm.copyWith(
                      color: AppPalette.textSecondary(context),
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }
}
