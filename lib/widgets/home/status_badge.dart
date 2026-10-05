import 'package:flutter/material.dart';

import '../../theme/home_text_styles.dart';

/// Horizontal padding inside the pill (Tailwind `px-2.5` = 10px).
const double _kPillHorizontalPadding = 10;

/// Vertical padding inside the pill (Tailwind `py-1` = 4px).
const double _kPillVerticalPadding = 4;

/// Gap between indicator (dot or icon) and label (Tailwind `gap-1` = 4px).
const double _kIndicatorGap = 4;

/// Diameter of the status dot (HTML `w-1.5 h-1.5` = 6px).
const double _kDotSize = 6;

/// Icon size for icon-variant badges (HTML `text-[14px]`).
const double _kBadgeIconSize = 14;

/// Compact pill badge used to categorize reports.
///
/// Two visual variants:
/// - **dot**: colored circle + label (e.g. "Kondisi Kampus").
/// - **icon**: Material icon + label (e.g. "Info Penting" with campaign icon).
class StatusBadge extends StatelessWidget {
  /// Creates a badge with a small colored dot indicator.
  const StatusBadge.dot({
    super.key,
    required this.label,
    required this.dotColor,
    required this.backgroundColor,
    required this.textColor,
  }) : icon = null;

  /// Creates a badge with a Material icon indicator.
  const StatusBadge.icon({
    super.key,
    required this.label,
    required this.icon,
    required this.backgroundColor,
    required this.textColor,
  }) : dotColor = null;

  /// Badge label text (e.g. "Kondisi Kampus").
  final String label;

  /// Dot color — only for the [StatusBadge.dot] variant.
  final Color? dotColor;

  /// Leading icon — only for the [StatusBadge.icon] variant.
  final IconData? icon;

  /// Pill background color.
  final Color backgroundColor;

  /// Label (and icon) text color.
  final Color textColor;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: _kPillHorizontalPadding,
        vertical: _kPillVerticalPadding,
      ),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(9999),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (dotColor != null)
            Container(
              width: _kDotSize,
              height: _kDotSize,
              decoration: BoxDecoration(
                color: dotColor,
                shape: BoxShape.circle,
              ),
            ),
          if (icon != null)
            Icon(icon, size: _kBadgeIconSize, color: textColor),
          const SizedBox(width: _kIndicatorGap),
          Text(
            label,
            style: HomeTextStyles.labelSm.copyWith(
              fontWeight: FontWeight.w700,
              color: textColor,
            ),
          ),
        ],
      ),
    );
  }
}
