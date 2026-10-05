import 'package:flutter/material.dart';

import '../../theme/home_colors.dart';

/// Button size (HTML `w-9 h-9` = 36px).
const double _kButtonSize = 36;

/// Icon size (HTML `text-[20px]`).
const double _kIconSize = 20;

/// Share / send button that triggers an [onPressed] callback.
///
/// The parent screen is responsible for showing the toast notification
/// ("Tautan disalin ke clipboard") via [ScaffoldMessenger].
class ShareButton extends StatelessWidget {
  const ShareButton({super.key, this.onPressed});

  /// Called when the button is tapped.
  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onPressed,
      child: const SizedBox(
        width: _kButtonSize,
        height: _kButtonSize,
        child: Center(
          child: Icon(
            Icons.send,
            size: _kIconSize,
            color: HomeColors.onSurfaceVariant,
          ),
        ),
      ),
    );
  }
}
