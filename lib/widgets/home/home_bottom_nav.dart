import 'dart:ui';

import 'package:flutter/material.dart';

import '../../theme/app_spacing.dart';
import '../../theme/home_colors.dart';
import '../../theme/home_shadows.dart';
import '../../theme/home_text_styles.dart';

/// Navigation bar height (HTML `h-16` = 64px).
const double _kNavHeight = 64;

/// Nav icon size (HTML `text-[24px]`).
const double _kNavIconSize = 24;

/// FAB size (HTML `w-14 h-14` = 56px).
const double _kFabSize = 56;

/// FAB icon size (HTML `text-[28px]`).
const double _kFabIconSize = 28;

/// How far the FAB sticks out above the bar.
/// (56px FAB centred in a 64px bar sits 4px from the top; HTML `-top-5`
/// moves it 20px up => it overflows the bar by 16px.)
const double _kFabOverflow = 16;

/// Notification dot size (HTML `w-2 h-2` = 8px).
const double _kDotSize = 8;

/// Notification dot ring width (HTML `ring-1` = 1px).
const double _kDotRingWidth = 1;

/// Profile image size (HTML `w-6 h-6` = 24px).
const double _kProfileSize = 24;

/// Label top margin (Tailwind `mt-0.5` = 2px).
const double _kLabelTopMargin = 2;

/// Backdrop blur sigma (Tailwind `backdrop-blur-xl` = 24px).
const double _kBlurSigma = 24;

/// Profile image URL from the HTML reference.
const String _kProfileUrl =
    'https://lh3.googleusercontent.com/aida/AEtjO1V92EVQ4KN0Kz3oky3ZOjOFB36uMErkEeLAHNV9VFiNR4xHvqrU9y0IB6mb3iqoNJ7swFKmS8DJgKYBhUgFghvxzqoDcWA-tD8zi4vI_JKMI7HK8V7NKtPZM80iTjo6MyY1UFw6KP_73ds3DU6H-yxPWgQ4EA9QnC5J6vKVOODwssgoJO6s-U4JOiunlGU-RGUKB_8Mh_9roo5zd4SLPhhNl7Ky0TQaHz58_z9QyCB75uw1XHJR0hI7plY';

/// Fixed frosted-glass bottom navigation bar for the home screen.
///
/// Contains five items: Beranda, Peta, FAB "+", Notif (with red dot),
/// and Akun (with profile picture).
///
/// The blur layer is clipped to the bar area only. The FAB lives outside
/// the clipped layer so it can overflow the top edge without causing the
/// backdrop blur to spread across the whole screen.
class HomeBottomNav extends StatelessWidget {
  const HomeBottomNav({
    super.key,
    this.currentIndex = 0,
    this.onTap,
  });

  /// Currently selected tab index (0 = Beranda).
  final int currentIndex;

  /// Called when a tab is tapped, with the tab index.
  final void Function(int index)? onTap;

  @override
  Widget build(BuildContext context) {
    final bottomPadding = MediaQuery.of(context).padding.bottom;
    final barHeight = _kNavHeight + bottomPadding;

    return SizedBox(
      height: barHeight + _kFabOverflow,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          // Glass layer: blur ONLY inside the bar area.
          Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            height: barHeight,
            child: ClipRect(
              child: BackdropFilter(
                filter: ImageFilter.blur(
                  sigmaX: _kBlurSigma,
                  sigmaY: _kBlurSigma,
                ),
                child: Container(
                  padding: EdgeInsets.only(bottom: bottomPadding),
                  decoration: const BoxDecoration(
                    color: Color(0xE6FFFFFF), // surfacePure at 90%
                    boxShadow: HomeShadows.bottomNavGlass,
                  ),
                  child: SizedBox(
                    height: _kNavHeight,
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: AppSpacing.xs,
                      ),
                      child: Row(
                        children: [
                          _NavItem(
                            icon: Icons.home,
                            label: 'Beranda',
                            isActive: currentIndex == 0,
                            onTap: () => onTap?.call(0),
                          ),
                          _NavItem(
                            icon: Icons.map,
                            label: 'Peta',
                            isActive: currentIndex == 1,
                            onTap: () => onTap?.call(1),
                          ),
                          // Empty slot reserved for the FAB.
                          const Expanded(child: SizedBox()),
                          _NavItem(
                            icon: Icons.notifications_none,
                            label: 'Notif',
                            isActive: currentIndex == 3,
                            showBadge: true,
                            onTap: () => onTap?.call(3),
                          ),
                          _ProfileNavItem(
                            label: 'Akun',
                            isActive: currentIndex == 4,
                            onTap: () => onTap?.call(4),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),

          // FAB outside the ClipRect: not clipped, still tappable.
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [_FabCenter(onTap: () => onTap?.call(2))],
            ),
          ),
        ],
      ),
    );
  }
}

/// Standard navigation item with icon + label.
class _NavItem extends StatelessWidget {
  const _NavItem({
    required this.icon,
    required this.label,
    this.isActive = false,
    this.showBadge = false,
    this.onTap,
  });

