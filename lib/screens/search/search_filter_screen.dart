import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../theme/app_palette.dart';
import '../../theme/app_spacing.dart';
import '../../widgets/home/upvote_button.dart';
import '../../widgets/home/video_player_box.dart';
import '../home/data/report_repository.dart';
import '../home/models/report_model.dart';
import '../home/report_detail_screen.dart';

// ─── Design constants ─────────────────────────────────────────────────────────

/// Colors from the Figma CSS export.
const Color _kBgWhite = Color(0xFFFFFFFF);
const Color _kBgBlue100 = Color(0xFFE5EEFF);
const Color _kPrimary = Color(0xFF0048D4);
const Color _kPrimaryDeep = Color(0xFF0B3A9C);
const Color _kBorderPrimary = Color(0xFF0048D4);
const Color _kConditionBg = Color(0xFFFEF3DC);
const Color _kConditionText = Color(0xFF653E00);
const Color _kConditionBorder = Color(0xFF9C6200);
const Color _kStatusCondition = Color(0xFFF59E0B);
const Color _kStatusInfo = Color(0xFF0048D4);
const Color _kBorderOutline = Color(0xFFC3CADB);

/// Radius tokens.
const double _kRadiusFull = 9999;
const double _kRadiusLg = 16;
const double _kRadiusMd = 12;
const double _kRadiusSm = 8;

// ─── Data Models ──────────────────────────────────────────────────────────────

/// Enum for report categories.
enum ReportCategory { kondisiKampus, informasiPenting }

/// Enum for sorting.
enum SortMode { terbaru, upvoteTerbanyak }

/// Enum for time range.
enum TimeRange { hariIni, tujuhHari, bulanIni, semua }

/// Preview result item.
class SearchResultItem {
  const SearchResultItem({
    required this.id,
    required this.title,
    required this.location,
    required this.age,
    required this.upvoteCount,
    required this.isUpvoted,
    required this.imageUrl,
    required this.category,
    this.report,
  });

  final String id;
  final String title;
  final String location;

  /// Umur laporan sejak dibuat. Dipakai untuk filter rentang waktu & urutan terbaru.
  final Duration age;
  final int upvoteCount;
  final bool isUpvoted;
  final String imageUrl;
  final ReportCategory category;
  final ReportModel? report;

  /// Label waktu relatif yang ditampilkan di UI, diturunkan dari [age].
  String get timeAgo {
    if (age.inHours < 1) return '${age.inMinutes}m lalu';
    if (age.inDays < 1) return '${age.inHours} jam lalu';
    if (age.inDays == 1) return 'Kemarin';
    return '${age.inDays} hari lalu';
  }
}

/// Batas umur maksimal laporan untuk setiap rentang waktu (null = tanpa batas).
Duration? _maxAgeFor(TimeRange range) {
  switch (range) {
    case TimeRange.hariIni:
      return const Duration(days: 1);
    case TimeRange.tujuhHari:
      return const Duration(days: 7);
    case TimeRange.bulanIni:
      return const Duration(days: 30);
    case TimeRange.semua:
      return null;
  }
}

/// Return data when "Terapkan filter" is pressed.
class SearchFilterResult {
  const SearchFilterResult({
    required this.query,
    required this.categories,
    required this.sortMode,
    required this.timeRange,
    required this.resultCount,
  });

  final String query;
  final Set<ReportCategory> categories;
  final SortMode sortMode;
  final TimeRange timeRange;
  final int resultCount;
}

// ─── Live Data from Repository ────────────────────────────────────────────────

/// Mapping dari metaText di [ReportModel] ke [Duration] untuk dipakai di filter
/// rentang waktu halaman search. Parsing sederhana dari string "Xm lalu",
/// "X jam lalu", "X hari lalu".
Duration _parseAge(String metaText) {
  // metaText format: "Gedung GKB C • 15m lalu" atau "Bundaran PKM UNAND • 1 jam lalu"
  final parts = metaText.split('•');
  if (parts.length < 2) return Duration.zero;
  final timePart = parts.last.trim(); // e.g. "15m lalu", "1 jam lalu", "1 hari lalu"

  final mMatch = RegExp(r'(\d+)\s*m\s+lalu').firstMatch(timePart);
  if (mMatch != null) return Duration(minutes: int.parse(mMatch.group(1)!));

  final hMatch = RegExp(r'(\d+)\s*jam\s+lalu').firstMatch(timePart);
  if (hMatch != null) return Duration(hours: int.parse(hMatch.group(1)!));

  final dMatch = RegExp(r'(\d+)\s*hari\s+lalu').firstMatch(timePart);
  if (dMatch != null) return Duration(days: int.parse(dMatch.group(1)!));

  return Duration.zero;
}

