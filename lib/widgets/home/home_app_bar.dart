import 'dart:ui';

import 'package:flutter/material.dart';

import '../../theme/app_spacing.dart';
import '../../theme/home_colors.dart';
import '../../theme/home_shadows.dart';
import '../../theme/home_text_styles.dart';

/// Header bar height (HTML `h-16` = 64px).
const double _kBarHeight = 64;

/// Logo height (HTML `h-8` = 32px).
const double _kLogoHeight = 32;

/// Gap between logo and text block (Tailwind `gap-2.5` = 10px).
const double _kLogoTextGap = 10;

/// UNAND badge horizontal padding (Tailwind `px-1.5` = 6px).
const double _kBadgeHPadding = 6;

/// UNAND badge vertical padding (Tailwind `py-0.5` = 2px).
const double _kBadgeVPadding = 2;

/// Gap between KILAS text and UNAND badge (Tailwind `gap-1` = 4px).
const double _kTitleBadgeGap = 4;

/// Tagline top margin (Tailwind `mt-0.5` = 2px).
const double _kTaglineTopMargin = 2;

/// Search button size (HTML `w-10 h-10` = 40px).
const double _kSearchButtonSize = 40;

/// Search icon size (HTML `text-[24px]`).
const double _kSearchIconSize = 24;

/// Backdrop blur sigma matching Tailwind `backdrop-blur-xl` (24px).
const double _kBlurSigma = 24;

/// Logo image URL from the HTML reference.
const String _kLogoUrl =
    'https://lh3.googleusercontent.com/aida/AEtjO1V5x6XcYLkVRl7VhJTw6lNACmLYMohVB-_AysCYDqamhrlZr3yOby6xHiE2hETw3sjOJhLod-avEzKVoZyS5vbuopWFLcRfxB5_y-v_HuZPky55aSQfYYodgcjRwdiNbK8w_7MUmfsDfTH9rmxsbLwV_fCSmUjGKWVZKMeN7ggYAFhtRznTa4ZvEqmUMRL0G3evbmUr9jxvSs1UZUF_cr_xduW51yt29OAZJ2pkwQn5sQAxzKY5BxkJOs0';

/// Fixed frosted-glass header bar for the home screen.
///
/// Contains the KILAS logo, "UNAND" badge, tagline text, and a
/// search action button. Uses [BackdropFilter] for the glass effect.
class HomeAppBar extends StatelessWidget {
  const HomeAppBar({super.key, this.onSearchPressed});

  /// Called when the search icon is tapped.
  final VoidCallback? onSearchPressed;

  @override
  Widget build(BuildContext context) {
    final topPadding = MediaQuery.of(context).padding.top;
    return ClipRect(
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: _kBlurSigma, sigmaY: _kBlurSigma),
        child: Container(
          padding: EdgeInsets.only(top: topPadding),
          decoration: const BoxDecoration(
            color: Color(0xD9FFFFFF), // surfacePure at 85% (#FFFFFF / 0.85)
            boxShadow: HomeShadows.headerGlass,
            border: Border(
              bottom: BorderSide(color: HomeColors.surfaceContainer),
            ),
          ),
          child: SizedBox(
            height: _kBarHeight,
            child: Padding(
              padding:
                  const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
              child: Row(
                children: [
                  Expanded(child: _LogoBrand()),
                  _SearchButton(onPressed: onSearchPressed),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// KILAS logo image + "KILAS" text + "UNAND" badge + tagline.
class _LogoBrand extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        SizedBox(
          height: _kLogoHeight,
          child: Image.network(
            _kLogoUrl,
            height: _kLogoHeight,
            fit: BoxFit.contain,
            errorBuilder: (_, _, _) => Container(
              width: _kLogoHeight,
              height: _kLogoHeight,
              decoration: const BoxDecoration(
                color: HomeColors.primaryContainer,
                shape: BoxShape.circle,
              ),
              alignment: Alignment.center,
              child: const Icon(
                Icons.bolt,
                color: HomeColors.onPrimary,
                size: 20,
              ),
            ),
          ),
        ),
        const SizedBox(width: _kLogoTextGap),
        Expanded(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Text(
                    'KILAS',
                    style: HomeTextStyles.headlineSm.copyWith(
                      color: HomeColors.onSurface,
                      height: 1.0,
                      letterSpacing: -0.45,
                    ),
                  ),
                  const SizedBox(width: _kTitleBadgeGap),
                  const _UnandBadge(),
                ],
              ),
              const SizedBox(height: _kTaglineTopMargin),
              Text(
                'Halo Mahasiswa, Pantau Kampus',
                style: HomeTextStyles.labelSm.copyWith(
                  color: HomeColors.onSurfaceVariant,
                  height: 1.0,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      ],
    );
  }
}

/// Small "UNAND" chip next to the KILAS title.
class _UnandBadge extends StatelessWidget {
  const _UnandBadge();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: _kBadgeHPadding,
        vertical: _kBadgeVPadding,
      ),
      decoration: BoxDecoration(
        color: HomeColors.surfaceContainerHigh,
        borderRadius: BorderRadius.circular(9999),
      ),
      child: Text(
        'UNAND',
        style: HomeTextStyles.labelSm.copyWith(
          color: HomeColors.primary,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }
}

/// Circular search action button.
class _SearchButton extends StatelessWidget {
  const _SearchButton({this.onPressed});

  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onPressed,
      child: const SizedBox(
        width: _kSearchButtonSize,
        height: _kSearchButtonSize,
        child: Center(
          child: Icon(
            Icons.search,
            size: _kSearchIconSize,
            color: HomeColors.onSurface,
          ),
        ),
      ),
    );
  }
}
