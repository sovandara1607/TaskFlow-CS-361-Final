import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'auth_service.dart';

/// Manages authentication state with token persistence via SharedPreferences.
class AuthProvider extends ChangeNotifier {
  static const _keyToken = 'auth_token';
  static const _keyUserName = 'auth_user_name';
  static const _keyUserEmail = 'auth_user_email';
  static const _keyUserId = 'auth_user_id';

  final AuthService _authService = AuthService();

  String? _token;
  String? _userName;
  String? _userEmail;
  int? _userId;
  bool _isLoading = false;

  String? get token => _token;
  String? get userName => _userName;
  String? get userEmail => _userEmail;
  int? get userId => _userId;
  bool get isAuthenticated => _token != null;
  bool get isLoading => _isLoading;

  // ── Try auto-login from stored token ──
  Future<bool> tryAutoLogin() async {
    final prefs = await SharedPreferences.getInstance();
    final storedToken = prefs.getString(_keyToken);

    if (storedToken == null) return false;

    try {
      // Validate token by calling /user
      final userData = await _authService.getUser(storedToken);
      _token = storedToken;
      final user = userData['data'] as Map<String, dynamic>;
      _userName = user['username'] as String?;
      _userEmail = user['email'] as String?;
      _userId = user['id'] as int?;
      notifyListeners();
      return true;
    } catch (_) {
      // Token is invalid, clear it
      await _clearStoredAuth();
      return false;
    }
  }

  // ── Register ──
  Future<void> register({
    required String name,
    required String email,
    required String password,
    required String passwordConfirmation,
  }) async {
    _isLoading = true;
    notifyListeners();

    try {
      final data = await _authService.register(
        name: name,
        email: email,
        password: password,
        passwordConfirmation: passwordConfirmation,
      );

      final inner = data['data'] as Map<String, dynamic>;
      _token = inner['token'] as String;
      final user = inner['user'] as Map<String, dynamic>;
      _userName = user['username'] as String?;
      _userEmail = user['email'] as String?;
      _userId = user['id'] as int?;

      await _persistAuth();
      notifyListeners();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // ── Login ──
  Future<void> login({required String email, required String password}) async {
    _isLoading = true;
    notifyListeners();

    try {
      final data = await _authService.login(email: email, password: password);

      final inner = data['data'] as Map<String, dynamic>;
      _token = inner['token'] as String;
      final user = inner['user'] as Map<String, dynamic>;
      _userName = user['username'] as String?;
      _userEmail = user['email'] as String?;
      _userId = user['id'] as int?;

      await _persistAuth();
      notifyListeners();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // ── GitHub Login ──
  Future<void> githubLogin(String accessToken) async {
    _isLoading = true;
    notifyListeners();

    try {
      final data = await _authService.githubLogin(accessToken);

      final inner = data['data'] as Map<String, dynamic>;
      _token = inner['token'] as String;
      final user = inner['user'] as Map<String, dynamic>;
      _userName = user['username'] as String?;
      _userEmail = user['email'] as String?;
      _userId = user['id'] as int?;

      await _persistAuth();
      notifyListeners();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // ── Login with existing token (from GitHub OAuth deep link) ──
  Future<void> loginWithToken(String token) async {
    _isLoading = true;
    notifyListeners();

    try {
      _token = token;
      final userData = await _authService.getUser(token);
      final user = userData['data'] as Map<String, dynamic>;
      _userName = user['username'] as String?;
      _userEmail = user['email'] as String?;
      _userId = user['id'] as int?;

      await _persistAuth();
      notifyListeners();
    } catch (e) {
      _token = null;
      rethrow;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // ── Logout ──
  Future<void> logout() async {
    if (_token != null) {
      try {
        await _authService.logout(_token!);
      } catch (_) {
        // Even if API call fails, clear local state
      }
    }

    _token = null;
    _userName = null;
    _userEmail = null;
    _userId = null;
    await _clearStoredAuth();
    notifyListeners();
  }

  // ── Persist token and user info ──
  Future<void> _persistAuth() async {
    final prefs = await SharedPreferences.getInstance();
    if (_token != null) await prefs.setString(_keyToken, _token!);
    if (_userName != null) await prefs.setString(_keyUserName, _userName!);
    if (_userEmail != null) await prefs.setString(_keyUserEmail, _userEmail!);
    if (_userId != null) await prefs.setInt(_keyUserId, _userId!);
  }

  // ── Clear stored auth data ──
  Future<void> _clearStoredAuth() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_keyToken);
    await prefs.remove(_keyUserName);
    await prefs.remove(_keyUserEmail);
    await prefs.remove(_keyUserId);
  }
}
