import 'package:flutter/material.dart';

/// Application‑wide constants.
class AppConstants {
  // ── Colors ──
  static const Color primaryColor = Color(0xFF4A6CF7);
  static const Color accentColor = Color(0xFF03DAC6);
  static const Color successColor = Color(0xFF22C55E);
  static const Color warningColor = Color(0xFFF59E0B);
  static const Color errorColor = Color(0xFFEF4444);
  static const Color surfaceColor = Color(0xFFF8FAFC);

  // ── Strings ──
  static const String appName = 'TaskFlow';

  // ── Padding / Radius ──
  static const double defaultPadding = 16.0;
  static const double defaultRadius = 12.0;

  // ── Status Colors ──
  static Color statusColor(String status) {
    switch (status) {
      case 'in_progress':
        return warningColor;
      case 'completed':
        return successColor;
      default:
        return primaryColor;
    }
  }

  // ── Status Icons ──
  static IconData statusIcon(String status) {
    switch (status) {
      case 'in_progress':
        return Icons.timelapse_rounded;
      case 'completed':
        return Icons.check_circle_rounded;
      default:
        return Icons.radio_button_unchecked;
    }
  }
}
