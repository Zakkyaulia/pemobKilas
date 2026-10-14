import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../theme/app_spacing.dart';

// ─── Design constants ─────────────────────────────────────────────────────────

/// Colors from the Figma CSS export.
const Color _kBgCanvas = Color(0xFFF8F9FF);
const Color _kBgWhite = Color(0xFFFFFFFF);
const Color _kBgBlue100 = Color(0xFFE5EEFF);
const Color _kTextDark = Color(0xFF0B1C30);
const Color _kTextMuted = Color(0xFF5C6070);
const Color _kTextBody = Color(0xFF434656);
const Color _kTextMeta = Color(0xFF737687);
const Color _kPrimary = Color(0xFF0048D4);
const Color _kPrimaryDeep = Color(0xFF0B3A9C);
const Color _kBorderPrimary = Color(0xFF0048D4);
const Color _kBorderLight = Color(0xFFE5EEFF);
const Color _kConditionBg = Color(0xFFFEF3DC);
const Color _kConditionText = Color(0xFF653E00);
const Color _kConditionBorder = Color(0xFF9C6200);
const Color _kStatusCondition = Color(0xFFF59E0B);
const Color _kStatusInfo = Color(0xFF0048D4);
const Color _kBorderOutline = Color(0xFFC3CADB);
const Color _kDivider = Color(0x99DCE9FF); // 60% opacity

/// Radius tokens.
const double _kRadiusFull = 9999;
const double _kRadiusLg = 16;
const double _kRadiusMd = 12;
const double _kRadiusSm = 8;

// ─── Data Models ──────────────────────────────────────────────────────────────

/// Enum for report categories.
enum ReportCategory {
  kondisiKampus,
  informasiPenting,
}

/// Enum for sorting.
enum SortMode {
  terbaru,
  upvoteTerbanyak,
}

/// Enum for time range.
enum TimeRange {
  hariIni,
  tujuhHari,
  bulanIni,
  semua,
}

/// Preview result item.
class SearchResultItem {
  const SearchResultItem({
    required this.title,
    required this.location,
    required this.timeAgo,
    required this.upvoteCount,
    required this.imageUrl,
    required this.category,
  });

