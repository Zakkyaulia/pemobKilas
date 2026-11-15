import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:qr_flutter/qr_flutter.dart';

import '../../../services/user_api_service.dart';
import '../../../theme/app_palette.dart';
import '../../../theme/app_spacing.dart';
import '../../../theme/home_colors.dart';
import '../../../theme/home_text_styles.dart';
import '../data/campus_users_data.dart';
import '../data/user_profile_repository.dart';
import '../public_profile_screen.dart';
import '../qr_scanner_screen.dart';

/// Modal sheet untuk menampilkan QR Profil sendiri ("QR Saya") dan memindai
/// QR pengguna lain ("Pindai QR") untuk membuka Profil Publik (FR-16 & FR-B5).
class QrProfileSheet extends StatefulWidget {
  const QrProfileSheet({super.key});

  static Future<void> show(BuildContext context) {
    return showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => const QrProfileSheet(),
    );
  }

  @override
  State<QrProfileSheet> createState() => _QrProfileSheetState();
}

class _QrProfileSheetState extends State<QrProfileSheet>
    with SingleTickerProviderStateMixin {
  late final TabController _tabController;

  // ── State Validasi & Feedback Pemindaian QR ──
  bool _isProcessingScan = false;
  String? _scanStatusTitle;
  String? _scanStatusMessage;
  IconData? _scanStatusIcon;
  Color? _scanStatusColor;
  CampusUserItem? _scannedUser;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    UserProfileRepository.instance.fetchProfileFromBackend();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = AppPalette.isDark(context);

    return AnimatedBuilder(
      animation: UserProfileRepository.instance,
      builder: (context, _) {
        final user = UserProfileRepository.instance.profile;

        return Container(
          height: MediaQuery.of(context).size.height * 0.86,
          decoration: BoxDecoration(
            color: AppPalette.surface(context),
            borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
          ),
          child: Column(
            children: [
              const SizedBox(height: 12),
              Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: isDark ? const Color(0xFF334155) : const Color(0xFFCBD5E1),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(height: AppSpacing.lg),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'QR Profil Mahasiswa',
                      style: HomeTextStyles.headlineSm.copyWith(
                        fontWeight: FontWeight.w700,
                        color: AppPalette.textPrimary(context),
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.close_rounded),
                      color: AppPalette.textSecondary(context),
                      onPressed: () => Navigator.pop(context),
                    ),
                  ],
                ),
              ),
              Container(
                margin: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.lg,
                  vertical: AppSpacing.sm,
                ),
                decoration: BoxDecoration(
                  color: AppPalette.canvas(context),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: AppPalette.divider(context)),
                ),
                child: TabBar(
                  controller: _tabController,
                  indicator: BoxDecoration(
                    color: HomeColors.primaryContainer,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  indicatorSize: TabBarIndicatorSize.tab,
                  dividerColor: Colors.transparent,
                  labelColor: Colors.white,
                  unselectedLabelColor: AppPalette.textSecondary(context),
                  labelStyle: HomeTextStyles.labelMd.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
                  unselectedLabelStyle: HomeTextStyles.labelMd.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                  tabs: const [
                    Tab(
                      icon: Icon(Icons.qr_code_2_rounded, size: 18),
                      text: 'QR Saya',
                    ),
                    Tab(
                      icon: Icon(Icons.qr_code_scanner_rounded, size: 18),
                      text: 'Pindai QR',
                    ),
                  ],
                ),
              ),
              Expanded(
                child: TabBarView(
                  controller: _tabController,
                  children: [
                    _buildMyQrTab(context, user, isDark),
                    _buildScanQrTab(context, isDark),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildMyQrTab(BuildContext context, dynamic user, bool isDark) {
    final rawUsername = (user.username as String? ?? '').trim();
    final cleanUsername = rawUsername.replaceAll('@', '').trim();
    final qrData = cleanUsername.isNotEmpty
        ? 'https://kilas.app/u/$cleanUsername'
        : 'https://kilas.app';
    final displayName = (user.nama as String? ?? '').trim().isNotEmpty
        ? user.nama as String
        : 'Mahasiswa UNAND';
    final displayUsername = rawUsername.isNotEmpty
        ? (rawUsername.startsWith('@') ? rawUsername : '@$rawUsername')
        : '@unand';

    return SingleChildScrollView(
      padding: const EdgeInsets.all(AppSpacing.xxl),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(AppSpacing.xl),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.08),
                  blurRadius: 16,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Column(
              children: [
                RepaintBoundary(
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: QrImageView(
                      data: qrData,
                      version: QrVersions.auto,
                      size: 200.0,
                      backgroundColor: Colors.white,
                      padding: const EdgeInsets.all(10),
                      eyeStyle: const QrEyeStyle(
                        eyeShape: QrEyeShape.square,
                        color: Color(0xFF0F172A),
                      ),
                      dataModuleStyle: const QrDataModuleStyle(
                        dataModuleShape: QrDataModuleShape.square,
                        color: Color(0xFF0F172A),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 14),
                Text(
                  displayName,
                  style: HomeTextStyles.headlineSm.copyWith(
                    fontWeight: FontWeight.w700,
                    color: const Color(0xFF0F172A),
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  displayUsername,
                  style: HomeTextStyles.labelMd.copyWith(
                    fontWeight: FontWeight.w600,
                    color: HomeColors.primaryContainer,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: AppSpacing.xl),
          Text(
            'Tunjukkan QR ini ke sesama mahasiswa UNAND untuk membuka Profil Publik Anda tanpa nomor HP/data privat.',
            textAlign: TextAlign.center,
            style: HomeTextStyles.bodySm.copyWith(
              color: AppPalette.textSecondary(context),
              height: 1.4,
            ),
          ),
          const SizedBox(height: AppSpacing.lg),
          OutlinedButton.icon(
            style: OutlinedButton.styleFrom(
              side: BorderSide(color: AppPalette.divider(context)),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
            ),
            onPressed: () {
              Clipboard.setData(ClipboardData(text: qrData));
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(
                    'Tautan profil $displayUsername berhasil disalin ke clipboard!',
                    style: HomeTextStyles.labelMd.copyWith(color: Colors.white),
                  ),
                  backgroundColor: const Color(0xFF1E293B),
                ),
              );
            },
            icon: const Icon(Icons.copy_rounded, size: 16),
            label: Text(
              'Salin Tautan Profil',
              style: HomeTextStyles.labelMd.copyWith(
                fontWeight: FontWeight.w600,
                color: AppPalette.textPrimary(context),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildScanQrTab(BuildContext context, bool isDark) {
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xxl, vertical: AppSpacing.lg),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 200,
            height: 200,
            decoration: BoxDecoration(
              color: isDark ? const Color(0xFF0F1A30) : const Color(0xFFEFF4FF),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: HomeColors.primaryContainer.withValues(alpha: 0.5),
                width: 2,
              ),
            ),
            child: Stack(
              alignment: Alignment.center,
              children: [
                Icon(
                  Icons.qr_code_scanner_rounded,
                  size: 64,
                  color: HomeColors.primaryContainer.withValues(alpha: 0.7),
                ),
                Positioned(
                  top: 14,
                  left: 14,
                  child: _buildCorner(isTop: true, isLeft: true),
                ),
                Positioned(
                  top: 14,
                  right: 14,
                  child: _buildCorner(isTop: true, isLeft: false),
                ),
                Positioned(
                  bottom: 14,
                  left: 14,
                  child: _buildCorner(isTop: false, isLeft: true),
                ),
                Positioned(
                  bottom: 14,
                  right: 14,
                  child: _buildCorner(isTop: false, isLeft: false),
                ),
              ],
            ),
          ),
          const SizedBox(height: AppSpacing.lg),
          Text(
            'Pindai QR Profil Mahasiswa',
            textAlign: TextAlign.center,
            style: HomeTextStyles.labelLg.copyWith(
              fontWeight: FontWeight.w700,
              color: AppPalette.textPrimary(context),
            ),
          ),
          const SizedBox(height: 6),
          Text(
            'Gunakan kamera untuk memindai QR profil mahasiswa lain atau verifikasi laporan fasilitas kampus.',
            textAlign: TextAlign.center,
            style: HomeTextStyles.bodySm.copyWith(
              color: AppPalette.textSecondary(context),
              height: 1.4,
            ),
          ),
          const SizedBox(height: AppSpacing.xl),
          SizedBox(
            width: double.infinity,
            height: 48,
            child: ElevatedButton.icon(
              style: ElevatedButton.styleFrom(
                backgroundColor: HomeColors.primaryContainer,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                elevation: 2,
              ),
              onPressed: () => _handleScanQr(context, fromGallery: false),
              icon: const Icon(Icons.camera_alt_rounded, size: 20),
              label: const Text(
                'Buka Kamera Pemindai',
                style: TextStyle(fontWeight: FontWeight.w700, fontSize: 14),
              ),
            ),
          ),
          const SizedBox(height: 10),
          SizedBox(
            width: double.infinity,
            height: 44,
            child: OutlinedButton.icon(
              style: OutlinedButton.styleFrom(
                foregroundColor: HomeColors.primaryContainer,
                side: BorderSide(
                  color: HomeColors.primaryContainer.withValues(alpha: 0.4),
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              onPressed: () => _handleScanQr(context, fromGallery: true),
              icon: const Icon(Icons.photo_library_outlined, size: 18),
              label: const Text(
                'Pilih Gambar QR dari Galeri',
                style: TextStyle(fontWeight: FontWeight.w600, fontSize: 13),
              ),
            ),
          ),
          if (_isProcessingScan) _buildScanProcessingCard(isDark),
          if (_scanStatusMessage != null) _buildScanResultCard(context, isDark),
        ],
      ),
    );
  }

  Widget _buildScanProcessingCard(bool isDark) {
    return Container(
      margin: const EdgeInsets.only(top: 18),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1E293B) : const Color(0xFFF8FAFC),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppPalette.divider(context)),
      ),
      child: Row(
        children: [
          const SizedBox(
            width: 22,
            height: 22,
            child: CircularProgressIndicator(
              strokeWidth: 2.5,
              valueColor: AlwaysStoppedAnimation<Color>(HomeColors.primaryContainer),
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Text(
              'Sedang memproses & memvalidasi QR...',
              style: HomeTextStyles.labelMd.copyWith(
                fontWeight: FontWeight.w600,
                color: AppPalette.textPrimary(context),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildScanResultCard(BuildContext context, bool isDark) {
    final color = _scanStatusColor ?? HomeColors.primaryContainer;
    final isSuccess = _scannedUser != null;

    return Container(
      margin: const EdgeInsets.only(top: 18),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withValues(alpha: isDark ? 0.15 : 0.08),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: color.withValues(alpha: 0.4), width: 1.5),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.18),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  _scanStatusIcon ?? Icons.info_outline_rounded,
                  size: 20,
                  color: color,
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  _scanStatusTitle ?? 'Hasil Validasi',
                  style: HomeTextStyles.labelMd.copyWith(
                    fontWeight: FontWeight.w700,
                    color: color,
                  ),
                ),
              ),
              GestureDetector(
                onTap: () {
                  setState(() {
                    _scanStatusMessage = null;
                    _scanStatusTitle = null;
                    _scannedUser = null;
                  });
                },
                child: Padding(
                  padding: const EdgeInsets.all(4),
                  child: Icon(
                    Icons.close_rounded,
                    size: 18,
                    color: AppPalette.textSecondary(context),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Text(
            _scanStatusMessage ?? '',
            style: HomeTextStyles.bodySm.copyWith(
              color: AppPalette.textPrimary(context),
              height: 1.45,
            ),
          ),
          if (isSuccess && _scannedUser != null) ...[
            const SizedBox(height: 14),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppPalette.surface(context),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: AppPalette.divider(context)),
              ),
              child: Row(
                children: [
                  CircleAvatar(
                    radius: 20,
                    backgroundColor: _scannedUser!.avatarBgColor,
                    child: Text(
                      _scannedUser!.initials,
                      style: TextStyle(
                        color: _scannedUser!.avatarFgColor,
                        fontWeight: FontWeight.w700,
                        fontSize: 13,
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          _scannedUser!.name,
                          style: HomeTextStyles.labelMd.copyWith(
                            fontWeight: FontWeight.w700,
                            color: AppPalette.textPrimary(context),
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        Text(
                          _scannedUser!.username,
                          style: HomeTextStyles.bodySm.copyWith(
                            color: HomeColors.primaryContainer,
                            fontWeight: FontWeight.w600,
                            fontSize: 11.5,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 12),
            SizedBox(
              width: double.infinity,
              height: 42,
              child: ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  backgroundColor: HomeColors.primaryContainer,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                  elevation: 1,
                ),
                onPressed: () {
                  Navigator.pop(context);
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => PublicProfileScreen.fromCampusUser(_scannedUser!),
                    ),
                  );
                },
                icon: const Icon(Icons.person_rounded, size: 16),
                label: const Text(
                  'Buka Profil Publik',
                  style: TextStyle(fontWeight: FontWeight.w700, fontSize: 13),
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  String? _extractUsernameFromQr(String raw) {
    final trimmed = raw.trim();
    if (trimmed.isEmpty) return null;

    final uri = Uri.tryParse(trimmed);
    if (uri != null && uri.pathSegments.isNotEmpty) {
      final segments = uri.pathSegments;
      final uIndex = segments.indexOf('u');
      if (uIndex != -1 && uIndex + 1 < segments.length) {
        return segments[uIndex + 1].replaceAll('@', '').trim();
      }
      if (segments.length >= 2 && (segments[0] == 'user' || segments[0] == 'profile')) {
        return segments[1].replaceAll('@', '').trim();
      }
    }

    final schemeRegex = RegExp(r'kilas:\/\/(?:u|user)\/([a-zA-Z0-9_.]+)');
    final match = schemeRegex.firstMatch(trimmed);
    if (match != null) {
      return match.group(1)?.replaceAll('@', '').trim();
    }

    final userMatch = RegExp(r'^@?([a-zA-Z0-9_.]{3,30})$').firstMatch(trimmed);
    if (userMatch != null) {
      return userMatch.group(1);
    }

    return null;
  }

  Future<void> _handleScanQr(BuildContext context, {bool fromGallery = false}) async {
    final bool? allowCamera = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppPalette.surface(context),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: HomeColors.primaryContainer.withValues(alpha: 0.12),
                shape: BoxShape.circle,
              ),
              child: Icon(
                fromGallery ? Icons.photo_library_rounded : Icons.camera_alt_rounded,
                color: HomeColors.primaryContainer,
                size: 22,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                'Izin Akses & Privasi',
                style: HomeTextStyles.labelLg.copyWith(
                  fontWeight: FontWeight.w700,
                  color: AppPalette.textPrimary(context),
                ),
              ),
            ),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              fromGallery
                  ? 'KILAS UNAND memerlukan izin untuk membuka galeri foto Anda guna memindai gambar QR code profil mahasiswa.'
                  : 'KILAS UNAND memerlukan izin akses kamera perangkat Anda untuk memindai kode QR profil mahasiswa secara langsung.',
              style: HomeTextStyles.bodySm.copyWith(
                color: AppPalette.textSecondary(context),
                height: 1.45,
              ),
            ),
            const SizedBox(height: 14),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppPalette.isDark(context)
                    ? const Color(0xFF13203A)
                    : const Color(0xFFEFF4FF),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: HomeColors.primaryContainer.withValues(alpha: 0.3),
                ),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Icon(
                    Icons.lock_outline_rounded,
                    color: HomeColors.primaryContainer,
                    size: 18,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'Privasi Terjamin: Akses kamera dan foto hanya diproses secara lokal di perangkat Anda untuk membaca kode QR.',
                      style: HomeTextStyles.labelSm.copyWith(
                        color: AppPalette.isDark(context)
                            ? const Color(0xFFBFDBFE)
                            : const Color(0xFF1E3A8A),
                        height: 1.35,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: Text(
              'Batal',
              style: HomeTextStyles.labelMd.copyWith(
                color: AppPalette.textSecondary(context),
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: HomeColors.primaryContainer,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            ),
            onPressed: () => Navigator.pop(ctx, true),
            child: Text(
              fromGallery ? 'Izinkan Galeri' : 'Izinkan & Buka Kamera',
              style: HomeTextStyles.labelMd.copyWith(
                color: Colors.white,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ],
      ),
    );

    if (allowCamera != true || !context.mounted) return;

    if (!fromGallery) {
      // 1. Live camera scanner
      final scannedData = await Navigator.of(context).push<String>(
        MaterialPageRoute(builder: (_) => const QrScannerScreen()),
      );
      if (scannedData == null || !context.mounted) return;

      setState(() {
        _isProcessingScan = true;
        _scanStatusMessage = null;
        _scannedUser = null;
      });

      await _processScannedQrData(context, scannedData);
    } else {
      // 2. Dari Galeri
      try {
        final picker = ImagePicker();
        final XFile? file = await picker.pickImage(
          source: ImageSource.gallery,
          maxWidth: 1600,
          maxHeight: 1600,
        );
        if (file == null || !context.mounted) return;

        setState(() {
          _isProcessingScan = true;
          _scanStatusMessage = null;
          _scannedUser = null;
        });

        final scannerController = MobileScannerController();
        final BarcodeCapture? capture = await scannerController.analyzeImage(file.path);
        await scannerController.dispose();

        if (capture == null || capture.barcodes.isEmpty) {
          if (!context.mounted) return;
          setState(() {
            _isProcessingScan = false;
            _scannedUser = null;
            _scanStatusTitle = 'Kode QR Tidak Ditemukan';
            _scanStatusMessage = 'Gambar yang Anda pilih tidak memuat kode QR. Pastikan memilih foto atau tangkapan layar yang memuat kode QR profil KILAS yang jelas.';
            _scanStatusIcon = Icons.image_not_supported_outlined;
            _scanStatusColor = const Color(0xFFEF4444);
          });
          return;
        }

        final rawValue = capture.barcodes.first.rawValue;
        if (rawValue == null || rawValue.trim().isEmpty) {
          if (!context.mounted) return;
          setState(() {
            _isProcessingScan = false;
            _scannedUser = null;
            _scanStatusTitle = 'Kode QR Kosong';
            _scanStatusMessage = 'Kode QR pada gambar tidak memiliki data atau teks yang dapat dibaca.';
            _scanStatusIcon = Icons.qr_code_scanner_rounded;
            _scanStatusColor = const Color(0xFFEF4444);
          });
          return;
        }

        if (!context.mounted) return;
        await _processScannedQrData(context, rawValue.trim());
      } catch (e) {
        if (!context.mounted) return;
        setState(() {
          _isProcessingScan = false;
          _scannedUser = null;
          _scanStatusTitle = 'Gagal Memproses Gambar';
          _scanStatusMessage = 'Terjadi kesalahan saat membaca file gambar: $e';
          _scanStatusIcon = Icons.error_outline_rounded;
          _scanStatusColor = const Color(0xFFEF4444);
        });
      }
    }
  }

  Future<void> _processScannedQrData(BuildContext context, String rawData) async {
    final username = _extractUsernameFromQr(rawData);
    if (username == null) {
      if (!context.mounted) return;
      setState(() {
        _isProcessingScan = false;
        _scannedUser = null;
        _scanStatusTitle = 'Bukan QR Profil KILAS';
        _scanStatusMessage = 'Kode QR yang dipindai bukan merupakan format profil mahasiswa KILAS.\n\nData terbaca:\n"$rawData"';
        _scanStatusIcon = Icons.qr_code_2_rounded;
        _scanStatusColor = const Color(0xFFEF4444);
      });
      return;
    }

    final lookupResult = await UserApiService.getUserByUsername(username);

    if (!context.mounted) return;

    switch (lookupResult) {
      case UserLookupSuccess(:final user):
        setState(() {
          _isProcessingScan = false;
          _scannedUser = user;
          _scanStatusTitle = 'QR Berhasil Divalidasi';
          _scanStatusMessage = 'Profil mahasiswa terverifikasi: ${user.name} (${user.username})';
          _scanStatusIcon = Icons.check_circle_rounded;
          _scanStatusColor = const Color(0xFF10B981);
        });
        _showScannedProfileDialog(context, user);

      case UserLookupNotFound(:final username):
        setState(() {
          _isProcessingScan = false;
          _scannedUser = null;
          _scanStatusTitle = 'Mahasiswa Tidak Terdaftar';
          _scanStatusMessage = 'Kode QR valid, namun akun @$username tidak ditemukan di database KILAS.';
          _scanStatusIcon = Icons.person_off_rounded;
          _scanStatusColor = const Color(0xFFEF4444);
        });

      case UserLookupNetworkError(:final message):
        setState(() {
          _isProcessingScan = false;
          _scannedUser = null;
          _scanStatusTitle = 'Koneksi Backend Terputus';
          _scanStatusMessage = '$message\n\nPastikan adb reverse aktif (adb reverse tcp:3000 tcp:3000).';
          _scanStatusIcon = Icons.wifi_off_rounded;
          _scanStatusColor = const Color(0xFFF59E0B);
        });

      case UserLookupError(:final message):
        setState(() {
          _isProcessingScan = false;
          _scannedUser = null;
          _scanStatusTitle = 'Validasi Gagal';
          _scanStatusMessage = message;
          _scanStatusIcon = Icons.error_outline_rounded;
          _scanStatusColor = const Color(0xFFEF4444);
        });
    }
  }

  void _showScannedProfileDialog(BuildContext context, CampusUserItem user) {
    final isDarkTheme = AppPalette.isDark(context);
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (ctx) => Container(
        decoration: BoxDecoration(
          color: AppPalette.surface(context),
          borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
          border: Border.all(color: AppPalette.divider(context)),
        ),
        padding: const EdgeInsets.fromLTRB(20, 16, 20, 28),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: AppPalette.divider(context),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(6),
                  decoration: BoxDecoration(
                    color: const Color(0xFF10B981).withValues(alpha: 0.15),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.check_circle_rounded,
                    color: Color(0xFF10B981),
                    size: 20,
                  ),
                ),
                const SizedBox(width: 8),
                Text(
                  'QR Berhasil Dipindai',
                  style: HomeTextStyles.labelLg.copyWith(
                    fontWeight: FontWeight.w700,
                    color: AppPalette.textPrimary(context),
                  ),
                ),
                const Spacer(),
                IconButton(
                  icon: const Icon(Icons.close_rounded),
                  color: AppPalette.textSecondary(context),
                  onPressed: () => Navigator.pop(ctx),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: isDarkTheme
                    ? const Color(0xFF13203A)
                    : const Color(0xFFF8FAFC),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: AppPalette.divider(context)),
              ),
              child: Row(
                children: [
                  CircleAvatar(
                    radius: 26,
                    backgroundColor: user.avatarBgColor,
                    child: Text(
                      user.initials,
                      style: TextStyle(
                        color: user.avatarFgColor,
                        fontWeight: FontWeight.w700,
                        fontSize: 16,
                      ),
                    ),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          user.name,
                          style: HomeTextStyles.labelMd.copyWith(
                            fontWeight: FontWeight.w700,
                            color: AppPalette.textPrimary(context),
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          user.username,
                          style: HomeTextStyles.bodySm.copyWith(
                            color: HomeColors.primaryContainer,
                            fontWeight: FontWeight.w600,
                            fontSize: 12,
                          ),
                        ),
                        if (user.jurusan != null || user.fakultas != null) ...[
                          const SizedBox(height: 2),
                          Text(
                            [user.jurusan, user.fakultas].whereType<String>().join(' • '),
                            style: HomeTextStyles.bodySm.copyWith(
                              color: AppPalette.textSecondary(context),
                              fontSize: 11.5,
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 4),
              child: ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  backgroundColor: HomeColors.primaryContainer,
                  foregroundColor: Colors.white,
                  minimumSize: const Size(double.infinity, 50),
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                  elevation: 2,
                ),
                onPressed: () {
                  Navigator.pop(ctx);
                  Navigator.pop(context); // tutup sheet QR
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => PublicProfileScreen.fromCampusUser(user),
                    ),
                  );
                },
                icon: const Icon(Icons.person_rounded, size: 18),
                label: const Text(
                  'Lihat Profil Lengkap',
                  style: TextStyle(fontWeight: FontWeight.w700, fontSize: 14),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCorner({required bool isTop, required bool isLeft}) {
    return Container(
      width: 24,
      height: 24,
      decoration: BoxDecoration(
        border: Border(
          top: isTop
              ? const BorderSide(color: HomeColors.primaryContainer, width: 3)
              : BorderSide.none,
          bottom: !isTop
              ? const BorderSide(color: HomeColors.primaryContainer, width: 3)
              : BorderSide.none,
          left: isLeft
              ? const BorderSide(color: HomeColors.primaryContainer, width: 3)
              : BorderSide.none,
          right: !isLeft
              ? const BorderSide(color: HomeColors.primaryContainer, width: 3)
              : BorderSide.none,
        ),
      ),
    );
  }
}

