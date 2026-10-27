import 'dart:io';
import 'dart:ui' show ImageFilter;
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../theme/app_palette.dart';
import '../../theme/app_spacing.dart';
import '../../theme/home_colors.dart';
import '../../theme/home_text_styles.dart';
import '../home/data/report_repository.dart';
import '../home/models/report_model.dart';
import '../home/report_detail_screen.dart';
import '../report/create_report_screen.dart';
import 'data/user_profile_repository.dart';

/// Pilihan filter periode statistik pribadi (FR-17).
enum StatsPeriod {
  semuaWaktu,
  bulanIni,
  mingguIni,
}

/// Warna aksen upvote yang sudah dipakai di app (hijau emerald).
const Color _kUpvoteGreen = Color(0xFF10B981);

/// Warna aksen amber untuk kartu laporan terpopuler.
const Color _kAmber = Color(0xFFF59E0B);

/// Halaman Dashboard "Kontribusi Saya" (FR-17 & FR-B6).
///
/// Ringkasan kontribusi mahasiswa (bukan halaman analitik):
/// 1. Filter Periode ("Minggu Ini", "Bulan Ini", "Semua Waktu").
/// 2. Kartu metrik: Laporan Terbit & Total Upvote.
/// 3. Grafik garis upvote diterima per hari/minggu/bulan (mengikuti filter).
/// 4. Distribusi kategori ringkas (Kondisi Kampus vs Info Penting).
/// 5. Laporan Terpopuler Saya (navigasi ke detail laporan).
class PersonalStatsDashboardScreen extends StatefulWidget {
  const PersonalStatsDashboardScreen({super.key});

  @override
  State<PersonalStatsDashboardScreen> createState() =>
      _PersonalStatsDashboardScreenState();
}