  final String title;
  final String location;
  final String timeAgo;
  final int upvoteCount;
  final String imageUrl;
  final ReportCategory category;
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

// ─── Static Mock Data ─────────────────────────────────────────────────────────

const List<SearchResultItem> _kMockResults = [
  SearchResultItem(
    title: 'Lampu Koridor GKB Lantai 3',
    location: 'Gedung Kuliah Bersa...',
    timeAgo: '2 jam lalu',
    upvoteCount: 38,
    imageUrl:
        'https://lh3.googleusercontent.com/aida-public/AB6AXuCdbZW47ogPynpDzdG32WMlEctLMsUNyyXLC0m1MCtLoI-r1GqnCyuSjAKUVIWoMfC6KUrDhrCnaOgzgUPpxPdeUsoteiPJaDhupg2E3auy-DaEzK6o-7wfyCwZkYJMSlgbvfXxW7JWbLor94mGeETE7P_OE8WgKHtwu1ZmJhBRERmtIWF25NoYkk_5cz-M08X__4XRlxK56vUisHYjA55usx-gfRKkQNLbQNMBhyR7KSxeK_jnObDL',
    category: ReportCategory.kondisiKampus,
  ),
  SearchResultItem(
    title: 'Pohon Tumbang Sebagian A...',
    location: 'Tangga Sayap Barat C...',
    timeAgo: '5 jam lalu',
    upvoteCount: 19,
    imageUrl:
        'https://lh3.googleusercontent.com/aida-public/AB6AXuDhulrtRVYTzfPtie0w7FaqMEbrW1xBHiOaigYreoY2A4wWQ8VekDw7g_o7CPzzqkxx5Mr3dQHlF1dgkZKybtJ7NS98Mx58xUj9aAXIamvRatDKvrmn-RblqYuSbnurXCNFeBs2SfpoPKVqH9l3f22oiOfvFyspAVEPGpIX1JFwnS78EwkV93JyB3NNccIbNnwBrOx0mujBMedVk6aT15PwKnhLcmDHjbJmBCaUKmcmWl2Ud8m9uBsV',
    category: ReportCategory.kondisiKampus,
  ),
  SearchResultItem(
    title: 'Ditemukan Dompet Hitam a...',
    location: 'Selasar GKB Lt. 1',
    timeAgo: 'Kemarin',
    upvoteCount: 45,
    imageUrl:
        'https://lh3.googleusercontent.com/aida-public/AB6AXuCdnOTwLApErt0cbY9ePBdGUGMH2jG4BfLKq153ygCGBc_vOEcsmVt3Lk2OJLn7Z9dAG9Qxh-PXQHHmBJuhlCo2jDy785d-P2yFXTYjXC-_b4CcccD2nmdenYc_BcvvGJOJ7ZciQtkHhjC5FwE8GAxFF0oDKTaKiX_qba4rIkDBlkLRC4KJZ7ZZGsEl9GjSnKVlRbrmjW_obdBw6ZPm6ZbGUuoHt97lT3MnrcQCwO56tGe0cneSmRb8',
    category: ReportCategory.informasiPenting,
  ),
];

// All possible results for filtering simulation
const List<SearchResultItem> _kAllMockResults = [
  ..._kMockResults,
  SearchResultItem(
    title: 'AC Ruang Kuliah GKB C 204 bocor',
    location: 'Gedung GKB C',
    timeAgo: '15m lalu',
    upvoteCount: 42,
    imageUrl:
        'https://lh3.googleusercontent.com/aida-public/AB6AXuCQjRXiN2w4dCPIVQhWlufSduDBSOqq2UCDygQfUyfqSojlTedSVb-jV0eQv01FkURvr7Qgez_9haHqOHRzyrTMm3-zTxvYqLoT_9pOnwvzbpXntLaJrl15dn9w9LqHV6h_Q-VTAArbnGCIPrkLxKjPYJlR_v1VSLY4KUOIjrOZXQlOZdLstSB2MYxJK3RiWV-7pjLLrSMmfoav9T6019ykOx4WMX3P7hAfHAQKUCS_DHnrVSu8_buT',
    category: ReportCategory.kondisiKampus,
  ),
  SearchResultItem(
    title: 'Genangan Air di Bundaran PKM',
    location: 'Bundaran PKM UNAND',
    timeAgo: '1 jam lalu',
    upvoteCount: 31,
    imageUrl:
        'https://lh3.googleusercontent.com/aida-public/AB6AXuCQjRXiN2w4dCPIVQhWlufSduDBSOqq2UCDygQfUyfqSojlTedSVb-jV0eQv01FkURvr7Qgez_9haHqOHRzyrTMm3-zTxvYqLoT_9pOnwvzbpXntLaJrl15dn9w9LqHV6h_Q-VTAArbnGCIPrkLxKjPYJlR_v1VSLY4KUOIjrOZXQlOZdLstSB2MYxJK3RiWV-7pjLLrSMmfoav9T6019ykOx4WMX3P7hAfHAQKUCS_DHnrVSu8_buT',
    category: ReportCategory.kondisiKampus,
  ),
  SearchResultItem(
    title: 'Keran Toilet Lantai 2 Rusak',
    location: 'Gedung GKB A Lt. 2',
    timeAgo: '3 jam lalu',
    upvoteCount: 15,
    imageUrl:
        'https://lh3.googleusercontent.com/aida-public/AB6AXuDhulrtRVYTzfPtie0w7FaqMEbrW1xBHiOaigYreoY2A4wWQ8VekDw7g_o7CPzzqkxx5Mr3dQHlF1dgkZKybtJ7NS98Mx58xUj9aAXIamvRatDKvrmn-RblqYuSbnurXCNFeBs2SfpoPKVqH9l3f22oiOfvFyspAVEPGpIX1JFwnS78EwkV93JyB3NNccIbNnwBrOx0mujBMedVk6aT15PwKnhLcmDHjbJmBCaUKmcmWl2Ud8m9uBsV',
    category: ReportCategory.kondisiKampus,
  ),
  SearchResultItem(
    title: 'Pipa Air Bocor Jalur Utama',
    location: 'Jalan Utama Kampus',
    timeAgo: '6 jam lalu',
    upvoteCount: 28,
    imageUrl:
        'https://lh3.googleusercontent.com/aida-public/AB6AXuCdnOTwLApErt0cbY9ePBdGUGMH2jG4BfLKq153ygCGBc_vOEcsmVt3Lk2OJLn7Z9dAG9Qxh-PXQHHmBJuhlCo2jDy785d-P2yFXTYjXC-_b4CcccD2nmdenYc_BcvvGJOJ7ZciQtkHhjC5FwE8GAxFF0oDKTaKiX_qba4rIkDBlkLRC4KJZ7ZZGsEl9GjSnKVlRbrmjW_obdBw6ZPm6ZbGUuoHt97lT3MnrcQCwO56tGe0cneSmRb8',
    category: ReportCategory.kondisiKampus,
  ),
  SearchResultItem(
    title: 'Jalan Berlubang Depan FE',
    location: 'Depan Fakultas Ekonomi',
    timeAgo: '8 jam lalu',
    upvoteCount: 55,
    imageUrl:
        'https://lh3.googleusercontent.com/aida-public/AB6AXuCdbZW47ogPynpDzdG32WMlEctLMsUNyyXLC0m1MCtLoI-r1GqnCyuSjAKUVIWoMfC6KUrDhrCnaOgzgUPpxPdeUsoteiPJaDhupg2E3auy-DaEzK6o-7wfyCwZkYJMSlgbvfXxW7JWbLor94mGeETE7P_OE8WgKHtwu1ZmJhBRERmtIWF25NoYkk_5cz-M08X__4XRlxK56vUisHYjA55usx-gfRKkQNLbQNMBhyR7KSxeK_jnObDL',
    category: ReportCategory.kondisiKampus,
  ),
  SearchResultItem(
    title: 'Jadwal Wisuda Semester Ganjil',
    location: 'Auditorium UNAND',
    timeAgo: '1 hari lalu',
    upvoteCount: 120,
    imageUrl:
        'https://lh3.googleusercontent.com/aida-public/AB6AXuCdnOTwLApErt0cbY9ePBdGUGMH2jG4BfLKq153ygCGBc_vOEcsmVt3Lk2OJLn7Z9dAG9Qxh-PXQHHmBJuhlCo2jDy785d-P2yFXTYjXC-_b4CcccD2nmdenYc_BcvvGJOJ7ZciQtkHhjC5FwE8GAxFF0oDKTaKiX_qba4rIkDBlkLRC4KJZ7ZZGsEl9GjSnKVlRbrmjW_obdBw6ZPm6ZbGUuoHt97lT3MnrcQCwO56tGe0cneSmRb8',
    category: ReportCategory.informasiPenting,
  ),
  SearchResultItem(
    title: 'Pengumuman UAS Susulan',
    location: 'Rektorat UNAND',
    timeAgo: '2 hari lalu',
    upvoteCount: 88,
    imageUrl:
        'https://lh3.googleusercontent.com/aida-public/AB6AXuDhulrtRVYTzfPtie0w7FaqMEbrW1xBHiOaigYreoY2A4wWQ8VekDw7g_o7CPzzqkxx5Mr3dQHlF1dgkZKybtJ7NS98Mx58xUj9aAXIamvRatDKvrmn-RblqYuSbnurXCNFeBs2SfpoPKVqH9l3f22oiOfvFyspAVEPGpIX1JFwnS78EwkV93JyB3NNccIbNnwBrOx0mujBMedVk6aT15PwKnhLcmDHjbJmBCaUKmcmWl2Ud8m9uBsV',
    category: ReportCategory.informasiPenting,
  ),
  SearchResultItem(
    title: 'Lampu Taman Padam Blok B',
    location: 'Taman Blok B',
    timeAgo: '4 jam lalu',
    upvoteCount: 12,
    imageUrl:
        'https://lh3.googleusercontent.com/aida-public/AB6AXuCdbZW47ogPynpDzdG32WMlEctLMsUNyyXLC0m1MCtLoI-r1GqnCyuSjAKUVIWoMfC6KUrDhrCnaOgzgUPpxPdeUsoteiPJaDhupg2E3auy-DaEzK6o-7wfyCwZkYJMSlgbvfXxW7JWbLor94mGeETE7P_OE8WgKHtwu1ZmJhBRERmtIWF25NoYkk_5cz-M08X__4XRlxK56vUisHYjA55usx-gfRKkQNLbQNMBhyR7KSxeK_jnObDL',
    category: ReportCategory.kondisiKampus,
  ),
  SearchResultItem(
    title: 'Kursi Patah Aula Rapat Dekan',
    location: 'Aula FT Lt. 3',
    timeAgo: '7 jam lalu',
    upvoteCount: 9,
    imageUrl:
        'https://lh3.googleusercontent.com/aida-public/AB6AXuDhulrtRVYTzfPtie0w7FaqMEbrW1xBHiOaigYreoY2A4wWQ8VekDw7g_o7CPzzqkxx5Mr3dQHlF1dgkZKybtJ7NS98Mx58xUj9aAXIamvRatDKvrmn-RblqYuSbnurXCNFeBs2SfpoPKVqH9l3f22oiOfvFyspAVEPGpIX1JFwnS78EwkV93JyB3NNccIbNnwBrOx0mujBMedVk6aT15PwKnhLcmDHjbJmBCaUKmcmWl2Ud8m9uBsV',
    category: ReportCategory.kondisiKampus,
  ),
  SearchResultItem(
    title: 'Projector Rusak di Lab Komputer',
    location: 'Lab Komputer FT',
    timeAgo: 'Kemarin',
    upvoteCount: 22,
    imageUrl:
        'https://lh3.googleusercontent.com/aida-public/AB6AXuCdnOTwLApErt0cbY9ePBdGUGMH2jG4BfLKq153ygCGBc_vOEcsmVt3Lk2OJLn7Z9dAG9Qxh-PXQHHmBJuhlCo2jDy785d-P2yFXTYjXC-_b4CcccD2nmdenYc_BcvvGJOJ7ZciQtkHhjC5FwE8GAxFF0oDKTaKiX_qba4rIkDBlkLRC4KJZ7ZZGsEl9GjSnKVlRbrmjW_obdBw6ZPm6ZbGUuoHt97lT3MnrcQCwO56tGe0cneSmRb8',
    category: ReportCategory.kondisiKampus,
  ),
];

// ─── Screen ───────────────────────────────────────────────────────────────────

/// Halaman Cari & Filter untuk mencari dan memfilter laporan kampus.
///
/// **Workflow UTS (5 tahap - Manual Apply Pattern):**
/// 1. Input/Event  → User mengubah draft (ketik/kategori/sort/waktu), lalu menekan tombol "Terapkan filter"
/// 2. State        → Pemisahan Draft State (pilihan UI saat ini) vs Applied State (filter aktif yang menghasilkan data)
/// 3. Validation   → Minimal 1 kategori harus dipilih pada draft sebelum diterapkan
/// 4. Feedback     → Floating SnackBar error jika validasi gagal, SnackBar sukses + auto-scroll ke Pratinjau Hasil jika berhasil
/// 5. Navigation   → Mengembalikan [SearchFilterResult] dari applied state ke screen pemanggil via tombol back (←)
class SearchFilterScreen extends StatefulWidget {
  const SearchFilterScreen({super.key});

