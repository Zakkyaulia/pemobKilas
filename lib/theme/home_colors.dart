import 'package:flutter/material.dart';

/// Color tokens for the KILAS home screen, extracted from the
/// "Kilas Civic Pulse" design system specification (`design/home.md`).
///
/// Naming follows Material 3 convention. Values come directly from
/// the `colors` section of the YAML frontmatter.
abstract final class HomeColors {
  // ── Primary ─────────────────────────────────────────────────────────────
  /// `#0048D4` — primary action triggers, active tab indicators.
  static const Color primary = Color(0xFF0048D4);

  /// `#FFFFFF` — text/icon on primary surfaces.
  static const Color onPrimary = Color(0xFFFFFFFF);

  /// `#1E60FF` — FAB, active upvote, nav highlight.
  static const Color primaryContainer = Color(0xFF1E60FF);

  /// `#F2F2FF` — text/icon on primary-container.
  static const Color onPrimaryContainer = Color(0xFFF2F2FF);

  /// `#B6C4FF` — inverse primary for dark surfaces.
  static const Color inversePrimary = Color(0xFFB6C4FF);

  // ── Secondary ───────────────────────────────────────────────────────────
  /// `#006A61` — environmental/green metrics.
  static const Color secondary = Color(0xFF006A61);

  /// `#FFFFFF`
  static const Color onSecondary = Color(0xFFFFFFFF);

  /// `#86F2E4` — avatar bg for second report card.
  static const Color secondaryContainer = Color(0xFF86F2E4);

  /// `#006F66` — text/icon on secondary-container.
  static const Color onSecondaryContainer = Color(0xFF006F66);

  // ── Tertiary ────────────────────────────────────────────────────────────
  /// `#7A4C00`
  static const Color tertiary = Color(0xFF7A4C00);

  /// `#FFFFFF`
  static const Color onTertiary = Color(0xFFFFFFFF);

  /// `#9C6200`
  static const Color tertiaryContainer = Color(0xFF9C6200);

  /// `#FFF1E4`
  static const Color onTertiaryContainer = Color(0xFFFFF1E4);

  // ── Error ───────────────────────────────────────────────────────────────
  /// `#BA1A1A`
  static const Color error = Color(0xFFBA1A1A);

  /// `#FFFFFF`
  static const Color onError = Color(0xFFFFFFFF);

  /// `#FFDAD6`
  static const Color errorContainer = Color(0xFFFFDAD6);

  /// `#93000A`
  static const Color onErrorContainer = Color(0xFF93000A);

  // ── Surface ─────────────────────────────────────────────────────────────
  /// `#F8F9FF` — main screen background.
  static const Color surface = Color(0xFFF8F9FF);

  /// `#CBDBF5`
  static const Color surfaceDim = Color(0xFFCBDBF5);

  /// `#F8F9FF`
  static const Color surfaceBright = Color(0xFFF8F9FF);

  /// `#FFFFFF`
  static const Color surfaceContainerLowest = Color(0xFFFFFFFF);

  /// `#EFF4FF` — info card content box bg.
  static const Color surfaceContainerLow = Color(0xFFEFF4FF);

  /// `#E5EEFF` — dividers, borders between cards.
  static const Color surfaceContainer = Color(0xFFE5EEFF);

  /// `#DCE9FF` — UNAND badge bg, Info Penting badge bg.
  static const Color surfaceContainerHigh = Color(0xFFDCE9FF);

  /// `#D3E4FE`
  static const Color surfaceContainerHighest = Color(0xFFD3E4FE);

  /// `#D3E4FE` — avatar bg for first report card.
  static const Color surfaceVariant = Color(0xFFD3E4FE);

  /// `#004FE5`
  static const Color surfaceTint = Color(0xFF004FE5);

  /// `#0B1C30` — primary text, headings.
  static const Color onSurface = Color(0xFF0B1C30);

  /// `#434656` — body text, descriptions.
  static const Color onSurfaceVariant = Color(0xFF434656);

  /// `#213145` — toast background.
  static const Color inverseSurface = Color(0xFF213145);

  /// `#EAF1FF` — toast text.
  static const Color inverseOnSurface = Color(0xFFEAF1FF);

  // ── Outline ─────────────────────────────────────────────────────────────
  /// `#737687`
  static const Color outline = Color(0xFF737687);

  /// `#C3C5D9`
  static const Color outlineVariant = Color(0xFFC3C5D9);