/// Konversi [ReportModel] dari repository ke [SearchResultItem].
/// Data dibaca live dari [ReportRepository] sehingga upvote count
/// dan status upvote selalu sinkron dengan halaman Home.
List<SearchResultItem> _buildLiveResults() {
  final repo = ReportRepository.instance;
  return repo.reports.map((r) {
    final category = r.badgeLabel == 'Info Penting'
        ? ReportCategory.informasiPenting
        : ReportCategory.kondisiKampus;
    final title = r.title ?? (r.contentTitle ?? '');
    return SearchResultItem(
      id: r.id,
      title: title,
      location: r.locationName ?? '',
      age: _parseAge(r.metaText),
      upvoteCount: r.upvoteCount,
      isUpvoted: r.isUpvoted,
      imageUrl: r.imageUrl ?? '',
      category: category,
      report: r,
    );
  }).toList();
}

// ─── Screen ───────────────────────────────────────────────────────────────────

/// Halaman Cari & Filter untuk mencari dan memfilter laporan kampus.
///
/// **Workflow UTS (5 tahap - Manual Apply Pattern):**
/// 1. Input/Event  → User mengubah draft (ketik/kategori/sort/waktu), lalu menekan tombol "Terapkan filter"
/// 2. State        → Pemisahan Draft State (pilihan UI saat ini) vs Applied State (filter aktif yang menghasilkan data)
/// 3. Validation   → Minimal 1 kategori harus dipilih pada draft sebelum diterapkan
/// 4. Feedback     → Floating SnackBar error jika validasi gagal, SnackBar sukses + auto-scroll ke Pratinjau Hasil jika berhasil
/// 5. Navigation   → Menerima [initialFilter] dari screen pemanggil saat dibuka, dan mengembalikan
///                   [SearchFilterResult] ke screen pemanggil via tombol back (←) jika filter diterapkan
class SearchFilterScreen extends StatefulWidget {
  const SearchFilterScreen({super.key, this.initialFilter});

  /// Data yang dikirim dari screen pemanggil: filter terakhir yang diterapkan user.
  /// Null jika user belum pernah menerapkan filter (pakai nilai default).
  final SearchFilterResult? initialFilter;

  @override
  State<SearchFilterScreen> createState() => _SearchFilterScreenState();
}

class _SearchFilterScreenState extends State<SearchFilterScreen> {
  // ── 2. State ────────────────────────────────────────────────────────────

  // ── Draft State (Menyimpan pilihan user yang sedang diubah di UI) ────────
  final TextEditingController _searchController = TextEditingController();

  /// Kategori yang dipilih user pada draft (bisa lebih dari satu).
  final Set<ReportCategory> _draftCategories = {ReportCategory.kondisiKampus};

  /// Mode sorting pada draft.
  SortMode _draftSortMode = SortMode.terbaru;

  /// Rentang waktu pada draft.
  TimeRange _draftTimeRange = TimeRange.tujuhHari;

  // ── Applied State (Filter aktif yang menghasilkan data pratinjau) ───────
  String _appliedQuery = '';
  Set<ReportCategory> _appliedCategories = {ReportCategory.kondisiKampus};
  SortMode _appliedSortMode = SortMode.terbaru;
  TimeRange _appliedTimeRange = TimeRange.tujuhHari;

  /// Hasil laporan yang benar-benar aktif/diterapkan.
  List<SearchResultItem> _appliedResults = [];

  /// Result filter yang dikembalikan saat tombol Back ditekan.
  /// Tetap null selama user belum menekan "Terapkan filter" di sesi ini,
  /// sehingga screen pemanggil tidak menampilkan pesan "Filter diterapkan".
  SearchFilterResult? _appliedResult;

  final ScrollController _scrollController = ScrollController();
  final GlobalKey _previewKey = GlobalKey();

  @override
  void initState() {
    super.initState();
    // Dengarkan perubahan pada repository agar data sinkron real-time
    ReportRepository.instance.addListener(_onRepoChanged);

    // Pakai data yang dikirim screen pemanggil sebagai draft & applied state awal
    final initial = widget.initialFilter;
    if (initial != null) {
      _searchController.text = initial.query;
      _draftCategories
        ..clear()
        ..addAll(initial.categories);
      _draftSortMode = initial.sortMode;
      _draftTimeRange = initial.timeRange;

      _appliedQuery = initial.query;
      _appliedCategories = Set.from(initial.categories);
      _appliedSortMode = initial.sortMode;
      _appliedTimeRange = initial.timeRange;
    }

    // Inisialisasi hasil pratinjau awal saat screen pertama kali dibuka
    _executeAppliedFilter();
  }

