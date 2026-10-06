import 'package:flutter/material.dart';

import '../widgets/home/home_bottom_nav.dart';
import 'home/home_screen.dart';
import 'map/map_screen.dart';

/// Wrapper utama (Shell) yang menangani Bottom Navigation dan menjaga state
/// halaman menggunakan IndexedStack agar peta tidak dimuat ulang.
class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _currentIndex = 0;

  // Daftar halaman untuk IndexedStack
  final List<Widget> _screens = const [
    HomeScreen(),
    MapScreen(),
    SizedBox(), // Slot FAB
    Center(child: Text('Notifikasi (Dalam Pengembangan)')),
    Center(child: Text('Akun (Dalam Pengembangan)')),
  ];

  void _onTabTapped(int index) {
    if (index == 2) {
      // FAB Tap -> Tangani fungsi buat laporan baru di sini
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Buat Laporan Baru')),
      );
      return;
    }
    setState(() {
      _currentIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          IndexedStack(
            index: _currentIndex,
            children: _screens,
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
