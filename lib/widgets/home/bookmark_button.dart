import 'package:flutter/material.dart';

import '../../theme/home_colors.dart';

/// Button size (HTML `w-9 h-9` = 36px).
const double _kButtonSize = 36;

/// Icon size (HTML `text-[20px]`).
const double _kIconSize = 20;

/// Toggle-able bookmark button.
///
/// Switches between outline ([Icons.bookmark_border]) and
/// filled ([Icons.bookmark]) states on tap.
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

  void _toggle() {
    setState(() => _isBookmarked = !_isBookmarked);
    widget.onChanged?.call(_isBookmarked);
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: _toggle,
      child: SizedBox(
        width: _kButtonSize,
        height: _kButtonSize,
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
