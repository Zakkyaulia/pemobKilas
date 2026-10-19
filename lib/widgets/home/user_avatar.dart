import 'dart:io';
import 'package:flutter/material.dart';

import '../../theme/home_colors.dart';
import '../../theme/home_text_styles.dart';

/// Design spec: `w-10 h-10` = 40×40 avatar.
const double _kDefaultSize = 40;

/// Icon size inside the avatar (HTML `text-[20px]`).
const double _kIconSize = 20;

/// Circular avatar displaying an [avatarUrl], [initials] text, or an [icon].
///
/// Used in report card headers for user avatars and official accounts.
class UserAvatar extends StatelessWidget {
  const UserAvatar({
    super.key,
    this.avatarUrl,
    this.initials,
    this.icon,
    required this.backgroundColor,
    this.foregroundColor = HomeColors.primary,
    this.size = _kDefaultSize,
  }) : assert(avatarUrl != null || initials != null || icon != null,
            'Either avatarUrl, initials, or icon must be provided');

  /// URL, file path, or asset path to the user's avatar image.
  final String? avatarUrl;

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

  Widget _buildFallback() {
    return icon != null
        ? Icon(icon, size: _kIconSize, color: foregroundColor)
        : Text(
            initials ?? 'U',
            style: HomeTextStyles.labelMd.copyWith(
              fontWeight: FontWeight.w700,
              color: foregroundColor,
            ),
          );
  }

  Widget _buildImage(String url) {
    if (url.startsWith('http://') || url.startsWith('https://')) {
      return Image.network(
        url,
        width: size,
        height: size,
        fit: BoxFit.cover,
        errorBuilder: (_, _, _) => _buildFallback(),
      );
    }
    if (url.startsWith('assets/')) {
      return Image.asset(
        url,
        width: size,
        height: size,
        fit: BoxFit.cover,
        errorBuilder: (_, _, _) => _buildFallback(),
      );
    }
    return Image.file(
      File(url),
      width: size,
      height: size,
      fit: BoxFit.cover,
      errorBuilder: (_, _, _) => _buildFallback(),
    );
  }

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
      child: ClipOval(
        child: (avatarUrl != null && avatarUrl!.isNotEmpty)
            ? _buildImage(avatarUrl!)
            : _buildFallback(),
      ),
    );
  }
}
