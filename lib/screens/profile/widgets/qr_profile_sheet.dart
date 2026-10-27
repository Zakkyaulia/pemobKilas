import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';
import 'package:qr_flutter/qr_flutter.dart';

import '../../../theme/app_palette.dart';
import '../../../theme/app_spacing.dart';
import '../../../theme/home_colors.dart';
import '../../../theme/home_text_styles.dart';
import '../data/user_profile_repository.dart';
import '../public_profile_screen.dart';

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

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = AppPalette.isDark(context);
    final user = UserProfileRepository.instance.profile;

    return Container(
      height: MediaQuery.of(context).size.height * 0.75,
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
  }

  Widget _buildMyQrTab(BuildContext context, dynamic user, bool isDark) {
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
                      data: 'https://kilas.app/u/${user.username.replaceAll('@', '')}',
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
                  user.nama,
                  style: HomeTextStyles.headlineSm.copyWith(
                    fontWeight: FontWeight.w700,
                    color: const Color(0xFF0F172A),
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  user.username,
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
              final link = 'https://kilas.app/u/${user.username.replaceAll('@', '')}';
              Clipboard.setData(ClipboardData(text: link));
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(
                    'Tautan profil ${user.username} berhasil disalin ke clipboard!',
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
          const SizedBox(height: 20),
          Row(
            children: [
              Expanded(child: Divider(color: AppPalette.divider(context))),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 10),
                child: Text(
                  'ATAU TES SIMULASI SCAN REKAN',
                  style: HomeTextStyles.labelSm.copyWith(
                    color: AppPalette.textSecondary(context),
                    letterSpacing: 0.5,
                    fontSize: 10.5,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
              Expanded(child: Divider(color: AppPalette.divider(context))),
            ],
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            alignment: WrapAlignment.center,
            children: [
              ActionChip(
                backgroundColor: isDark ? const Color(0xFF13203A) : const Color(0xFFEFF4FF),
                side: BorderSide(
                  color: HomeColors.primaryContainer.withValues(alpha: 0.3),
                ),
                avatar: const CircleAvatar(
                  radius: 12,
                  backgroundColor: HomeColors.primaryContainer,
                  child: Text('AF', style: TextStyle(fontSize: 10, color: Colors.white, fontWeight: FontWeight.w700)),
                ),
                label: Text(
                  'Ahmad Fauzan .S',
                  style: HomeTextStyles.labelSm.copyWith(
                    fontWeight: FontWeight.w700,
                    color: AppPalette.textPrimary(context),
                  ),
                ),
                onPressed: () => _showScannedProfileDialog(
                  context,
                  name: 'Ahmad Fauzan .S',
                  username: '@ahmadfauzan',
                  nim: '2211521008',
                  jurusan: 'Sistem Informasi',
                  fakultas: 'Fakultas Teknologi Informasi',
                  bio: 'Aktif berkontribusi melaporkan fasilitas di UNAND.',
                  initials: 'AF',
                ),
              ),
              ActionChip(
                backgroundColor: isDark ? const Color(0xFF13203A) : const Color(0xFFEFF4FF),
                side: BorderSide(
                  color: HomeColors.primaryContainer.withValues(alpha: 0.3),
                ),
                avatar: const CircleAvatar(
                  radius: 12,
                  backgroundColor: HomeColors.primaryContainer,
                  child: Text('AH', style: TextStyle(fontSize: 10, color: Colors.white, fontWeight: FontWeight.w700)),
                ),
                label: Text(
                  'Aziz Hakim',
                  style: HomeTextStyles.labelSm.copyWith(
                    fontWeight: FontWeight.w700,
                    color: AppPalette.textPrimary(context),
                  ),
                ),
                onPressed: () => _showScannedProfileDialog(
                  context,
                  name: 'Aziz Hakim',
                  username: '@aziz_hakim',
                  nim: '2211522014',
                  jurusan: 'Teknik Komputer',
                  fakultas: 'Fakultas Teknologi Informasi',
                  bio: 'Mahasiswa Teknik Komputer UNAND angkatan 2022.',
                  initials: 'AH',
                ),
              ),
            ],
          ),
        ],
      ),
    );
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
                  ? 'KILAS UNAND memerlukan izin untuk membuka galeri foto Anda guna memindai gambar QR code profil mahasiswa atau bukti laporan.'
                  : 'KILAS UNAND memerlukan izin akses kamera perangkat Anda untuk memindai kode QR profil mahasiswa atau memverifikasi keaslian laporan secara langsung.',
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
                      'Privasi Terjamin: Akses kamera dan foto hanya diproses secara lokal di perangkat Anda untuk membaca kode QR dan tidak disebarkan ke publik tanpa izin.',
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

    if (allowCamera != true) return;

    try {
      final picker = ImagePicker();
      final XFile? captured = await picker.pickImage(
        source: fromGallery ? ImageSource.gallery : ImageSource.camera,
        maxWidth: 1200,
        maxHeight: 1200,
      );

      if (captured == null) return;

      if (!context.mounted) return;

      _showScannedProfileDialog(context);
    } catch (e) {
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Gagal membuka kamera: $e',
            style: HomeTextStyles.labelMd.copyWith(color: Colors.white),
          ),
          backgroundColor: const Color(0xFFEF4444),
        ),
      );
    }
  }

  void _showScannedProfileDialog(
    BuildContext context, {
    String name = 'Ahmad Fauzan .S',
    String username = '@ahmadfauzan',
    String nim = '2211521008',
    String jurusan = 'Sistem Informasi',
    String fakultas = 'Fakultas Teknologi Informasi',
    String bio = 'Aktif berkontribusi melaporkan fasilitas di UNAND.',
    String initials = 'AF',
  }) {
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
                    backgroundColor: HomeColors.primaryContainer,
                    child: Text(
                      initials,
                      style: const TextStyle(
                        color: Colors.white,
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
                        Row(
                          children: [
                            Text(
                              name,
                              style: HomeTextStyles.labelMd.copyWith(
                                fontWeight: FontWeight.w700,
                                color: AppPalette.textPrimary(context),
                              ),
                            ),
                            const SizedBox(width: 4),
                            const Icon(
                              Icons.verified_rounded,
                              size: 15,
                              color: HomeColors.primaryContainer,
                            ),
                          ],
                        ),
                        const SizedBox(height: 2),
                        Text(
                          '$nim • $jurusan',
                          style: HomeTextStyles.bodySm.copyWith(
                            color: AppPalette.textSecondary(context),
                            fontSize: 12,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          bio,
                          style: HomeTextStyles.bodySm.copyWith(
                            color: AppPalette.textPrimary(context),
                            fontSize: 11.5,
                          ),
                          maxLines: 2,
                        ),
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
                      builder: (context) => PublicProfileScreen(
                        name: name,
                        username: username,
                        nim: nim,
                        jurusan: jurusan,
                        fakultas: fakultas,
                        bio: bio,
                        initials: initials,
                      ),
                    ),
                  );
                },
                icon: const Icon(Icons.person_search_rounded, size: 22, color: Colors.white),
                label: Text(
                  'Lihat Profil & Laporan Mahasiswa',
                  style: HomeTextStyles.labelMd.copyWith(
                    fontWeight: FontWeight.w700,
                    color: Colors.white,
                    fontSize: 13.5,
                  ),
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

