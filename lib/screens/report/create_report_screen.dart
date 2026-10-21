import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';

import '../../services/location_service.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_palette.dart';
import '../../theme/app_spacing.dart';
import '../../theme/home_colors.dart';
import '../../widgets/map/dummy_map_data.dart';
import '../home/data/report_repository.dart';
import '../home/models/report_model.dart';
import '../profile/data/user_profile_repository.dart';
import 'package:latlong2/latlong.dart';

// ─── Design tokens matching SearchFilterScreen ───────────────────────────────
const Color _kPrimary = Color(0xFF0048D4);
const Color _kConditionBg = Color(0xFFFEF3DC);
const Color _kConditionBorder = Color(0xFF9C6200);
const Color _kBgBlue100 = Color(0xFFE5EEFF);
const Color _kPrimaryDeep = Color(0xFF0B3A9C);

const double _kRadiusLg = 16.0;
const double _kRadiusMd = 12.0;
const double _kRadiusSm = 8.0;

/// Batas maksimal ukuran file (10 MB).
const int _kMaxFileSizeBytes = 10 * 1024 * 1024;

/// Batas maksimal durasi rekaman video (15 detik).
const Duration _kMaxVideoDuration = Duration(seconds: 15);

/// Screen untuk membuat dan mengunggah laporan baru ke aplikasi KILAS.
///
/// Fitur Fungsional & Keamanan:
/// - Default tampilan: 2 opsi pemilihan (Kamera & Galeri)
/// - Dialog Izin Keamanan & Ketentuan Privasi (Terms & Policy)
/// - Integrasi nyata [ImagePicker] dengan validasi ukuran file (<= 10MB) & durasi video
/// - Konfirmasi dialog: Kirim Laporan, Simpan Draft, dan Hapus Media (mencegah salah klik)
/// - Intersepsi navigasi Back (PopScope) dengan konfirmasi jika ada draf/media belum disimpan
/// - Teks tombol rapi dan vertikal presisi tanpa kepotong
class CreateReportScreen extends StatefulWidget {
  const CreateReportScreen({super.key});

  @override
  State<CreateReportScreen> createState() => _CreateReportScreenState();
}

class _CreateReportScreenState extends State<CreateReportScreen> {
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();

  final ImagePicker _picker = ImagePicker();

  /// Media file nyata yang dipilih pengguna (null saat pertama kali masuk).
  XFile? _selectedMediaFile;

  /// True jika media yang dipilih adalah video.
  bool _isVideo = false;

  /// Ukuran file terpilih dalam bytes.
  int _selectedFileSize = 0;

  /// Status persetujuan Syarat & Kebijakan Privasi (Terms & Policy).
  bool _hasConsent = false;

  /// Kategori yang dipilih: 'Kondisi Kampus' atau 'Informasi Penting'.
  String _selectedCategory = 'Kondisi Kampus';

  /// Status & data penguncian GPS asli
  GpsLockStatus _gpsStatus = GpsLockStatus.initial;
  String _locationName = 'Menghubungkan ke sensor GPS...';
  String _coordinates = '';
  double? _latitude;
  double? _longitude;
  double? _accuracy;
  String? _gpsErrorMessage;
  bool _isInCampusArea = true;
  bool _allowPopWithoutPrompt = false;

  static const int _maxDescriptionLength = 1500;

