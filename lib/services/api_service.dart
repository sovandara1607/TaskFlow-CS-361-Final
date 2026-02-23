import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/task.dart';

/// Service class that handles all REST API communication with the Laravel backend.
///
/// API Base URL should point to your Laravel server.
/// For Android Emulator use: http://10.0.2.2:8000/api
/// For iOS Simulator / Physical device use your machine IP: http://YOUR_IP:8000/api
/// For web use: http://localhost:8000/api
class ApiService {
  // ── Change this URL to match your Laravel server address ──
  static const String _baseUrl = 'http://127.0.0.1:8000/api';

  // ── READ ──────────────────────────────────────────────────────────────
  /// Fetch all tasks (GET /api/tasks)
  Future<List<Task>> fetchTasks() async {
    final response = await http.get(
      Uri.parse('$_baseUrl/tasks'),
      headers: {'Accept': 'application/json'},
    );

    if (response.statusCode == 200) {
      final Map<String, dynamic> body = json.decode(response.body);
      final List<dynamic> data = body['data'] ?? [];
      return data.map((item) => Task.fromJson(item)).toList();
    } else {
      throw Exception('Failed to load tasks (${response.statusCode})');
    }
  }

  /// Fetch a single task by id (GET /api/tasks/:id)
  Future<Task> fetchTask(int id) async {
    final response = await http.get(
      Uri.parse('$_baseUrl/tasks/$id'),
      headers: {'Accept': 'application/json'},
    );

    if (response.statusCode == 200) {
      final Map<String, dynamic> body = json.decode(response.body);
      return Task.fromJson(body['data']);
    } else {
      throw Exception('Failed to load task (${response.statusCode})');
    }
  }

  // ── CREATE ────────────────────────────────────────────────────────────
  /// Create a new task (POST /api/tasks)
  Future<Task> createTask(Task task) async {
    final response = await http.post(
      Uri.parse('$_baseUrl/tasks'),
      headers: {
        'Content-Type': 'application/json; charset=UTF-8',
        'Accept': 'application/json',
      },
      body: json.encode(task.toJson()),
    );

    if (response.statusCode == 201) {
      final Map<String, dynamic> body = json.decode(response.body);
      return Task.fromJson(body['data']);
    } else {
      throw Exception('Failed to create task (${response.statusCode})');
    }
  }

  // ── UPDATE ────────────────────────────────────────────────────────────
  /// Update an existing task (PUT /api/tasks/:id)
  Future<Task> updateTask(Task task) async {
    final response = await http.put(
      Uri.parse('$_baseUrl/tasks/${task.id}'),
      headers: {
        'Content-Type': 'application/json; charset=UTF-8',
        'Accept': 'application/json',
      },
      body: json.encode(task.toJson()),
    );

    if (response.statusCode == 200) {
      final Map<String, dynamic> body = json.decode(response.body);
      return Task.fromJson(body['data']);
    } else {
      throw Exception('Failed to update task (${response.statusCode})');
    }
  }

  // ── DELETE ────────────────────────────────────────────────────────────
  /// Delete a task (DELETE /api/tasks/:id)
  Future<bool> deleteTask(int id) async {
    final response = await http.delete(
      Uri.parse('$_baseUrl/tasks/$id'),
      headers: {'Accept': 'application/json'},
    );

    if (response.statusCode == 200) {
      return true;
    } else {
      throw Exception('Failed to delete task (${response.statusCode})');
    }
  }
}
