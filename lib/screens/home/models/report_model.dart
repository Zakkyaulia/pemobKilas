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
}