  @override
  void initState() {
    super.initState();
    _descriptionController.addListener(() {
      setState(() {});
    });
    _titleController.addListener(() {
      setState(() {});
    });
    // Kunci titik koordinat GPS secara otomatis saat layar laporan dibuka
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _lockGpsPosition();
    });
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  /// Cek apakah pengguna telah memasukkan perubahan yang belum disimpan.
  bool get _hasUnsavedChanges {
    if (_allowPopWithoutPrompt) return false;
    return _selectedMediaFile != null ||
        _titleController.text.trim().isNotEmpty ||
        _descriptionController.text.trim().isNotEmpty;
  }

  void _onCategorySelected(String category) {
    setState(() {
      _selectedCategory = category;
    });
  }

  /// Menampilkan Pop-up Keamanan / Terms & Policy sebelum mengakses Kamera atau Galeri.
  Future<bool> _requestMediaConsent(String sourceName) async {
    if (_hasConsent) return true;

    final accepted = await showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (ctx) {
        return AlertDialog(
          backgroundColor: AppPalette.surface(context),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(_kRadiusLg),
          ),
          titlePadding: const EdgeInsets.fromLTRB(20, 20, 20, 8),
          contentPadding: const EdgeInsets.symmetric(horizontal: 20),
          actionsPadding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
          title: Row(
            children: [
              Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  color: _kBgBlue100,
                  borderRadius: BorderRadius.circular(_kRadiusSm),
                ),
                child: const Icon(
                  Icons.security_rounded,
                  color: _kPrimary,
                  size: 20,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  'Izin Akses & Privasi',
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    color: AppPalette.textPrimary(context),
                    height: 1.2,
                  ),
                ),
              ),
            ],
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 4),
              Text(
                'Aplikasi KILAS memerlukan izin untuk mengakses $sourceName perangkat Anda guna melampirkan bukti visual laporan fasilitas kampus.',
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 13,
                  color: AppPalette.textSecondary(context),
                  height: 1.4,
                ),
              ),
              const SizedBox(height: 14),
              _buildPolicyItem(
                icon: Icons.shield_outlined,
                title: 'Kerahasiaan & Keamanan',
                subtitle:
                    'Media visual hanya digunakan untuk verifikasi laporan kampus dan tidak dibagikan ke pihak ketiga tanpa izin.',
              ),
              const SizedBox(height: 10),
              _buildPolicyItem(
                icon: Icons.gavel_outlined,
                title: 'Ketentuan & Etika Konten',
                subtitle:
                    'Dilarang melampirkan media yang melanggar hukum, norma kesusilaan, atau privasi orang lain.',
              ),
            ],
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
                      'Tolak',
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
                      'Setuju & Izinkan',
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
        );
      },
    );

    if (accepted == true) {
      setState(() {
        _hasConsent = true;
      });
      return true;
    } else {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Akses media dibatalkan karena izin belum disetujui.',
              style: GoogleFonts.plusJakartaSans(
                color: Colors.white,
                fontSize: 13,
                fontWeight: FontWeight.w500,
              ),
            ),
            backgroundColor: const Color(0xFF334155),
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
      return false;
    }
  }

  Widget _buildPolicyItem({
    required IconData icon,
    required String title,
    required String subtitle,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 18, color: _kPrimary),
        const SizedBox(width: 8),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                  color: AppPalette.textPrimary(context),
                  height: 1.1,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                subtitle,
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 11,
                  color: AppPalette.textSecondary(context),
                  height: 1.3,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  /// Memvalidasi ukuran file apakah melebihi 10MB.
  Future<bool> _validateFileSize(XFile file) async {
    final length = await file.length();
    if (length > _kMaxFileSizeBytes) {
      final sizeMb = (length / (1024 * 1024)).toStringAsFixed(1);
      _showErrorSnackBar(
        'Ukuran file ($sizeMb MB) melebihi batas maksimal 10MB. Silakan pilih file yang lebih kecil.',
      );
      return false;
    }
    _selectedFileSize = length;
    return true;
  }

  /// Membuka aksi Kamera (bisa foto atau video).
  Future<void> _handleCameraAction() async {
    final granted = await _requestMediaConsent('Kamera');
    if (!granted) return;

    if (!mounted) return;
    showModalBottomSheet(
      context: context,
      backgroundColor: AppPalette.surface(context),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(AppSpacing.lg),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Gunakan Kamera',
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    color: AppPalette.textPrimary(context),
                    height: 1.2,
                  ),
                ),
                const SizedBox(height: 12),
                ListTile(
                  leading: Container(
                    width: 36,
                    height: 36,
                    decoration: BoxDecoration(
                      color: _kBgBlue100,
                      borderRadius: BorderRadius.circular(_kRadiusSm),
                    ),
                    child: const Icon(Icons.photo_camera, color: _kPrimary, size: 20),
                  ),
                  title: Text(
                    'Ambil Foto',
                    style: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.w600),
                  ),
                  subtitle: const Text('Gunakan foto untuk bukti visual fasilitas (Maks. 10MB)'),
                  onTap: () async {
                    Navigator.pop(ctx);
                    try {
                      final XFile? photo = await _picker.pickImage(
                        source: ImageSource.camera,
                        imageQuality: 85,
                      );
                      if (photo != null) {
                        final valid = await _validateFileSize(photo);
                        if (!valid) return;

                        setState(() {
                          _selectedMediaFile = photo;
                          _isVideo = false;
                        });
                      }
                    } catch (e) {
                      _showErrorSnackBar('Gagal mengakses kamera: $e');
                    }
                  },
                ),
                ListTile(
                  leading: Container(
                    width: 36,
                    height: 36,
                    decoration: BoxDecoration(
                      color: _kBgBlue100,
                      borderRadius: BorderRadius.circular(_kRadiusSm),
                    ),
                    child: const Icon(Icons.videocam, color: _kPrimary, size: 20),
                  ),
                  title: Text(
                    'Rekam Video',
                    style: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.w600),
                  ),
                  subtitle: const Text('Maksimal durasi rekaman 15 detik (Maks. 10MB)'),
                  onTap: () async {
                    Navigator.pop(ctx);
                    try {
                      final XFile? video = await _picker.pickVideo(
                        source: ImageSource.camera,
                        maxDuration: _kMaxVideoDuration,
                      );
                      if (video != null) {
                        final valid = await _validateFileSize(video);
                        if (!valid) return;

                        setState(() {
                          _selectedMediaFile = video;
                          _isVideo = true;
                        });
                      }
                    } catch (e) {
                      _showErrorSnackBar('Gagal merekam video: $e');
                    }
                  },
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  /// Membuka aksi Galeri (bisa pilih foto atau video).
  Future<void> _handleGalleryAction() async {
    final granted = await _requestMediaConsent('Galeri');
    if (!granted) return;

    if (!mounted) return;
    showModalBottomSheet(
      context: context,
      backgroundColor: AppPalette.surface(context),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(AppSpacing.lg),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Pilih dari Galeri',
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    color: AppPalette.textPrimary(context),
                    height: 1.2,
                  ),
                ),
                const SizedBox(height: 12),
                ListTile(
                  leading: Container(
                    width: 36,
                    height: 36,
                    decoration: BoxDecoration(
                      color: _kBgBlue100,
                      borderRadius: BorderRadius.circular(_kRadiusSm),
                    ),
                    child: const Icon(Icons.photo_library, color: _kPrimary, size: 20),
                  ),
                  title: Text(
                    'Pilih Foto',
                    style: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.w600),
                  ),
                  subtitle: const Text('Format JPG atau PNG (Maks. 10MB)'),
                  onTap: () async {
                    Navigator.pop(ctx);
                    try {
                      final XFile? photo = await _picker.pickImage(
                        source: ImageSource.gallery,
                        imageQuality: 85,
                      );
                      if (photo != null) {
                        final valid = await _validateFileSize(photo);
                        if (!valid) return;

                        setState(() {
                          _selectedMediaFile = photo;
                          _isVideo = false;
                        });
                      }
                    } catch (e) {
                      _showErrorSnackBar('Gagal memilih foto: $e');
                    }
                  },
                ),
                ListTile(
                  leading: Container(
                    width: 36,
                    height: 36,
                    decoration: BoxDecoration(
                      color: _kBgBlue100,
                      borderRadius: BorderRadius.circular(_kRadiusSm),
                    ),
                    child: const Icon(Icons.video_library, color: _kPrimary, size: 20),
                  ),
                  title: Text(
                    'Pilih Video',
                    style: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.w600),
                  ),
                  subtitle: const Text('Format MP4 (Maks. 15 detik & Maks. 10MB)'),
                  onTap: () async {
                    Navigator.pop(ctx);
                    try {
                      final XFile? video = await _picker.pickVideo(
                        source: ImageSource.gallery,
                        maxDuration: _kMaxVideoDuration,
                      );
                      if (video != null) {
                        final valid = await _validateFileSize(video);
                        if (!valid) return;

                        setState(() {
                          _selectedMediaFile = video;
                          _isVideo = true;
                        });
                      }
                    } catch (e) {
                      _showErrorSnackBar('Gagal memilih video: $e');
                    }
                  },
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  /// Dialog konfirmasi sebelum menghapus media foto/video terlampir.
  Future<void> _confirmRemoveMedia() async {
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
          'Apakah Anda yakin ingin menghapus foto/video ini dari laporan? Anda dapat memilih atau mengambil ulang media lainnya.',
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
        _selectedMediaFile = null;
        _isVideo = false;
        _selectedFileSize = 0;
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
    ScaffoldMessenger.of(context).showSnackBar(
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

  /// Mengunci titik koordinat GPS pengguna secara nyata via LocationService.
  Future<void> _lockGpsPosition() async {
    if (!mounted) return;
    setState(() {
      _gpsStatus = GpsLockStatus.locating;
      _locationName = 'Mengunci sinyal satelit GPS...';
      _gpsErrorMessage = null;
    });

    try {
      final position = await LocationService.instance.lockCurrentPosition();
      if (!mounted) return;

      final lat = position.latitude;
      final lng = position.longitude;
      final acc = position.accuracy;
      final formattedCoords = '${lat.toStringAsFixed(6)}, ${lng.toStringAsFixed(6)}';

      setState(() {
        _gpsStatus = GpsLockStatus.locked;
        _latitude = lat;
        _longitude = lng;
        _accuracy = acc;
        _coordinates = formattedCoords;
        _locationName = 'Mencari detail lokasi...';
        _gpsErrorMessage = null;
        // Bounding box perkiraan kampus Unand Limau Manis
        _isInCampusArea = (lat <= -0.9000 && lat >= -0.9350 && lng >= 100.4400 && lng <= 100.4800);
      });

      // Lakukan reverse geocoding untuk nama gedung/jalan yang ramah pengguna
      final resolvedName = await LocationService.instance.reverseGeocode(lat, lng);
      if (!mounted) return;

      setState(() {
        if (resolvedName != null && resolvedName.isNotEmpty) {
          _locationName = resolvedName;
        } else {
          _locationName = 'Titik GPS Akurat (Lat: ${lat.toStringAsFixed(5)}, Lng: ${lng.toStringAsFixed(5)})';
        }
      });
    } on GpsServiceDisabledException catch (e) {
      if (!mounted) return;
      setState(() {
        _gpsStatus = GpsLockStatus.serviceDisabled;
        _gpsErrorMessage = e.message;
        _locationName = 'GPS Perangkat Tidak Aktif';
      });
    } on GpsPermissionDeniedException catch (e) {
      if (!mounted) return;
      setState(() {
        _gpsStatus = GpsLockStatus.permissionDenied;
        _gpsErrorMessage = e.message;
        _locationName = 'Izin Akses Lokasi Ditolak';
      });
    } on GpsPermissionPermanentlyDeniedException catch (e) {
      if (!mounted) return;
      setState(() {
        _gpsStatus = GpsLockStatus.permissionDeniedForever;
        _gpsErrorMessage = e.message;
        _locationName = 'Izin Lokasi Ditolak Permanen';
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _gpsStatus = GpsLockStatus.error;
        _gpsErrorMessage = 'Gagal mengunci posisi GPS: $e';
        _locationName = 'Gagal Membaca Koordinat';
      });
    }
  }

  /// Membuka pengaturan lokasi atau aplikasi saat izin/layanan bermasalah.
  Future<void> _handleGpsAction() async {
    if (_gpsStatus == GpsLockStatus.serviceDisabled) {
      await LocationService.instance.openLocationSettings();
      // Tunggu sebentar dan coba kunci kembali
      Future.delayed(const Duration(seconds: 1), _lockGpsPosition);
    } else if (_gpsStatus == GpsLockStatus.permissionDeniedForever) {
      await LocationService.instance.openAppSettings();
    } else {
      _lockGpsPosition();
    }
  }

  /// Menampilkan dialog peringatan bahwa GPS wajib dikunci sebelum laporan dikirim.
  void _showGpsRequiredDialog() {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppPalette.surface(context),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(_kRadiusLg),
        ),
        titlePadding: const EdgeInsets.fromLTRB(20, 20, 20, 8),
        contentPadding: const EdgeInsets.symmetric(horizontal: 20),
        actionsPadding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
        title: Row(
          children: [
            Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                color: const Color(0xFFFEE2E2),
                borderRadius: BorderRadius.circular(_kRadiusSm),
              ),
              child: const Icon(
                Icons.location_off_rounded,
                color: Color(0xFFDC2626),
                size: 20,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                'Wajib Mengunci GPS',
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  color: AppPalette.textPrimary(context),
                  height: 1.2,
                ),
              ),
            ),
          ],
        ),
        content: Text(
          'Untuk memastikan keaslian laporan, sistem KILAS mewajibkan titik koordinat GPS asli Anda terkunci terlebih dahulu.\n\nPastikan GPS perangkat Anda sudah AKTIF dan beri izin lokasi untuk aplikasi.',
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
                  onPressed: () => Navigator.pop(ctx),
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
                  onPressed: () {
                    Navigator.pop(ctx);
                    _handleGpsAction();
                  },
                  child: Text(
                    'Aktifkan GPS',
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
  }



  /// Menampilkan dialog konfirmasi sebelum benar-benar mengirim laporan.
  Future<void> _confirmAndSubmitReport() async {
    final title = _titleController.text.trim();
    final description = _descriptionController.text.trim();

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

    // ── Validasi Wajib: Titik Koordinat GPS Harus Terkunci Terlebih Dahulu ──
    if (_gpsStatus != GpsLockStatus.locked || _latitude == null || _longitude == null) {
      _showGpsRequiredDialog();
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
          'Kirim Laporan Sekarang?',
          style: GoogleFonts.plusJakartaSans(
            fontSize: 16,
            fontWeight: FontWeight.w700,
            color: AppPalette.textPrimary(context),
            height: 1.2,
          ),
        ),
        content: Text(
          'Pastikan informasi judul, deskripsi permasalahan, dan bukti visual yang Anda lampirkan sudah sesuai dan akurat.',
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
                    'Ya, Kirim',
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
      _executeSubmitReport(title, description);
    }
  }

  void _executeSubmitReport(String title, String description) {
    final isCondition = _selectedCategory == 'Kondisi Kampus';
    final currentUser = UserProfileRepository.instance.currentUser;
    final initials = currentUser.nama.isNotEmpty
        ? currentUser.nama
            .trim()
            .split(' ')
            .map((w) => w.isNotEmpty ? w[0] : '')
            .take(2)
            .join()
        : 'U';
    final newReport = ReportModel(
      id: 'post-${DateTime.now().millisecondsSinceEpoch}',
      cardType: CardType.report,
      authorName: currentUser.nama,
      authorUsername: currentUser.username,
      authorInitials: initials,
      authorAvatarUrl: currentUser.fotoProfil,
      avatarBgColor: HomeColors.surfaceVariant,
      avatarFgColor: HomeColors.primary,
      metaIcon: Icons.location_on,
      metaIconColor: HomeColors.primary,
      metaText: '$_locationName • Baru saja',
      locationName: _locationName,
      locationDetail: _coordinates,
      timestamp: 'Baru saja',
      createdAt: DateTime.now(),
      badgeLabel: isCondition ? 'Kondisi Kampus' : 'Info Penting',
      badgeVariant: isCondition ? BadgeVariant.dot : BadgeVariant.icon,
      badgeDotColor: isCondition ? HomeColors.statusCondition : null,
      badgeIcon: isCondition ? null : Icons.campaign,
      badgeBgColor: isCondition ? HomeColors.tertiaryFixed : HomeColors.surfaceContainerHigh,
      badgeTextColor: isCondition ? HomeColors.onTertiaryFixedVariant : HomeColors.primary,
      title: title,
      description: description,
      imageUrl: _selectedMediaFile?.path,
      aspectRatio: 16 / 9,
      imageSemanticLabel: title,
      upvoteCount: 1,
      isUpvoted: true,
    );

    ReportRepository.instance.addReport(newReport);

    // Rekam dan pasang juga pin koordinat nyata ke peta laporan (Map Screen)
    final reportLat = _latitude ?? -0.9142;
    final reportLng = _longitude ?? 100.4608;
    DummyMapData.basicReports.insert(
      0,
      ReportGeoData(
        id: newReport.id,
        title: title,
        category: newReport.badgeLabel,
        position: LatLng(reportLat, reportLng),
      ),
    );

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppPalette.surface(context),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(_kRadiusLg)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const SizedBox(height: 12),
            Container(
              width: 60,
              height: 60,
              decoration: const BoxDecoration(
                color: Color(0xFFDCFCE7),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.check_circle_rounded,
                color: Color(0xFF16A34A),
                size: 36,
              ),
            ),
            const SizedBox(height: 16),
            Text(
              'Laporan Terkirim',
              style: GoogleFonts.plusJakartaSans(
                fontSize: 18,
                fontWeight: FontWeight.w700,
                color: AppPalette.textPrimary(context),
                height: 1.2,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Laporan Anda berhasil diterbitkan dan siap dipantau sivitas akademika.',
              textAlign: TextAlign.center,
              style: GoogleFonts.plusJakartaSans(
                fontSize: 13,
                color: AppPalette.textSecondary(context),
                height: 1.4,
              ),
            ),
            const SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
              height: 44,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: _kPrimary,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(_kRadiusMd),
                  ),
                  elevation: 0,
                  padding: EdgeInsets.zero,
                  alignment: Alignment.center,
                ),
                onPressed: () {
                  setState(() {
                    _allowPopWithoutPrompt = true;
                  });
                  Navigator.pop(ctx);
                  Navigator.pop(context);
                },
                child: Text(
                  'Lihat di Beranda',
                  style: GoogleFonts.plusJakartaSans(
                    fontWeight: FontWeight.w600,
                    color: Colors.white,
                    height: 1.1,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Menampilkan dialog konfirmasi sebelum menyimpan laporan ke Draft lokal.
  Future<void> _confirmAndSaveDraft() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppPalette.surface(context),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(_kRadiusLg),
        ),
        title: Text(
          'Simpan sebagai Draft?',
          style: GoogleFonts.plusJakartaSans(
            fontSize: 16,
            fontWeight: FontWeight.w700,
            color: AppPalette.textPrimary(context),
            height: 1.2,
          ),
        ),
        content: Text(
          'Laporan akan disimpan secara lokal di perangkat Anda dan dapat Anda lanjutkan kapan saja.',
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
      if (mounted) {
        setState(() {
          _allowPopWithoutPrompt = true;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                const Icon(Icons.bookmark_added_outlined, color: Colors.white, size: 20),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'Laporan berhasil disimpan ke Draft lokal',
                    style: GoogleFonts.plusJakartaSans(
                      color: Colors.white,
                      fontSize: 13,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ],
            ),
            backgroundColor: const Color(0xFF0F172A),
            behavior: SnackBarBehavior.floating,
          ),
        );
        Navigator.of(context).pop();
      }
    }
  }

  /// Menampilkan dialog konfirmasi saat tombol Back ditekan dan ada draf/media belum disimpan.
  Future<bool> _showDiscardConfirmationDialog() async {
    final result = await showDialog<String>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppPalette.surface(context),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(_kRadiusLg),
        ),
        title: Text(
          'Keluar dari Halaman Ini?',
          style: GoogleFonts.plusJakartaSans(
            fontSize: 16,
            fontWeight: FontWeight.w700,
            color: AppPalette.textPrimary(context),
            height: 1.2,
          ),
        ),
        content: Text(
          'Laporan yang Anda susun belum dikirim. Perubahan yang belum disimpan akan hilang jika Anda keluar sekarang.',
          style: GoogleFonts.plusJakartaSans(
            fontSize: 13,
            color: AppPalette.textSecondary(context),
            height: 1.4,
          ),
        ),
        actions: [
          Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              SizedBox(
                width: double.infinity,
                height: 42,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: _kPrimary,
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(_kRadiusMd),
                    ),
                    padding: EdgeInsets.zero,
                    alignment: Alignment.center,
                  ),
                  onPressed: () => Navigator.pop(ctx, 'stay'),
                  child: Text(
                    'Lanjut Mengedit',
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                      color: Colors.white,
                      height: 1.1,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      style: OutlinedButton.styleFrom(
                        side: const BorderSide(color: Color(0xFFEF4444)),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(_kRadiusMd),
                        ),
                        padding: const EdgeInsets.symmetric(vertical: 10),
                      ),
                      onPressed: () => Navigator.pop(ctx, 'discard'),
                      child: Text(
                        'Buang & Keluar',
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: const Color(0xFFEF4444),
                          height: 1.1,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: OutlinedButton(
                      style: OutlinedButton.styleFrom(
                        side: BorderSide(color: AppPalette.divider(context)),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(_kRadiusMd),
                        ),
                        padding: const EdgeInsets.symmetric(vertical: 10),
                      ),
                      onPressed: () => Navigator.pop(ctx, 'draft'),
                      child: Text(
                        'Simpan Draft',
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: AppPalette.textPrimary(context),
                          height: 1.1,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );

    if (result == 'discard') {
      setState(() {
        _allowPopWithoutPrompt = true;
      });
      return true; // Keluar tanpa simpan
    } else if (result == 'draft') {
      setState(() {
        _allowPopWithoutPrompt = true;
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                const Icon(Icons.bookmark_added_outlined, color: Colors.white, size: 20),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'Laporan berhasil disimpan ke Draft lokal',
                    style: GoogleFonts.plusJakartaSans(
                      color: Colors.white,
                      fontSize: 13,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ],
            ),
            backgroundColor: const Color(0xFF0F172A),
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
      return true; // Keluar setelah simpan draft
    }
    return false; // Tetap di halaman
  }

  @override
  Widget build(BuildContext context) {
    final isDark = AppPalette.isDark(context);

    return PopScope(
      canPop: !_hasUnsavedChanges,
      onPopInvokedWithResult: (didPop, _) async {
        if (didPop) return;
        final shouldLeave = await _showDiscardConfirmationDialog();
        if (shouldLeave && context.mounted) {
          setState(() {
            _allowPopWithoutPrompt = true;
          });
          Navigator.of(context).pop();
        }
      },
      child: Scaffold(
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
                // 1. Preview Media (Default: 2 pilihan Kamera & Galeri)
                _buildMediaSection(context, isDark),
                const SizedBox(height: AppSpacing.lg),

                // 2. Pencatatan GPS Otomatis
                _buildGpsCard(context, isDark),
                const SizedBox(height: AppSpacing.xl),

                // 3. Pilihan Kategori Isu (dengan garis tepi tegas & ikon native)
                _buildCategorySelector(context, isDark),
                const SizedBox(height: AppSpacing.xl),

                // 4. Input Judul Laporan (rapi single-border)
                _buildTitleInput(context, isDark),
                const SizedBox(height: AppSpacing.lg),

                // 5. Input Keterangan Laporan (rapi single-border)
                _buildDescriptionInput(context, isDark),
                const SizedBox(height: AppSpacing.xxl),

                // 6. Tombol Aksi Bawah
                _buildActionButtons(context, isDark),
                const SizedBox(height: AppSpacing.xxl),
              ],
            ),
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
          Icons.arrow_back,
          color: AppPalette.textPrimary(context),
          size: 24,
        ),
        onPressed: () async {
          if (_hasUnsavedChanges) {
            final shouldLeave = await _showDiscardConfirmationDialog();
            if (shouldLeave && context.mounted) {
              setState(() {
                _allowPopWithoutPrompt = true;
              });
              Navigator.of(context).pop();
            }
          } else {
            Navigator.of(context).pop();
          }
        },
      ),
      titleSpacing: 0,
      title: Text(
        'Buat Laporan',
        style: GoogleFonts.plusJakartaSans(
          fontSize: 18,
          fontWeight: FontWeight.w700,
          color: AppPalette.textPrimary(context),
          height: 1.2,
        ),
      ),
      actions: [
        Padding(
          padding: const EdgeInsets.only(right: AppSpacing.lg),
          child: Center(
            child: ListenableBuilder(
              listenable: UserProfileRepository.instance,
              builder: (context, _) {
                final user = UserProfileRepository.instance.currentUser;
                final photo = user.fotoProfil;
                final initials = user.nama.isNotEmpty
                    ? user.nama
                        .trim()
                        .split(' ')
                        .map((w) => w.isNotEmpty ? w[0] : '')
                        .take(2)
                        .join()
                    : 'U';

                Widget fallback() => Container(
                      color: HomeColors.primaryContainer,
                      alignment: Alignment.center,
                      child: Text(
                        initials,
                        style: GoogleFonts.plusJakartaSans(
                          fontWeight: FontWeight.w700,
                          fontSize: 13,
                          color: Colors.white,
                          height: 1.0,
                        ),
                      ),
                    );

                Widget buildAvatar() {
                  if (photo == null || photo.isEmpty) return fallback();
                  if (photo.startsWith('http://') || photo.startsWith('https://')) {
                    return Image.network(
                      photo,
                      fit: BoxFit.cover,
                      errorBuilder: (_, _, _) => fallback(),
                    );
                  }
                  if (photo.startsWith('assets/')) {
                    return Image.asset(
                      photo,
                      fit: BoxFit.cover,
                      errorBuilder: (_, _, _) => fallback(),
                    );
                  }
                  return Image.file(
                    File(photo),
                    fit: BoxFit.cover,
                    errorBuilder: (_, _, _) => fallback(),
                  );
                }

                return Container(
                  width: 36,
                  height: 36,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: isDark ? const Color(0xFF334155) : const Color(0xFFE2E8F0),
                      width: 1.5,
                    ),
                  ),
                  child: ClipOval(
                    child: buildAvatar(),
                  ),
                );
              },
            ),
          ),
        ),
      ],
      bottom: PreferredSize(
        preferredSize: const Size.fromHeight(1),
        child: Container(
          color: AppPalette.divider(context),
          height: 1,
        ),
      ),
    );
  }

  /// Section Media:
  /// - Default: Wadah 2 pilihan (Kamera & Galeri) dengan batas file & durasi di bawah teks
  /// - Terlampir: Preview foto/video dengan label dinamis ("1 Foto Terlampir" / "1 Video Terlampir")
  Widget _buildMediaSection(BuildContext context, bool isDark) {
    if (_selectedMediaFile == null) {
      // Default: Belum ada media, tampilkan wadah 2 pilihan (Kamera & Galeri)
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
                color: _kBgBlue100,
                borderRadius: BorderRadius.circular(_kRadiusSm),
              ),
              child: const Icon(
                Icons.add_photo_alternate_outlined,
                color: _kPrimary,
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
            // Batas ukuran & durasi tepat di bawah teks
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
            // 2 pilihan aksi utama: Kamera & Galeri (dengan tinggi terdefinisi dan teks centered)
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                _buildActionPickerPill(
                  icon: Icons.camera_alt_outlined,
                  label: 'Kamera',
                  onTap: _handleCameraAction,
                ),
                const SizedBox(width: 12),
                _buildActionPickerPill(
                  icon: Icons.photo_library_outlined,
                  label: 'Galeri',
                  onTap: _handleGalleryAction,
                ),
              ],
            ),
          ],
        ),
      );
    }

    // Media Terlampir: Preview foto atau video asli dari perangkat
    final sizeInMb = (_selectedFileSize / (1024 * 1024)).toStringAsFixed(1);
    final badgeText = _isVideo
        ? '1 Video Terlampir • Maks. 15 dtk'
        : '1 Foto Terlampir • $sizeInMb MB';

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
            // Preview Konten Media
            if (!_isVideo)
              kIsWeb
                  ? Image.network(
                      _selectedMediaFile!.path,
                      fit: BoxFit.cover,
                      errorBuilder: (_, _, _) => _buildMediaFallback(),
                    )
                  : Image.file(
                      File(_selectedMediaFile!.path),
                      fit: BoxFit.cover,
                      errorBuilder: (_, _, _) => _buildMediaFallback(),
                    )
            else
              Container(
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
                        _selectedMediaFile!.name,
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
              ),

            // Top Badge Pill (teks berubah dinamis sesuai foto atau video)
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

            // Bottom action buttons: Ambil Ulang, Galeri, Hapus
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

  Widget _buildMediaFallback() {
    return Container(
      color: Colors.grey.shade900,
      alignment: Alignment.center,
      child: const Icon(Icons.broken_image, color: Colors.white54, size: 40),
    );
  }

  /// Tombol pill pemilihan awal (Kamera & Galeri) dengan penataan teks centered presisi.
  Widget _buildActionPickerPill({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
  }) {
    return SizedBox(
      height: 40,
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: _kPrimary,
          foregroundColor: Colors.white,
          elevation: 0,
          padding: const EdgeInsets.symmetric(horizontal: 18),
          alignment: Alignment.center,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(_kRadiusMd),
          ),
        ),
        onPressed: onTap,
        child: Row(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Icon(icon, size: 16, color: Colors.white),
            const SizedBox(width: 6),
            Text(
              label,
              style: GoogleFonts.plusJakartaSans(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: Colors.white,
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
        height: 36,
        padding: const EdgeInsets.symmetric(horizontal: 14),
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(9999),
          border: Border.all(
            color: const Color(0xFFE2E8F0),
            width: 1,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.12),
              blurRadius: 5,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Icon(icon, size: 15, color: const Color(0xFF0F172A)),
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

  /// Card pencatatan lokasi GPS otomatis dengan border rapi.
  /// Card pencatatan lokasi GPS nyata dengan status dinamis & interaktif.
  Widget _buildGpsCard(BuildContext context, bool isDark) {
    // ── 1. Tampilan ketika GPS Mati (Service Disabled) ───────────────────────
    if (_gpsStatus == GpsLockStatus.serviceDisabled) {
      return Container(
        padding: const EdgeInsets.all(AppSpacing.md),
        decoration: BoxDecoration(
          color: isDark ? const Color(0xFF2A1515) : const Color(0xFFFEF2F2),
          borderRadius: BorderRadius.circular(_kRadiusLg),
          border: Border.all(
            color: const Color(0xFFF87171),
            width: 1.2,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: const Color(0xFFFEE2E2),
                    borderRadius: BorderRadius.circular(_kRadiusSm),
                  ),
                  child: const Center(
                    child: Icon(
                      Icons.location_off_rounded,
                      color: Color(0xFFDC2626),
                      size: 22,
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'GPS Perangkat Belum Aktif',
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 14,
                          fontWeight: FontWeight.w700,
                          color: const Color(0xFFDC2626),
                          height: 1.2,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Aplikasi mewajibkan GPS aktif untuk mengunci titik koordinat asli saat membuat laporan.',
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 12,
                          color: AppPalette.textSecondary(context),
                          height: 1.3,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFDC2626),
                      foregroundColor: Colors.white,
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(_kRadiusSm),
                      ),
                      padding: const EdgeInsets.symmetric(vertical: 10),
                    ),
                    onPressed: _handleGpsAction,
                    icon: const Icon(Icons.settings, size: 16),
                    label: Text(
                      'Nyalakan GPS',
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                OutlinedButton.icon(
                  style: OutlinedButton.styleFrom(
                    foregroundColor: AppPalette.textPrimary(context),
                    side: BorderSide(color: AppPalette.divider(context)),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(_kRadiusSm),
                    ),
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                  ),
                  onPressed: _lockGpsPosition,
                  icon: const Icon(Icons.refresh_rounded, size: 16),
                  label: Text(
                    'Cek Lagi',
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      );
    }

    // ── 2. Tampilan Izin Ditolak (Permission Denied) ──────────────────────────
    if (_gpsStatus == GpsLockStatus.permissionDenied ||
        _gpsStatus == GpsLockStatus.permissionDeniedForever) {
      return Container(
        padding: const EdgeInsets.all(AppSpacing.md),
        decoration: BoxDecoration(
          color: isDark ? const Color(0xFF2C2214) : const Color(0xFFFFFBEB),
          borderRadius: BorderRadius.circular(_kRadiusLg),
          border: Border.all(
            color: const Color(0xFFFBBF24),
            width: 1.2,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: const Color(0xFFFEF3C7),
                    borderRadius: BorderRadius.circular(_kRadiusSm),
                  ),
                  child: const Center(
                    child: Icon(
                      Icons.security_update_warning_rounded,
                      color: Color(0xFFD97706),
                      size: 22,
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Izin Lokasi Dibutuhkan',
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 14,
                          fontWeight: FontWeight.w700,
                          color: const Color(0xFFB45309),
                          height: 1.2,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        _gpsErrorMessage ??
                            'Beri izin akses lokasi agar aplikasi dapat merekam koordinat akurat laporan Anda.',
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 12,
                          color: AppPalette.textSecondary(context),
                          height: 1.3,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFD97706),
                      foregroundColor: Colors.white,
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(_kRadiusSm),
                      ),
                      padding: const EdgeInsets.symmetric(vertical: 10),
                    ),
                    onPressed: _handleGpsAction,
                    icon: const Icon(Icons.lock_open_rounded, size: 16),
                    label: Text(
                      'Beri Izin Lokasi',
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                OutlinedButton.icon(
                  style: OutlinedButton.styleFrom(
                    foregroundColor: AppPalette.textPrimary(context),
                    side: BorderSide(color: AppPalette.divider(context)),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(_kRadiusSm),
                    ),
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                  ),
                  onPressed: _lockGpsPosition,
                  icon: const Icon(Icons.refresh_rounded, size: 16),
                  label: Text(
                    'Coba Lagi',
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      );
    }

    // ── 3. Tampilan Sedang Mengunci Lokasi (Locating / Loading) ──────────────
    if (_gpsStatus == GpsLockStatus.locating || _gpsStatus == GpsLockStatus.initial) {
      return Container(
        padding: const EdgeInsets.all(AppSpacing.md),
        decoration: BoxDecoration(
          color: AppPalette.surface(context),
          borderRadius: BorderRadius.circular(_kRadiusLg),
          border: Border.all(
            color: _kPrimary.withValues(alpha: 0.5),
            width: 1.2,
          ),
        ),
        child: Row(
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: isDark ? const Color(0xFF162544) : _kBgBlue100,
                borderRadius: BorderRadius.circular(_kRadiusSm),
              ),
              child: Center(
                child: SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(
                    strokeWidth: 2.2,
                    color: isDark ? const Color(0xFF60A5FA) : _kPrimary,
                  ),
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Text(
                        'Mengunci Posisi GPS...',
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 13,
                          fontWeight: FontWeight.w700,
                          color: isDark ? const Color(0xFF60A5FA) : _kPrimary,
                          height: 1.1,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 3),
                  Text(
                    _locationName,
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 12,
                      color: AppPalette.textSecondary(context),
                      height: 1.2,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
          ],
        ),
      );
    }

    // ── 4. Tampilan Berhasil Terkunci (Locked) / Default ──────────────────────
    return Container(
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: AppPalette.surface(context),
        borderRadius: BorderRadius.circular(_kRadiusLg),
        border: Border.all(
          color: const Color(0xFF10B981).withValues(alpha: 0.7),
          width: 1.4,
        ),
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
                  color: isDark ? const Color(0xFF064E3B) : const Color(0xFFDCFCE7),
                  borderRadius: BorderRadius.circular(_kRadiusSm),
                ),
                child: Center(
                  child: Icon(
                    Icons.my_location_rounded,
                    color: isDark ? const Color(0xFF34D399) : const Color(0xFF059669),
                    size: 20,
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Flexible(
                          child: Text(
                            'Koordinat GPS Terkunci (Asli)',
                            style: GoogleFonts.plusJakartaSans(
                              fontSize: 13,
                              fontWeight: FontWeight.w700,
                              color: AppPalette.textPrimary(context),
                              height: 1.1,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        const SizedBox(width: 4),
                        Icon(
                          Icons.verified,
                          color: isDark ? const Color(0xFF34D399) : const Color(0xFF059669),
                          size: 15,
                        ),
                      ],
                    ),
                    const SizedBox(height: 3),
                    Text(
                      _locationName,
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: AppPalette.textPrimary(context),
                        height: 1.2,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    if (_coordinates.isNotEmpty) ...[
                      const SizedBox(height: 2),
                      Text(
                        '$_coordinates${_accuracy != null ? " • ±${_accuracy!.toStringAsFixed(1)}m" : ""}',
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 11,
                          color: AppPalette.textSecondary(context),
                          height: 1.1,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Flexible(
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: _isInCampusArea
                        ? (isDark ? const Color(0xFF063327) : const Color(0xFFDCFCE7))
                        : (isDark ? const Color(0xFF3B1D1D) : const Color(0xFFFEE2E2)),
                    borderRadius: BorderRadius.circular(_kRadiusSm),
                    border: Border.all(
                      color: _isInCampusArea
                          ? (isDark ? const Color(0xFF059669) : const Color(0xFF86EFAC))
                          : (isDark ? const Color(0xFFDC2626) : const Color(0xFFFCA5A5)),
                      width: 0.8,
                    ),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        width: 6,
                        height: 6,
                        decoration: BoxDecoration(
                          color: _isInCampusArea
                              ? (isDark ? const Color(0xFF34D399) : const Color(0xFF10B981))
                              : const Color(0xFFEF4444),
                          shape: BoxShape.circle,
                        ),
                      ),
                      const SizedBox(width: 6),
                      Flexible(
                        child: Text(
                          _isInCampusArea
                              ? 'Dalam Area Kampus UNAND'
                              : 'Luar Area Kampus UNAND',
                          style: GoogleFonts.plusJakartaSans(
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                            color: _isInCampusArea
                                ? (isDark ? const Color(0xFF34D399) : const Color(0xFF059669))
                                : (isDark ? const Color(0xFFF87171) : const Color(0xFFDC2626)),
                            height: 1.1,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(width: 8),
              InkWell(
                onTap: _lockGpsPosition,
                borderRadius: BorderRadius.circular(_kRadiusSm),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                  decoration: BoxDecoration(
                    color: isDark ? const Color(0xFF162544) : _kBgBlue100,
                    borderRadius: BorderRadius.circular(_kRadiusSm),
                    border: Border.all(
                      color: (isDark ? const Color(0xFF60A5FA) : _kPrimary).withValues(alpha: 0.35),
                      width: 0.8,
                    ),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.refresh_rounded,
                        color: isDark ? const Color(0xFF60A5FA) : _kPrimary,
                        size: 13,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        'Refresh',
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 11,
                          fontWeight: FontWeight.w700,
                          color: isDark ? const Color(0xFF60A5FA) : _kPrimary,
                          height: 1.1,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  /// Pilihan kategori isu dengan garis tepi (border) tegas & ikon profesional.
  Widget _buildCategorySelector(BuildContext context, bool isDark) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Pilih Kategori Isu',
              style: GoogleFonts.plusJakartaSans(
                fontSize: 15,
                fontWeight: FontWeight.w700,
                color: AppPalette.textPrimary(context),
                height: 1.2,
              ),
            ),
            Text(
              'Wajib Diisi',
              style: GoogleFonts.plusJakartaSans(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: isDark ? const Color(0xFF60A5FA) : _kPrimary,
                height: 1.2,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            // Card 1: Kondisi Kampus
            Expanded(
              child: _buildCategoryCard(
                context: context,
                title: 'Kondisi Kampus',
                subtitle: 'Fasilitas & Sarpras',
                iconData: Icons.apartment_rounded,
                iconBgColor: isDark ? const Color(0xFF332205) : _kConditionBg,
                iconColor: isDark ? const Color(0xFFFFB95F) : _kConditionBorder,
                isSelected: _selectedCategory == 'Kondisi Kampus',
                onTap: () => _onCategorySelected('Kondisi Kampus'),
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
                onTap: () => _onCategorySelected('Informasi Penting'),
                isDark: isDark,
              ),
            ),
          ],
        ),
      ],
    );
  }

  /// Card kategori tunggal dengan garis tepi tegas (border outline).
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
    final borderColor = isSelected
        ? _kPrimary
        : AppPalette.divider(context);

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

  /// Input judul laporan rapi dengan single-border outline.
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

  /// Input keterangan laporan (deskripsi) rapi dengan single-border outline.
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

  /// Tombol aksi bawah dengan penataan tinggi 50px dan teks centered presisi.
  Widget _buildActionButtons(BuildContext context, bool isDark) {
    return Column(
      children: [
        SizedBox(
          width: double.infinity,
          height: 50,
          child: ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: _kPrimary,
              elevation: 0,
              padding: EdgeInsets.zero,
              alignment: Alignment.center,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(_kRadiusMd),
              ),
            ),
            onPressed: _confirmAndSubmitReport,
            child: Text(
              'Kirim Laporan Sekarang',
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
          onTap: _confirmAndSaveDraft,
          behavior: HitTestBehavior.opaque,
          child: Container(
            height: 40,
            alignment: Alignment.center,
            child: Text(
              'Simpan sebagai Draft',
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