  @override
  State<SearchFilterScreen> createState() => _SearchFilterScreenState();
}

class _SearchFilterScreenState extends State<SearchFilterScreen> {
  // ── 2. State ────────────────────────────────────────────────────────────

  // ── Draft State (Menyimpan pilihan user yang sedang diubah di UI) ────────
  final TextEditingController _searchController = TextEditingController();

  /// Kategori yang dipilih user pada draft (bisa lebih dari satu).
  final Set<ReportCategory> _draftCategories = {
    ReportCategory.kondisiKampus,
  };

  /// Mode sorting pada draft.
  SortMode _draftSortMode = SortMode.terbaru;

  /// Rentang waktu pada draft.
  TimeRange _draftTimeRange = TimeRange.tujuhHari;

  // ── Applied State (Filter aktif yang menghasilkan data pratinjau) ───────
  String _appliedQuery = '';
  Set<ReportCategory> _appliedCategories = {
    ReportCategory.kondisiKampus,
  };
  SortMode _appliedSortMode = SortMode.terbaru;
  TimeRange _appliedTimeRange = TimeRange.tujuhHari;

  /// Hasil laporan yang benar-benar aktif/diterapkan.
  List<SearchResultItem> _appliedResults = [];

  /// Result filter yang disimpan untuk dikembalikan saat tombol Back ditekan.
  SearchFilterResult? _appliedResult;

