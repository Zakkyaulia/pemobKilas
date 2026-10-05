import 'package:flutter/material.dart';

import '../../theme/home_colors.dart';
import '../../theme/home_text_styles.dart';

/// Design spec: `w-10 h-10` = 40×40 avatar.
const double _kDefaultSize = 40;

/// Icon size inside the avatar (HTML `text-[20px]`).
const double _kIconSize = 20;

/// Circular avatar displaying either [initials] text or an [icon].
///
/// Used in report card headers for user avatars (initials) and
/// official accounts (verified icon).
class UserAvatar extends StatelessWidget {
  const UserAvatar({
    super.key,
    this.initials,
    this.icon,
    required this.backgroundColor,
    this.foregroundColor = HomeColors.primary,
    this.size = _kDefaultSize,
  }) : assert(initials != null || icon != null,
            'Either initials or icon must be provided');

  /// Two-letter initials (e.g. "ZA", "AH").
  final String? initials;

  /// Icon to display instead of initials (e.g. [Icons.verified]).
  final IconData? icon;

  /// Circle background color.
  final Color backgroundColor;

  /// Text / icon color.
  final Color foregroundColor;

  /// Diameter of the circle.
  final double size;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: backgroundColor,
        shape: BoxShape.circle,
      ),
      alignment: Alignment.center,
      child: icon != null
          ? Icon(icon, size: _kIconSize, color: foregroundColor)
          : Text(
              initials!,
              style: HomeTextStyles.labelMd.copyWith(
                fontWeight: FontWeight.w700,
                color: foregroundColor,
              ),
            ),
    );
  }
}
