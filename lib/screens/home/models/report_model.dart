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

/// Standard categories for reports in KILAS.
abstract final class ReportCategories {
  /// Category label for campus condition issues ("Kondisi Kampus").
  static const String kondisiKampus = 'Kondisi Kampus';

  /// Standard category label for important announcements/info ("Info Penting").
  static const String infoPenting = 'Info Penting';

  /// Alternative label used in search/filter ("Informasi Penting").
  static const String informasiPenting = 'Informasi Penting';

  /// Helper to check if a badge label matches "Info Penting" / "Informasi Penting".
  static bool isImportantInfo(String? label) {
    return label == infoPenting || label == informasiPenting;
  }

  /// Helper to check if a badge label matches "Kondisi Kampus".
  static bool isCampusCondition(String? label) {
    return label == kondisiKampus;
  }
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

  /// Membuat [ReportModel] dari Map/SQLite/JSON.
  factory ReportModel.fromMap(Map<String, dynamic> map) {
    final cTypeStr = (map['card_type'] ?? map['cardType'] ?? 'report').toString();
    final cardType = cTypeStr == 'official' ? CardType.official : CardType.report;

    final bVariantStr = (map['badge_variant'] ?? map['badgeVariant'] ?? 'dot').toString();
    final badgeVariant = bVariantStr == 'icon' ? BadgeVariant.icon : BadgeVariant.dot;

    DateTime? parseDate(dynamic val) {
      if (val == null) return null;
      if (val is DateTime) return val;
      return DateTime.tryParse(val.toString());
    }

    return ReportModel(
      id: (map['id'] ?? '').toString(),
      cardType: cardType,
      authorName: (map['author_name'] ?? map['authorName'] ?? 'Warga Kampus').toString(),
      authorUsername: map['author_username'] ?? map['authorUsername'],
      authorInitials: map['author_initials'] ?? map['authorInitials'],
      authorAvatarUrl: map['author_avatar_url'] ?? map['authorAvatarUrl'],
      avatarBgColor: const Color(0xFFE2E8F0),
      avatarFgColor: const Color(0xFF006A61),
      isVerified: map['is_verified'] ?? map['isVerified'] ?? false,
      metaIcon: Icons.location_on_rounded,
      metaIconColor: const Color(0xFF006A61),
      metaText: (map['meta_text'] ?? map['metaText'] ?? 'UNAND').toString(),
      locationName: map['location_name'] ?? map['locationName'],
      locationDetail: map['location_detail'] ?? map['locationDetail'],
      timestamp: map['timestamp'],
      createdAt: parseDate(map['created_at'] ?? map['createdAt']),
      editedAt: parseDate(map['edited_at'] ?? map['editedAt']),
      badgeLabel: (map['badge_label'] ?? map['badgeLabel'] ?? 'Fasilitas').toString(),
      badgeVariant: badgeVariant,
      badgeBgColor: const Color(0xFFECFDF5),
      badgeTextColor: const Color(0xFF059669),
      title: map['title'],
      description: map['description'],
      imageUrl: map['image_url'] ?? map['imageUrl'],
      contentTitle: map['content_title'] ?? map['contentTitle'],
      contentDescription: map['content_description'] ?? map['contentDescription'],
      upvoteCount: (map['upvote_count'] ?? map['upvoteCount'] ?? 0) is int
          ? (map['upvote_count'] ?? map['upvoteCount'] ?? 0) as int
          : int.tryParse((map['upvote_count'] ?? map['upvoteCount'] ?? 0).toString()) ?? 0,
      isUpvoted: map['is_upvoted'] ?? map['isUpvoted'] ?? false,
      isBookmarked: map['is_bookmarked'] ?? map['isBookmarked'] ?? false,
    );
  }

  /// Membuat [ReportModel] dari format JSON (alias untuk [fromMap]).
  factory ReportModel.fromJson(Map<String, dynamic> json) => ReportModel.fromMap(json);

  /// Mengonversi [ReportModel] menjadi format Map (untuk SQLite atau manipulasi objek).
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'card_type': cardType.name,
      'author_name': authorName,
      'author_username': authorUsername,
      'author_initials': authorInitials,
      'author_avatar_url': authorAvatarUrl,
      'is_verified': isVerified,
      'meta_text': metaText,
      'location_name': locationName,
      'location_detail': locationDetail,
      'timestamp': timestamp,
      'created_at': createdAt?.toIso8601String(),
      'edited_at': editedAt?.toIso8601String(),
      'badge_label': badgeLabel,
      'badge_variant': badgeVariant.name,
      'title': title,
      'description': description,
      'image_url': imageUrl,
      'content_title': contentTitle,
      'content_description': contentDescription,
      'upvote_count': upvoteCount,
      'is_upvoted': isUpvoted,
      'is_bookmarked': isBookmarked,
    };
  }

  /// Mengonversi [ReportModel] menjadi format Map/JSON untuk dikirim ke API backend (alias [toMap]).
  Map<String, dynamic> toJson() => toMap();
}

