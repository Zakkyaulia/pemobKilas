import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// Typography tokens for the KILAS home screen, extracted from the
/// "Kilas Civic Pulse" design system specification (`design/home.md`).
///
/// All styles use Plus Jakarta Sans via [GoogleFonts].
/// Letter-spacing values are converted from `em` to `px`:
///   `letterSpacing_px = em_value × fontSize`.
abstract final class HomeTextStyles {
  static TextStyle _base({
    required double fontSize,
    required FontWeight fontWeight,
    required double lineHeight,
    double? letterSpacing,
    Color? color,
  }) {
    return GoogleFonts.plusJakartaSans(
      fontSize: fontSize,
      fontWeight: fontWeight,
      height: lineHeight / fontSize,
      letterSpacing: letterSpacing,
      color: color,
    );
  }

  // ── Display ─────────────────────────────────────────────────────────────

  /// 32px / w800 / 40px / -0.96px (-0.03em × 32).
  static TextStyle get displayLg => _base(
        fontSize: 32,
        fontWeight: FontWeight.w800,
        lineHeight: 40,
        letterSpacing: -0.96,
      );

  // ── Headlines ───────────────────────────────────────────────────────────

  /// 24px / w700 / 32px / -0.48px (-0.02em × 24).
  static TextStyle get headlineLg => _base(
        fontSize: 24,
        fontWeight: FontWeight.w700,
        lineHeight: 32,
        letterSpacing: -0.48,
      );

  /// 20px / w700 / 28px / -0.30px (-0.015em × 20).
  static TextStyle get headlineMd => _base(
        fontSize: 20,
        fontWeight: FontWeight.w700,
        lineHeight: 28,
        letterSpacing: -0.30,
      );

  /// 18px / w600 / 24px / no letter-spacing.
  static TextStyle get headlineSm => _base(
        fontSize: 18,
        fontWeight: FontWeight.w600,
        lineHeight: 24,
      );

  // ── Body ────────────────────────────────────────────────────────────────

  /// 16px / w400 / 24px.
  static TextStyle get bodyLg => _base(
        fontSize: 16,
        fontWeight: FontWeight.w400,
        lineHeight: 24,
      );

  /// 14px / w400 / 20px.
  static TextStyle get bodyMd => _base(
        fontSize: 14,
        fontWeight: FontWeight.w400,
        lineHeight: 20,
      );

  /// 12px / w400 / 16px.
  static TextStyle get bodySm => _base(
        fontSize: 12,
        fontWeight: FontWeight.w400,
        lineHeight: 16,
      );

  // ── Labels ──────────────────────────────────────────────────────────────

  /// 14px / w600 / 20px / 0.14px (0.01em × 14).
  static TextStyle get labelLg => _base(
        fontSize: 14,
        fontWeight: FontWeight.w600,
        lineHeight: 20,
        letterSpacing: 0.14,
      );

  /// 12px / w600 / 16px / 0.24px (0.02em × 12).
  static TextStyle get labelMd => _base(
        fontSize: 12,
        fontWeight: FontWeight.w600,
        lineHeight: 16,
        letterSpacing: 0.24,
      );

  /// 10px / w700 / 14px / 0.40px (0.04em × 10).
  static TextStyle get labelSm => _base(
        fontSize: 10,
        fontWeight: FontWeight.w700,
        lineHeight: 14,
        letterSpacing: 0.40,
      );
}
