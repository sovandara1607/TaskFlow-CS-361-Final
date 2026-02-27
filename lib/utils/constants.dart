import 'package:flutter/material.dart';

/// Application‑wide constants.
class AppConstants {
  // ── Primary palette (dark grey) ──
  static const Color primaryColor = Color(0xFF424242);
  static const Color primaryLight = Color(0xFF757575);
  static const Color primaryDark = Color(0xFF212121);

  // ── Backgrounds ──
  static const Color backgroundColor = Color(0xFFF5F5F5);
  static const Color surfaceColor = Color(0xFFFFFFFF);
  static const Color cardColor = Color(0xFFFFFFFF);

  // ── Dark mode backgrounds ──
  static const Color darkBackground = Color(0xFF1A1A1A);
  static const Color darkSurface = Color(0xFF2C2C2C);
  static const Color darkCard = Color(0xFF363636);

  // ── Pastel accents ──
  static const Color accentPink = Color(0xFFF0C6DB);
  static const Color accentMint = Color(0xFFA8E6CF);
  static const Color accentPeach = Color(0xFFFFD3B6);
  static const Color accentLavender = Color(0xFFBDBDBD);
  static const Color accentSky = Color(0xFFB6D8F2);

  // ── Semantic colors ──
  static const Color successColor = Color(0xFF6BCB77);
  static const Color warningColor = Color(0xFFFFB347);
  static const Color errorColor = Color(0xFFFF6B6B);

  // ── Text colors ──
  static const Color textPrimary = Color(0xFF1C1C1E);
  static const Color textSecondary = Color(0xFF8E8E93);
  static const Color textLight = Color(0xFFAEAEB2);

  // ── Strings ──
  static const String appName = 'TaskFlow';

  // ── Padding / Radius ──
  static const double defaultPadding = 20.0;
  static const double cardRadius = 20.0;
  static const double defaultRadius = 16.0;

  // ── Status colours ──
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

  // ── Status card background (pastel) ──
  static Color statusBgColor(String status) {
    switch (status) {
      case 'in_progress':
        return accentPeach;
      case 'completed':
        return accentMint;
      default:
        return accentLavender;
    }
  }

  // ── Status icons ──
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

  // ── Category helpers ──
  static const List<String> categories = [
    'general',
    'school',
    'work',
    'home',
    'personal',
  ];

  static IconData categoryIcon(String category) {
    switch (category) {
      case 'school':
        return Icons.school_rounded;
      case 'work':
        return Icons.work_outline_rounded;
      case 'home':
        return Icons.home_outlined;
      case 'personal':
        return Icons.person_outline_rounded;
      default:
        return Icons.folder_outlined;
    }
  }

  static Color categoryColor(String category) {
    switch (category) {
      case 'school':
        return accentSky;
      case 'work':
        return accentPeach;
      case 'home':
        return accentMint;
      case 'personal':
        return accentPink;
      default:
        return accentLavender;
    }
  }

  static String categoryLabel(String category) {
    switch (category) {
      case 'school':
        return 'School';
      case 'work':
        return 'Work';
      case 'home':
        return 'Home';
      case 'personal':
        return 'Personal';
      default:
        return 'General';
    }
  }

  /// Get card/surface color based on brightness
  static Color cardColorFor(BuildContext context) {
    return Theme.of(context).brightness == Brightness.dark
        ? darkCard
        : cardColor;
  }

  static Color bgColorFor(BuildContext context) {
    return Theme.of(context).brightness == Brightness.dark
        ? darkBackground
        : backgroundColor;
  }
}
