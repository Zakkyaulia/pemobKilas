import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import 'app_colors.dart';

/// Centralized typography tokens for the KILAS app.
///
/// All text styles use Plus Jakarta Sans as specified in the Figma design.
/// Values (size, weight, line-height) are extracted from the design spec.
abstract final class AppTextStyles {
  // ── Base font family ────────────────────────────────────────────────────
  static String get _fontFamily => GoogleFonts.plusJakartaSans().fontFamily!;

  static TextStyle _base({
    required double fontSize,
    required FontWeight fontWeight,
    required double height,
    Color? color,
  }) {
    return GoogleFonts.plusJakartaSans(
      fontSize: fontSize,
      fontWeight: fontWeight,
      height: height / fontSize, // Flutter height = lineHeight / fontSize
      color: color ?? AppColors.textPrimary,
    );
  }

  // ── Headings ────────────────────────────────────────────────────────────
  /// KILAS heading — 26px, bold (w700), line-height 32px.
  static TextStyle get heading =>
      _base(fontSize: 26, fontWeight: FontWeight.w700, height: 32);

  /// Section heading — 20px, semi-bold (w600), line-height 28px.
  static TextStyle get sectionHeading =>
      _base(fontSize: 20, fontWeight: FontWeight.w600, height: 28);

  // ── Body ────────────────────────────────────────────────────────────────
  /// Supporting text / description — 14px, regular (w400), line-height 20px.
  static TextStyle get body => _base(
    fontSize: 14,
    fontWeight: FontWeight.w400,
    height: 20,
    color: AppColors.textSecondary,
  );

  /// Body small — 12px, regular (w400), line-height 16px.
  static TextStyle get bodySmall => _base(
    fontSize: 12,
    fontWeight: FontWeight.w400,
    height: 16,
    color: AppColors.textMuted,
  );

  // ── Labels ──────────────────────────────────────────────────────────────
  /// Form label — 12px, semi-bold (w600), line-height 16px.
  static TextStyle get label =>
      _base(fontSize: 12, fontWeight: FontWeight.w600, height: 16);

  /// Toggle / Tab label — 14px, semi-bold (w600), line-height 20px.
  static TextStyle get toggleLabel =>
      _base(fontSize: 14, fontWeight: FontWeight.w600, height: 20);

  // ── Input ───────────────────────────────────────────────────────────────
  /// Input text — 14px, regular (w400), line-height 20px.
  static TextStyle get input =>
      _base(fontSize: 14, fontWeight: FontWeight.w400, height: 20);

  /// Input hint — 14px, regular (w400), line-height 20px, muted color.
  static TextStyle get inputHint => _base(
    fontSize: 14,
    fontWeight: FontWeight.w400,
    height: 20,
    color: AppColors.textMuted,
  );

  // ── Buttons ─────────────────────────────────────────────────────────────
  /// CTA button text — 18px, semi-bold (w600), line-height 24px.
  static TextStyle get button => _base(
    fontSize: 18,
    fontWeight: FontWeight.w600,
    height: 24,
    color: AppColors.onPrimary,
  );

  // ── Links / Secondary ──────────────────────────────────────────────────
  /// Link text — 14px, semi-bold (w600), line-height 20px, primary blue.
  static TextStyle get link => _base(
    fontSize: 14,
    fontWeight: FontWeight.w600,
    height: 20,
    color: AppColors.primaryBlue,
  );

  /// Caption — 12px, medium (w500), line-height 16px, muted.
  static TextStyle get caption => _base(
    fontSize: 12,
    fontWeight: FontWeight.w500,
    height: 16,
    color: AppColors.textMuted,
  );

  /// Getter for the font family name (for ThemeData).
  static String get fontFamily => _fontFamily;
}
