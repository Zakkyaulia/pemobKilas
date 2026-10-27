import 'dart:ui';

import 'package:flutter/material.dart';

import '../../theme/app_palette.dart';
import '../../theme/app_spacing.dart';
import '../../theme/home_colors.dart';
import '../../theme/home_shadows.dart';
import '../../theme/home_text_styles.dart';

/// Header bar height (HTML `h-16` = 64px).
const double _kBarHeight = 64;

/// Logo height matching text block height (50px).
const double _kLogoHeight = 50;

/// Search button size (HTML `w-10 h-10` = 40px).
const double _kSearchButtonSize = 40;

/// Search icon size (HTML `text-[24px]`).
const double _kSearchIconSize = 24;

/// Backdrop blur sigma matching Tailwind `backdrop-blur-xl` (24px).
const double _kBlurSigma = 24;

/// Fixed frosted-glass header bar for the home screen.
///
/// Menyajikan logo di kiri, teks "KILAS" tepat di tengah (center),
/// dan tombol cari di sebelah kanan.
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
          decoration: BoxDecoration(
            color: AppPalette.glassBackground(context),
            boxShadow: HomeShadows.headerGlass,
            border: Border(
              bottom: BorderSide(color: AppPalette.divider(context)),
            ),
          ),
          child: SizedBox(
            height: _kBarHeight,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
              child: Stack(
                alignment: Alignment.center,
                children: [
                  // Logo di sebelah kiri
                  Align(
                    alignment: Alignment.centerLeft,
                    child: SizedBox(
                      height: _kLogoHeight,
                      child: Image.asset(
                        'assets/icons/app_logo_rev1.png',
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
                  ),

                  // Teks "KILAS" persis di tengah
                  Center(
                    child: Text(
                      'KILAS',
                      style: HomeTextStyles.headlineSm.copyWith(
                        color: AppPalette.textPrimary(context),
                        height: 1.0,
                        letterSpacing: -0.45,
                      ),
                    ),
                  ),

                  // Tombol cari di sebelah kanan
                  Align(
                    alignment: Alignment.centerRight,
                    child: _SearchButton(onPressed: onSearchPressed),
                  ),
                ],
              ),
            ),
          ),
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
      child: SizedBox(
        width: _kSearchButtonSize,
        height: _kSearchButtonSize,
        child: Center(
          child: Icon(
            Icons.search,
            size: _kSearchIconSize,
            color: AppPalette.textPrimary(context),
          ),
        ),
      ),
    );
  }
}
