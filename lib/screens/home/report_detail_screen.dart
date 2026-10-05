import 'package:flutter/material.dart';

import '../../theme/app_spacing.dart';
import '../../theme/home_colors.dart';
import '../../theme/home_text_styles.dart';
import '../../widgets/home/network_image_box.dart';
import '../../widgets/home/official_content_box.dart';
import '../../widgets/home/report_card_footer.dart';
import '../../widgets/home/report_card_header.dart';
import '../../widgets/home/status_badge.dart';
import '../../widgets/home/user_avatar.dart';
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
    // 2. State update & 3. Validation
    setState(() {
      _report = _report.copyWith(
        isUpvoted: isUpvoted,
        upvoteCount: count,
      );
    });

    // 4. Feedback: SnackBar
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          content: Row(
            children: [
              Icon(
                isUpvoted ? Icons.thumb_up : Icons.thumb_up_alt_outlined,
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

  void _handleShare() {
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
        backgroundColor: HomeColors.surfacePure,
        appBar: AppBar(
          backgroundColor: HomeColors.surfacePure,
          elevation: 0,
          scrolledUnderElevation: 1,
          leading: IconButton(
            icon: const Icon(
              Icons.arrow_back_ios_new,
              size: 20,
              color: HomeColors.onSurface,
            ),
            onPressed: () => Navigator.pop(context, _report),
          ),
          title: Text(
            'Detail Laporan',
            style: HomeTextStyles.headlineSm.copyWith(
              fontWeight: FontWeight.w700,
              color: HomeColors.onSurface,
            ),
          ),
          centerTitle: true,
          actions: [
            IconButton(
              icon: const Icon(Icons.share_outlined, color: HomeColors.onSurface),
              onPressed: _handleShare,
            ),
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
                    color: HomeColors.onSurface,
                    height: 1.35,
                  ),
                ),
                const SizedBox(height: 12),
              ],

              if (_report.description != null) ...[
                Text(
                  _report.description!,
                  style: HomeTextStyles.bodyMd.copyWith(
                    color: HomeColors.onSurfaceVariant,
                    height: 1.65,
                  ),
                ),
              ],

              // Gambar Bukti Laporan (Jika Ada)
              if (_report.imageUrl != null) ...[
                const SizedBox(height: 16),
                NetworkImageBox(
                  imageUrl: _report.imageUrl!,
                  height: 260,
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
              const Divider(height: 1, thickness: 1, color: HomeColors.surfaceContainer),
              const SizedBox(height: 16),

              // Baris Interaksi (Upvote, Bookmark, Share)
              ReportCardFooter(
                upvoteCount: _report.upvoteCount,
                isUpvoted: _report.isUpvoted,
                onUpvoteChanged: _handleUpvote,
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
    final Widget avatar = _report.authorInitials != null
        ? UserAvatar(
            initials: _report.authorInitials,
            backgroundColor: _report.avatarBgColor,
            foregroundColor: _report.avatarFgColor,
          )
        : UserAvatar(
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
      username: _report.authorUsername,
      isVerified: _report.isVerified,
      metaIcon: Icons.schedule,
      metaIconColor: HomeColors.onSurfaceVariant,
      metaText: _report.timestamp ?? _report.metaText,
      badge: badge,
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
        color: HomeColors.surfaceSubtle,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: HomeColors.surfaceContainer,
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
                    color: HomeColors.onSurface,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  'Koordinat: $coordinate',
                  style: HomeTextStyles.bodySm.copyWith(
                    color: HomeColors.onSurfaceVariant,
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
