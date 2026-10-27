import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../theme/app_palette.dart';
import '../../theme/app_spacing.dart';
import '../../theme/home_colors.dart';
import '../../theme/home_text_styles.dart';
import '../../widgets/home/network_image_box.dart';
import '../../widgets/home/official_content_box.dart';
import '../../widgets/home/report_card_footer.dart';
import '../../widgets/home/report_card_header.dart';
import '../../widgets/home/status_badge.dart';
import '../../widgets/home/user_avatar.dart';
import '../../widgets/home/video_player_box.dart';
import '../profile/data/user_profile_repository.dart';
import '../profile/models/user_profile_model.dart';
import '../profile/public_profile_screen.dart';
import '../report/edit_report_screen.dart';
import 'data/report_repository.dart';
import 'models/report_model.dart';

/// Screen detail untuk melihat laporan secara penuh tanpa terpotong,
/// dengan kotak informasi lokasi (nama + koordinat GPS) dan aksi interaktif.
class ReportDetailScreen extends StatefulWidget {
  const ReportDetailScreen({
    super.key,
    required this.report,
  });

  /// Data model laporan yang dikirim dari screen sebelumnya.
  final ReportModel report;

  @override
  State<ReportDetailScreen> createState() => _ReportDetailScreenState();
}

class _ReportDetailScreenState extends State<ReportDetailScreen> {
  late ReportModel _report;

  @override
  void initState() {
    super.initState();
    _report = widget.report;
  }

  void _handleUpvote(bool isUpvoted, int count) {
    // 2. State: Update status dan jumlah vote setelah lolos validasi cooldown
    final updated = _report.copyWith(
      isUpvoted: isUpvoted,
      upvoteCount: count,
    );
    setState(() {
      _report = updated;
    });
    ReportRepository.instance.updateById(updated.id, updated);

    if (isUpvoted) {
      UserProfileRepository.instance.addActivity(
        actionType: ActivityActionType.upvote,
        title: 'Memberikan Upvote',
        description: 'Upvote pada laporan "${updated.title ?? "Laporan Kampus"}"',
        reportId: updated.id,
      );
    }

    // 4. Feedback Sukses: SnackBar konfirmasi vote ditambahkan / ditarik
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          content: Row(
            children: [
              Icon(
                Icons.arrow_upward_rounded,
                color: isUpvoted ? Colors.greenAccent : Colors.orangeAccent,
                size: 20,
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  isUpvoted
                      ? 'Upvote berhasil diberikan! (+1)'
                      : 'Upvote berhasil ditarik. (-1)',
                  style: HomeTextStyles.bodySm.copyWith(
                    color: HomeColors.inverseOnSurface,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
          backgroundColor: HomeColors.inverseSurface,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          margin: const EdgeInsets.all(AppSpacing.lg),
          duration: const Duration(seconds: 2),
        ),
      );
  }

  /// 3. Validation & 4. Feedback (Rejection):
  /// Ditampilkan ketika user men-tap upvote berturut-turut dalam jeda < 2 detik.
  /// Aksi ditolak (state tidak berubah), dan pesan peringatan halus ditampilkan.
  void _handleUpvoteCooldown() {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          content: Row(
            children: [
              const Icon(
                Icons.hourglass_empty_rounded,
                color: HomeColors.statusCondition,
                size: 20,
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  'Tunggu sebentar sebelum vote lagi',
                  style: HomeTextStyles.bodySm.copyWith(
                    color: HomeColors.inverseOnSurface,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
          backgroundColor: HomeColors.inverseSurface,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          margin: const EdgeInsets.all(AppSpacing.lg),
          duration: const Duration(milliseconds: 1500),
        ),
      );
  }

  Future<void> _handleShare() async {
    // Menyalin tautan unik laporan secara nyata ke clipboard perangkat
    await Clipboard.setData(
      ClipboardData(text: 'https://kilas.app/p/${_report.id}'),
    );

    if (!mounted) return;

    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          content: Row(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(
                Icons.check_circle,
                size: 18,
                color: HomeColors.statusResolved,
              ),
              const SizedBox(width: 8),
              Text(
                'Tautan disalin ke clipboard',
                style: HomeTextStyles.labelMd.copyWith(
                  color: HomeColors.inverseOnSurface,
                ),
              ),
            ],
          ),
          backgroundColor: HomeColors.inverseSurface,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(9999),
          ),
          margin: const EdgeInsets.symmetric(horizontal: 40, vertical: 20),
          duration: const Duration(seconds: 2),
        ),
      );
  }

