import 'package:flutter/material.dart';

import '../../theme/app_palette.dart';
import '../main_screen.dart';
import '../home/data/report_repository.dart';
import '../home/models/report_model.dart';
import 'data/user_profile_repository.dart';
import 'widgets/profile_activity_tab.dart';
import 'widgets/profile_app_bar.dart';
import 'widgets/profile_bookmarks_tab.dart';
import 'widgets/profile_header.dart';
import 'widgets/profile_quick_settings.dart';
import 'widgets/profile_reports_tab.dart';
import 'widgets/profile_stats_row.dart';
import 'widgets/profile_tab_bar.dart';

/// Halaman Profil Utama Pengguna (Akun) KILAS UNAND.
///
/// Menyajikan:
/// 1. Header Profil (FR-03 & Identitas Mahasiswa).
/// 2. Dashboard Statistik Pribadi (FR-17 & FR-B6).
/// 3. Tab Konten: Laporan Sendiri (FR-05, FR-06), Bookmark Terkunci Biometrik (FR-10), dan Riwayat Aktivitas (FR-24).
/// 4. Pengaturan Cepat & Keluar Akun (FR-18, FR-23, FR-02).
///
/// Kerangka layout, header frosted glass, typography, dan spacing disinkronisasi
/// secara konsisten dengan halaman Beranda (HomeScreen).
class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  int _selectedTab = 0;

  void _navigateToNotificationTab() {
    MainScreen.switchToTab(context, 3);
  }

  @override
  Widget build(BuildContext context) {
    final topPadding = MediaQuery.of(context).padding.top;
    final bottomPadding = MediaQuery.of(context).padding.bottom;

    // Header = status bar + 64px bar height (identik dengan HomeScreen).
    final headerHeight = topPadding + 64;
    // Bottom nav = 64px bar + safe area + extra space for FAB overflow.
    final bottomNavHeight = 64 + bottomPadding + 20;

    return Scaffold(
      backgroundColor: AppPalette.canvas(context),
      body: Stack(
        children: [
          // ── Scrollable profile content ───────────────────────────
          AnimatedBuilder(
            animation: Listenable.merge([
              UserProfileRepository.instance,
              ReportRepository.instance,
            ]),
            builder: (context, _) {
              final profile = UserProfileRepository.instance.profile;
              final allReports = ReportRepository.instance.reports;

              // Filter laporan milik pengguna saat ini (FR-05, FR-06)
              final myReports = allReports.where((r) {
                final matchesUsername = r.authorUsername != null &&
                    r.authorUsername!.toLowerCase() ==
                        profile.username.toLowerCase();
                final matchesName =
                    r.authorName.toLowerCase() == profile.nama.toLowerCase();
                return matchesUsername || matchesName;
              }).toList();

              // Laporan bookmark milik pengguna (FR-10)
              final myBookmarks =
                  allReports.where((r) => r.isBookmarked).toList();

              // Hitung total upvote yang diterima oleh laporan milik pengguna
              final totalUpvotes = myReports.fold<int>(
                0,
                (acc, curr) => acc + curr.upvoteCount,
              );

              // Laporan bulan ini (FR-B6)
              final reportsThisMonth = myReports.length;

              final isBookmarkUnlocked =
                  UserProfileRepository.instance.isBookmarkUnlocked;

              return SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                padding: EdgeInsets.only(
                  top: headerHeight,
                  bottom: bottomNavHeight,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // 1. Header Profil (FR-03 & Identitas)
                    ProfileHeader(user: profile),

                    const SizedBox(height: 8),

                    // 2. Baris Statistik Pribadi (FR-17 & FR-B6)
                    ProfileStatsRow(
                      totalReports: myReports.length,
                      totalUpvotes: totalUpvotes,
                      reportsThisMonth: reportsThisMonth,
                    ),

                    const SizedBox(height: 12),

                    // 3. Tab Bar (Laporan, Bookmark 🔒, Riwayat)
                    ProfileTabBar(
                      selectedIndex: _selectedTab,
                      onTabChanged: (index) {
                        setState(() => _selectedTab = index);
                      },
                      reportCount: myReports.length,
                      isBookmarkUnlocked: isBookmarkUnlocked,
                    ),

                    const SizedBox(height: 12),

                    // 4. Konten Tab Terpilih
                    AnimatedSwitcher(
                      duration: const Duration(milliseconds: 250),
                      child: _buildTabContent(
                        _selectedTab,
                        myReports: myReports,
                        myBookmarks: myBookmarks,
                      ),
                    ),

                    const SizedBox(height: 20),

                    // 5. Pengaturan & Fitur Cepat (Pengingat FR-18, Goyang HP FR-23, Tema, Logout FR-02)
                    const ProfileQuickSettings(),
                  ],
                ),
              );
            },
          ),

          // ── Fixed frosted header bar (konsisten dengan HomeAppBar) ────────
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: ProfileAppBar(
              onNotificationPressed: _navigateToNotificationTab,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTabContent(
    int tabIndex, {
    required List<ReportModel> myReports,
    required List<ReportModel> myBookmarks,
  }) {
    switch (tabIndex) {
      case 0:
        return ProfileReportsTab(
          key: const ValueKey('reports_tab'),
          reports: myReports,
        );
      case 1:
        return ProfileBookmarksTab(
          key: const ValueKey('bookmarks_tab'),
          bookmarks: myBookmarks,
        );
      case 2:
        return const ProfileActivityTab(
          key: ValueKey('activity_tab'),
        );
      default:
        return const SizedBox.shrink();
    }
  }
}
