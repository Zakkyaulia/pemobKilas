import 'package:flutter/material.dart';
import '../../../../utils/time_utils.dart';

/// Type of card in the home feed.
enum CardType {
  /// Standard user-submitted incident report with optional image.
  report,

  /// Official administrative announcement with a content box.
  official,
}

/// Visual variant of the [StatusBadge] indicator.
enum BadgeVariant {
  /// Small coloured dot (e.g. "Kondisi Kampus").
  dot,

  /// Material icon (e.g. "Info Penting" with campaign icon).
  icon,
}

/// Lightweight UI model representing a single feed item.
///
/// Used by both [ReportCard] and [OfficialInfoCard] widgets.
/// All colour and icon values are Flutter types so this is
/// strictly a presentation-layer model.
class ReportModel {
  const ReportModel({
    required this.id,
    required this.cardType,
    // ── Author ──────────────────────────────────────────────
    required this.authorName,
    this.authorUsername,
    this.authorInitials,
    this.authorIcon,
    this.authorAvatarUrl,
    required this.avatarBgColor,
    required this.avatarFgColor,
    this.isVerified = false,
    // ── Meta ────────────────────────────────────────────────
    required this.metaIcon,
    required this.metaIconColor,
    required this.metaText,
    this.locationName,
    this.locationDetail,
    this.timestamp,
    this.createdAt,
    this.editedAt,
    // ── Badge ───────────────────────────────────────────────
    required this.badgeLabel,
    required this.badgeVariant,
    this.badgeDotColor,
    this.badgeIcon,
    required this.badgeBgColor,
    required this.badgeTextColor,
    // ── Content (report) ────────────────────────────────────
    this.title,
    this.description,
    this.imageUrl,
    this.imageHeight,
    this.aspectRatio,
    this.imageSemanticLabel,
    // ── Content (official) ──────────────────────────────────
    this.contentIcon,
    this.contentTitle,
    this.contentDescription,
    // ── Interaction ─────────────────────────────────────────
    required this.upvoteCount,
    this.isUpvoted = false,
    this.isBookmarked = false,
  });

  final String id;
  final CardType cardType;

  // Author
  final String authorName;
  final String? authorUsername;
  final String? authorInitials;
  final IconData? authorIcon;
  final String? authorAvatarUrl;
  final Color avatarBgColor;
  final Color avatarFgColor;
  final bool isVerified;

  // Meta row & Timestamp (FR-A2)
  final IconData metaIcon;
  final Color metaIconColor;
  final String metaText;
  final String? locationName;
  final String? locationDetail;
  final String? timestamp;
  final DateTime? createdAt;
  final DateTime? editedAt;

  // Badge
  final String badgeLabel;
  final BadgeVariant badgeVariant;
  final Color? badgeDotColor;
  final IconData? badgeIcon;
  final Color badgeBgColor;
  final Color badgeTextColor;

  // Content — report variant
  final String? title;
  final String? description;
  final String? imageUrl;
  final double? imageHeight;
  final double? aspectRatio;
  final String? imageSemanticLabel;

  // Content — official variant
  final IconData? contentIcon;
  final String? contentTitle;
  final String? contentDescription;

  // Interaction
  final int upvoteCount;
  final bool isUpvoted;
  final bool isBookmarked;

  /// Apakah laporan ini pernah diedit (FR-A2 penanda "diedit").
  bool get isEdited => editedAt != null;

  /// Apakah laporan masih dalam batas 24 jam untuk diedit (FR-A2 batas 24 jam).
  bool get canEdit => TimeUtils.canEdit(createdAt);

  /// Sisa waktu sebelum jendela 24 jam edit berakhir.
  Duration get remainingEditDuration => createdAt != null
      ? TimeUtils.remainingEditDuration(createdAt!)
      : const Duration(hours: 24);

  /// String teks sisa waktu edit yang ramah pengguna.
  String get remainingEditText =>
      createdAt != null ? TimeUtils.formatRemainingTime(createdAt!) : '';

