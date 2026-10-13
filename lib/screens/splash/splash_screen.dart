import 'package:flutter/material.dart';

import '../../theme/home_colors.dart';
import '../../theme/home_text_styles.dart';
import '../auth/login_screen.dart';

/// Screen pembuka (Splash Screen) dengan animasi logo KILAS,
/// efek cahaya pulsing (civic pulse), dan transisi halus ke halaman login.
class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;
  late Animation<double> _fadeAnimation;
  late Animation<double> _glowAnimation;
  late Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2800),
    );

    // Animasi logo membesar halus dengan sedikit bouncing
    _scaleAnimation = Tween<double>(begin: 0.75, end: 1.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.0, 0.60, curve: Curves.easeOutBack),
      ),
    );

    // Animasi muncul perlahan (fade-in)
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.0, 0.50, curve: Curves.easeIn),
      ),
    );

    // Efek cahaya berdenyut di belakang logo (pulsing halo)
    _glowAnimation = Tween<double>(begin: 0.4, end: 1.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.2, 0.9, curve: Curves.easeInOut),
      ),
    );

    // Animasi teks judul dan tagline meluncur dari bawah
    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.25),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.30, 0.80, curve: Curves.easeOutCubic),
      ),
    );

    _controller.forward();

    // Otomatis berpindah ke LoginScreen setelah animasi dinikmati (~4 detik total)
    _controller.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        Future.delayed(const Duration(milliseconds: 1200), _navigateToNextScreen);
      }
    });
  }

  void _navigateToNextScreen() {
    if (!mounted) return;
    Navigator.of(context).pushReplacement(
      PageRouteBuilder(
        pageBuilder: (context, animation, secondaryAnimation) =>
            const LoginScreen(),
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          return FadeTransition(opacity: animation, child: child);
        },
        transitionDuration: const Duration(milliseconds: 600),
      ),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;

    return Scaffold(
      backgroundColor: const Color(0xFF081024), // Deep civic navy
      body: Stack(
        fit: StackFit.expand,
        children: [
          // ── Background Ambient Glow Rings ───────────────────────
          AnimatedBuilder(
            animation: _glowAnimation,
            builder: (context, child) {
              return Center(
                child: Container(
                  width: 320 * _glowAnimation.value,
                  height: 320 * _glowAnimation.value,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: RadialGradient(
                      colors: [
                        HomeColors.primary.withValues(alpha: 0.35 * _glowAnimation.value),
                        HomeColors.primaryContainer.withValues(alpha: 0.12 * _glowAnimation.value),
                        Colors.transparent,
                      ],
                      stops: const [0.0, 0.5, 1.0],
                    ),
                  ),
                ),
              );
            },
          ),

          // ── Konten Utama (Logo + Judul + Tagline) ───────────────
          Center(
            child: AnimatedBuilder(
              animation: _controller,
              builder: (context, child) {
                return FadeTransition(
                  opacity: _fadeAnimation,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      // Logo KILAS dengan Container Card Elegan & Shadow Halus
                      ScaleTransition(
                        scale: _scaleAnimation,
                        child: Container(
                          width: 110,
                          height: 110,
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: const Color(0xFF0F1E3D),
                            borderRadius: BorderRadius.circular(28),
                            border: Border.all(
                              color: HomeColors.primary.withValues(alpha: 0.45),
                              width: 1.5,
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: HomeColors.primary.withValues(alpha: 0.35),
                                blurRadius: 28,
                                spreadRadius: 2,
                                offset: const Offset(0, 8),
                              ),
                            ],
                          ),
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(16),
                            child: Image.asset(
                              'assets/icons/app_logo.png',
                              fit: BoxFit.contain,
                              errorBuilder: (context, error, stackTrace) {
                                return const Icon(
                                  Icons.bolt_rounded,
                                  size: 64,
                                  color: HomeColors.primaryContainer,
                                );
                              },
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 28),

                      // Nama Aplikasi & Tagline
                      SlideTransition(
                        position: _slideAnimation,
                        child: Column(
                          children: [
                            // Judul Aplikasi
                            Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Text(
                                  'KI',
                                  style: HomeTextStyles.headlineLg.copyWith(
                                    fontSize: 32,
                                    fontWeight: FontWeight.w900,
                                    letterSpacing: 2,
                                    color: Colors.white,
                                  ),
                                ),
                                Text(
                                  'LAS',
                                  style: HomeTextStyles.headlineLg.copyWith(
                                    fontSize: 32,
                                    fontWeight: FontWeight.w900,
                                    letterSpacing: 2,
                                    color: const Color(0xFF4880FF),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 8),

                            // Subtitle Resmi
                            Text(
                              'KABAR LINTAS ANDALAS',
                              style: HomeTextStyles.labelMd.copyWith(
                                fontSize: 12,
                                fontWeight: FontWeight.w700,
                                letterSpacing: 4,
                                color: const Color(0xFF94A3B8),
                              ),
                            ),
                            const SizedBox(height: 14),

                            // Badge info kecil kampus UNAND
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 14,
                                vertical: 6,
                              ),
                              decoration: BoxDecoration(
                                color: Colors.white.withValues(alpha: 0.06),
                                borderRadius: BorderRadius.circular(9999),
                                border: Border.all(
                                  color: Colors.white.withValues(alpha: 0.12),
                                  width: 1,
                                ),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Container(
                                    width: 6,
                                    height: 6,
                                    decoration: const BoxDecoration(
                                      shape: BoxShape.circle,
                                      color: Color(0xFF10B981), // Emerald green pulse
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  Text(
                                    'Universitas Andalas',
                                    style: HomeTextStyles.bodySm.copyWith(
                                      fontSize: 11,
                                      color: const Color(0xFFCBD5E1),
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
          ),

          // ── Footer Versi & Progress Halus di Bawah ────────────────
          Positioned(
            bottom: screenHeight * 0.06,
            left: 0,
            right: 0,
            child: FadeTransition(
              opacity: _fadeAnimation,
              child: Column(
                children: [
                  SizedBox(
                    width: 36,
                    height: 3,
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(99),
                      child: const LinearProgressIndicator(
                        backgroundColor: Color(0xFF1E293B),
                        valueColor: AlwaysStoppedAnimation<Color>(
                          Color(0xFF3B82F6),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    'Mobile Programming',
                    style: HomeTextStyles.labelSm.copyWith(
                      color: const Color(0xFF64748B),
                      fontSize: 10,
                      letterSpacing: 1.2,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
