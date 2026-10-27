import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';

import '../../theme/app_colors.dart';
import '../../theme/app_palette.dart';
import '../../theme/app_spacing.dart';
import '../../theme/home_colors.dart';
import '../../widgets/home/video_player_box.dart';
import '../home/data/report_repository.dart';
import '../home/models/report_model.dart';
import '../profile/data/user_profile_repository.dart';
import '../profile/models/user_profile_model.dart';

// ─── Design tokens mapped to centralized HomeColors ──────────────────────────
const Color _kPrimary = HomeColors.primary;
const Color _kConditionBg = HomeColors.conditionBg;
const Color _kConditionBorder = HomeColors.conditionBorder;
const Color _kBgBlue100 = HomeColors.bgBlue100;
const Color _kPrimaryDeep = HomeColors.primaryDeep;

const double _kRadiusLg = 16.0;
const double _kRadiusMd = 12.0;
const double _kRadiusSm = 8.0;

/// Batas maksimal ukuran file (10 MB).
const int _kMaxFileSizeBytes = 10 * 1024 * 1024;

/// Batas maksimal durasi rekaman video (15 detik).
const Duration _kMaxVideoDuration = Duration(seconds: 15);

/// Halaman edit laporan (FR-A2) yang 100% konsisten dengan [CreateReportScreen].
///
/// Pengguna dapat mengubah:
/// 1. Media bukti (Ganti foto/video baru dari Kamera / Galeri, atau hapus media)
/// 2. Kategori laporan ("Kondisi Kampus" vs "Informasi Penting")
/// 3. Caption / Judul laporan
/// 4. Keterangan / Deskripsi lengkap (konsisten tanpa validasi kaku 10 karakter)
///
/// Aturan bisnis:
/// - Hanya dapat diedit dalam waktu 24 jam sejak diterbitkan.
/// - Hasil edit akan ditandai dengan label "diedit".
class EditReportScreen extends StatefulWidget {
  const EditReportScreen({
    super.key,
    required this.report,
  });

  final ReportModel report;

  @override
  State<EditReportScreen> createState() => _EditReportScreenState();
}

class _EditReportScreenState extends State<EditReportScreen> {
  late final TextEditingController _titleController;
  late final TextEditingController _descriptionController;

  late String _selectedCategory;
  String? _mediaPath;
  bool _isVideo = false;
  int _selectedFileSize = 0;
  bool _isNewLocalMedia = false;
  bool _isSubmitting = false;

  final ImagePicker _picker = ImagePicker();

  static const int _maxDescriptionLength = 1500;

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController(text: widget.report.title ?? '');
    _descriptionController =
        TextEditingController(text: widget.report.description ?? '');

    // Standarisasi label kategori agar cocok dengan 'Kondisi Kampus' dan 'Informasi Penting'
    if (ReportCategories.isImportantInfo(widget.report.badgeLabel)) {
      _selectedCategory = 'Informasi Penting';
    } else {
      _selectedCategory = ReportCategories.kondisiKampus;
    }

    _mediaPath = widget.report.imageUrl;
    _isVideo = isVideoMedia(_mediaPath);

    _descriptionController.addListener(() => setState(() {}));
    _titleController.addListener(() => setState(() {}));
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  bool get _canEdit => widget.report.canEdit;

  Future<void> _handleCameraAction() async {
    if (!_canEdit) return;
    try {
      final XFile? photo = await _picker.pickImage(
        source: ImageSource.camera,
        maxWidth: 1920,
        maxHeight: 1080,
        imageQuality: 85,
      );
      if (photo == null) return;

      final bytes = await photo.length();
      if (bytes > _kMaxFileSizeBytes) {
        _showErrorSnackBar('Ukuran foto melebihi batas 10MB.');
        return;
      }

      setState(() {
        _mediaPath = photo.path;
        _isVideo = false;
        _selectedFileSize = bytes;
        _isNewLocalMedia = true;
      });
    } catch (e) {
      _showErrorSnackBar('Gagal membuka kamera: $e');
    }
  }

