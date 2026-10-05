import 'package:flutter/material.dart';

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
    this.imageSemanticLabel,
    // ── Content (official) ──────────────────────────────────
    this.contentIcon,
    this.contentTitle,
    this.contentDescription,
    // ── Interaction ─────────────────────────────────────────
    required this.upvoteCount,
    this.isUpvoted = false,
  });

  final String id;
  final CardType cardType;

  // Author
  final String authorName;
  final String? authorUsername;
  final String? authorInitials;
  final IconData? authorIcon;
  final Color avatarBgColor;
  final Color avatarFgColor;
  final bool isVerified;

  // Meta row
  final IconData metaIcon;
  final Color metaIconColor;
  final String metaText;
  final String? locationName;
  final String? locationDetail;
  final String? timestamp;

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
  final String? imageSemanticLabel;

  // Content — official variant
  final IconData? contentIcon;
  final String? contentTitle;
  final String? contentDescription;

  // Interaction
  final int upvoteCount;
  final bool isUpvoted;

  /// Creates a copy of this [ReportModel] with the given fields replaced with new values.
  ReportModel copyWith({
    String? id,
    CardType? cardType,
    String? authorName,
    String? authorUsername,
    String? authorInitials,
    IconData? authorIcon,
    Color? avatarBgColor,
    Color? avatarFgColor,
    bool? isVerified,
    IconData? metaIcon,
    Color? metaIconColor,
    String? metaText,
    String? locationName,
    String? locationDetail,
    String? timestamp,
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
    String? imageSemanticLabel,
    IconData? contentIcon,
    String? contentTitle,
    String? contentDescription,
    int? upvoteCount,
    bool? isUpvoted,
  }) {
    return ReportModel(
      id: id ?? this.id,
      cardType: cardType ?? this.cardType,
      authorName: authorName ?? this.authorName,
      authorUsername: authorUsername ?? this.authorUsername,
      authorInitials: authorInitials ?? this.authorInitials,
      authorIcon: authorIcon ?? this.authorIcon,
      avatarBgColor: avatarBgColor ?? this.avatarBgColor,
      avatarFgColor: avatarFgColor ?? this.avatarFgColor,
      isVerified: isVerified ?? this.isVerified,
      metaIcon: metaIcon ?? this.metaIcon,
      metaIconColor: metaIconColor ?? this.metaIconColor,
      metaText: metaText ?? this.metaText,
      locationName: locationName ?? this.locationName,
      locationDetail: locationDetail ?? this.locationDetail,
      timestamp: timestamp ?? this.timestamp,
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
      imageSemanticLabel: imageSemanticLabel ?? this.imageSemanticLabel,
      contentIcon: contentIcon ?? this.contentIcon,
      contentTitle: contentTitle ?? this.contentTitle,
      contentDescription: contentDescription ?? this.contentDescription,
      upvoteCount: upvoteCount ?? this.upvoteCount,
      isUpvoted: isUpvoted ?? this.isUpvoted,
    );
  }
}
