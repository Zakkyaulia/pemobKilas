import 'dart:ui';

import 'package:flutter/material.dart';

import '../../../theme/app_palette.dart';
import '../../../theme/app_spacing.dart';
import '../../../theme/home_colors.dart';
import '../../../theme/home_shadows.dart';
import '../../../theme/home_text_styles.dart';
import '../../report/data/draft_repository.dart';

/// Header bar height matching HomeScreen (64px).
const double _kBarHeight = 64;

/// Logo height matching text block height (~42px).
const double _kLogoHeight = 50;

/// Gap between logo and text block (10px).
const double _kLogoTextGap = 10;



/// Action button size (40px).
const double _kButtonSize = 40;

/// Backdrop blur sigma matching Tailwind `backdrop-blur-xl` (24px).
const double _kBlurSigma = 24;

/// Fixed frosted-glass header bar for the Profile screen,
/// fully consistent with [HomeAppBar].
class ProfileAppBar extends StatelessWidget {
  const ProfileAppBar({
    super.key,
    this.onSettingsPressed,
    this.onDraftPressed,
  });

  final VoidCallback? onSettingsPressed;
  final VoidCallback? onDraftPressed;

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
              child: Row(
                children: [
                  const Expanded(child: _ProfileLogoBrand()),
                  _DraftButton(onPressed: onDraftPressed),
                  const SizedBox(width: AppSpacing.xs),
                  _SettingsButton(onPressed: onSettingsPressed),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// KILAS logo image + "KILAS" text + "UNAND" badge + subtitle tagline.
class _ProfileLogoBrand extends StatelessWidget {
  const _ProfileLogoBrand();

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        SizedBox(
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
        const SizedBox(width: _kLogoTextGap),
        Text(
          'Profil',
          style: HomeTextStyles.headlineSm.copyWith(
            color: AppPalette.textPrimary(context),
            height: 1.0,
            letterSpacing: -0.45,
          ),
        ),
      ],
    );
  }
}


/// Settings gear action button.
class _SettingsButton extends StatelessWidget {
  const _SettingsButton({this.onPressed});

  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) {
    return Tooltip(
      message: 'Pengaturan',
      child: GestureDetector(
        onTap: onPressed,
        behavior: HitTestBehavior.opaque,
        child: SizedBox(
          width: _kButtonSize,
          height: _kButtonSize,
          child: Icon(
            Icons.settings_outlined,
            size: 24,
            color: AppPalette.textPrimary(context),
          ),
        ),
      ),
    );
  }
}

/// Draft action button with dynamic draft count badge.
class _DraftButton extends StatelessWidget {
  const _DraftButton({this.onPressed});

  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) {
    return Tooltip(
      message: 'Draft Laporan',
      child: GestureDetector(
        onTap: onPressed,
        behavior: HitTestBehavior.opaque,
        child: SizedBox(
          width: _kButtonSize,
          height: _kButtonSize,
          child: Center(
            child: ListenableBuilder(
              listenable: DraftRepository.instance,
              builder: (context, _) {
                final count = DraftRepository.instance.draftCount;
                return Badge(
                  isLabelVisible: count > 0,
                  backgroundColor: HomeColors.primaryContainer,
                  label: Text(
                    '$count',
                    style: const TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  child: Icon(
                    Icons.drafts_outlined,
                    size: 24,
                    color: AppPalette.textPrimary(context),
                  ),
                );
              },
            ),
          ),
        ),
      ),
    );
  }
}