  Future<void> _handleGalleryAction() async {
    if (!_canEdit) return;
    showModalBottomSheet(
      context: context,
      backgroundColor: AppPalette.surface(context),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(_kRadiusLg)),
      ),
      builder: (ctx) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 36,
                height: 4,
                decoration: BoxDecoration(
                  color: AppPalette.divider(context),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(height: 16),
              Text(
                'Pilih Jenis Media',
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  color: AppPalette.textPrimary(context),
                ),
              ),
              const SizedBox(height: 12),
              ListTile(
                leading: Container(
                  width: 38,
                  height: 38,
                  decoration: BoxDecoration(
                    color: _kBgBlue100,
                    borderRadius: BorderRadius.circular(_kRadiusSm),
                  ),
                  child: const Icon(Icons.photo_library_outlined, color: _kPrimary, size: 20),
                ),
                title: Text(
                  'Foto dari Galeri',
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: AppPalette.textPrimary(context),
                  ),
                ),
                subtitle: Text(
                  'Format JPG, PNG (Maks. 10MB)',
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 12,
                    color: AppPalette.textSecondary(context),
                  ),
                ),
                onTap: () {
                  Navigator.pop(ctx);
                  _pickPhotoFromGallery();
                },
              ),
              ListTile(
                leading: Container(
                  width: 38,
                  height: 38,
                  decoration: BoxDecoration(
                    color: const Color(0xFFFEF3C7),
                    borderRadius: BorderRadius.circular(_kRadiusSm),
                  ),
                  child: const Icon(Icons.videocam_outlined, color: Color(0xFFD97706), size: 22),
                ),
                title: Text(
                  'Video dari Galeri',
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: AppPalette.textPrimary(context),
                  ),
                ),
                subtitle: Text(
                  'Maksimal durasi 15 detik',
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 12,
                    color: AppPalette.textSecondary(context),
                  ),
                ),
                onTap: () {
                  Navigator.pop(ctx);
                  _pickVideoFromGallery();
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _pickPhotoFromGallery() async {
    try {
      final XFile? photo = await _picker.pickImage(
        source: ImageSource.gallery,
        maxWidth: 1920,
        maxHeight: 1080,
        imageQuality: 85,
      );
      if (photo == null) return;

      final bytes = await photo.length();
      if (bytes > _kMaxFileSizeBytes) {
        _showErrorSnackBar('Ukuran foto melebihi batas 10MB.');
        return;
      }

      setState(() {
        _mediaPath = photo.path;
        _isVideo = false;
        _selectedFileSize = bytes;
        _isNewLocalMedia = true;
      });
    } catch (e) {
      _showErrorSnackBar('Gagal memilih foto: $e');
    }
  }

  Future<void> _pickVideoFromGallery() async {
    try {
      final XFile? video = await _picker.pickVideo(
        source: ImageSource.gallery,
        maxDuration: _kMaxVideoDuration,
      );
      if (video == null) return;

      final bytes = await video.length();
      if (bytes > 25 * 1024 * 1024) {
        _showErrorSnackBar('Ukuran video melebihi batas 25MB.');
        return;
      }

      setState(() {
        _mediaPath = video.path;
        _isVideo = true;
        _selectedFileSize = bytes;
        _isNewLocalMedia = true;
      });
    } catch (e) {
      _showErrorSnackBar('Gagal memilih video: $e');
    }
  }

  Future<void> _confirmRemoveMedia() async {
    if (!_canEdit) return;
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppPalette.surface(context),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(_kRadiusLg),
        ),
        title: Text(
          'Hapus Lampiran Media?',
          style: GoogleFonts.plusJakartaSans(
            fontSize: 16,
            fontWeight: FontWeight.w700,
            color: AppPalette.textPrimary(context),
            height: 1.2,
          ),
        ),
        content: Text(
          'Apakah Anda yakin ingin menghapus foto/video ini dari laporan? Anda dapat memilih media lain atau menyimpannya sebagai laporan teks.',
          style: GoogleFonts.plusJakartaSans(
            fontSize: 13,
            color: AppPalette.textSecondary(context),
            height: 1.4,
          ),
        ),
        actions: [
          Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  style: OutlinedButton.styleFrom(
                    side: BorderSide(color: AppPalette.divider(context)),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(_kRadiusMd),
                    ),
                    padding: const EdgeInsets.symmetric(vertical: 12),
                  ),
                  onPressed: () => Navigator.pop(ctx, false),
                  child: Text(
                    'Batal',
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: AppPalette.textSecondary(context),
                      height: 1.1,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFEF4444),
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(_kRadiusMd),
                    ),
                    padding: const EdgeInsets.symmetric(vertical: 12),
                  ),
                  onPressed: () => Navigator.pop(ctx, true),
                  child: Text(
                    'Hapus',
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                      color: Colors.white,
                      height: 1.1,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );

    if (confirmed == true) {
      setState(() {
        _mediaPath = null;
        _isVideo = false;
        _selectedFileSize = 0;
        _isNewLocalMedia = false;
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Lampiran media berhasil dihapus.',
              style: GoogleFonts.plusJakartaSans(
                color: Colors.white,
                fontSize: 13,
                fontWeight: FontWeight.w500,
              ),
            ),
            backgroundColor: const Color(0xFF1E293B),
            duration: const Duration(seconds: 2),
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    }
  }

  void _showErrorSnackBar(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          content: Text(
            message,
            style: GoogleFonts.plusJakartaSans(
              color: Colors.white,
              fontSize: 13,
              fontWeight: FontWeight.w500,
            ),
          ),
          backgroundColor: AppColors.error,
          behavior: SnackBarBehavior.floating,
        ),
      );
  }

  Future<void> _confirmAndSaveReport() async {
    if (!_canEdit) {
      _showErrorSnackBar(
          'Laporan ini telah melewati batas 24 jam dan tidak dapat diubah lagi.');
      return;
    }

    final title = _titleController.text.trim();
    final description = _descriptionController.text.trim();

    // Validasi konsisten persis seperti di CreateReportScreen:
    // Cukup pastikan judul dan keterangan tidak kosong (tanpa batasan minimal 10 karakter yang kaku).
    if (title.isEmpty) {
      _showErrorSnackBar('Mohon masukkan judul laporan.');
      return;
    }

    if (description.isEmpty) {
      _showErrorSnackBar('Mohon masukkan keterangan laporan.');
      return;
    }

    if (description.length > _maxDescriptionLength) {
      _showErrorSnackBar(
          'Keterangan laporan tidak boleh melebihi $_maxDescriptionLength karakter.');
      return;
    }

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppPalette.surface(context),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(_kRadiusLg),
        ),
        title: Text(
          'Simpan Perubahan Laporan?',
          style: GoogleFonts.plusJakartaSans(
            fontSize: 16,
            fontWeight: FontWeight.w700,
            color: AppPalette.textPrimary(context),
            height: 1.2,
          ),
        ),
        content: Text(
          'Perubahan pada judul, keterangan, kategori, dan media akan disimpan. Laporan akan otomatis diberi penanda "(diedit)".',
          style: GoogleFonts.plusJakartaSans(
            fontSize: 13,
            color: AppPalette.textSecondary(context),
            height: 1.4,
          ),
        ),
        actions: [
          Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  style: OutlinedButton.styleFrom(
                    side: BorderSide(color: AppPalette.divider(context)),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(_kRadiusMd),
                    ),
                    padding: const EdgeInsets.symmetric(vertical: 12),
                  ),
                  onPressed: () => Navigator.pop(ctx, false),
                  child: Text(
                    'Periksa Lagi',
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: AppPalette.textSecondary(context),
                      height: 1.1,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: _kPrimary,
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(_kRadiusMd),
                    ),
                    padding: const EdgeInsets.symmetric(vertical: 12),
                  ),
                  onPressed: () => Navigator.pop(ctx, true),
                  child: Text(
                    'Ya, Simpan',
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                      color: Colors.white,
                      height: 1.1,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );

    if (confirmed == true) {
      _executeSaveReport(title, description);
    }
  }

  void _executeSaveReport(String title, String description) {
    setState(() => _isSubmitting = true);

    final isCondition = _selectedCategory == 'Kondisi Kampus';
    final now = DateTime.now();

    final updated = widget.report.copyWith(
      title: title,
      description: description,
      badgeLabel: isCondition ? 'Kondisi Kampus' : 'Info Penting',
      badgeVariant: isCondition ? BadgeVariant.dot : BadgeVariant.icon,
      badgeDotColor: isCondition ? HomeColors.statusCondition : null,
      badgeIcon: isCondition ? null : Icons.campaign,
      badgeBgColor: isCondition ? HomeColors.tertiaryFixed : HomeColors.surfaceContainerHigh,
      badgeTextColor: isCondition ? HomeColors.onTertiaryFixedVariant : HomeColors.primary,
      imageUrl: _mediaPath,
      editedAt: now,
    );

    // 1. Simpan perubahan ke ReportRepository
    ReportRepository.instance.updateById(widget.report.id, updated);

    // 2. Catat riwayat aktivitas pengguna
    UserProfileRepository.instance.addActivity(
      actionType: ActivityActionType.ubahLaporan,
      title: 'Mengubah Laporan',
      description: updated.title ?? 'Laporan diedit',
      reportId: widget.report.id,
    );

    if (!mounted) return;
    setState(() => _isSubmitting = false);

    // Feedback sukses ramah
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          content: Row(
            children: [
              const Icon(Icons.check_circle_rounded, color: Colors.white, size: 20),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  'Laporan berhasil diperbarui dengan penanda "diedit".',
                  style: GoogleFonts.plusJakartaSans(
                    color: Colors.white,
                    fontWeight: FontWeight.w600,
                    fontSize: 13,
                  ),
                ),
              ),
            ],
          ),
          backgroundColor: const Color(0xFF10B981),
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(_kRadiusMd)),
          margin: const EdgeInsets.all(AppSpacing.lg),
          duration: const Duration(seconds: 3),
        ),
      );

    Navigator.pop(context, updated);
  }

  @override
  Widget build(BuildContext context) {
    final isDark = AppPalette.isDark(context);

    return Scaffold(
      backgroundColor: AppPalette.canvas(context),
      appBar: _buildAppBar(context, isDark),
      body: SafeArea(
        top: false,
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.lg,
            vertical: AppSpacing.md,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ── 1. Banner Batas Waktu 24 Jam (FR-A2) ─────────────────────
              _buildTimerBanner(context, isDark),
              const SizedBox(height: AppSpacing.lg),

              // ── 2. Section Media (Gaya CreateReportScreen) ───────────────
              _buildMediaSection(context, isDark),
              const SizedBox(height: AppSpacing.lg),

              // ── 3. Kartu Lokasi Tersemat (Read-only) ─────────────────────
              _buildLocationCard(context, isDark),
              const SizedBox(height: AppSpacing.xl),

              // ── 4. Pilihan Kategori Isu (Gaya CreateReportScreen) ─────────
              _buildCategorySelector(context, isDark),
              const SizedBox(height: AppSpacing.xl),

              // ── 5. Input Judul Laporan ──────────────────────────────────
              _buildTitleInput(context, isDark),
              const SizedBox(height: AppSpacing.lg),

              // ── 6. Input Keterangan Laporan ──────────────────────────────
              _buildDescriptionInput(context, isDark),
              const SizedBox(height: AppSpacing.xxl),

              // ── 7. Tombol Aksi Bawah (Tidak akan tenggelam) ───────────────
              _buildActionButtons(context, isDark),
              const SizedBox(height: AppSpacing.xxl),
            ],
          ),
        ),
      ),
    );
  }

  PreferredSizeWidget _buildAppBar(BuildContext context, bool isDark) {
    return AppBar(
      backgroundColor: AppPalette.surface(context),
      elevation: 0,
      scrolledUnderElevation: 0,
      leading: IconButton(
        icon: Icon(
          Icons.arrow_back_ios_new,
          size: 19,
          color: AppPalette.textPrimary(context),
        ),
        onPressed: () => Navigator.pop(context),
      ),
      title: Text(
        'Edit Laporan',
        style: GoogleFonts.plusJakartaSans(
          fontSize: 18,
          fontWeight: FontWeight.w700,
          color: AppPalette.textPrimary(context),
          height: 1.2,
        ),
      ),
      centerTitle: true,
      bottom: PreferredSize(
        preferredSize: const Size.fromHeight(1),
        child: Container(
          color: AppPalette.divider(context),
          height: 1,
        ),
      ),
    );
  }

  Widget _buildTimerBanner(BuildContext context, bool isDark) {
    final canEdit = _canEdit;
    final remainingText = widget.report.remainingEditText;

    if (!canEdit) {
      return Container(
        width: double.infinity,
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: isDark ? const Color(0xFF3B1D1D) : const Color(0xFFFEE2E2),
          borderRadius: BorderRadius.circular(_kRadiusMd),
          border: Border.all(
            color: isDark ? const Color(0xFFDC2626) : const Color(0xFFFCA5A5),
            width: 1,
          ),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Icon(Icons.lock_clock_rounded, color: Color(0xFFDC2626), size: 22),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Batas Waktu Edit Berakhir (24 Jam)',
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                      color: isDark ? const Color(0xFFFCA5A5) : const Color(0xFF991B1B),
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    'Laporan ini diterbitkan lebih dari 24 jam yang lalu. Sesuai ketentuan PRD FR-A2, laporan tidak dapat diubah lagi.',
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 12,
                      color: isDark ? const Color(0xFFF87171) : const Color(0xFFB91C1C),
                      height: 1.3,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      );
    }

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF162544) : _kBgBlue100,
        borderRadius: BorderRadius.circular(_kRadiusMd),
        border: Border.all(
          color: (isDark ? const Color(0xFF60A5FA) : _kPrimary).withValues(alpha: 0.35),
          width: 1,
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(
            Icons.history_toggle_off_rounded,
            color: isDark ? const Color(0xFF60A5FA) : _kPrimary,
            size: 22,
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(
                      'Sisa Waktu Edit: ',
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: isDark ? Colors.white : const Color(0xFF1E3A8A),
                      ),
                    ),
                    Text(
                      remainingText,
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 13,
                        fontWeight: FontWeight.w800,
                        color: isDark ? const Color(0xFF93C5FD) : _kPrimaryDeep,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 3),
                Text(
                  'Laporan dapat diedit dalam 24 jam pertama. Perubahan akan otomatis diberi penanda "(diedit)".',
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 12,
                    color: isDark ? const Color(0xFF94A3B8) : const Color(0xFF1E40AF),
                    height: 1.3,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  /// Section Media persis dengan gaya CreateReportScreen:
  /// - Default kosong: Wadah 2 pilihan (Kamera & Galeri)
  /// - Terlampir: Preview foto/video dengan label dinamis dan aksi Ambil Ulang, Galeri, Hapus
  Widget _buildMediaSection(BuildContext context, bool isDark) {
    if (_mediaPath == null || _mediaPath!.isEmpty) {
      return Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 16),
        decoration: BoxDecoration(
          color: AppPalette.surface(context),
          borderRadius: BorderRadius.circular(_kRadiusLg),
          border: Border.all(
            color: AppPalette.divider(context),
            width: 1.2,
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: isDark ? const Color(0xFF162544) : _kBgBlue100,
                borderRadius: BorderRadius.circular(_kRadiusSm),
              ),
              child: Icon(
                Icons.add_photo_alternate_outlined,
                color: isDark ? const Color(0xFF60A5FA) : _kPrimary,
                size: 24,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              'Unggah Foto atau Video',
              style: GoogleFonts.plusJakartaSans(
                fontSize: 15,
                fontWeight: FontWeight.w700,
                color: AppPalette.textPrimary(context),
                height: 1.2,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              'Maks. ukuran file 10MB • Maks. durasi video 15 dtk',
              textAlign: TextAlign.center,
              style: GoogleFonts.plusJakartaSans(
                fontSize: 12,
                color: AppPalette.textSecondary(context),
                height: 1.3,
              ),
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                _buildActionPickerPill(
                  icon: Icons.camera_alt_outlined,
                  label: 'Kamera',
                  onTap: _canEdit ? _handleCameraAction : null,
                  isDark: isDark,
                ),
                const SizedBox(width: 12),
                _buildActionPickerPill(
                  icon: Icons.photo_library_outlined,
                  label: 'Galeri',
                  onTap: _canEdit ? _handleGalleryAction : null,
                  isDark: isDark,
                ),
              ],
            ),
          ],
        ),
      );
    }

    // Media Terlampir
    final badgeText = _isVideo
        ? '1 Video Terlampir • Maks. 15 dtk'
        : (_selectedFileSize > 0
            ? '1 Foto Terlampir • ${(_selectedFileSize / (1024 * 1024)).toStringAsFixed(1)} MB'
            : '1 Foto Terlampir');

    return Container(
      height: 220,
      width: double.infinity,
      decoration: BoxDecoration(
        color: Colors.black87,
        borderRadius: BorderRadius.circular(_kRadiusLg),
        border: Border.all(
          color: AppPalette.divider(context),
          width: 1.0,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.08),
            blurRadius: 8,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(_kRadiusLg - 1),
        child: Stack(
          fit: StackFit.expand,
          children: [
            // Konten Preview Media
            _buildMediaContentWidget(),

            // Top Badge Pill
            Positioned(
              top: 12,
              left: 0,
              right: 0,
              child: Center(
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.94),
                    borderRadius: BorderRadius.circular(9999),
                    border: Border.all(
                      color: const Color(0xFFE2E8F0),
                      width: 1,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.12),
                        blurRadius: 6,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        width: 7,
                        height: 7,
                        decoration: const BoxDecoration(
                          color: Color(0xFF10B981),
                          shape: BoxShape.circle,
                        ),
                      ),
                      const SizedBox(width: 6),
                      Text(
                        badgeText,
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 11,
                          fontWeight: FontWeight.w700,
                          color: const Color(0xFF0F172A),
                          height: 1.1,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),

            // Bottom action buttons: Kamera, Galeri, Hapus
            if (_canEdit)
              Positioned(
                bottom: 12,
                left: 12,
                right: 12,
                child: Row(
                  children: [
                    _buildMediaActionButton(
                      icon: Icons.camera_alt_outlined,
                      label: 'Ambil Ulang',
                      onTap: _handleCameraAction,
                    ),
                    const SizedBox(width: 8),
                    _buildMediaActionButton(
                      icon: Icons.photo_library_outlined,
                      label: 'Galeri',
                      onTap: _handleGalleryAction,
                    ),
                    const Spacer(),
                    GestureDetector(
                      onTap: _confirmRemoveMedia,
                      child: Container(
                        width: 38,
                        height: 38,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: const Color(0xFFFEE2E2),
                            width: 1,
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withValues(alpha: 0.15),
                              blurRadius: 6,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                        child: const Center(
                          child: Icon(
                            Icons.delete_outline_rounded,
                            color: Color(0xFFEF4444),
                            size: 20,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildMediaContentWidget() {
    if (_isVideo) {
      return Container(
        color: const Color(0xFF0F172A),
        alignment: Alignment.center,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 56,
              height: 56,
              decoration: BoxDecoration(
                color: _kPrimary.withValues(alpha: 0.9),
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: _kPrimary.withValues(alpha: 0.4),
                    blurRadius: 12,
                  ),
                ],
              ),
              child: const Icon(
                Icons.play_arrow_rounded,
                color: Colors.white,
                size: 36,
              ),
            ),
            const SizedBox(height: 10),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Text(
                'Video Lampiran Laporan',
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: Colors.white70,
                  height: 1.2,
                ),
              ),
            ),
          ],
        ),
      );
    }

    if (_isNewLocalMedia ||
        (!_mediaPath!.startsWith('http://') && !_mediaPath!.startsWith('https://'))) {
      return Image.file(
        File(_mediaPath!),
        fit: BoxFit.cover,
        errorBuilder: (context, error, stackTrace) => const Center(
          child: Icon(Icons.broken_image, color: Colors.white),
        ),
      );
    }

    return Image.network(
      _mediaPath!,
      fit: BoxFit.cover,
      errorBuilder: (context, error, stackTrace) => const Center(
        child: Icon(Icons.broken_image, color: Colors.white),
      ),
    );
  }

  Widget _buildActionPickerPill({
    required IconData icon,
    required String label,
    required VoidCallback? onTap,
    required bool isDark,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(_kRadiusMd),
      child: Container(
        height: 42,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        decoration: BoxDecoration(
          color: isDark ? const Color(0xFF1E293B) : const Color(0xFFF1F5F9),
          borderRadius: BorderRadius.circular(_kRadiusMd),
          border: Border.all(
            color: isDark ? const Color(0xFF334155) : const Color(0xFFCBD5E1),
            width: 1,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              size: 18,
              color: isDark ? const Color(0xFF94A3B8) : const Color(0xFF475569),
            ),
            const SizedBox(width: 8),
            Text(
              label,
              style: GoogleFonts.plusJakartaSans(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: isDark ? Colors.white : const Color(0xFF0F172A),
                height: 1.1,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMediaActionButton({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 38,
        padding: const EdgeInsets.symmetric(horizontal: 12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(_kRadiusSm),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.15),
              blurRadius: 6,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 16, color: const Color(0xFF0F172A)),
            const SizedBox(width: 6),
            Text(
              label,
              style: GoogleFonts.plusJakartaSans(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: const Color(0xFF0F172A),
                height: 1.1,
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Kartu Lokasi Tersemat (Read-only dengan layout kartu CreateReportScreen)
  Widget _buildLocationCard(BuildContext context, bool isDark) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppPalette.surface(context),
        borderRadius: BorderRadius.circular(_kRadiusLg),
        border: Border.all(
          color: AppPalette.divider(context),
          width: 1.2,
        ),
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
              Container(
                width: 38,
                height: 38,
                decoration: BoxDecoration(
                  color: isDark ? const Color(0xFF162544) : _kBgBlue100,
                  borderRadius: BorderRadius.circular(_kRadiusSm),
                ),
                child: Icon(
                  Icons.location_on,
                  color: isDark ? const Color(0xFF60A5FA) : _kPrimary,
                  size: 20,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      widget.report.locationDisplay,
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                        color: AppPalette.textPrimary(context),
                        height: 1.2,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      widget.report.locationDetail ?? 'Titik Koordinat Tersemat',
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 12,
                        color: AppPalette.textSecondary(context),
                        height: 1.2,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: isDark ? const Color(0xFF063327) : const Color(0xFFDCFCE7),
              borderRadius: BorderRadius.circular(_kRadiusSm),
              border: Border.all(
                color: isDark ? const Color(0xFF059669) : const Color(0xFF86EFAC),
                width: 0.8,
              ),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 6,
                  height: 6,
                  decoration: const BoxDecoration(
                    color: Color(0xFF10B981),
                    shape: BoxShape.circle,
                  ),
                ),
                const SizedBox(width: 6),
                Flexible(
                  child: Text(
                    'Lokasi Terkunci Permanen (tidak dapat diubah)',
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                      color: isDark ? const Color(0xFF34D399) : const Color(0xFF059669),
                      height: 1.1,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  /// Pilihan Kategori Isu (Gaya kartu CreateReportScreen dengan radio check circle & icon box)
  Widget _buildCategorySelector(BuildContext context, bool isDark) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Kategori Laporan',
          style: GoogleFonts.plusJakartaSans(
            fontSize: 15,
            fontWeight: FontWeight.w700,
            color: AppPalette.textPrimary(context),
            height: 1.2,
          ),
        ),
        const SizedBox(height: 10),
        Row(
          children: [
            // Card 1: Kondisi Kampus
            Expanded(
              child: _buildCategoryCard(
                context: context,
                title: 'Kondisi Kampus',
                subtitle: 'Fasilitas & Sarpras',
                iconData: Icons.warning_amber_rounded,
                iconBgColor: isDark ? const Color(0xFF2E2008) : _kConditionBg,
                iconColor: isDark ? const Color(0xFFFFB95F) : _kConditionBorder,
                isSelected: _selectedCategory == 'Kondisi Kampus',
                onTap: _canEdit ? () => setState(() => _selectedCategory = 'Kondisi Kampus') : () {},
                isDark: isDark,
              ),
            ),
            const SizedBox(width: 12),
            // Card 2: Informasi Penting
            Expanded(
              child: _buildCategoryCard(
                context: context,
                title: 'Informasi Penting',
                subtitle: 'Akses & Situasi',
                iconData: Icons.campaign_rounded,
                iconBgColor: isDark ? const Color(0xFF162544) : _kBgBlue100,
                iconColor: isDark ? const Color(0xFF60A5FA) : _kPrimary,
                isSelected: _selectedCategory == 'Informasi Penting',
                onTap: _canEdit ? () => setState(() => _selectedCategory = 'Informasi Penting') : () {},
                isDark: isDark,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildCategoryCard({
    required BuildContext context,
    required String title,
    required String subtitle,
    required IconData iconData,
    required Color iconBgColor,
    required Color iconColor,
    required bool isSelected,
    required VoidCallback onTap,
    required bool isDark,
  }) {
    final borderColor = isSelected ? _kPrimary : AppPalette.divider(context);

    final cardBg = isSelected
        ? (isDark ? const Color(0xFF132347) : const Color(0xFFF0F5FF))
        : AppPalette.surface(context);

    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: cardBg,
          borderRadius: BorderRadius.circular(_kRadiusLg),
          border: Border.all(
            color: borderColor,
            width: isSelected ? 1.8 : 1.2,
          ),
          boxShadow: [
            BoxShadow(
              color: isSelected
                  ? _kPrimary.withValues(alpha: 0.12)
                  : Colors.black.withValues(alpha: 0.02),
              blurRadius: isSelected ? 8 : 4,
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
                Container(
                  width: 38,
                  height: 38,
                  decoration: BoxDecoration(
                    color: iconBgColor,
                    borderRadius: BorderRadius.circular(_kRadiusSm),
                  ),
                  child: Center(
                    child: Icon(iconData, color: iconColor, size: 20),
                  ),
                ),
                Container(
                  width: 22,
                  height: 22,
                  decoration: BoxDecoration(
                    color: isSelected ? _kPrimary : Colors.transparent,
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: isSelected
                          ? _kPrimary
                          : (isDark ? const Color(0xFF475569) : const Color(0xFFCBD5E1)),
                      width: 1.5,
                    ),
                  ),
                  child: isSelected
                      ? const Icon(
                          Icons.check,
                          size: 14,
                          color: Colors.white,
                        )
                      : null,
                ),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              title,
              style: GoogleFonts.plusJakartaSans(
                fontSize: 14,
                fontWeight: FontWeight.w700,
                color: isSelected
                    ? (isDark ? const Color(0xFF93C5FD) : _kPrimaryDeep)
                    : AppPalette.textPrimary(context),
                height: 1.1,
              ),
            ),
            const SizedBox(height: 3),
            Text(
              subtitle,
              style: GoogleFonts.plusJakartaSans(
                fontSize: 11,
                color: AppPalette.textSecondary(context),
                height: 1.2,
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Input judul laporan rapi dengan single-border outline matching CreateReportScreen.
  Widget _buildTitleInput(BuildContext context, bool isDark) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Judul Laporan',
          style: GoogleFonts.plusJakartaSans(
            fontSize: 15,
            fontWeight: FontWeight.w700,
            color: AppPalette.textPrimary(context),
            height: 1.2,
          ),
        ),
        const SizedBox(height: 8),
        TextField(
          controller: _titleController,
          enabled: _canEdit,
          style: GoogleFonts.plusJakartaSans(
            fontSize: 14,
            fontWeight: FontWeight.w500,
            color: AppPalette.textPrimary(context),
          ),
          decoration: InputDecoration(
            hintText: 'Contoh: Kerusakan Meja di Ruang Kuliah',
            hintStyle: GoogleFonts.plusJakartaSans(
              fontSize: 14,
              fontWeight: FontWeight.w400,
              color: AppPalette.textSecondary(context),
            ),
            filled: true,
            fillColor: AppPalette.surface(context),
            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(_kRadiusMd),
              borderSide: BorderSide(
                color: AppPalette.divider(context),
                width: 1.2,
              ),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(_kRadiusMd),
              borderSide: const BorderSide(
                color: _kPrimary,
                width: 1.5,
              ),
            ),
          ),
        ),
      ],
    );
  }

  /// Input keterangan laporan (deskripsi) rapi matching CreateReportScreen.
  Widget _buildDescriptionInput(BuildContext context, bool isDark) {
    final currentLength = _descriptionController.text.length;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Keterangan Laporan',
              style: GoogleFonts.plusJakartaSans(
                fontSize: 15,
                fontWeight: FontWeight.w700,
                color: AppPalette.textPrimary(context),
                height: 1.2,
              ),
            ),
            Text(
              '$currentLength/$_maxDescriptionLength',
              style: GoogleFonts.plusJakartaSans(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: currentLength > _maxDescriptionLength
                    ? AppColors.error
                    : AppPalette.textSecondary(context),
                height: 1.2,
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        TextField(
          controller: _descriptionController,
          enabled: _canEdit,
          maxLines: 5,
          maxLength: _maxDescriptionLength,
          maxLengthEnforcement: MaxLengthEnforcement.enforced,
          buildCounter: (_, {required currentLength, required isFocused, maxLength}) => null,
          style: GoogleFonts.plusJakartaSans(
            fontSize: 14,
            fontWeight: FontWeight.w400,
            color: AppPalette.textPrimary(context),
            height: 1.5,
          ),
          decoration: InputDecoration(
            hintText: 'Tuliskan deskripsi kondisi atau kejadian selengkap mungkin...',
            hintStyle: GoogleFonts.plusJakartaSans(
              fontSize: 14,
              fontWeight: FontWeight.w400,
              color: AppPalette.textSecondary(context),
            ),
            filled: true,
            fillColor: AppPalette.surface(context),
            contentPadding: const EdgeInsets.all(16),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(_kRadiusMd),
              borderSide: BorderSide(
                color: AppPalette.divider(context),
                width: 1.2,
              ),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(_kRadiusMd),
              borderSide: const BorderSide(
                color: _kPrimary,
                width: 1.5,
              ),
            ),
          ),
        ),
      ],
    );
  }

  /// Tombol aksi bawah (Tinggi 50px, teks presisi, berada di dalam scroll view sehingga tidak tenggelam)
  Widget _buildActionButtons(BuildContext context, bool isDark) {
    final canEdit = _canEdit;

    return Column(
      children: [
        SizedBox(
          width: double.infinity,
          height: 50,
          child: ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: canEdit ? _kPrimary : Colors.grey,
              elevation: 0,
              padding: EdgeInsets.zero,
              alignment: Alignment.center,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(_kRadiusMd),
              ),
            ),
            onPressed: canEdit && !_isSubmitting ? _confirmAndSaveReport : null,
            child: _isSubmitting
                ? const SizedBox(
                    width: 22,
                    height: 22,
                    child: CircularProgressIndicator(
                      strokeWidth: 2.2,
                      valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                    ),
                  )
                : Text(
                    canEdit ? 'Simpan Perubahan' : 'Batas Waktu Edit Berakhir',
                    textAlign: TextAlign.center,
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 15,
                      fontWeight: FontWeight.w700,
                      color: Colors.white,
                      height: 1.1,
                    ),
                  ),
          ),
        ),
        const SizedBox(height: 12),
        GestureDetector(
          onTap: () => Navigator.pop(context),
          behavior: HitTestBehavior.opaque,
          child: Container(
            height: 40,
            alignment: Alignment.center,
            child: Text(
              'Batalkan Perubahan',
              textAlign: TextAlign.center,
              style: GoogleFonts.plusJakartaSans(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: isDark ? const Color(0xFF60A5FA) : _kPrimary,
                height: 1.1,
              ),
            ),
          ),
        ),
      ],
    );
  }
}
