import 'package:flutter/material.dart';

import '../../theme/home_colors.dart';
import '../../theme/home_text_styles.dart';

/// Gap between avatar and text column (Tailwind `gap-2.5` = 10px).
const double _kAvatarGap = 10;

/// Gap between name and username (Tailwind `gap-1.5` = 6px).
const double _kNameUsernameGap = 6;

/// Gap between name and verified icon (Tailwind `gap-1` = 4px).
const double _kNameVerifiedGap = 4;

/// Gap between meta icon and text (Tailwind `gap-1` = 4px).
const double _kMetaGap = 4;

/// Outer gap between left content and badge (Tailwind `gap-2` = 8px).
const double _kOuterGap = 8;

/// Name font size override (HTML `text-[15px]`).
const double _kNameFontSize = 15;

/// Meta icon size (HTML `text-[13px]`).
const double _kMetaIconSize = 13;

/// Verified check icon size (HTML `text-[15px]`).
const double _kVerifiedIconSize = 15;

/// Top row of a report / info card showing author identity,
/// location + timestamp metadata, and a status badge.
///
/// Works for both regular user reports and official announcements
/// by toggling [username] vs [isVerified].
class ReportCardHeader extends StatelessWidget {
  const ReportCardHeader({
    super.key,
    required this.avatar,
    required this.displayName,
    this.username,
    this.isVerified = false,
    required this.metaIcon,
    this.metaIconColor = HomeColors.primary,
    required this.metaText,
    required this.badge,
  });

  /// Leading avatar widget ([UserAvatar]).
  final Widget avatar;

  /// Author display name.
  final String displayName;

  /// Handle like "@zakkyaldrin" — shown for regular users.
  final String? username;

  /// When `true`, a filled [Icons.check_circle] is shown after the name.
  final bool isVerified;

  /// Icon shown before [metaText] (e.g. [Icons.location_on]).
  final IconData metaIcon;

  /// Color of [metaIcon].
  final Color metaIconColor;

  /// Location + timestamp string (e.g. "Gedung GKB C • 15m lalu").
  final String metaText;

  /// Trailing status badge widget ([StatusBadge]).
  final Widget badge;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              avatar,
              const SizedBox(width: _kAvatarGap),
              Expanded(child: _NameMetaColumn(header: this)),
            ],
          ),
        ),
        const SizedBox(width: _kOuterGap),
        badge,
      ],
    );
  }
}

/// Name + meta lines displayed next to the avatar.
class _NameMetaColumn extends StatelessWidget {
  const _NameMetaColumn({required this.header});

  final ReportCardHeader header;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        _NameRow(header: header),
        const SizedBox(height: 2),
        _MetaRow(
          icon: header.metaIcon,
          iconColor: header.metaIconColor,
          text: header.metaText,
        ),
      ],
    );
  }
}

/// First line: display name + optional @username or verified badge.
class _NameRow extends StatelessWidget {
  const _NameRow({required this.header});

  final ReportCardHeader header;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Flexible(
          child: Text(
            header.displayName,
            style: HomeTextStyles.headlineSm.copyWith(
              fontSize: _kNameFontSize,
              fontWeight: FontWeight.w700,
              color: HomeColors.onSurface,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ),
        if (header.isVerified) ...[
          const SizedBox(width: _kNameVerifiedGap),
          const Icon(
            Icons.check_circle,
            size: _kVerifiedIconSize,
            color: HomeColors.primary,
          ),
        ],
        if (header.username != null) ...[
          const SizedBox(width: _kNameUsernameGap),
          Flexible(
            child: Text(
              header.username!,
              style: HomeTextStyles.labelSm.copyWith(
                color: HomeColors.onSurfaceVariant,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ],
    );
  }
}

/// Second line: location/schedule icon + descriptive text.
class _MetaRow extends StatelessWidget {
  const _MetaRow({
    required this.icon,
    required this.iconColor,
    required this.text,
  });

  final IconData icon;
  final Color iconColor;
  final String text;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, size: _kMetaIconSize, color: iconColor),
        const SizedBox(width: _kMetaGap),
        Expanded(
          child: Text(
            text,
            style: HomeTextStyles.bodySm.copyWith(
              color: HomeColors.onSurfaceVariant,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }
}