  final IconData icon;
  final String label;
  final bool isActive;
  final bool showBadge;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final iconColor =
        isActive ? HomeColors.primaryContainer : HomeColors.onSurfaceVariant;
    final labelColor =
        isActive ? HomeColors.primary : HomeColors.onSurfaceVariant;
    final labelWeight = isActive ? FontWeight.w700 : FontWeight.w700;

    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        behavior: HitTestBehavior.opaque,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (showBadge)
              _BadgedIcon(icon: icon, iconColor: iconColor)
            else
              Icon(icon, size: _kNavIconSize, color: iconColor),
            const SizedBox(height: _kLabelTopMargin),
            Text(
              label,
              style: HomeTextStyles.labelSm.copyWith(
                color: labelColor,
                fontWeight: labelWeight,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Notification icon with a red dot badge centered above the label.
class _BadgedIcon extends StatelessWidget {
  const _BadgedIcon({required this.icon, required this.iconColor});

  final IconData icon;
  final Color iconColor;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: _kNavIconSize,
      height: _kNavIconSize,
      child: Stack(
        clipBehavior: Clip.none,
        alignment: Alignment.center,
        children: [
          Icon(icon, size: _kNavIconSize, color: iconColor),
          Positioned(
            top: 0,
            right: 0,
            child: Container(
              width: _kDotSize,
              height: _kDotSize,
              decoration: BoxDecoration(
                color: HomeColors.statusFacility,
                shape: BoxShape.circle,
                border: Border.all(
                  color: HomeColors.surfacePure,
                  width: _kDotRingWidth,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// Centre floating action button ("+") that hovers above the nav bar.
class _FabCenter extends StatelessWidget {
  const _FabCenter({this.onTap});

  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: _kFabSize,
        height: _kFabSize,
        decoration: const BoxDecoration(
          color: HomeColors.primaryContainer,
          shape: BoxShape.circle,
          boxShadow: HomeShadows.fabBlue,
        ),
        alignment: Alignment.center,
        child: const Icon(
          Icons.add,
          size: _kFabIconSize,
          color: HomeColors.onPrimary,
        ),
      ),
    );
  }
}

/// Profile picture navigation item.
class _ProfileNavItem extends StatelessWidget {
  const _ProfileNavItem({
    required this.label,
    this.isActive = false,
    this.onTap,
  });

  final String label;
  final bool isActive;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final labelColor =
        isActive ? HomeColors.primary : HomeColors.onSurfaceVariant;

    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        behavior: HitTestBehavior.opaque,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            ClipOval(
              child: Image.network(
                _kProfileUrl,
                width: _kProfileSize,
                height: _kProfileSize,
                fit: BoxFit.cover,
                errorBuilder: (_, _, _) => Container(
                  width: _kProfileSize,
                  height: _kProfileSize,
                  color: HomeColors.surfaceSubtle,
                  child: const Icon(
                    Icons.person,
                    size: 16,
                    color: HomeColors.onSurfaceVariant,
                  ),
                ),
              ),
            ),
            const SizedBox(height: _kLabelTopMargin),
            Text(
              label,
              style: HomeTextStyles.labelSm.copyWith(
                color: labelColor,
                fontWeight: FontWeight.w700,
              ),
            ),
          ],
        ),
      ),
    );
  }
}