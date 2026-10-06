import 'package:flutter/material.dart';

/// Centralized color tokens for the KILAS app.
///
/// All colors are extracted from the Figma design specification.
/// Use these constants instead of hardcoding color values in widgets.
abstract final class AppColors {
  // ── Background ──────────────────────────────────────────────────────────
  /// Primary background color for screens.
  static const Color backgroundPrimary = Color(0xFFF8F9FF);

  // ── Surface ─────────────────────────────────────────────────────────────
  /// Card / elevated surface background.
  static const Color surface = Color(0xFFFFFFFF);

  /// Light blue surface — used for subtle highlighted areas.
  static const Color surfaceLightBlue = Color(0xFFEFF4FF);

  // ── Text ────────────────────────────────────────────────────────────────
  /// Primary text color — headings, titles, important labels.
  static const Color textPrimary = Color(0xFF0B1C30);

  /// Secondary text color — body copy, descriptions.
  static const Color textSecondary = Color(0xFF434656);

  /// Muted text / icon color — placeholders, disabled states.
  static const Color textMuted = Color(0xFF6E7977);

  // ── Brand ───────────────────────────────────────────────────────────────
  /// Primary brand blue — CTA buttons, active indicators.
  static const Color primaryBlue = Color(0xFF0048D4);

  /// Accent cyan — toggle highlight, badges, secondary accent.
  static const Color accentCyan = Color(0xFF89F5E7);

  /// Accent brown/gold — status badges, special labels.
  static const Color accentBrownGold = Color(0xFF734700);

  // ── Semantic ────────────────────────────────────────────────────────────
  /// Error color for form validation.
  static const Color error = Color(0xFFEF4444);

  /// Divider / border color.
  static const Color border = Color(0xFFE0E0E0);

  /// Input field border color.
  static const Color inputBorder = Color(0xFFD0D5DD);

  /// Input field focused border color.
  static const Color inputBorderFocused = Color(0xFF0048D4);

  /// Disabled state overlay.
  static const Color disabled = Color(0xFFBDBDBD);

  /// Button text on primary green.
  static const Color onPrimary = Color(0xFFFFFFFF);
}
