import 'package:flutter/material.dart';

import '../../theme/home_colors.dart';

/// Button size (40px circular container matching upvote height).
const double _kButtonSize = 40;

/// Icon size (22px).
const double _kIconSize = 22;

/// Share button with circular touch target that triggers an [onPressed] callback.
class ShareButton extends StatelessWidget {
  const ShareButton({super.key, this.onPressed});

  /// Called when the button is tapped.
  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onPressed,
      behavior: HitTestBehavior.opaque,
      child: Container(
        width: _kButtonSize,
        height: _kButtonSize,
        decoration: const BoxDecoration(
          color: HomeColors.surfaceSubtle,
          shape: BoxShape.circle,
        ),
        child: const Center(
          child: Icon(
            Icons.share_outlined,
            size: _kIconSize,
            color: HomeColors.onSurfaceVariant,
          ),
        ),
      ),
    );
  }
}
