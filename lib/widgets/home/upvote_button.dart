import 'package:flutter/material.dart';

import '../../theme/home_colors.dart';
import '../../theme/home_shadows.dart';
import '../../theme/home_text_styles.dart';

/// Horizontal padding (Tailwind `px-3` = 12px).
const double _kHorizontalPadding = 12;

/// Vertical padding (Tailwind `py-1.5` = 6px).
const double _kVerticalPadding = 6;

/// Gap between icon and count (Tailwind `gap-1.5` = 6px).
const double _kGap = 6;

/// Arrow icon size (HTML `text-[16px]`).
const double _kIconSize = 16;

/// Toggle-able upvote pill button with an arrow icon and count.
///
/// **Active state**: blue background ([HomeColors.primaryContainer]),
/// white text, small shadow.
/// **Inactive state**: subtle grey background ([HomeColors.surfaceSubtle]),
/// dark text, no shadow.
class UpvoteButton extends StatefulWidget {
  const UpvoteButton({
    super.key,
    required this.initialCount,
    this.initialIsUpvoted = false,
    this.onChanged,
    this.cooldownDuration = const Duration(seconds: 2),
    this.onCooldownTriggered,
  });

  /// Starting vote count.
  final int initialCount;

  /// Whether the button starts in the active (upvoted) state.
  final bool initialIsUpvoted;

  /// Called when the upvote state changes.
  final void Function(bool isUpvoted, int count)? onChanged;

  /// Cooldown duration between consecutive taps (anti-spam validation).
  final Duration cooldownDuration;

  /// Called when the user taps within the cooldown period (validation rejection).
  final VoidCallback? onCooldownTriggered;

  @override
  State<UpvoteButton> createState() => _UpvoteButtonState();
}

class _UpvoteButtonState extends State<UpvoteButton> {
  late bool _isUpvoted;
  late int _count;
  DateTime? _lastTapTime;

  @override
  void initState() {
    super.initState();
    _isUpvoted = widget.initialIsUpvoted;
    _count = widget.initialCount;
  }

  @override
  void didUpdateWidget(covariant UpvoteButton oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.initialIsUpvoted != widget.initialIsUpvoted ||
        oldWidget.initialCount != widget.initialCount) {
      _isUpvoted = widget.initialIsUpvoted;
      _count = widget.initialCount;
    }
  }

  void _toggle() {
    final now = DateTime.now();

    // ── 3. Validation: Cooldown rate-limit check (< 2 detik dianggap spam/invalid) ──
    if (_lastTapTime != null &&
        now.difference(_lastTapTime!) < widget.cooldownDuration) {
      widget.onCooldownTriggered?.call();
      return; // Tolak aksi: state tidak berubah
    }

    _lastTapTime = now;

    // ── 2. State: Update status dan jumlah vote hanya jika lolos validasi ──
    setState(() {
      _isUpvoted = !_isUpvoted;
      _count += _isUpvoted ? 1 : -1;
    });
    widget.onChanged?.call(_isUpvoted, _count);
  }

  @override
  Widget build(BuildContext context) {
    final backgroundColor =
        _isUpvoted ? HomeColors.primaryContainer : HomeColors.surfaceSubtle;
    final foregroundColor =
        _isUpvoted ? HomeColors.onPrimary : HomeColors.onSurfaceVariant;
    final shadows = _isUpvoted ? HomeShadows.sm : <BoxShadow>[];

    return GestureDetector(
      onTap: _toggle,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(
          horizontal: _kHorizontalPadding,
          vertical: _kVerticalPadding,
        ),
        decoration: BoxDecoration(
          color: backgroundColor,
          borderRadius: BorderRadius.circular(9999),
          boxShadow: shadows,
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.arrow_upward,
              size: _kIconSize,
              color: foregroundColor,
            ),
            const SizedBox(width: _kGap),
            Text(
              '$_count',
              style: HomeTextStyles.labelMd.copyWith(
                fontWeight: FontWeight.w700,
                color: foregroundColor,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
