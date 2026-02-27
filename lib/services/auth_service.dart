import 'dart:convert';
import 'package:http/http.dart' as http;

/// Handles all authentication API calls to the Laravel Sanctum backend.
class AuthService {
  static const String _baseUrl = 'http://127.0.0.1:8000/api';

  // ── Register ──
  Future<Map<String, dynamic>> register({
    required String name,
    required String email,
    required String password,
    required String passwordConfirmation,
  }) async {
    final response = await http.post(
      Uri.parse('$_baseUrl/register'),
      headers: {
        'Content-Type': 'application/json; charset=UTF-8',
        'Accept': 'application/json',
      },
      body: json.encode({
        'username': name,
        'email': email,
        'password': password,
        'password_confirmation': passwordConfirmation,
      }),
    );

    final body = json.decode(response.body) as Map<String, dynamic>;

    if (response.statusCode == 201) {
      return body;
    } else {
      final message = body['message'] ?? 'Registration failed';
      final errors = body['errors'] as Map<String, dynamic>?;
      String errorString = message.toString();
      if (errors != null) {
        errorString = errors.values
            .expand((list) => list is List ? list : [list])
            .join('\n');
      }
      throw Exception(errorString);
    }
  }

  // ── Login ──
  Future<Map<String, dynamic>> login({
    required String email,
    required String password,
  }) async {
    final response = await http.post(
      Uri.parse('$_baseUrl/login'),
      headers: {
        'Content-Type': 'application/json; charset=UTF-8',
        'Accept': 'application/json',
      },
      body: json.encode({'email': email, 'password': password}),
    );

    final body = json.decode(response.body) as Map<String, dynamic>;

    if (response.statusCode == 200) {
      return body;
    } else {
      final message = body['message'] ?? 'Login failed';
      throw Exception(message.toString());
    }
  }

  // ── GitHub Sign-In ──
  Future<Map<String, dynamic>> githubLogin(String accessToken) async {
    final response = await http.post(
      Uri.parse('$_baseUrl/auth/github'),
      headers: {
        'Content-Type': 'application/json; charset=UTF-8',
        'Accept': 'application/json',
      },
      body: json.encode({'access_token': accessToken}),
    );

    final body = json.decode(response.body) as Map<String, dynamic>;

    if (response.statusCode == 200) {
      return body;
    } else {
      final message = body['message'] ?? 'GitHub login failed';
      throw Exception(message.toString());
    }
  }

  // ── Get Current User ──
  Future<Map<String, dynamic>> getUser(String token) async {
    final response = await http.get(
      Uri.parse('$_baseUrl/user'),
      headers: {'Accept': 'application/json', 'Authorization': 'Bearer $token'},
    );

    if (response.statusCode == 200) {
      return json.decode(response.body) as Map<String, dynamic>;
    } else {
      throw Exception('Failed to get user');
    }
  }

  // ── Update Profile ──
  Future<Map<String, dynamic>> updateProfile({
    required String token,
    required Map<String, dynamic> data,
  }) async {
    final response = await http.put(
      Uri.parse('$_baseUrl/user'),
      headers: {
        'Content-Type': 'application/json; charset=UTF-8',
        'Accept': 'application/json',
        'Authorization': 'Bearer $token',
      },
      body: json.encode(data),
    );

    final body = json.decode(response.body) as Map<String, dynamic>;

    if (response.statusCode == 200) {
      return body;
    } else {
      final message = body['message'] ?? 'Profile update failed';
      final errors = body['errors'] as Map<String, dynamic>?;
      String errorString = message.toString();
      if (errors != null) {
        errorString = errors.values
            .expand((list) => list is List ? list : [list])
            .join('\n');
      }
      throw Exception(errorString);
    }
  }

  // ── Logout ──
  Future<void> logout(String token) async {
    await http.post(
      Uri.parse('$_baseUrl/logout'),
      headers: {'Accept': 'application/json', 'Authorization': 'Bearer $token'},
    );
  }
}