  @override
  void dispose() {
    ReportRepository.instance.removeListener(_onRepoChanged);
    _searchController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _onRepoChanged() {
    if (mounted) {
      setState(() {
        _executeAppliedFilter();
      });
    }
  }

  /// Menjalankan filter terhadap mock data hanya berdasarkan applied state.
  void _executeAppliedFilter() {
    final query = _appliedQuery.toLowerCase();
    List<SearchResultItem> results = _buildLiveResults();

    // Filter by category
    if (_appliedCategories.isNotEmpty) {
      results = results
          .where((item) => _appliedCategories.contains(item.category))
          .toList();
    }

    // Filter by search query
    if (query.isNotEmpty) {
      results = results
          .where(
            (item) =>
                item.title.toLowerCase().contains(query) ||
                item.location.toLowerCase().contains(query),
          )
          .toList();
    }

    // Filter by time range
    final maxAge = _maxAgeFor(_appliedTimeRange);
    if (maxAge != null) {
      results = results.where((item) => item.age < maxAge).toList();
    }

    // Sort
    if (_appliedSortMode == SortMode.upvoteTerbanyak) {
      results.sort((a, b) => b.upvoteCount.compareTo(a.upvoteCount));
    } else {
      // Terbaru: umur laporan paling kecil di atas
      results.sort((a, b) => a.age.compareTo(b.age));
    }

    _appliedResults = results;
  }

  // ── 3. Validation ──────────────────────────────────────────────────────

  /// Validasi: minimal satu kategori harus dipilih pada draft.
  bool _validateFilters() {
    if (_draftCategories.isEmpty) {
      return false;
    }
    return true;
  }

  // ── 4. Feedback ────────────────────────────────────────────────────────

  void _showValidationError() {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          content: Row(
            children: [
              const Icon(
                Icons.warning_amber_rounded,
                color: Colors.orangeAccent,
                size: 20,
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  'Pilih minimal satu kategori untuk menerapkan filter',
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 13,
                    fontWeight: FontWeight.w500,
                    color: Colors.white,
                  ),
                ),
              ),
            ],
          ),
          backgroundColor: const Color(0xFF213145),
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(_kRadiusFull),
          ),
          elevation: 20,
          margin: const EdgeInsets.fromLTRB(24, 0, 24, 24),
          duration: const Duration(seconds: 3),
        ),
      );
  }

  void _showSuccessFeedback(int count) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          content: Row(
            children: [
              const Icon(
                Icons.check_circle,
                color: Color(0xFF10B981),
                size: 20,
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  'Filter diterapkan · $count laporan ditemukan',
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 13,
                    fontWeight: FontWeight.w500,
                    color: Colors.white,
                  ),
                ),
              ),
            ],
          ),
          backgroundColor: const Color(0xFF213145),
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(_kRadiusFull),
          ),
          elevation: 20,
          margin: const EdgeInsets.fromLTRB(24, 0, 24, 24),
          duration: const Duration(seconds: 2),
        ),
      );
  }

  // ── 5. Navigation / Result / Apply ─────────────────────────────────────

  /// Terapkan filter: salin draft state ke applied state dan perbarui pratinjau.
  /// User tetap berada di layar Cari & Filter (tidak pop).
  void _applyFilter() {
    // 3. Validation: cek draft sebelum diterapkan
    if (!_validateFilters()) {
      // 4. Feedback (error)
      _showValidationError();
      return;
    }

    setState(() {
      // Salin Draft State -> Applied State
      _appliedQuery = _searchController.text.trim();
      _appliedCategories = Set.from(_draftCategories);
      _appliedSortMode = _draftSortMode;
      _appliedTimeRange = _draftTimeRange;

      // Jalankan proses filter
      _executeAppliedFilter();

      // Simpan result untuk dikembalikan ke screen pemanggil saat Back
      _appliedResult = SearchFilterResult(
        query: _appliedQuery,
        categories: Set.from(_appliedCategories),
        sortMode: _appliedSortMode,
        timeRange: _appliedTimeRange,
        resultCount: _appliedResults.length,
      );
    });

    // 4. Feedback (sukses)
    _showSuccessFeedback(_appliedResults.length);

    // Auto-scroll ke bagian Pratinjau hasil agar langsung terlihat
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_previewKey.currentContext != null) {
        Scrollable.ensureVisible(
          _previewKey.currentContext!,
          duration: const Duration(milliseconds: 500),
          curve: Curves.easeInOutCubic,
        );
      }
    });
  }

  /// Menutup halaman dan mengembalikan applied filter terakhir ke screen sebelumnya
  /// (null jika user tidak menekan "Terapkan filter").
  void _handleBack() {
    Navigator.pop(context, _appliedResult);
  }

  /// Reset draft state ke default (tanpa kategori, urutan terbaru, rentang semua, query kosong).
  /// Tidak langsung mengubah applied state (user tetap perlu menekan Terapkan).
  void _resetFilters() {
    setState(() {
      _searchController.text = '';
      _draftCategories.clear();
      _draftSortMode = SortMode.terbaru;
      _draftTimeRange = TimeRange.semua;
    });
    // Applied state dan hasil pratinjau TIDAK berubah saat Reset
  }

  // ── Category toggle ────────────────────────────────────────────────────

  void _toggleCategory(ReportCategory cat) {
    setState(() {
      if (_draftCategories.contains(cat)) {
        _draftCategories.remove(cat);
      } else {
        _draftCategories.add(cat);
      }
    });
    // HANYA memperbarui draft state! Hasil pratinjau tidak berubah sampai Terapkan ditekan.
  }

  // ─── Build ─────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    final topPadding = MediaQuery.of(context).padding.top;
    final bottomPadding = MediaQuery.of(context).padding.bottom;

    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, _) {
        if (didPop) return;
        _handleBack();
      },
      child: Scaffold(
        backgroundColor: AppPalette.canvas(context),
        body: Column(
          children: [
            // ── Header (white bg) ──────────────────────────────────────
            _buildHeader(topPadding),

            // ── Scrollable content ─────────────────────────────────────
            Expanded(
              child: SingleChildScrollView(
                controller: _scrollController,
                padding: const EdgeInsets.only(bottom: 120),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: AppSpacing.lg),
                    _buildSearchBar(),
                    const SizedBox(height: 24),
                    _buildKategoriSection(),
                    const SizedBox(height: 24),
                    _buildUrutkanSection(),
                    const SizedBox(height: 24),
                    _buildRentangWaktuSection(),
                    const SizedBox(height: 24),
                    _buildPratinjauHasil(),
                  ],
                ),
              ),
            ),

            // ── Footer ─────────────────────────────────────────────────
            _buildFooter(bottomPadding),
          ],
        ),
      ),
    );
  }

  // ═══════════════════════════════════════════════════════════════════════
  // Sub-widgets
  // ═══════════════════════════════════════════════════════════════════════

  Widget _buildHeader(double topPadding) {
    return Container(
      color: AppPalette.surface(context),
      child: Column(
        children: [
          SizedBox(height: topPadding),
          SizedBox(
            height: 56,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
              child: Row(
                children: [
                  // Back button
                  GestureDetector(
                    onTap: _handleBack,
                    child: Icon(
                      Icons.arrow_back,
                      color: AppPalette.textPrimary(context),
                      size: 24,
                    ),
                  ),
                  const SizedBox(width: 12),
                  // Title
                  Text(
                    'Cari & Filter',
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                      color: AppPalette.textPrimary(context),
                    ),
                  ),
                  const Spacer(),
                  // Reset button
                  GestureDetector(
                    onTap: _resetFilters,
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.refresh_rounded, color: _kPrimary, size: 14),
                        const SizedBox(width: 4),
                        Text(
                          'Reset',
                          style: GoogleFonts.plusJakartaSans(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: _kPrimary,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
          // Separator line
          Container(height: 1, color: AppPalette.divider(context)),
        ],
      ),
    );
  }

  Widget _buildSearchBar() {
    final isDark = AppPalette.isDark(context);
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
      child: Container(
        height: 48,
        decoration: BoxDecoration(
          color: AppPalette.surface(context),
          borderRadius: BorderRadius.circular(_kRadiusFull),
          border: Border.all(
            color: isDark ? const Color(0xFF3B82F6) : _kBorderPrimary,
            width: 1.5,
          ),
        ),
        child: Row(
          children: [
            const SizedBox(width: 16),
            // Search icon
            Icon(Icons.search, color: AppPalette.textSecondary(context), size: 20),
            const SizedBox(width: 10),
            // Text field (transparent to avoid double-box border nesting)
            Expanded(
              child: TextField(
                controller: _searchController,
                textAlignVertical: TextAlignVertical.center,
                textInputAction: TextInputAction.search,
                onSubmitted: (_) => _applyFilter(),
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 14,
                  fontWeight: FontWeight.w400,
                  color: AppPalette.textPrimary(context),
                ),
                decoration: InputDecoration(
                  hintText: 'Cari laporan kampus...',
                  hintStyle: GoogleFonts.plusJakartaSans(
                    fontSize: 14,
                    fontWeight: FontWeight.w400,
                    color: AppPalette.textSecondary(context),
                  ),
                  filled: false,
                  fillColor: Colors.transparent,
                  border: InputBorder.none,
                  enabledBorder: InputBorder.none,
                  focusedBorder: InputBorder.none,
                  errorBorder: InputBorder.none,
                  disabledBorder: InputBorder.none,
                  isDense: true,
                  contentPadding: EdgeInsets.zero,
                ),
              ),
            ),
            // Dynamic clear button: only shown when user types text
            ValueListenableBuilder<TextEditingValue>(
              valueListenable: _searchController,
              builder: (context, value, _) {
                if (value.text.isEmpty) {
                  return const SizedBox(width: 16);
                }
                return Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: GestureDetector(
                    onTap: () {
                      _searchController.clear();
                    },
                    behavior: HitTestBehavior.opaque,
                    child: Container(
                      width: 28,
                      height: 28,
                      decoration: BoxDecoration(
                        color: isDark
                            ? AppPalette.surfaceSubtle(context)
                            : _kBgBlue100,
                        shape: BoxShape.circle,
                      ),
                      child: const Center(
                        child: Icon(
                          Icons.close_rounded,
                          color: _kPrimary,
                          size: 16,
                        ),
                      ),
                    ),
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  // ── Kategori Section ───────────────────────────────────────────────────

  Widget _buildKategoriSection() {
    final kondisiSelected = _draftCategories.contains(
      ReportCategory.kondisiKampus,
    );
    final infoSelected = _draftCategories.contains(
      ReportCategory.informasiPenting,
    );

    // Count items per category
    final allItems = _buildLiveResults();
    final kondisiCount = allItems
        .where((item) => item.category == ReportCategory.kondisiKampus)
        .length;
    final infoCount = allItems
        .where((item) => item.category == ReportCategory.informasiPenting)
        .length;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Title row
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Kategori',
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  color: AppPalette.textPrimary(context),
                ),
              ),
              Text(
                'Pilih satu atau keduanya',
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 12,
                  fontWeight: FontWeight.w400,
                  color: AppPalette.textSecondary(context),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),

          // Kondisi Kampus card
          _buildCategoryCard(
            isSelected: kondisiSelected,
            iconBgColor: _kConditionBg,
            iconWidget: Icon(
              Icons.location_on_outlined,
              color: _kConditionBorder,
              size: 20,
            ),
            title: 'Kondisi Kampus',
            badgeCount: kondisiCount,
            badgeLabel: 'aktif',
            badgeBgColor: _kConditionBg,
            badgeTextColor: _kConditionText,
            description: 'Fasilitas rusak, jalan berlubang, pohon\ntumbang, lampu padam.',
            onTap: () => _toggleCategory(ReportCategory.kondisiKampus),
          ),
          const SizedBox(height: 12),

          // Informasi Penting card
          _buildCategoryCard(
            isSelected: infoSelected,
            iconBgColor: _kBgBlue100,
            iconWidget: Icon(
              Icons.campaign_outlined,
              color: _kPrimary,
              size: 20,
            ),
            title: 'Informasi Penting',
            badgeCount: infoCount,
            badgeLabel: 'aktif',
            badgeBgColor: _kBgBlue100,
            badgeTextColor: _kPrimaryDeep,
            description:
                'Barang hilang/ditemukan, pengumuman,\ndan informasi sivitas.',
            onTap: () => _toggleCategory(ReportCategory.informasiPenting),
          ),
        ],
      ),
    );
  }

  Widget _buildCategoryCard({
    required bool isSelected,
    required Color iconBgColor,
    required Widget iconWidget,
    required String title,
    required int badgeCount,
    required String badgeLabel,
    required Color badgeBgColor,
    required Color badgeTextColor,
    required String description,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppPalette.surface(context),
          borderRadius: BorderRadius.circular(_kRadiusMd),
          border: Border.all(
            color: isSelected ? _kBorderPrimary : AppPalette.divider(context),
            width: 1.5,
          ),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Icon circle
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: iconBgColor,
                borderRadius: BorderRadius.circular(_kRadiusSm),
              ),
              child: Center(child: iconWidget),
            ),
            const SizedBox(width: 12),
            // Texts
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Text(
                        title,
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 15,
                          fontWeight: FontWeight.w700,
                          color: AppPalette.textPrimary(context),
                        ),
                      ),
                      const SizedBox(width: 8),
                      // Badge count
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 2,
                        ),
                        decoration: BoxDecoration(
                          color: badgeBgColor,
                          borderRadius: BorderRadius.circular(_kRadiusFull),
                        ),
                        child: Text(
                          '$badgeCount $badgeLabel',
                          style: GoogleFonts.plusJakartaSans(
                            fontSize: 11,
                            fontWeight: FontWeight.w700,
                            color: badgeTextColor,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    description,
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 12,
                      fontWeight: FontWeight.w400,
                      color: AppPalette.textSecondary(context),
                      height: 1.4,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 8),
            // Checkbox
            AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              width: 24,
              height: 24,
              decoration: BoxDecoration(
                color: isSelected ? _kPrimary : Colors.transparent,
                shape: BoxShape.circle,
                border: Border.all(
                  color: isSelected ? _kPrimary : _kBorderOutline,
                  width: 1.5,
                ),
              ),
              child: isSelected
                  ? const Center(
                      child: Icon(Icons.check, color: _kBgWhite, size: 16),
                    )
                  : null,
            ),
          ],
        ),
      ),
    );
  }

  // ── Urutkan Section ────────────────────────────────────────────────────

  Widget _buildUrutkanSection() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Urutkan',
            style: GoogleFonts.plusJakartaSans(
              fontSize: 16,
              fontWeight: FontWeight.w700,
              color: AppPalette.textPrimary(context),
            ),
          ),
          const SizedBox(height: 12),
          Container(
            height: 48,
            decoration: BoxDecoration(
              color: AppPalette.surfaceSubtle(context),
              borderRadius: BorderRadius.circular(_kRadiusFull),
            ),
            child: Row(
              children: [
                // Terbaru
                Expanded(
                  child: _buildSortChip(
                    icon: Icons.access_time,
                    label: 'Terbaru',
                    isSelected: _draftSortMode == SortMode.terbaru,
                    onTap: () {
                      setState(() => _draftSortMode = SortMode.terbaru);
                    },
                  ),
                ),
                // Upvote terbanyak
                Expanded(
                  child: _buildSortChip(
                    icon: Icons.arrow_upward,
                    label: 'Upvote terbanyak',
                    isSelected: _draftSortMode == SortMode.upvoteTerbanyak,
                    onTap: () {
                      setState(() => _draftSortMode = SortMode.upvoteTerbanyak);
                    },
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSortChip({
    required IconData icon,
    required String label,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        margin: const EdgeInsets.all(4),
        decoration: BoxDecoration(
          color: isSelected ? AppPalette.surface(context) : Colors.transparent,
          borderRadius: BorderRadius.circular(_kRadiusFull),
        ),
        child: Center(
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                icon,
                size: 16,
                color: isSelected
                    ? _kPrimary
                    : AppPalette.textSecondary(context),
              ),
              const SizedBox(width: 6),
              Text(
                label,
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                  color: isSelected
                      ? _kPrimary
                      : AppPalette.textSecondary(context),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ── Rentang Waktu Section ──────────────────────────────────────────────

  Widget _buildRentangWaktuSection() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Rentang waktu',
            style: GoogleFonts.plusJakartaSans(
              fontSize: 16,
              fontWeight: FontWeight.w700,
              color: AppPalette.textPrimary(context),
            ),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              _buildTimeChip(label: 'Hari ini', range: TimeRange.hariIni),
              const SizedBox(width: 8),
              _buildTimeChip(label: '7 hari', range: TimeRange.tujuhHari),
              const SizedBox(width: 8),
              _buildTimeChip(label: 'Bulan ini', range: TimeRange.bulanIni),
              const SizedBox(width: 8),
              _buildTimeChip(label: 'Semua', range: TimeRange.semua),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildTimeChip({required String label, required TimeRange range}) {
    final isSelected = _draftTimeRange == range;
    return Expanded(
      child: GestureDetector(
        onTap: () {
          setState(() => _draftTimeRange = range);
        },
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          height: 40,
          decoration: BoxDecoration(
            color: isSelected ? _kPrimary : AppPalette.surface(context),
            borderRadius: BorderRadius.circular(_kRadiusFull),
            border: isSelected
                ? null
                : Border.all(color: AppPalette.divider(context), width: 1.5),
          ),
          child: Center(
            child: Text(
              label,
              style: GoogleFonts.plusJakartaSans(
                fontSize: 12,
                fontWeight: FontWeight.w700,
                color: isSelected
                    ? _kBgWhite
                    : AppPalette.textSecondary(context),
              ),
            ),
          ),
        ),
      ),
    );
  }

  // ── Pratinjau Hasil Section ────────────────────────────────────────────

  Widget _buildPratinjauHasil() {
    // Show max 3 preview items from applied results
    final previewItems = _appliedResults.take(100).toList();

    return Padding(
      key: _previewKey,
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Title row
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Pratinjau hasil',
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  color: AppPalette.textPrimary(context),
                ),
              ),
              Text(
                '${_appliedResults.length} ditemukan',
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                  color: _kPrimary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),

          // Results card
          if (previewItems.isEmpty)
            _buildEmptyState()
          else
            Container(
              decoration: BoxDecoration(
                color: AppPalette.surface(context),
                borderRadius: BorderRadius.circular(_kRadiusLg),
                border: Border.all(
                  color: AppPalette.divider(context),
                  width: 1,
                ),
                boxShadow: [
                  BoxShadow(
                    color: AppPalette.isDark(context)
                        ? Colors.black26
                        : const Color(0x0D000000),
                    blurRadius: 4,
                    offset: const Offset(0, 1),
                  ),
                ],
              ),
              padding: const EdgeInsets.all(8),
              child: Column(
                children: [
                  for (int i = 0; i < previewItems.length; i++) ...[
                    if (i > 0)
                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: 2),
                        child: Divider(
                          height: 1,
                          color: AppPalette.divider(context),
                        ),
                      ),
                    _buildResultItem(previewItems[i]),
                  ],
                ],
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 40),
      decoration: BoxDecoration(
        color: AppPalette.surfaceSubtle(context),
        borderRadius: BorderRadius.circular(_kRadiusLg),
      ),
      child: Column(
        children: [
          Icon(
            Icons.search_off,
            color: AppPalette.textSecondary(context),
            size: 40,
          ),
          const SizedBox(height: 8),
          Text(
            'Tidak ada laporan ditemukan',
            style: GoogleFonts.plusJakartaSans(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: AppPalette.textPrimary(context),
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'Coba ubah kata kunci atau filter lalu tekan Terapkan',
            style: GoogleFonts.plusJakartaSans(
              fontSize: 12,
              fontWeight: FontWeight.w400,
              color: AppPalette.textSecondary(context),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildResultItem(SearchResultItem item) {
    final isCondition = item.category == ReportCategory.kondisiKampus;
    final statusColor = isCondition ? _kStatusCondition : _kStatusInfo;

    return InkWell(
      onTap: () async {
        final repo = ReportRepository.instance;
        final report = item.report ??
            repo.reports.firstWhere(
              (r) => r.id == item.id,
              orElse: () => repo.reports.first,
            );
        final updatedReport = await Navigator.push<ReportModel>(
          context,
          MaterialPageRoute(
            builder: (context) => ReportDetailScreen(report: report),
          ),
        );
        if (updatedReport != null && mounted) {
          repo.updateById(updatedReport.id, updatedReport);
        }
      },
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Row(
          children: [
            // Thumbnail
            _buildThumbnail(item, statusColor),
            const SizedBox(width: 12),
            // Text content
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    item.title,
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: AppPalette.textPrimary(context),
                      letterSpacing: 0.14,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      Icon(
                        Icons.location_on,
                        size: 11,
                        color: AppPalette.textSecondary(context),
                      ),
                      const SizedBox(width: 2),
                      Flexible(
                        child: Text(
                          item.location,
                          style: GoogleFonts.plusJakartaSans(
                            fontSize: 12,
                            fontWeight: FontWeight.w400,
                            color: AppPalette.textSecondary(context),
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Container(
                        width: 4,
                        height: 4,
                        decoration: BoxDecoration(
                          color: AppPalette.textSecondary(context),
                          shape: BoxShape.circle,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        item.timeAgo,
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 10,
                          fontWeight: FontWeight.w700,
                          color: AppPalette.textSecondary(context),
                          letterSpacing: 0.4,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(width: 12),
            // Upvote button (reusable modular component with anti-spam cooldown)
            UpvoteButton(
              initialCount: item.upvoteCount,
              initialIsUpvoted: item.isUpvoted,
              onChanged: (isUpvoted, count) {
                final repo = ReportRepository.instance;
                final report = item.report ??
                    repo.reports.firstWhere(
                      (r) => r.id == item.id,
                      orElse: () => repo.reports.first,
                    );
                final updated = report.copyWith(
                  isUpvoted: isUpvoted,
                  upvoteCount: count,
                );
                repo.updateById(updated.id, updated);
              },
              onCooldownTriggered: () {
                ScaffoldMessenger.of(context)
                  ..hideCurrentSnackBar()
                  ..showSnackBar(
                    const SnackBar(
                      content: Text('Tunggu sebentar sebelum memberi vote lagi.'),
                      duration: Duration(seconds: 1),
                      behavior: SnackBarBehavior.floating,
                    ),
                  );
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildThumbnail(SearchResultItem item, Color statusColor) {
    final hasMedia = item.imageUrl.isNotEmpty;
    final isNetwork =
        item.imageUrl.startsWith('http://') || item.imageUrl.startsWith('https://');
    final isVideo = isVideoMedia(item.imageUrl);
    final isCondition = item.category == ReportCategory.kondisiKampus;

    Widget mediaContent;
    if (!hasMedia) {
      mediaContent = _buildCategoryFallback(isCondition);
    } else if (isVideo) {
      mediaContent = Container(
        width: 48,
        height: 48,
        color: const Color(0xFF0F172A),
        child: const Center(
          child: Icon(
            Icons.play_circle_fill_rounded,
            color: Colors.white,
            size: 24,
          ),
        ),
      );
    } else if (isNetwork) {
      mediaContent = Image.network(
        item.imageUrl,
        width: 48,
        height: 48,
        fit: BoxFit.cover,
        errorBuilder: (_, _, _) => _buildCategoryFallback(isCondition),
      );
    } else {
      mediaContent = kIsWeb
          ? Image.network(
              item.imageUrl,
              width: 48,
              height: 48,
              fit: BoxFit.cover,
              errorBuilder: (_, _, _) => _buildCategoryFallback(isCondition),
            )
          : Image.file(
              File(item.imageUrl),
              width: 48,
              height: 48,
              fit: BoxFit.cover,
              errorBuilder: (_, _, _) => _buildCategoryFallback(isCondition),
            );
    }

    return Stack(
      children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(_kRadiusSm),
          child: SizedBox(
            width: 48,
            height: 48,
            child: mediaContent,
          ),
        ),
        Positioned(
          right: 0,
          bottom: 0,
          child: Container(
            width: 12,
            height: 12,
            decoration: BoxDecoration(
              color: statusColor,
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(6),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildCategoryFallback(bool isCondition) {
    return Container(
      width: 48,
      height: 48,
      color: isCondition ? _kConditionBg : _kBgBlue100,
      child: Center(
        child: Icon(
          isCondition ? Icons.apartment_rounded : Icons.campaign_rounded,
          color: isCondition ? _kConditionBorder : _kPrimary,
          size: 22,
        ),
      ),
    );
  }

  // ── Footer ─────────────────────────────────────────────────────────────

  Widget _buildFooter(double bottomPadding) {
    return Container(
      color: AppPalette.surface(context),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Accent line / divider
          Container(height: 1, color: AppPalette.divider(context)),
          Padding(
            padding: EdgeInsets.fromLTRB(
              AppSpacing.lg,
              12,
              AppSpacing.lg,
              12 + bottomPadding,
            ),
            child: SizedBox(
              width: double.infinity,
              height: 48,
              // 1. Input/Event → User tap tombol terapkan filter
              child: ElevatedButton(
                onPressed: _applyFilter,
                style: ElevatedButton.styleFrom(
                  backgroundColor: _kPrimary,
                  foregroundColor: _kBgWhite,
                  padding: EdgeInsets.zero,
                  alignment: Alignment.center,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(_kRadiusMd),
                  ),
                  elevation: 0,
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    const Icon(Icons.filter_list, size: 18, color: _kBgWhite),
                    const SizedBox(width: 8),
                    Text(
                      'Terapkan filter',
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 15,
                        fontWeight: FontWeight.w700,
                        color: _kBgWhite,
                        height: 1.0,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
