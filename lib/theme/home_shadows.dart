import 'package:flutter/material.dart';

/// Shadow tokens for the KILAS home screen, extracted from the
/// "Kilas Civic Pulse" design system (`design/home.md`).
///
/// Values come from both the elevation spec (Layer 0–3) and the
/// actual CSS `box-shadow` declarations in the HTML reference.
abstract final class HomeShadows {
  // ── Layer 1 — Card surfaces ─────────────────────────────────────────────

  /// Soft ambient shadow for report cards and feed items.
  /// CSS: `0px 4px 20px -2px rgba(15, 23, 42, 0.05)`.
  static const List<BoxShadow> card = [
    BoxShadow(
      color: Color.fromRGBO(15, 23, 42, 0.05),
      offset: Offset(0, 4),
      blurRadius: 20,
      spreadRadius: -2,
    ),
  ];

  // ── Layer 2 — Floating action (blue tint) ───────────────────────────────

  /// Energetic tinted shadow for the FAB "+" button.
  /// CSS: `0 8px 24px -4px rgba(30, 96, 255, 0.45)`.
  static const List<BoxShadow> fabBlue = [
    BoxShadow(
      color: Color.fromRGBO(30, 96, 255, 0.45),
      offset: Offset(0, 8),
      blurRadius: 24,
      spreadRadius: -4,
    ),
  ];

  // ── Layer 3 — Glass surfaces ────────────────────────────────────────────

  /// Header glass shadow.
  /// CSS: `0 1px 8px rgba(0, 0, 0, 0.04)`.
  static const List<BoxShadow> headerGlass = [
    BoxShadow(
      color: Color.fromRGBO(0, 0, 0, 0.04),
      offset: Offset(0, 1),
      blurRadius: 8,
    ),
  ];

  /// Bottom navigation glass shadow.
  /// CSS: `0 -4px 20px rgba(15, 23, 42, 0.06)`.
  static const List<BoxShadow> bottomNavGlass = [
    BoxShadow(
      color: Color.fromRGBO(15, 23, 42, 0.06),
      offset: Offset(0, -4),
      blurRadius: 20,
    ),
  ];

  // ── Utility ─────────────────────────────────────────────────────────────

  /// Small shadow for active upvote pill and info card icon circle.
  /// Tailwind `shadow-sm` ≈ `0 1px 2px rgba(0, 0, 0, 0.05)`.
  static const List<BoxShadow> sm = [
    BoxShadow(
      color: Color.fromRGBO(0, 0, 0, 0.05),
      offset: Offset(0, 1),
      blurRadius: 2,
    ),
  ];

  /// Elevated shadow for toast notification.
  /// Tailwind `shadow-xl` ≈ `0 20px 25px -5px rgba(0,0,0,0.1),
  /// 0 8px 10px -6px rgba(0,0,0,0.1)`.
  static const List<BoxShadow> xl = [
    BoxShadow(
      color: Color.fromRGBO(0, 0, 0, 0.10),
      offset: Offset(0, 20),
      blurRadius: 25,
      spreadRadius: -5,
    ),
    BoxShadow(
      color: Color.fromRGBO(0, 0, 0, 0.10),
      offset: Offset(0, 8),
      blurRadius: 10,
      spreadRadius: -6,
    ),
  ];
}
