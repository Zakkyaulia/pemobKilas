import 'package:flutter/material.dart';

import '../../theme/app_spacing.dart';
import '../../theme/home_colors.dart';
import '../../theme/home_text_styles.dart';
import 'network_image_box.dart';
import 'report_card_footer.dart';
import 'report_card_header.dart';

/// Gap between title and description (Tailwind `gap-1` = 4px).
const double _kTitleDescGap = 4;

/// Vertical gap between major sections (Tailwind `gap-3` = 12px).
const double _kSectionGap = 12;

/// Full-width user report card for the home feed.
///
/// Composes [ReportCardHeader], title, description, an optional
/// [NetworkImageBox], and [ReportCardFooter].
class ReportCard extends StatelessWidget {
  const ReportCard({
    super.key,
    required this.header,
    required this.title,
    required this.description,
    this.imageUrl,
    this.imageHeight = 224,
    this.aspectRatio,
    this.imageSemanticLabel,
    required this.upvoteCount,
    this.isUpvoted = false,
    this.isBookmarked = false,
    this.onUpvoteChanged,
    this.onBookmarkChanged,
    this.onSharePressed,
    this.onTap,
  });

  /// Pre-built [ReportCardHeader] widget.
  final Widget header;

  /// Report title (bold headline).
  final String title;

  /// Report body text (clamped to 2 lines).
  final String description;

  /// Optional photo URL — omit for text-only reports.
  final String? imageUrl;

  /// Height of the image container (default 224px = Tailwind `h-56`).
  final double imageHeight;

  /// Optional dynamic aspect ratio (e.g. 16/9, 1/1, 4/3, 9/16).
  final double? aspectRatio;

  /// Accessibility label for the image.
  final String? imageSemanticLabel;

  /// Upvote count for the footer pill.
  final int upvoteCount;

  /// Whether the upvote starts active.
  final bool isUpvoted;

  /// Whether the bookmark starts active.
  final bool isBookmarked;

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
            _TitleDescription(title: title, description: description),
            if (imageUrl != null) ...[
              const SizedBox(height: _kSectionGap),
              NetworkImageBox(
                imageUrl: imageUrl!,
                height: aspectRatio == null ? imageHeight : null,
                aspectRatio: aspectRatio,
                semanticLabel: imageSemanticLabel,
              ),
            ],
            const SizedBox(height: _kSectionGap),
            ReportCardFooter(
              upvoteCount: upvoteCount,
              isUpvoted: isUpvoted,
              isBookmarked: isBookmarked,
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

/// Title + description text block with tight vertical spacing.
class _TitleDescription extends StatelessWidget {
  const _TitleDescription({
    required this.title,
    required this.description,
  });

  final String title;
  final String description;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: HomeTextStyles.headlineSm.copyWith(
            fontWeight: FontWeight.w700,
            color: HomeColors.onSurface,
            height: 1.375,
          ),
        ),
        const SizedBox(height: _kTitleDescGap),
        Text(
          description,
          style: HomeTextStyles.bodyMd.copyWith(
            color: HomeColors.onSurfaceVariant,
            height: 1.625,
          ),
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
        ),
      ],
    );
  }
}
