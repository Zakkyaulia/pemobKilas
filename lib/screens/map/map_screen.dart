import 'dart:ui';
import 'package:flutter/material.dart';

import '../../theme/app_palette.dart';
import '../../theme/app_spacing.dart';
import '../../theme/home_colors.dart';
import '../../theme/home_shadows.dart';
import '../../theme/home_text_styles.dart';
import '../../widgets/map/map_view.dart';

/// Header bar height matching HomeScreen (64px).
const double _kBarHeight = 64;

/// Backdrop blur sigma matching Tailwind `backdrop-blur-xl` (24px).
const double _kBlurSigma = 24;

/// Halaman peta sebaran hotspot laporan kampus UNAND.
///
/// Menggunakan kerangka Stack dan fixed frosted-glass header bar
/// yang konsisten dengan [HomeScreen] dan [ProfileScreen].
class MapScreen extends StatelessWidget {
  const MapScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final topPadding = MediaQuery.of(context).padding.top;

    return Scaffold(
      backgroundColor: AppPalette.canvas(context),
      body: Stack(
        children: [
          // ── Komponen peta responsif ──────────────────────────────
          Positioned.fill(
            child: MapView(topInset: topPadding + _kBarHeight),
          ),

          // ── Fixed frosted-glass header bar ───────────────────────
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: ClipRect(
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
                          Expanded(
                            child: Row(
                              children: [
                                SizedBox(
                                  height: 50,
                                  child: Image.asset(
                                    'assets/icons/app_logo_rev1.png',
                                    height: 50,
                                    fit: BoxFit.contain,
                                    errorBuilder: (_, _, _) => Container(
                                      width: 50,
                                      height: 50,
                                      decoration: const BoxDecoration(
                                        color: HomeColors.primaryContainer,
                                        shape: BoxShape.circle,
                                      ),
                                      alignment: Alignment.center,
                                      child: const Icon(
                                        Icons.map_rounded,
                                        color: HomeColors.onPrimary,
                                        size: 22,
                                      ),
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 10),
                                Text(
                                  'Peta Hotspot Laporan',
                                  style: HomeTextStyles.headlineSm.copyWith(
                                    color: AppPalette.textPrimary(context),
                                    height: 1.0,
                                    letterSpacing: -0.45,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

