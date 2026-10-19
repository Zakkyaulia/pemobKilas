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
          const Positioned.fill(
            child: MapView(),
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
                                  height: 32,
                                  child: Image.asset(
                                    'assets/icons/app_logo.png',
                                    height: 32,
                                    fit: BoxFit.contain,
                                    errorBuilder: (_, _, _) => Container(
                                      width: 32,
                                      height: 32,
                                      decoration: const BoxDecoration(
                                        color: HomeColors.primaryContainer,
                                        shape: BoxShape.circle,
                                      ),
                                      alignment: Alignment.center,
                                      child: const Icon(
                                        Icons.map_rounded,
                                        color: HomeColors.onPrimary,
                                        size: 18,
                                      ),
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 10),
                                Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      children: [
                                        Text(
                                          'Peta Kampus',
                                          style: HomeTextStyles.headlineSm.copyWith(
                                            color: AppPalette.textPrimary(context),
                                            height: 1.0,
                                            letterSpacing: -0.45,
                                          ),
                                        ),
                                        const SizedBox(width: 4),
                                        Container(
                                          padding: const EdgeInsets.symmetric(
                                            horizontal: 6,
                                            vertical: 2,
                                          ),
                                          decoration: BoxDecoration(
                                            color: AppPalette.isDark(context)
                                                ? const Color(0xFF1E293B)
                                                : HomeColors.surfaceContainerHigh,
                                            borderRadius: BorderRadius.circular(9999),
                                          ),
                                          child: Text(
                                            'UNAND',
                                            style: HomeTextStyles.labelSm.copyWith(
                                              color: HomeColors.primaryContainer,
                                              fontWeight: FontWeight.w700,
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: 2),
                                    Text(
                                      'Sebaran Hotspot & Laporan Mahasiswa',
                                      style: HomeTextStyles.labelSm.copyWith(
                                        color: AppPalette.textSecondary(context),
                                        height: 1.0,
                                      ),
                                    ),
                                  ],
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

