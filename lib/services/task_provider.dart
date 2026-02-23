import 'package:flutter/material.dart';
import '../models/task.dart';
import '../services/api_service.dart';

/// State management via ChangeNotifier (Provider pattern) for tasks.
class TaskProvider extends ChangeNotifier {
  final ApiService _apiService = ApiService();

  List<Task> _tasks = [];
  List<Task> get tasks => _tasks;

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  String? _error;
  String? get error => _error;

  // ── Computed Stats ──
  int get totalTasks => _tasks.length;
  int get pendingTasks => _tasks.where((t) => t.status == 'pending').length;
  int get inProgressTasks =>
      _tasks.where((t) => t.status == 'in_progress').length;
  int get completedTasks => _tasks.where((t) => t.status == 'completed').length;

  // ── READ ──
  Future<void> fetchTasks() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _tasks = await _apiService.fetchTasks();
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // ── CREATE ──
  Future<bool> addTask(Task task) async {
    try {
      final created = await _apiService.createTask(task);
      _tasks.insert(0, created);
      notifyListeners();
      return true;
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      return false;
    }
  }

  // ── UPDATE ──
  Future<bool> updateTask(Task task) async {
    try {
      final updated = await _apiService.updateTask(task);
      final index = _tasks.indexWhere((t) => t.id == task.id);
      if (index != -1) {
        _tasks[index] = updated;
      }
      notifyListeners();
      return true;
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      return false;
    }
  }

  // ── DELETE ──
  Future<bool> deleteTask(int id) async {
    try {
      await _apiService.deleteTask(id);
      _tasks.removeWhere((t) => t.id == id);
      notifyListeners();
      return true;
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      return false;
    }
  }
}