class _PersonalStatsDashboardScreenState
    extends State<PersonalStatsDashboardScreen> {
  StatsPeriod _selectedPeriod = StatsPeriod.semuaWaktu;

  /// Logika periode kalender (Pendekatan 1: agregasi harian terpusat):
  /// - Minggu Ini: minggu kalender berjalan (Senin s/d Minggu).
  /// - Bulan Ini: bulan kalender berjalan (tanggal 1 s/d akhir bulan).
  /// - Semua Waktu: seluruh riwayat.
  /// Laporan tanpa tanggal selalu diikutsertakan.
  bool _isInPeriod(ReportModel r, StatsPeriod period, DateTime now) {
    if (r.createdAt == null) return true;
    final d = r.createdAt!;
    switch (period) {
      case StatsPeriod.semuaWaktu:
        return true;
      case StatsPeriod.bulanIni:
        return d.year == now.year && d.month == now.month;
      case StatsPeriod.mingguIni:
        final today = DateTime(now.year, now.month, now.day);
        final startOfWeek = today.subtract(Duration(days: now.weekday - 1));
        final endOfWeek = startOfWeek.add(const Duration(days: 7));
        final reportDate = DateTime(d.year, d.month, d.day);
        return !reportDate.isBefore(startOfWeek) && reportDate.isBefore(endOfWeek);
    }
  }

  @override
  Widget build(BuildContext context) {
    final topPadding = MediaQuery.of(context).padding.top;
    final isDark = AppPalette.isDark(context);

    return Scaffold(
      backgroundColor: AppPalette.canvas(context),
      body: AnimatedBuilder(
        animation: Listenable.merge([
          UserProfileRepository.instance,
          ReportRepository.instance,
        ]),
        builder: (context, _) {
          final profile = UserProfileRepository.instance.profile;
          final allReports = ReportRepository.instance.reports;

          // Filter semua laporan milik user saat ini
          final myAllReports = allReports.where((r) {
            final matchUsername = r.authorUsername != null &&
                r.authorUsername!.toLowerCase() ==
                    profile.username.toLowerCase();
            final matchName =
                r.authorName.toLowerCase() == profile.nama.toLowerCase();
            return matchUsername || matchName;
          }).toList();

          // Filter laporan berdasarkan periode yang dipilih
          final now = DateTime.now();
          final filteredReports = myAllReports
              .where((r) => _isInPeriod(r, _selectedPeriod, now))
              .toList();

          // Metrik-metrik terhitung
          final totalReports = filteredReports.length;
          final totalUpvotes = filteredReports.fold<int>(
            0,
            (acc, curr) => acc + curr.upvoteCount,
          );
          final reportsThisMonth = myAllReports
              .where((r) => _isInPeriod(r, StatsPeriod.bulanIni, now))
              .length;

          // Laporan terpopuler milik sendiri
          ReportModel? mostUpvotedReport;
          if (filteredReports.isNotEmpty) {
            final sortedByUpvotes = List<ReportModel>.from(filteredReports)
              ..sort((a, b) => b.upvoteCount.compareTo(a.upvoteCount));
            mostUpvotedReport = sortedByUpvotes.first;
          }

          // Rasio kategori
          final conditionReports = filteredReports
              .where((r) => r.badgeLabel == 'Kondisi Kampus')
              .length;
          final infoReports = filteredReports
              .where((r) => r.badgeLabel == 'Info Penting')
              .length;

          // Seri grafik upvote (granularitas mengikuti filter)
          final series = _buildChartSeries(
            period: _selectedPeriod,
            filteredReports: filteredReports,
            now: now,
          );

          return Stack(
            children: [
              // ── Scrollable Body Konten ─────────────────────────────
              Positioned.fill(
                child: SingleChildScrollView(
                  physics: const BouncingScrollPhysics(),
                  padding: EdgeInsets.fromLTRB(
                    AppSpacing.lg,
                    topPadding + 64 + 16,
                    AppSpacing.lg,
                    32,
                  ),
                  child: myAllReports.isEmpty
                      ? _buildNewUserEmptyState(context, isDark)
                      : Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            // 1. Selector Periode Waktu
                            _buildPeriodSelector(context, isDark),

                            const SizedBox(height: 12),

                            // 2. Kartu Metrik Utama
                            _buildPrimaryMetrics(
                              context: context,
                              isDark: isDark,
                              totalReports: totalReports,
                              totalUpvotes: totalUpvotes,
                              reportsThisMonth: reportsThisMonth,
                            ),

                            const SizedBox(height: 12),

                            // 3. Grafik Upvote Diterima
                            _buildUpvoteChartCard(
                              context: context,
                              isDark: isDark,
                              series: series,
                            ),

                            const SizedBox(height: 12),

                            // 4. Distribusi Kategori (ringkas)
                            _buildCategoryRatioSection(
                              context: context,
                              isDark: isDark,
                              conditionCount: conditionReports,
                              infoCount: infoReports,
                              total: totalReports,
                            ),

                            const SizedBox(height: 16),

                            // 5. Laporan Terpopuler Saya
                            _buildMostUpvotedReportCard(
                              context: context,
                              isDark: isDark,
                              topReport: mostUpvotedReport,
                            ),
                          ],
                        ),
                ),
              ),

              // ── Frosted-Glass App Bar Header ───────────────────────
              Positioned(
                top: 0,
                left: 0,
                right: 0,
                child: ClipRect(
                  child: BackdropFilter(
                    filter: ImageFilter.blur(sigmaX: 24, sigmaY: 24),
                    child: Container(
                      height: topPadding + 64,
                      color: AppPalette.surface(context).withValues(
                        alpha: isDark ? 0.85 : 0.90,
                      ),
                      child: SafeArea(
                        bottom: false,
                        child: Padding(
                          padding: const EdgeInsets.symmetric(
                            horizontal: AppSpacing.lg,
                          ),
                          child: Row(
                            children: [
                              IconButton(
                                icon: const Icon(
                                  Icons.arrow_back_ios_new_rounded,
                                  size: 20,
                                ),
                                tooltip: 'Kembali',
                                color: AppPalette.textPrimary(context),
                                onPressed: () => Navigator.pop(context),
                              ),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      'Kontribusi Saya',
                                      style: HomeTextStyles.headlineSm.copyWith(
                                        color: AppPalette.textPrimary(context),
                                        fontWeight: FontWeight.w700,
                                      ),
                                    ),
                                    Text(
                                      'Dashboard Kontribusi @${profile.username.replaceAll('@', '')}',
                                      style: HomeTextStyles.labelSm.copyWith(
                                        color:
                                            AppPalette.textSecondary(context),
                                      ),
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
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
          );
        },
      ),
    );
  }

  // ═════════════════════════════════════════════════════════════════════════
  // Data Grafik
  // ═════════════════════════════════════════════════════════════════════════

  static const List<String> _dayLabels = [
    'Sen', 'Sel', 'Rab', 'Kam', 'Jum', 'Sab', 'Min',
  ];

  static const List<String> _monthLabels = [
    'Jan', 'Feb', 'Mar', 'Apr', 'Mei', 'Jun',
    'Jul', 'Agu', 'Sep', 'Okt', 'Nov', 'Des',
  ];

  /// Menyusun seri upvote per titik waktu sesuai filter (Pendekatan 1).
  ///
  /// PENDEKATAN 1 (Backend Kirim Data Harian, Flutter Agregasi):
  /// Backend cukup mengembalikan data agregasi harian per tanggal:
  ///   [{ "date": "2026-10-27", "count": 12 }, ...]
  ///
  /// Flutter bertugas mengelompokkan data tanggal harian tersebut ke dalam:
  /// - Minggu Ini  -> 7 hari (Sen s/d Min)
  /// - Bulan Ini   -> 4-5 bucket minggu (Mgg 1: tgl 1-7, Mgg 2: tgl 8-14, dst.)
  /// - Semua Waktu -> 2-12 bucket bulan (Jan, Feb, ...)
  _ChartSeries _buildChartSeries({
    required StatsPeriod period,
    required List<ReportModel> filteredReports,
    required DateTime now,
  }) {
    // 1. Ekstraksi data upvote harian (mensimulasikan respons harian dari backend)
    // Key format: 'YYYY-MM-DD' -> total upvote pada tanggal tersebut
    final Map<String, int> dailyUpvotes = {};
    for (final r in filteredReports) {
      final d = r.createdAt ?? now;
      final key = '${d.year.toString().padLeft(4, '0')}-'
          '${d.month.toString().padLeft(2, '0')}-'
          '${d.day.toString().padLeft(2, '0')}';
      dailyUpvotes[key] = (dailyUpvotes[key] ?? 0) + r.upvoteCount;
    }

    final today = DateTime(now.year, now.month, now.day);

    switch (period) {
      case StatsPeriod.mingguIni:
        // Rentang Senin (hari 1) s/d Minggu (hari 7) minggu kalender berjalan
        final startOfWeek = today.subtract(Duration(days: now.weekday - 1));
        final values = List<int>.filled(7, 0);
        for (var i = 0; i < 7; i++) {
          final targetDate = startOfWeek.add(Duration(days: i));
          final key = '${targetDate.year.toString().padLeft(4, '0')}-'
              '${targetDate.month.toString().padLeft(2, '0')}-'
              '${targetDate.day.toString().padLeft(2, '0')}';
          values[i] = dailyUpvotes[key] ?? 0;
        }
        return _ChartSeries(
          unit: 'Hari',
          labels: List<String>.from(_dayLabels),
          values: values,
        );

      case StatsPeriod.bulanIni:
        // Bulan kalender berjalan per tanggal (1 s/d 28/29/30/31 sesuai bulan berjalan)
        final daysInMonth = DateTime(now.year, now.month + 1, 0).day;
        final values = List<int>.filled(daysInMonth, 0);

        for (var day = 1; day <= daysInMonth; day++) {
          final key = '${now.year.toString().padLeft(4, '0')}-'
              '${now.month.toString().padLeft(2, '0')}-'
              '${day.toString().padLeft(2, '0')}';
          values[day - 1] = dailyUpvotes[key] ?? 0;
        }

        return _ChartSeries(
          unit: 'Tanggal',
          labels: List<String>.generate(daysInMonth, (i) => '${i + 1}'),
          values: values,
        );

      case StatsPeriod.semuaWaktu:
        final endMonth = DateTime(now.year, now.month);
        var startMonth = endMonth;
        for (final r in filteredReports) {
          final d = r.createdAt ?? now;
          final m = DateTime(d.year, d.month);
          if (m.isBefore(startMonth)) startMonth = m;
        }
        var count = (endMonth.year - startMonth.year) * 12 +
            endMonth.month -
            startMonth.month +
            1;
        if (count > 12) {
          count = 12;
          startMonth = DateTime(endMonth.year, endMonth.month - 11);
        }
        if (count < 2) {
          count = 2;
          startMonth = DateTime(endMonth.year, endMonth.month - 1);
        }

        final values = List<int>.filled(count, 0);
        dailyUpvotes.forEach((dateKey, upvoteCount) {
          final parts = dateKey.split('-');
          if (parts.length == 3) {
            final y = int.tryParse(parts[0]) ?? now.year;
            final m = int.tryParse(parts[1]) ?? now.month;
            final idx = (y - startMonth.year) * 12 + m - startMonth.month;
            if (idx >= 0 && idx < count) {
              values[idx] += upvoteCount;
            }
          }
        });

        return _ChartSeries(
          unit: 'Bulan',
          labels: List<String>.generate(count, (i) {
            final m = DateTime(startMonth.year, startMonth.month + i);
            return _monthLabels[m.month - 1];
          }),
          values: values,
        );
    }
  }

  // ═════════════════════════════════════════════════════════════════════════
  // Komponen Sub-Widgets
  // ═════════════════════════════════════════════════════════════════════════

  Widget _buildNewUserEmptyState(BuildContext context, bool isDark) {
    return Container(
      padding: const EdgeInsets.fromLTRB(20, 28, 20, 20),
      decoration: BoxDecoration(
        color: AppPalette.surface(context),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppPalette.divider(context), width: 1),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: isDark ? 0.2 : 0.03),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          Container(
            width: 56,
            height: 56,
            decoration: BoxDecoration(
              color: isDark
                  ? const Color(0xFF2563EB).withValues(alpha: 0.15)
                  : const Color(0xFFEFF6FF),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.campaign_rounded,
              color: Color(0xFF2563EB),
              size: 28,
            ),
          ),
          const SizedBox(height: 14),
          Text(
            'Belum ada laporan. Buat laporan pertamamu.',
            textAlign: TextAlign.center,
            style: HomeTextStyles.bodyMd.copyWith(
              color: AppPalette.textPrimary(context),
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 18),
          SizedBox(
            width: double.infinity,
            height: 48,
            child: FilledButton.icon(
              onPressed: () {
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (_) => const CreateReportScreen(),
                  ),
                );
              },
              style: FilledButton.styleFrom(
                backgroundColor: HomeColors.primary,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              icon: const Icon(Icons.add_rounded, color: Colors.white),
              label: Text(
                'Buat Laporan',
                style: GoogleFonts.plusJakartaSans(
                  fontWeight: FontWeight.w600,
                  fontSize: 14,
                  color: Colors.white,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPeriodSelector(BuildContext context, bool isDark) {
    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: AppPalette.surface(context),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppPalette.divider(context), width: 1),
      ),
      child: Row(
        children: [
          _buildPeriodChip(
            label: 'Minggu Ini',
            period: StatsPeriod.mingguIni,
            isDark: isDark,
          ),
          _buildPeriodChip(
            label: 'Bulan Ini',
            period: StatsPeriod.bulanIni,
            isDark: isDark,
          ),
          _buildPeriodChip(
            label: 'Semua Waktu',
            period: StatsPeriod.semuaWaktu,
            isDark: isDark,
          ),
        ],
      ),
    );
  }

  Widget _buildPeriodChip({
    required String label,
    required StatsPeriod period,
    required bool isDark,
  }) {
    final isSelected = _selectedPeriod == period;

    return Expanded(
      child: Semantics(
        button: true,
        selected: isSelected,
        label: 'Filter periode $label',
        child: GestureDetector(
          onTap: () => setState(() => _selectedPeriod = period),
          behavior: HitTestBehavior.opaque,
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            height: 44,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: isSelected
                  ? (isDark ? const Color(0xFF1D4ED8) : HomeColors.primary)
                  : Colors.transparent,
              borderRadius: BorderRadius.circular(10),
              boxShadow: isSelected
                  ? [
                      BoxShadow(
                        color: HomeColors.primary.withValues(alpha: 0.25),
                        blurRadius: 6,
                        offset: const Offset(0, 2),
                      ),
                    ]
                  : null,
            ),
            child: Text(
              label,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: GoogleFonts.plusJakartaSans(
                fontSize: 13,
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                color: isSelected
                    ? Colors.white
                    : AppPalette.textSecondary(context),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildPrimaryMetrics({
    required BuildContext context,
    required bool isDark,
    required int totalReports,
    required int totalUpvotes,
    required int reportsThisMonth,
  }) {
    return Row(
      children: [
        Expanded(
          child: _buildMetricTile(
            context: context,
            isDark: isDark,
            title: 'Laporan Terbit',
            value: '$totalReports',
            unit: _selectedPeriod == StatsPeriod.semuaWaktu
                ? '+$reportsThisMonth bulan ini'
                : 'laporan',
            icon: Icons.campaign_rounded,
            iconColor: const Color(0xFF2563EB),
            iconBg: const Color(0xFFEFF6FF),
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: _buildMetricTile(
            context: context,
            isDark: isDark,
            title: 'Total Upvote',
            value: '$totalUpvotes',
            unit: 'dari mahasiswa lain',
            icon: Icons.arrow_upward_rounded,
            iconColor: _kUpvoteGreen,
            iconBg: const Color(0xFFECFDF5),
          ),
        ),
      ],
    );
  }

  Widget _buildMetricTile({
    required BuildContext context,
    required bool isDark,
    required String title,
    required String value,
    required String unit,
    required IconData icon,
    required Color iconColor,
    required Color iconBg,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
      decoration: BoxDecoration(
        color: AppPalette.surface(context),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppPalette.divider(context), width: 1),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: isDark ? 0.2 : 0.03),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  title,
                  style: HomeTextStyles.labelSm.copyWith(
                    color: AppPalette.textSecondary(context),
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              const SizedBox(width: 4),
              Container(
                width: 28,
                height: 28,
                decoration: BoxDecoration(
                  color: isDark ? iconColor.withValues(alpha: 0.15) : iconBg,
                  shape: BoxShape.circle,
                ),
                child: Icon(icon, color: iconColor, size: 16),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            value,
            style: GoogleFonts.plusJakartaSans(
              fontSize: 22,
              fontWeight: FontWeight.w700,
              color: AppPalette.textPrimary(context),
            ),
          ),
          const SizedBox(height: 2),
          Text(
            unit,
            style: HomeTextStyles.labelSm.copyWith(
              color: AppPalette.textSecondary(context),
              fontSize: 11,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }

  Widget _buildUpvoteChartCard({
    required BuildContext context,
    required bool isDark,
    required _ChartSeries series,
  }) {
    final isEmpty = series.values.every((v) => v == 0);
    final semanticsPoints = List<String>.generate(
      series.values.length,
      (i) => '${series.labels[i]}: ${series.values[i]}',
    ).join(', ');

    return Container(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 12),
      decoration: BoxDecoration(
        color: AppPalette.surface(context),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppPalette.divider(context), width: 1),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: isDark ? 0.2 : 0.03),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'UPVOTE DITERIMA PER ${series.unit.toUpperCase()}',
            style: HomeTextStyles.labelSm.copyWith(
              letterSpacing: 0.8,
              color: AppPalette.textSecondary(context),
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 12),
          Semantics(
            label: 'Grafik garis upvote diterima per ${series.unit.toLowerCase()}. '
                '${isEmpty ? 'Belum ada upvote pada periode ini.' : semanticsPoints}',
            child: ExcludeSemantics(
              child: SizedBox(
                height: 130,
                width: double.infinity,
                child: CustomPaint(
                  painter: _UpvoteLineChartPainter(
                    values: series.values,
                    labels: series.labels,
                    lineColor: _kUpvoteGreen,
                    gridColor: AppPalette.divider(context),
                    pointFillColor: AppPalette.surface(context),
                    labelStyle: HomeTextStyles.labelSm.copyWith(
                      color: AppPalette.textSecondary(context),
                      fontSize: 10,
                    ),
                    valueStyle: HomeTextStyles.labelSm.copyWith(
                      color: _kUpvoteGreen,
                      fontSize: 11,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ),
            ),
          ),
          if (isEmpty) ...[
            const SizedBox(height: 6),
            Text(
              'Belum ada upvote pada periode ini',
              style: HomeTextStyles.labelSm.copyWith(
                color: AppPalette.textSecondary(context),
                fontSize: 11,
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildCategoryRatioSection({
    required BuildContext context,
    required bool isDark,
    required int conditionCount,
    required int infoCount,
    required int total,
  }) {
    final conditionPct = total > 0 ? (conditionCount / total) : 0.0;
    final infoPct = total > 0 ? (infoCount / total) : 0.0;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppPalette.surface(context),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppPalette.divider(context), width: 1),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: isDark ? 0.2 : 0.03),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'DISTRIBUSI KATEGORI',
                style: HomeTextStyles.labelSm.copyWith(
                  letterSpacing: 0.8,
                  color: AppPalette.textSecondary(context),
                  fontWeight: FontWeight.w700,
                ),
              ),
              Text(
                'Total $total laporan',
                style: HomeTextStyles.labelSm.copyWith(
                  color: AppPalette.textSecondary(context),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),

          // Stacked Progress Bar
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: Container(
              height: 12,
              color: AppPalette.divider(context),
              child: Row(
                children: [
                  if (conditionCount > 0)
                    Expanded(
                      flex: conditionCount,
                      child: Container(
                        color: HomeColors.statusCondition,
                      ),
                    ),
                  if (infoCount > 0)
                    Expanded(
                      flex: infoCount,
                      child: Container(
                        color: HomeColors.primary,
                      ),
                    ),
                ],
              ),
            ),
          ),

          const SizedBox(height: 12),

          // Legenda dua kolom
          Row(
            children: [
              Expanded(
                child: _buildLegendItem(
                  context: context,
                  color: HomeColors.statusCondition,
                  label: 'Kondisi Kampus',
                  detail:
                      '$conditionCount laporan (${(conditionPct * 100).toStringAsFixed(0)}%)',
                ),
              ),
              Expanded(
                child: _buildLegendItem(
                  context: context,
                  color: HomeColors.primary,
                  label: 'Info Penting',
                  detail:
                      '$infoCount laporan (${(infoPct * 100).toStringAsFixed(0)}%)',
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildLegendItem({
    required BuildContext context,
    required Color color,
    required String label,
    required String detail,
  }) {
    return Row(
      children: [
        Container(
          width: 10,
          height: 10,
          decoration: BoxDecoration(color: color, shape: BoxShape.circle),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: HomeTextStyles.bodySm.copyWith(
                  color: AppPalette.textPrimary(context),
                  fontWeight: FontWeight.w600,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              Text(
                detail,
                style: HomeTextStyles.labelSm.copyWith(
                  color: AppPalette.textSecondary(context),
                  fontSize: 11,
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

  Widget _buildMostUpvotedReportCard({
    required BuildContext context,
    required bool isDark,
    required ReportModel? topReport,
  }) {
    final cardDecoration = BoxDecoration(
      color: AppPalette.surface(context),
      borderRadius: BorderRadius.circular(16),
      border: Border.all(
        color: _kAmber.withValues(alpha: 0.5),
        width: 1.5,
      ),
      boxShadow: [
        BoxShadow(
          color: _kAmber.withValues(alpha: isDark ? 0.15 : 0.06),
          blurRadius: 10,
          offset: const Offset(0, 3),
        ),
      ],
    );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'LAPORAN TERPOPULER SAYA',
          style: HomeTextStyles.labelSm.copyWith(
            letterSpacing: 0.8,
            color: AppPalette.textSecondary(context),
            fontWeight: FontWeight.w700,
          ),
        ),
        const SizedBox(height: 8),
        if (topReport == null)
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            decoration: cardDecoration,
            child: Text(
              'Belum ada laporan pada periode ini.',
              style: HomeTextStyles.bodySm.copyWith(
                color: AppPalette.textSecondary(context),
              ),
            ),
          )
        else
          Semantics(
            button: true,
            label:
                'Laporan terpopuler: ${topReport.title ?? 'Laporan Tanpa Judul'}, ${topReport.upvoteCount} upvote. Ketuk untuk membuka detail.',
            child: GestureDetector(
              onTap: () {
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (_) => ReportDetailScreen(report: topReport),
                  ),
                );
              },
              behavior: HitTestBehavior.opaque,
              child: Container(
                padding: const EdgeInsets.all(12),
                decoration: cardDecoration,
                child: Row(
                  children: [
                    // Thumbnail gambar laporan jika ada
                    ClipRRect(
                      borderRadius: BorderRadius.circular(10),
                      child: SizedBox(
                        width: 64,
                        height: 64,
                        child: topReport.imageUrl != null
                            ? _buildAdaptiveImage(
                                topReport.imageUrl!,
                                topReport.badgeLabel == 'Kondisi Kampus',
                              )
                            : Container(
                                color: HomeColors.surfaceVariant,
                                child: const Icon(
                                  Icons.campaign_rounded,
                                  color: HomeColors.primary,
                                  size: 28,
                                ),
                              ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            topReport.title ?? 'Laporan Tanpa Judul',
                            style: HomeTextStyles.labelLg.copyWith(
                              color: AppPalette.textPrimary(context),
                              fontWeight: FontWeight.w700,
                            ),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                          const SizedBox(height: 4),
                          Row(
                            children: [
                              const Icon(
                                Icons.location_on,
                                size: 13,
                                color: HomeColors.primary,
                              ),
                              const SizedBox(width: 3),
                              Expanded(
                                child: Text(
                                  topReport.locationName ?? 'UNAND',
                                  style: HomeTextStyles.labelSm.copyWith(
                                    color: AppPalette.textSecondary(context),
                                    fontSize: 11,
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 10),
                    Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(
                          Icons.arrow_upward_rounded,
                          size: 18,
                          color: _kUpvoteGreen,
                        ),
                        Text(
                          '${topReport.upvoteCount}',
                          style: GoogleFonts.plusJakartaSans(
                            fontSize: 15,
                            fontWeight: FontWeight.w700,
                            color: _kUpvoteGreen,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildAdaptiveImage(String pathOrUrl, bool isCondition) {
    if (pathOrUrl.startsWith('http://') || pathOrUrl.startsWith('https://')) {
      return Image.network(
        pathOrUrl,
        fit: BoxFit.cover,
        errorBuilder: (_, _, _) => Icon(
          isCondition ? Icons.apartment_rounded : Icons.campaign_rounded,
          color: HomeColors.primaryContainer,
        ),
      );
    }
    if (pathOrUrl.startsWith('assets/')) {
      return Image.asset(
        pathOrUrl,
        fit: BoxFit.cover,
        errorBuilder: (_, _, _) => Icon(
          isCondition ? Icons.apartment_rounded : Icons.campaign_rounded,
          color: HomeColors.primaryContainer,
        ),
      );
    }
    return Image.file(
      File(pathOrUrl),
      fit: BoxFit.cover,
      errorBuilder: (_, _, _) => Icon(
        isCondition ? Icons.apartment_rounded : Icons.campaign_rounded,
        color: HomeColors.primaryContainer,
      ),
    );
  }
}

/// Seri data grafik upvote (label sumbu X + nilai per titik).
class _ChartSeries {
  const _ChartSeries({
    required this.unit,
    required this.labels,
    required this.values,
  });

  /// Satuan granularitas: "Hari", "Minggu", atau "Bulan".
  final String unit;
  final List<String> labels;
  final List<int> values;
}

/// Grafik garis upvote sederhana tanpa dependency tambahan.
class _UpvoteLineChartPainter extends CustomPainter {
  _UpvoteLineChartPainter({
    required this.values,
    required this.labels,
    required this.lineColor,
    required this.gridColor,
    required this.pointFillColor,
    required this.labelStyle,
    required this.valueStyle,
  });

  final List<int> values;
  final List<String> labels;
  final Color lineColor;
  final Color gridColor;
  final Color pointFillColor;
  final TextStyle labelStyle;
  final TextStyle valueStyle;

  static const List<int> _stepCandidates = [
    1, 2, 5, 10, 20, 25, 50, 100, 200, 250, 500, 1000, 2000, 5000, 10000,
  ];

  TextPainter _layoutText(String text, TextStyle style) {
    return TextPainter(
      text: TextSpan(text: text, style: style),
      textDirection: TextDirection.ltr,
      maxLines: 1,
    )..layout();
  }

  @override
  void paint(Canvas canvas, Size size) {
    if (values.isEmpty) return;

    // ── Skala sumbu Y yang rapi ──────────────────────────────────────
    final maxVal = values.fold<int>(0, (a, b) => b > a ? b : a);
    var step = _stepCandidates.last;
    for (final c in _stepCandidates) {
      if (c * 4 >= maxVal) {
        step = c;
        break;
      }
    }
    final intervals = maxVal == 0 ? 4 : ((maxVal + step - 1) ~/ step);
    final yMax = step * (intervals < 1 ? 1 : intervals);
    final tickCount = yMax ~/ step;

    // ── Area plot ────────────────────────────────────────────────────
    final yLabelPainters = List<TextPainter>.generate(
      tickCount + 1,
      (i) => _layoutText('${step * i}', labelStyle),
    );
    final yLabelWidth = yLabelPainters.fold<double>(
      0,
      (a, tp) => tp.width > a ? tp.width : a,
    );
    const topPad = 18.0;
    const bottomPad = 18.0;
    const rightPad = 10.0;
    final leftPad = yLabelWidth + 8;

    final plotLeft = leftPad;
    final plotRight = size.width - rightPad;
    final plotTop = topPad;
    final plotBottom = size.height - bottomPad;
    final plotWidth = plotRight - plotLeft;
    final plotHeight = plotBottom - plotTop;
    if (plotWidth <= 0 || plotHeight <= 0) return;

    // ── Gridlines & label sumbu Y ────────────────────────────────────
    final gridPaint = Paint()
      ..color = gridColor
      ..strokeWidth = 1;
    for (var i = 0; i <= tickCount; i++) {
      final y = plotBottom - plotHeight * (i / tickCount);
      canvas.drawLine(Offset(plotLeft, y), Offset(plotRight, y), gridPaint);
      final tp = yLabelPainters[i];
      tp.paint(canvas, Offset(leftPad - 6 - tp.width, y - tp.height / 2));
    }

    // ── Titik data ───────────────────────────────────────────────────
    final n = values.length;
    final points = List<Offset>.generate(n, (i) {
      final x = n == 1 ? plotLeft + plotWidth / 2 : plotLeft + plotWidth * (i / (n - 1));
      final y = plotBottom - plotHeight * (values[i] / yMax);
      return Offset(x, y);
    });

    // ── Area semi-transparan di bawah garis ──────────────────────────
    final areaPath = Path()..moveTo(points.first.dx, plotBottom);
    for (final p in points) {
      areaPath.lineTo(p.dx, p.dy);
    }
    areaPath
      ..lineTo(points.last.dx, plotBottom)
      ..close();
    final areaPaint = Paint()
      ..shader = LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [
          lineColor.withValues(alpha: 0.28),
          lineColor.withValues(alpha: 0.02),
        ],
      ).createShader(Rect.fromLTRB(plotLeft, plotTop, plotRight, plotBottom));
    canvas.drawPath(areaPath, areaPaint);

    // ── Garis ────────────────────────────────────────────────────────
    final linePath = Path()..moveTo(points.first.dx, points.first.dy);
    for (var i = 1; i < n; i++) {
      linePath.lineTo(points[i].dx, points[i].dy);
    }
    canvas.drawPath(
      linePath,
      Paint()
        ..color = lineColor
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2.5
        ..strokeJoin = StrokeJoin.round
        ..strokeCap = StrokeCap.round,
    );

    // ── Titik tiap data (titik terakhir lebih besar) ─────────────────
    final isDense = n > 15;
    final dotFill = Paint()..color = pointFillColor;
    final dotStroke = Paint()
      ..color = lineColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2;

    if (!isDense) {
      for (var i = 0; i < n - 1; i++) {
        canvas.drawCircle(points[i], 3, dotFill);
        canvas.drawCircle(points[i], 3, dotStroke);
      }
    } else {
      // Pada tampilan padat (misal 30/31 hari), hanya sorot titik bernilai > 0 agar tidak bertumpuk
      for (var i = 0; i < n - 1; i++) {
        if (values[i] > 0) {
          canvas.drawCircle(points[i], 2.5, dotFill);
          canvas.drawCircle(points[i], 2.5, dotStroke);
        }
      }
    }

    final last = points.last;
    canvas.drawCircle(last, isDense ? 5 : 6, Paint()..color = lineColor);
    canvas.drawCircle(
      last,
      isDense ? 5 : 6,
      Paint()
        ..color = pointFillColor
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2,
    );

    // Angka pada titik terakhir
    final valueTp = _layoutText('${values.last}', valueStyle);
    var valueX = last.dx - valueTp.width / 2;
    if (valueX + valueTp.width > size.width) {
      valueX = size.width - valueTp.width;
    }
    final valueY = (last.dy - 10 - valueTp.height).clamp(0.0, size.height);
    valueTp.paint(canvas, Offset(valueX, valueY));

    // ── Label sumbu X ────────────────────────────────────────────────
    final spacing = n > 1 ? plotWidth / (n - 1) : plotWidth;
    for (var i = 0; i < n; i++) {
      if (isDense) {
        // Tampilkan label tanggal pada: tgl 1, kelipatan 5 (5, 10, 15, 20, 25), dan hari terakhir (28/30/31)
        final dayNum = i + 1;
        final isLast = i == n - 1;
        final isMilestone = dayNum == 1 || dayNum % 5 == 0;
        if (!isLast && !isMilestone) continue;
        if (!isLast && dayNum == 30 && n == 31) continue; // Jangan tabrak tgl 31
      } else {
        final every = spacing < 24 ? 2 : 1;
        final isLast = i == n - 1;
        if (!isLast && i % every != 0) continue;
        if (every > 1 && !isLast && i == n - 2) continue;
      }
      final tp = _layoutText(labels[i], labelStyle);
      var x = points[i].dx - tp.width / 2;
      if (x < plotLeft - 4) x = plotLeft - 4;
      if (x + tp.width > size.width) x = size.width - tp.width;
      tp.paint(canvas, Offset(x, plotBottom + 4));
    }
  }

  @override
  bool shouldRepaint(covariant _UpvoteLineChartPainter oldDelegate) {
    return oldDelegate.values.toString() != values.toString() ||
        oldDelegate.labels.toString() != labels.toString() ||
        oldDelegate.lineColor != lineColor ||
        oldDelegate.gridColor != gridColor ||
        oldDelegate.pointFillColor != pointFillColor ||
        oldDelegate.labelStyle != labelStyle ||
        oldDelegate.valueStyle != valueStyle;
  }
}
