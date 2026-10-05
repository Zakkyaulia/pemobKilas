import 'package:flutter/material.dart';

import '../../theme/home_colors.dart';
import '../../theme/home_text_styles.dart';

/// Gap between icon and text (Tailwind `gap-1.5` = 6px).
const double _kGap = 6;

/// Bounce icon size (HTML `text-[16px]`).
const double _kIconSize = 16;

/// Visual hint shown at the top of the feed, indicating that the user
/// can pull down to refresh. Appears at 60 % opacity.
///
/// This is a **static indicator only** — actual refresh behaviour is
/// handled by [RefreshIndicator] in the parent screen.
class PullToRefreshHint extends StatelessWidget {
  const PullToRefreshHint({super.key});

  @override
  Widget build(BuildContext context) {
    return Opacity(
      opacity: 0.60,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 8),
        decoration: const BoxDecoration(
          color: HomeColors.surface,
          border: Border(
            bottom: BorderSide(color: HomeColors.surfaceContainer),
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.south,
              size: _kIconSize,
              color: HomeColors.primary,
            ),
            const SizedBox(width: _kGap),
            Text(
              'TARIK UNTUK MEMUAT BARU',
              style: HomeTextStyles.labelSm.copyWith(
                color: HomeColors.onSurfaceVariant,
                letterSpacing: 1.2,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