  // ── Fixed ───────────────────────────────────────────────────────────────
  /// `#DCE1FF`
  static const Color primaryFixed = Color(0xFFDCE1FF);

  /// `#B6C4FF`
  static const Color primaryFixedDim = Color(0xFFB6C4FF);

  /// `#00164F`
  static const Color onPrimaryFixed = Color(0xFF00164F);

  /// `#003BB0`
  static const Color onPrimaryFixedVariant = Color(0xFF003BB0);

  /// `#89F5E7`
  static const Color secondaryFixed = Color(0xFF89F5E7);

  /// `#6BD8CB`
  static const Color secondaryFixedDim = Color(0xFF6BD8CB);

  /// `#00201D`
  static const Color onSecondaryFixed = Color(0xFF00201D);

  /// `#005049`
  static const Color onSecondaryFixedVariant = Color(0xFF005049);

  /// `#FFDDB8` — "Kondisi Kampus" badge bg.
  static const Color tertiaryFixed = Color(0xFFFFDDB8);

  /// `#FFB95F`
  static const Color tertiaryFixedDim = Color(0xFFFFB95F);

  /// `#2A1700`
  static const Color onTertiaryFixed = Color(0xFF2A1700);

  /// `#653E00` — "Kondisi Kampus" badge text.
  static const Color onTertiaryFixedVariant = Color(0xFF653E00);

  // ── Background ──────────────────────────────────────────────────────────
  /// `#F8F9FF`
  static const Color background = Color(0xFFF8F9FF);

  /// `#0B1C30`
  static const Color onBackground = Color(0xFF0B1C30);

  // ── Custom surface tokens ───────────────────────────────────────────────
  /// `#F8FAFC` — device background (Layer 0 canvas).
  static const Color canvasBase = Color(0xFFF8FAFC);

  /// `#F1F5F9` — inset containers, inactive upvote bg.
  static const Color surfaceSubtle = Color(0xFFF1F5F9);

  /// `#FFFFFF` — elevated cards, header/nav glass base.
  static const Color surfacePure = Color(0xFFFFFFFF);

  // ── Status ──────────────────────────────────────────────────────────────
  /// `#EF4444` — Fasilitas Rusak, notification dot.
  static const Color statusFacility = Color(0xFFEF4444);

  /// `#F59E0B` — Kondisi Kampus dot.
  static const Color statusCondition = Color(0xFFF59E0B);

  /// `#1E60FF` — Informasi Penting.
  static const Color statusAnnouncement = Color(0xFF1E60FF);

  /// `#10B981` — Selesai, toast check icon.
  static const Color statusResolved = Color(0xFF10B981);
}

/// [ThemeExtension] for status-category colors that have no
/// equivalent slot in Material [ColorScheme].
///
/// Access via `StatusColors.of(context)`.
@immutable
class StatusColors extends ThemeExtension<StatusColors> {
  const StatusColors({
    required this.facility,
    required this.condition,
    required this.announcement,
    required this.resolved,
  });

  /// Fasilitas Rusak — red.
  final Color facility;

  /// Kondisi Kampus — amber.
  final Color condition;

  /// Informasi Penting — blue.
  final Color announcement;

  /// Selesai — emerald.
  final Color resolved;

  /// Default light-theme instance.
  static const StatusColors light = StatusColors(
    facility: HomeColors.statusFacility,
    condition: HomeColors.statusCondition,
    announcement: HomeColors.statusAnnouncement,
    resolved: HomeColors.statusResolved,
  );

  /// Convenience accessor from [BuildContext].
  static StatusColors of(BuildContext context) =>
      Theme.of(context).extension<StatusColors>()!;

  @override
  StatusColors copyWith({
    Color? facility,
    Color? condition,
    Color? announcement,
    Color? resolved,
  }) {
    return StatusColors(
      facility: facility ?? this.facility,
      condition: condition ?? this.condition,
      announcement: announcement ?? this.announcement,
      resolved: resolved ?? this.resolved,
    );
  }

  @override
  StatusColors lerp(StatusColors? other, double t) {
    if (other is! StatusColors) return this;
    return StatusColors(
      facility: Color.lerp(facility, other.facility, t)!,
      condition: Color.lerp(condition, other.condition, t)!,
      announcement: Color.lerp(announcement, other.announcement, t)!,
      resolved: Color.lerp(resolved, other.resolved, t)!,
    );
  }
}