  void _handleBookmark(bool isBookmarked) {
    final updated = _report.copyWith(isBookmarked: isBookmarked);
    setState(() {
      _report = updated;
    });
    ReportRepository.instance.updateById(updated.id, updated);

    UserProfileRepository.instance.addActivity(
      actionType: ActivityActionType.bookmark,
      title: isBookmarked ? 'Menyimpan ke Bookmark' : 'Menghapus Bookmark',
      description: isBookmarked
          ? 'Menyimpan laporan "${updated.title ?? "Laporan Kampus"}"'
          : 'Menghapus laporan "${updated.title ?? "Laporan Kampus"}" dari koleksi',
      reportId: updated.id,
    );

    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          content: Row(
            children: [
              Icon(
                isBookmarked ? Icons.bookmark : Icons.bookmark_border,
                color: isBookmarked ? Colors.blueAccent : Colors.white,
                size: 20,
              ),
              const SizedBox(width: 10),
              Text(
                isBookmarked
                    ? 'Laporan disimpan ke bookmark'
                    : 'Laporan dihapus dari bookmark',
                style: HomeTextStyles.bodySm.copyWith(
                  color: HomeColors.inverseOnSurface,
                ),
              ),
            ],
          ),
          backgroundColor: HomeColors.inverseSurface,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          margin: const EdgeInsets.all(AppSpacing.lg),
          duration: const Duration(seconds: 2),
        ),
      );
  }

  Future<void> _handleEditReport() async {
    if (!_report.canEdit) {
      ScaffoldMessenger.of(context)
        ..hideCurrentSnackBar()
        ..showSnackBar(
          SnackBar(
            content: Row(
              children: [
                const Icon(Icons.lock_clock_rounded, color: Colors.white, size: 20),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    'Batas waktu edit (24 jam) untuk laporan ini telah berakhir.',
                    style: HomeTextStyles.bodySm.copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
            backgroundColor: const Color(0xFFEF4444),
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            margin: const EdgeInsets.all(AppSpacing.lg),
          ),
        );
      return;
    }

    final updated = await Navigator.push<ReportModel>(
      context,
      MaterialPageRoute(
        builder: (context) => EditReportScreen(report: _report),
      ),
    );

    if (updated != null && mounted) {
      setState(() {
        _report = updated;
      });
    }
  }

  void _navigateToPublicProfile() {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => PublicProfileScreen.fromReport(_report),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) {
        if (didPop) return;
        // 5. Navigation / Result: Kembalikan _report yang sudah terupdate ke screen sebelumnya
        Navigator.pop(context, _report);
      },
      child: Scaffold(
        backgroundColor: AppPalette.surface(context),
        appBar: AppBar(
          backgroundColor: AppPalette.surface(context),
          elevation: 0,
          scrolledUnderElevation: 1,
          leading: IconButton(
            icon: Icon(
              Icons.arrow_back_ios_new,
              size: 20,
              color: AppPalette.textPrimary(context),
            ),
            onPressed: () => Navigator.pop(context, _report),
          ),
          title: Text(
            'Detail Laporan',
            style: HomeTextStyles.headlineSm.copyWith(
              fontWeight: FontWeight.w700,
              color: AppPalette.textPrimary(context),
            ),
          ),
          centerTitle: true,
          actions: [
            Builder(
              builder: (context) {
                final currentUser = UserProfileRepository.instance.currentUser;
                final isCurrentUser = _report.authorName == currentUser.nama ||
                    _report.authorUsername == currentUser.username;
                if (!isCurrentUser) return const SizedBox.shrink();

                return IconButton(
                  icon: Icon(
                    Icons.edit_note_rounded,
                    size: 24,
                    color: _report.canEdit
                        ? HomeColors.primary
                        : AppPalette.textSecondary(context).withValues(alpha: 0.35),
                  ),
                  tooltip: _report.canEdit ? 'Edit Laporan' : 'Batas edit (24 jam) habis',
                  onPressed: _handleEditReport,
                );
              },
            ),
            const SizedBox(width: 6),
          ],
        ),
        body: SingleChildScrollView(
          padding: const EdgeInsets.all(AppSpacing.lg),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header Laporan: Pengirim + Waktu + Badge Status
              _buildHeader(),
              const SizedBox(height: 16),

              // Kotak Informasi Lokasi Khusus (Nama Lokasi + Koordinat GPS)
              if (_report.locationName != null) ...[
                _LocationCard(
                  locationName: _report.locationName!,
                  coordinate: _report.locationDetail ?? '-0.914203, 100.461021',
                ),
                const SizedBox(height: 16),
              ],

              // Konten Laporan Konsisten (Judul, Deskripsi Lengkap, Gambar)
              if (_report.title != null) ...[
                Text(
                  _report.title!,
                  style: HomeTextStyles.headlineSm.copyWith(
                    fontWeight: FontWeight.w700,
                    color: AppPalette.textPrimary(context),
                    height: 1.35,
                  ),
                ),
                const SizedBox(height: 12),
              ],

              if (_report.description != null) ...[
                Text(
                  _report.description!,
                  style: HomeTextStyles.bodyMd.copyWith(
                    color: AppPalette.textSecondary(context),
                    height: 1.65,
                  ),
                ),
              ],

              // Media Bukti Laporan (Foto atau Video)
              if (_report.imageUrl != null) ...[
                const SizedBox(height: 16),
                if (isVideoMedia(_report.imageUrl))
                  VideoPlayerBox(
                    videoUrl: _report.imageUrl!,
                    aspectRatio: _report.aspectRatio ?? 16 / 9,
                  )
                else
                  NetworkImageBox(
                    imageUrl: _report.imageUrl!,
                    height: _report.aspectRatio == null ? 260 : null,
                    aspectRatio: _report.aspectRatio,
                    semanticLabel: _report.imageSemanticLabel,
                  ),
              ] else if (_report.contentTitle != null) ...[
                const SizedBox(height: 16),
                OfficialContentBox(
                  icon: _report.contentIcon ?? Icons.campaign,
                  title: _report.contentTitle!,
                  description: _report.contentDescription ?? '',
                ),
              ],

              const SizedBox(height: 24),
              Divider(height: 1, thickness: 1, color: AppPalette.divider(context)),
              const SizedBox(height: 16),

              // Baris Interaksi (Upvote, Bookmark, Share)
              ReportCardFooter(
                upvoteCount: _report.upvoteCount,
                isUpvoted: _report.isUpvoted,
                isBookmarked: _report.isBookmarked,
                timestamp: _report.timeAgoDisplay,
                isEdited: _report.isEdited,
                onUpvoteChanged: _handleUpvote,
                onUpvoteCooldown: _handleUpvoteCooldown,
                onBookmarkChanged: _handleBookmark,
                onSharePressed: _handleShare,
              ),
              const SizedBox(height: 32),
            ],
          ),
        ),
      ),
    );
  }

  /// Header detail: menampilkan nama pengirim dan hanya jam/waktu di bawah nama agar bersih.
  ReportCardHeader _buildHeader() {
    final currentUser = UserProfileRepository.instance.currentUser;
    final isCurrentUser = _report.authorName == currentUser.nama ||
        _report.authorUsername == currentUser.username;
    final effectiveAvatar = isCurrentUser ? currentUser.fotoProfil : _report.authorAvatarUrl;

    final Widget avatar = UserAvatar(
      avatarUrl: effectiveAvatar,
      initials: _report.authorInitials,
      icon: _report.authorIcon,
      backgroundColor: _report.avatarBgColor,
      foregroundColor: _report.avatarFgColor,
    );

    final Widget badge = _report.badgeVariant == BadgeVariant.dot
        ? StatusBadge.dot(
            label: _report.badgeLabel,
            dotColor: _report.badgeDotColor!,
            backgroundColor: _report.badgeBgColor,
            textColor: _report.badgeTextColor,
          )
        : StatusBadge.icon(
            label: _report.badgeLabel,
            icon: _report.badgeIcon!,
            backgroundColor: _report.badgeBgColor,
            textColor: _report.badgeTextColor,
          );

    return ReportCardHeader(
      avatar: avatar,
      displayName: _report.authorName,
      username: null,
      isVerified: _report.isVerified,
      metaIcon: _report.metaIcon,
      metaIconColor: _report.metaIconColor,
      metaText: _report.locationDisplay,
      badge: badge,
      onAuthorTap: _navigateToPublicProfile,
    );
  }
}

/// Kotak tampilan lokasi khusus dengan icon pin melingkar, nama lokasi, dan koordinat GPS.
class _LocationCard extends StatelessWidget {
  const _LocationCard({
    required this.locationName,
    required this.coordinate,
  });

  final String locationName;
  final String coordinate;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: AppPalette.surfaceSubtle(context),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: AppPalette.divider(context),
          width: 1,
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // Circular location icon container
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: HomeColors.primary.withValues(alpha: 0.12),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.location_on,
              color: HomeColors.primary,
              size: 20,
            ),
          ),
          const SizedBox(width: 12),
          // Location text info
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  locationName,
                  style: HomeTextStyles.labelLg.copyWith(
                    fontWeight: FontWeight.w700,
                    color: AppPalette.textPrimary(context),
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  'Koordinat: $coordinate',
                  style: HomeTextStyles.bodySm.copyWith(
                    color: AppPalette.textSecondary(context),
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
