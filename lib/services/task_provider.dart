import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/task.dart';
import '../services/api_service.dart';
import '../services/notification_service.dart';

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

  /// Check if notifications are enabled in user settings.
  Future<bool> _areNotificationsEnabled() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool('notifications') ?? true;
  }

  // ── READ ──
  Future<void> fetchTasks() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _tasks = await _apiService.fetchTasks();
      // Only schedule notifications if the user has them enabled
      if (await _areNotificationsEnabled()) {
        await NotificationService.instance.scheduleAllTaskReminders(_tasks);
      }
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
      // Schedule notification for the new task
      if (await _areNotificationsEnabled() &&
          created.dueDate != null &&
          created.status != 'completed') {
        await NotificationService.instance.scheduleTaskReminder(created);
      }
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
      // Update notification: cancel old and reschedule if needed
      if (updated.id != null) {
        await NotificationService.instance.cancelTaskReminder(updated.id!);
        if (await _areNotificationsEnabled() &&
            updated.dueDate != null &&
            updated.status != 'completed') {
          await NotificationService.instance.scheduleTaskReminder(updated);
        }
      }
      notifyListeners();
      return true;
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      return false;
    }
  }

  // ── TOGGLE STATUS (for swipe-to-complete) ──
  Future<bool> toggleTaskStatus(Task task) async {
    final newStatus = task.status == 'completed' ? 'pending' : 'completed';
    final updated = task.copyWith(status: newStatus);
    return updateTask(updated);
  }

  // ── QUICK STATUS CHANGE ──
  Future<bool> quickUpdateStatus(Task task, String newStatus) async {
    final updated = task.copyWith(status: newStatus);
    return updateTask(updated);
  }

  // ── DELETE ──
  Future<bool> deleteTask(int id) async {
    try {
      await _apiService.deleteTask(id);
      _tasks.removeWhere((t) => t.id == id);
      // Cancel notification for deleted task
      await NotificationService.instance.cancelTaskReminder(id);
      notifyListeners();
      return true;
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      return false;
    }
  }
}
