import 'package:flutter/material.dart';

/// Centralized border radius tokens for the KILAS app.
///
/// Use these constants for consistent component rounding
/// across cards, buttons, inputs, and containers.
abstract final class AppRadius {
  /// 8.0 — small radius: input fields, small cards.
  static const double small = 8.0;

  /// 12.0 — medium radius: cards, dialogs.
  static const double medium = 12.0;

  /// 16.0 — large radius: major cards, modals.
  static const double large = 16.0;

  /// 24.0 — extra large radius: feature cards, hero sections.
  static const double xlarge = 24.0;

  /// 100.0 — fully rounded: pills, circular badges.
  static const double full = 100.0;

  // ── Pre-built BorderRadius ──────────────────────────────────────────────
  static final BorderRadius smallAll = BorderRadius.circular(small);
  static final BorderRadius mediumAll = BorderRadius.circular(medium);
  static final BorderRadius largeAll = BorderRadius.circular(large);
  static final BorderRadius xlargeAll = BorderRadius.circular(xlarge);
  static final BorderRadius fullAll = BorderRadius.circular(full);
}
