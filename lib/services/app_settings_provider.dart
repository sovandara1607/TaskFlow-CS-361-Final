import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Manages app-wide settings: theme, language, notifications, biometrics, profile.
/// All preferences are persisted via SharedPreferences.
class AppSettingsProvider extends ChangeNotifier {
  static const _keyThemeMode = 'theme_mode';
  static const _keyLocale = 'locale';
  static const _keyNotifications = 'notifications';
  static const _keyBiometrics = 'biometrics';

  ThemeMode _themeMode = ThemeMode.light;
  String _locale = 'en';
  bool _notificationsEnabled = true;
  bool _biometricsEnabled = false;

  ThemeMode get themeMode => _themeMode;
  bool get isDarkMode => _themeMode == ThemeMode.dark;
  String get locale => _locale;
  bool get notificationsEnabled => _notificationsEnabled;
  bool get biometricsEnabled => _biometricsEnabled;

  /// Load all saved preferences.
  Future<void> loadSettings() async {
    final prefs = await SharedPreferences.getInstance();
    final themeIndex = prefs.getInt(_keyThemeMode) ?? 1; // default light
    _themeMode = ThemeMode.values[themeIndex.clamp(0, 2)];
    _locale = prefs.getString(_keyLocale) ?? 'en';
    _notificationsEnabled = prefs.getBool(_keyNotifications) ?? true;
    _biometricsEnabled = prefs.getBool(_keyBiometrics) ?? false;
    notifyListeners();
  }

  // ── Theme ──
  Future<void> setThemeMode(ThemeMode mode) async {
    _themeMode = mode;
    notifyListeners();
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_keyThemeMode, mode.index);
  }

  Future<void> toggleDarkMode(bool isDark) async {
    await setThemeMode(isDark ? ThemeMode.dark : ThemeMode.light);
  }

  // ── Locale ──
  Future<void> setLocale(String locale) async {
    _locale = locale;
    notifyListeners();
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_keyLocale, locale);
  }

  // ── Notifications ──
  Future<void> setNotifications(bool enabled) async {
    _notificationsEnabled = enabled;
    notifyListeners();
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_keyNotifications, enabled);
  }

  // ── Biometrics ──
  Future<void> setBiometrics(bool enabled) async {
    _biometricsEnabled = enabled;
    notifyListeners();
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_keyBiometrics, enabled);
  }

  /// Helper to translate using the current locale.
  String tr(String key) {
    return key;
  }
}