  final ScrollController _scrollController = ScrollController();
  final GlobalKey _previewKey = GlobalKey();

  @override
  void initState() {
    super.initState();
    // Inisialisasi applied state awal saat screen pertama kali dibuka
    _executeAppliedFilter();
  }

  @override
  void dispose() {
    _searchController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  /// Menjalankan filter terhadap mock data hanya berdasarkan applied state.
  void _executeAppliedFilter() {
    final query = _appliedQuery.toLowerCase();
    List<SearchResultItem> results = List.from(_kAllMockResults);

    // Filter by category
    if (_appliedCategories.isNotEmpty) {
      results = results
          .where((item) => _appliedCategories.contains(item.category))
          .toList();
    }

    // Filter by search query
    if (query.isNotEmpty) {
      results = results
          .where((item) =>
              item.title.toLowerCase().contains(query) ||
              item.location.toLowerCase().contains(query))
          .toList();
    }

    // Sort
    if (_appliedSortMode == SortMode.upvoteTerbanyak) {
      results.sort((a, b) => b.upvoteCount.compareTo(a.upvoteCount));
    }
    // terbaru is default order

    _appliedResults = results;
    _appliedResult = SearchFilterResult(
      query: _appliedQuery,
      categories: Set.from(_appliedCategories),
      sortMode: _appliedSortMode,
      timeRange: _appliedTimeRange,
      resultCount: results.length,
    );
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
              const Icon(Icons.warning_amber_rounded,
                  color: Colors.orangeAccent, size: 20),
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
              const Icon(Icons.check_circle, color: Color(0xFF10B981), size: 20),
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

  /// Menutup halaman dan mengembalikan applied filter terakhir ke screen sebelumnya.
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
        backgroundColor: _kBgCanvas,
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
      color: _kBgWhite,
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
                    child: const Icon(Icons.arrow_back,
                        color: _kTextDark, size: 24),
                  ),
                  const SizedBox(width: 12),
                  // Title
                  Text(
                    'Cari & Filter',
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                      color: _kTextDark,
                    ),
                  ),
                  const Spacer(),
                  // Reset button
                  GestureDetector(
                    onTap: _resetFilters,
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.refresh_rounded,
                            color: _kPrimary, size: 14),
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
          // Thin blue separator line
          Container(height: 2, color: _kBgBlue100),
        ],
      ),
    );
  }

  Widget _buildSearchBar() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
      child: Container(
        height: 48,
        decoration: BoxDecoration(
          color: _kBgWhite,
          borderRadius: BorderRadius.circular(_kRadiusFull),
          border: Border.all(color: _kBorderPrimary, width: 1.5),
        ),
        child: Row(
          children: [
            const SizedBox(width: 16),
            // Search icon
            const Icon(Icons.search, color: _kTextMuted, size: 20),
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
                  color: _kTextDark,
                ),
                decoration: InputDecoration(
                  hintText: 'Cari laporan kampus...',
                  hintStyle: GoogleFonts.plusJakartaSans(
                    fontSize: 14,
                    fontWeight: FontWeight.w400,
                    color: _kTextMuted,
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
                      decoration: const BoxDecoration(
                        color: _kBgBlue100,
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
    final kondisiSelected =
        _draftCategories.contains(ReportCategory.kondisiKampus);
    final infoSelected =
        _draftCategories.contains(ReportCategory.informasiPenting);

    // Count items per category
    final kondisiCount = _kAllMockResults
        .where((item) => item.category == ReportCategory.kondisiKampus)
        .length;
    final infoCount = _kAllMockResults
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
                  color: _kTextDark,
                ),
              ),
              Text(
                'Pilih satu atau keduanya',
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 12,
                  fontWeight: FontWeight.w400,
                  color: _kTextMuted,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),

          // Kondisi Kampus card
          _buildCategoryCard(
            isSelected: kondisiSelected,
            iconBgColor: _kConditionBg,
            iconWidget: Icon(Icons.location_on_outlined,
                color: _kConditionBorder, size: 20),
            title: 'Kondisi Kampus',
            badgeCount: kondisiCount,
            badgeLabel: 'aktif',
            badgeBgColor: _kConditionBg,
            badgeTextColor: _kConditionText,
            description:
                'Fasilitas rusak, jalan berlubang, pohon\ntumbang, lampu padam.',
            onTap: () => _toggleCategory(ReportCategory.kondisiKampus),
          ),
          const SizedBox(height: 12),

          // Informasi Penting card
          _buildCategoryCard(
            isSelected: infoSelected,
            iconBgColor: _kBgBlue100,
            iconWidget:
                Icon(Icons.campaign_outlined, color: _kPrimary, size: 20),
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
          color: _kBgWhite,
          borderRadius: BorderRadius.circular(_kRadiusMd),
          border: Border.all(
            color: isSelected ? _kBorderPrimary : _kBorderLight,
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
                          color: _kTextDark,
                        ),
                      ),
                      const SizedBox(width: 8),
                      // Badge count
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 8, vertical: 2),
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
                      color: _kTextBody,
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
                      child: Icon(Icons.check, color: _kBgWhite, size: 16))
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
              color: _kTextDark,
            ),
          ),
          const SizedBox(height: 12),
          Container(
            height: 48,
            decoration: BoxDecoration(
              color: _kBgBlue100,
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
          color: isSelected ? _kBgWhite : Colors.transparent,
          borderRadius: BorderRadius.circular(_kRadiusFull),
        ),
        child: Center(
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon,
                  size: 16,
                  color: isSelected ? _kPrimary : _kTextBody),
              const SizedBox(width: 6),
              Text(
                label,
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                  color: isSelected ? _kPrimary : _kTextBody,
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
              color: _kTextDark,
            ),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              _buildTimeChip(
                label: 'Hari ini',
                range: TimeRange.hariIni,
              ),
              const SizedBox(width: 8),
              _buildTimeChip(
                label: '7 hari',
                range: TimeRange.tujuhHari,
              ),
              const SizedBox(width: 8),
              _buildTimeChip(
                label: 'Bulan ini',
                range: TimeRange.bulanIni,
              ),
              const SizedBox(width: 8),
              _buildTimeChip(
                label: 'Semua',
                range: TimeRange.semua,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildTimeChip({
    required String label,
    required TimeRange range,
  }) {
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
            color: isSelected ? _kPrimary : _kBgWhite,
            borderRadius: BorderRadius.circular(_kRadiusFull),
            border: isSelected
                ? null
                : Border.all(color: _kBorderLight, width: 1.5),
          ),
          child: Center(
            child: Text(
              label,
              style: GoogleFonts.plusJakartaSans(
                fontSize: 12,
                fontWeight: FontWeight.w700,
                color: isSelected ? _kBgWhite : _kTextBody,
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
    final previewItems = _appliedResults.take(3).toList();

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
                  color: _kTextDark,
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
                color: _kBgWhite,
                borderRadius: BorderRadius.circular(_kRadiusLg),
                boxShadow: const [
                  BoxShadow(
                    color: Color(0x0D000000),
                    blurRadius: 2,
                    offset: Offset(0, 1),
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
                          color: _kDivider,
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
        color: _kBgBlue100,
        borderRadius: BorderRadius.circular(_kRadiusLg),
      ),
      child: Column(
        children: [
          Icon(Icons.search_off, color: _kTextMuted, size: 40),
          const SizedBox(height: 8),
          Text(
            'Tidak ada laporan ditemukan',
            style: GoogleFonts.plusJakartaSans(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: _kTextBody,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'Coba ubah kata kunci atau filter lalu tekan Terapkan',
            style: GoogleFonts.plusJakartaSans(
              fontSize: 12,
              fontWeight: FontWeight.w400,
              color: _kTextMuted,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildResultItem(SearchResultItem item) {
    final isCondition = item.category == ReportCategory.kondisiKampus;
    final statusColor = isCondition ? _kStatusCondition : _kStatusInfo;

    return Padding(
      padding: const EdgeInsets.all(12),
      child: Row(
        children: [
          // Thumbnail
          Stack(
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(_kRadiusSm),
                child: Container(
                  width: 48,
                  height: 48,
                  color: _kBgBlue100,
                  child: Image.network(
                    item.imageUrl,
                    width: 48,
                    height: 48,
                    fit: BoxFit.cover,
                    errorBuilder: (_, _, _) => Container(
                      width: 48,
                      height: 48,
                      color: _kBgBlue100,
                      child: const Icon(Icons.image, color: _kTextMeta),
                    ),
                  ),
                ),
              ),
              // Status dot
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
          ),
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
                    color: _kTextDark,
                    letterSpacing: 0.14,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    const Icon(Icons.location_on,
                        size: 11, color: _kTextMeta),
                    const SizedBox(width: 2),
                    Flexible(
                      child: Text(
                        item.location,
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 12,
                          fontWeight: FontWeight.w400,
                          color: _kTextMeta,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Container(
                      width: 4,
                      height: 4,
                      decoration: const BoxDecoration(
                        color: _kTextMeta,
                        shape: BoxShape.circle,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      item.timeAgo,
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 10,
                        fontWeight: FontWeight.w700,
                        color: _kTextBody,
                        letterSpacing: 0.4,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(width: 12),
          // Upvote badge
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              color: isCondition
                  ? const Color(0x1A0048D4) // 10% primary
                  : _kBgBlue100,
              borderRadius: BorderRadius.circular(_kRadiusFull),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.arrow_upward,
                    size: 10,
                    color: isCondition ? _kPrimary : _kTextBody),
                const SizedBox(width: 4),
                Text(
                  '${item.upvoteCount}',
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 10,
                    fontWeight: FontWeight.w700,
                    color: isCondition ? _kPrimary : _kTextBody,
                    letterSpacing: 0.4,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ── Footer ─────────────────────────────────────────────────────────────

  Widget _buildFooter(double bottomPadding) {
    return Container(
      color: _kBgWhite,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Blue accent line
          Container(height: 2, color: _kBgBlue100),
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
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(_kRadiusMd),
                  ),
                  elevation: 0,
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.filter_list, size: 18, color: _kBgWhite),
                    const SizedBox(width: 8),
                    Text(
                      'Terapkan filter',
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 15,
                        fontWeight: FontWeight.w700,
                        color: _kBgWhite,
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
