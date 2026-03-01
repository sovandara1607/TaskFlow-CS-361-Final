import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../services/app_settings_provider.dart';

class AppFonts {
  /// Returns a full TextTheme using the correct font for the given locale.
  static TextTheme textTheme(String locale, [TextTheme? base]) {
    if (locale == 'km') {
      return GoogleFonts.kantumruyProTextTheme(base);
    }
    return GoogleFonts.poppinsTextTheme(base);
  }

  /// Returns a TextStyle with the correct font for the given locale.
  static TextStyle style(
    String locale, {
    double? fontSize,
    FontWeight? fontWeight,
    Color? color,
    double? letterSpacing,
    double? height,
    TextDecoration? decoration,
    Color? decorationColor,
  }) {
    if (locale == 'km') {
      return GoogleFonts.kantumruyPro(
        fontSize: fontSize,
        fontWeight: fontWeight,
        color: color,
        letterSpacing: letterSpacing,
        height: height,
        decoration: decoration,
        decorationColor: decorationColor,
      );
    }
    return GoogleFonts.poppins(
      fontSize: fontSize,
      fontWeight: fontWeight,
      color: color,
      letterSpacing: letterSpacing,
      height: height,
      decoration: decoration,
      decorationColor: decorationColor,
    );
  }

  /// Convenience: reads locale from the nearest AppSettingsProvider in context.
  static TextStyle of(
    BuildContext context, {
    double? fontSize,
    FontWeight? fontWeight,
    Color? color,
    double? letterSpacing,
    double? height,
    TextDecoration? decoration,
    Color? decorationColor,
  }) {
    final locale = context.read<AppSettingsProvider>().locale;
    return style(
      locale,
      fontSize: fontSize,
      fontWeight: fontWeight,
      color: color,
      letterSpacing: letterSpacing,
      height: height,
      decoration: decoration,
      decorationColor: decorationColor,
    );
  }
}