  /// Creates a copy of this [ReportModel] with the given fields replaced with new values.
  ReportModel copyWith({
    String? id,
    CardType? cardType,
    String? authorName,
    String? authorUsername,
    String? authorInitials,
    IconData? authorIcon,
    String? authorAvatarUrl,
    Color? avatarBgColor,
    Color? avatarFgColor,
    bool? isVerified,
    IconData? metaIcon,
    Color? metaIconColor,
    String? metaText,
    String? locationName,
    String? locationDetail,
    String? timestamp,
    DateTime? createdAt,
    DateTime? editedAt,
    String? badgeLabel,
    BadgeVariant? badgeVariant,
    Color? badgeDotColor,
    IconData? badgeIcon,
    Color? badgeBgColor,
    Color? badgeTextColor,
    String? title,
    String? description,
    String? imageUrl,
    double? imageHeight,
    double? aspectRatio,
    String? imageSemanticLabel,
    IconData? contentIcon,
    String? contentTitle,
    String? contentDescription,
    int? upvoteCount,
    bool? isUpvoted,
    bool? isBookmarked,
  }) {
    return ReportModel(
      id: id ?? this.id,
      cardType: cardType ?? this.cardType,
      authorName: authorName ?? this.authorName,
      authorUsername: authorUsername ?? this.authorUsername,
      authorInitials: authorInitials ?? this.authorInitials,
      authorIcon: authorIcon ?? this.authorIcon,
      authorAvatarUrl: authorAvatarUrl ?? this.authorAvatarUrl,
      avatarBgColor: avatarBgColor ?? this.avatarBgColor,
      avatarFgColor: avatarFgColor ?? this.avatarFgColor,
      isVerified: isVerified ?? this.isVerified,
      metaIcon: metaIcon ?? this.metaIcon,
      metaIconColor: metaIconColor ?? this.metaIconColor,
      metaText: metaText ?? this.metaText,
      locationName: locationName ?? this.locationName,
      locationDetail: locationDetail ?? this.locationDetail,
      timestamp: timestamp ?? this.timestamp,
      createdAt: createdAt ?? this.createdAt,
      editedAt: editedAt ?? this.editedAt,
      badgeLabel: badgeLabel ?? this.badgeLabel,
      badgeVariant: badgeVariant ?? this.badgeVariant,
      badgeDotColor: badgeDotColor ?? this.badgeDotColor,
      badgeIcon: badgeIcon ?? this.badgeIcon,
      badgeBgColor: badgeBgColor ?? this.badgeBgColor,
      badgeTextColor: badgeTextColor ?? this.badgeTextColor,
      title: title ?? this.title,
      description: description ?? this.description,
      imageUrl: imageUrl ?? this.imageUrl,
      imageHeight: imageHeight ?? this.imageHeight,
      aspectRatio: aspectRatio ?? this.aspectRatio,
      imageSemanticLabel: imageSemanticLabel ?? this.imageSemanticLabel,
      contentIcon: contentIcon ?? this.contentIcon,
      contentTitle: contentTitle ?? this.contentTitle,
      contentDescription: contentDescription ?? this.contentDescription,
      upvoteCount: upvoteCount ?? this.upvoteCount,
      isUpvoted: isUpvoted ?? this.isUpvoted,
      isBookmarked: isBookmarked ?? this.isBookmarked,
    );
  }

  /// Mengambil bagian nama lokasi saja (tanpa embel-embel waktu).
  String get locationDisplay {
    if (locationName != null && locationName!.isNotEmpty) {
      return locationName!;
    }
    final parts = metaText.split('•');
    return parts.first.trim();
  }

  /// Waktu relatif murni tanpa penanda '(diedit)'.
  String get rawTimeAgo {
    if (createdAt != null) {
      return TimeUtils.formatTimeAgo(createdAt, isShort: true);
    }
    final parts = metaText.split('•');
    if (parts.length >= 2) {
      return parts.last.trim();
    }
    if (timestamp != null && timestamp!.isNotEmpty) {
      final tParts = timestamp!.split('•');
      return tParts.first.trim();
    }
    return 'Baru saja';
  }

  /// Mengambil bagian waktu/timeline upload dinamis dengan penanda '(diedit)' jika berlaku.
  String get timeAgoDisplay {
    if (createdAt != null) {
      final formatted = TimeUtils.formatTimeAgo(createdAt, isShort: true);
      return isEdited ? '$formatted • (diedit)' : formatted;
    }
    final parts = metaText.split('•');
    String base;
    if (parts.length >= 2) {
      base = parts.last.trim();
    } else if (timestamp != null && timestamp!.isNotEmpty) {
      final tParts = timestamp!.split('•');
      base = tParts.first.trim();
    } else {
      base = 'Baru saja';
    }
    return isEdited && !base.contains('(diedit)') ? '$base • (diedit)' : base;
  }

  /// Mengambil waktu relatif versi lengkap (misal "15 menit yang lalu").
  String get fullTimeAgoDisplay {
    if (createdAt != null) {
      final formatted = TimeUtils.formatTimeAgo(createdAt, isShort: false);
      return isEdited ? '$formatted • (diedit)' : formatted;
    }
    final base = timestamp ?? 'Baru saja';
    return isEdited && !base.contains('(diedit)') ? '$base • (diedit)' : base;
  }
}

