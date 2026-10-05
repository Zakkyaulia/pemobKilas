import 'package:flutter/material.dart';

import '../../theme/home_colors.dart';

/// Button size (40px circular container matching upvote height).
const double _kButtonSize = 40;

/// Icon size (22px).
const double _kIconSize = 22;

/// Toggle-able bookmark button with circular touch target.
///
/// Switches between outline ([Icons.bookmark_border]) and
/// filled ([Icons.bookmark]) states on tap with smooth color transition.
class BookmarkButton extends StatefulWidget {
  const BookmarkButton({
    super.key,
    this.initialIsBookmarked = false,
    this.onChanged,
  });

  /// Whether the button starts in the bookmarked state.
  final bool initialIsBookmarked;

  /// Called when the bookmark state changes.
  final void Function(bool isBookmarked)? onChanged;

  @override
  State<BookmarkButton> createState() => _BookmarkButtonState();
}

class _BookmarkButtonState extends State<BookmarkButton> {
  late bool _isBookmarked;

  @override
  void initState() {
    super.initState();
    _isBookmarked = widget.initialIsBookmarked;
  }

  @override
  void didUpdateWidget(covariant BookmarkButton oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.initialIsBookmarked != widget.initialIsBookmarked) {
      _isBookmarked = widget.initialIsBookmarked;
    }
  }

  void _toggle() {
    setState(() => _isBookmarked = !_isBookmarked);
    widget.onChanged?.call(_isBookmarked);
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: _toggle,
      behavior: HitTestBehavior.opaque,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        width: _kButtonSize,
        height: _kButtonSize,
        decoration: BoxDecoration(
          color: _isBookmarked
              ? HomeColors.primary.withValues(alpha: 0.12)
              : HomeColors.surfaceSubtle,
          shape: BoxShape.circle,
        ),
        child: Center(
          child: Icon(
            _isBookmarked ? Icons.bookmark : Icons.bookmark_border,
            size: _kIconSize,
            color: _isBookmarked
                ? HomeColors.primaryContainer
                : HomeColors.onSurfaceVariant,
          ),
        ),
      ),
    );
  }
}
