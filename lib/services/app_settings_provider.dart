import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Manages app-wide settings: theme, language, notifications, biometrics, profile.
/// All preferences are persisted via SharedPreferences.
class AppSettingsProvider extends ChangeNotifier {
  static const _keyThemeMode = 'theme_mode';
  static const _keyLocale = 'locale';
  static const _keyNotifications = 'notifications';
  static const _keyBiometrics = 'biometrics';
  static const _keyUserName = 'user_name';
  static const _keyUserEmail = 'user_email';
  static const _keyUserPhone = 'user_phone';

  ThemeMode _themeMode = ThemeMode.light;
  String _locale = 'en';
  bool _notificationsEnabled = true;
  bool _biometricsEnabled = false;
  String _userName = 'Dara Student';
  String _userEmail = 'dara@university.edu';
  String _userPhone = '+855 12 345 678';

  ThemeMode get themeMode => _themeMode;
  bool get isDarkMode => _themeMode == ThemeMode.dark;
  String get locale => _locale;
  bool get notificationsEnabled => _notificationsEnabled;
  bool get biometricsEnabled => _biometricsEnabled;
  String get userName => _userName;
  String get userEmail => _userEmail;
  String get userPhone => _userPhone;

  /// Load all saved preferences.
  Future<void> loadSettings() async {
    final prefs = await SharedPreferences.getInstance();
    final themeIndex = prefs.getInt(_keyThemeMode) ?? 1; // default light
    _themeMode = ThemeMode.values[themeIndex.clamp(0, 2)];
    _locale = prefs.getString(_keyLocale) ?? 'en';
    _notificationsEnabled = prefs.getBool(_keyNotifications) ?? true;
    _biometricsEnabled = prefs.getBool(_keyBiometrics) ?? false;
    _userName = prefs.getString(_keyUserName) ?? 'Dara Student';
    _userEmail = prefs.getString(_keyUserEmail) ?? 'dara@university.edu';
    _userPhone = prefs.getString(_keyUserPhone) ?? '+855 12 345 678';
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

  // ── Profile ──
  Future<void> updateProfile({
    required String name,
    required String email,
    required String phone,
  }) async {
    _userName = name;
    _userEmail = email;
    _userPhone = phone;
    notifyListeners();
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_keyUserName, name);
    await prefs.setString(_keyUserEmail, email);
    await prefs.setString(_keyUserPhone, phone);
  }

  /// Helper to translate using the current locale.
  String tr(String key) {
    // Import-free: just uses the locale string to look up from AppLocalizations
    // This is called from widgets that also import AppLocalizations
    return key;
  }
}
