import 'package:flutter/material.dart';

import '../theme/app_palette.dart';
import '../theme/home_text_styles.dart';
import '../widgets/home/home_bottom_nav.dart';
import 'home/home_screen.dart';
import 'map/map_screen.dart';
import 'notification/notification_screen.dart';
import 'profile/profile_screen.dart';
import 'report/create_report_screen.dart';

/// Wrapper utama (Shell) yang menangani Bottom Navigation dan menjaga state
/// halaman menggunakan PageView agar bisa diswipe horizontal.
class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  /// Beralih ke tab bottom nav tertentu (0: Beranda, 1: Peta, 3: Notifikasi, 4: Profil).
  static void switchToTab(BuildContext context, int navIndex) {
    final state = context.findAncestorStateOfType<_MainScreenState>();
    state?._onTabTapped(navIndex);
  }

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  /// Bottom nav index (0-4, termasuk slot FAB di index 2).
  int _currentIndex = 0;

  late final PageController _pageController;

  /// Halaman aktual yang bisa di-swipe (tanpa slot FAB).
  /// Index mapping: nav 0→page 0, nav 1→page 1, nav 3→page 2, nav 4→page 3.
  final List<Widget> _pages = const [
    HomeScreen(),
    MapScreen(),
    NotificationScreen(),
    ProfileScreen(),
  ];

  @override
  void initState() {
    super.initState();
    _pageController = PageController(initialPage: _navToPage(_currentIndex));
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  /// Konversi index bottom nav (0-4) ke index PageView (0-3).
  /// Index 2 (FAB) tidak punya page, jadi di-skip.
  int _navToPage(int navIndex) {
    if (navIndex <= 1) return navIndex;
    if (navIndex >= 3) return navIndex - 1; // 3→2, 4→3
    return 0; // fallback untuk FAB
  }

  /// Konversi index PageView (0-3) ke index bottom nav (0-4).
  int _pageToNav(int pageIndex) {
    if (pageIndex <= 1) return pageIndex;
    return pageIndex + 1; // 2→3, 3→4
  }

  void _onTabTapped(int index) {
    if (index == 2) {
      // FAB Tap -> Buka halaman Buat Laporan baru
      Navigator.of(context).push(
        MaterialPageRoute(
          builder: (context) => const CreateReportScreen(),
        ),
      );
      return;
    }
    final pageIndex = _navToPage(index);
    final currentPage = _pageController.page?.round() ?? 0;
    final distance = (pageIndex - currentPage).abs();

    if (distance <= 1) {
      _pageController.animateToPage(
        pageIndex,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    } else {
      // Lompat langsung untuk jarak > 1 agar tidak merender halaman berat di tengah.
      _pageController.jumpToPage(pageIndex);
    }
  }

  void _onPageChanged(int pageIndex) {
    setState(() {
      _currentIndex = _pageToNav(pageIndex);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          PageView(
            controller: _pageController,
            onPageChanged: _onPageChanged,
            physics: const BouncingScrollPhysics(),
            children: _pages,
          ),
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: HomeBottomNav(
              currentIndex: _currentIndex,
              onTap: _onTabTapped,
            ),
          ),
        ],
      ),
    );
  }
}


