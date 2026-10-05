import 'package:flutter/material.dart';

import '../../theme/app_radius.dart';
import '../../theme/home_colors.dart';
import '../../theme/home_shadows.dart';
import '../../theme/home_text_styles.dart';

/// Inner padding (Tailwind `p-3.5` = 14px).
const double _kInnerPadding = 14;

/// Gap between icon circle and text (Tailwind `gap-3` = 12px).
const double _kContentGap = 12;

/// Icon circle size (HTML `w-10 h-10` = 40px).
const double _kIconCircleSize = 40;

/// Icon size inside the circle (HTML `text-[22px]`).
const double _kIconSize = 22;

/// Title font size override (HTML `text-[15px]`).
const double _kTitleFontSize = 15;

/// Top margin between title and description (Tailwind `mt-0.5` = 2px).
const double _kDescriptionTopMargin = 2;

/// Styled content box used inside official info cards.
///
/// Displays an icon in a white circle alongside a title and
/// two-line clamped description, on a tinted background with a border.
class OfficialContentBox extends StatelessWidget {
  const OfficialContentBox({
    super.key,
    required this.icon,
    required this.title,
    required this.description,
  });

  /// Leading icon (e.g. [Icons.elevator]).
  final IconData icon;

  /// Content title.
  final String title;

  /// Content description (clamped to 2 lines).
  final String description;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(_kInnerPadding),
      decoration: BoxDecoration(
        color: HomeColors.surfaceContainerLow,
        borderRadius: AppRadius.mediumAll,
        border: Border.all(color: HomeColors.surfaceContainer),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _IconCircle(icon: icon),
          const SizedBox(width: _kContentGap),
          Expanded(child: _TextContent(title: title, description: description)),
        ],
      ),
    );
  }
}

/// White circle with a primary-coloured icon and subtle shadow.
class _IconCircle extends StatelessWidget {
  const _IconCircle({required this.icon});

  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: _kIconCircleSize,
      height: _kIconCircleSize,
      decoration: const BoxDecoration(
        color: HomeColors.surfacePure,
        shape: BoxShape.circle,
        boxShadow: HomeShadows.sm,
      ),
      alignment: Alignment.center,
      child: Icon(icon, size: _kIconSize, color: HomeColors.primary),
    );
  }
}

/// Title and description text for the content box.
class _TextContent extends StatelessWidget {
  const _TextContent({required this.title, required this.description});

  final String title;
  final String description;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          title,
          style: HomeTextStyles.headlineSm.copyWith(
            fontSize: _kTitleFontSize,
            fontWeight: FontWeight.w700,
            color: HomeColors.onSurface,
          ),
        ),
        const SizedBox(height: _kDescriptionTopMargin),
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
