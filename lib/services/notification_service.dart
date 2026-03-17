import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_timezone/flutter_timezone.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:timezone/data/latest_all.dart' as tzdata;
import '../models/task.dart';

/// Handles local push notifications for task reminders.
class NotificationService {
  NotificationService._();
  static final NotificationService instance = NotificationService._();

  final FlutterLocalNotificationsPlugin _plugin =
      FlutterLocalNotificationsPlugin();

  bool _initialized = false;

  // ── Notification channel details (Android) ──
  static const _channelId = 'taskflow_reminders';
  static const _channelName = 'Task Reminders';
  static const _channelDesc = 'Notifications for upcoming and overdue tasks';

  /// Initialise the plugin. Call once from main().
  Future<void> init() async {
    if (_initialized) return;

    // ── 1. Set up timezone data + device local zone ──
    tzdata.initializeTimeZones();
    try {
      final deviceTz = await FlutterTimezone.getLocalTimezone();
      tz.setLocalLocation(tz.getLocation(deviceTz));
      debugPrint('[NotificationService] Device timezone: $deviceTz');
    } catch (e) {
      // Fallback — use UTC if we can't detect the timezone
      debugPrint('[NotificationService] Could not detect timezone: $e');
    }

    // ── 2. Platform-specific init settings ──
    const androidSettings = AndroidInitializationSettings(
      '@mipmap/ic_launcher',
    );

    const darwinSettings = DarwinInitializationSettings(
      requestAlertPermission: true,
      requestBadgePermission: true,
      requestSoundPermission: true,
    );

    const initSettings = InitializationSettings(
      android: androidSettings,
      iOS: darwinSettings,
      macOS: darwinSettings,
    );

    await _plugin.initialize(
      initSettings,
      onDidReceiveNotificationResponse: _onNotificationTapped,
    );

    // ── 3. Android: create channel + request permission ──
    final androidPlugin = _plugin
        .resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin
        >();
    if (androidPlugin != null) {
      await androidPlugin.createNotificationChannel(
        const AndroidNotificationChannel(
          _channelId,
          _channelName,
          description: _channelDesc,
          importance: Importance.high,
          playSound: true,
          enableVibration: true,
        ),
      );
      // Android 13+ runtime permission
      final granted = await androidPlugin.requestNotificationsPermission();
      debugPrint('[NotificationService] Android permission granted: $granted');
    }

    // ── 4. iOS: request permission ──
    final iosPlugin = _plugin
        .resolvePlatformSpecificImplementation<
          IOSFlutterLocalNotificationsPlugin
        >();
    if (iosPlugin != null) {
      final granted = await iosPlugin.requestPermissions(
        alert: true,
        badge: true,
        sound: true,
      );
      debugPrint('[NotificationService] iOS permission granted: $granted');
    }

    _initialized = true;
    debugPrint('[NotificationService] Initialized successfully');
  }

  /// Called when the user taps a notification.
  void _onNotificationTapped(NotificationResponse response) {
    debugPrint('[NotificationService] Tapped payload: ${response.payload}');
  }

  // ──────────────────────────────────────────────
  //  Public API
  // ──────────────────────────────────────────────

  /// Send a test notification immediately — useful for verifying setup.
  Future<void> sendTestNotification() async {
    try {
      await _plugin.show(
        0, // id = 0 reserved for test
        'TaskFlow Notification Test',
        'If you see this, notifications are working!',
        _notificationDetails(),
        payload: 'test',
      );
      debugPrint('[NotificationService] Test notification sent');
    } catch (e) {
      debugPrint('[NotificationService] Test notification FAILED: $e');
    }
  }

  /// Schedule a notification for a task.
  /// Uses scheduledAt - reminderMinutes if available, otherwise 8 AM on due date.
  Future<void> scheduleTaskReminder(Task task) async {
    if (task.id == null) return;

    try {
      tz.TZDateTime scheduledLocal;

      if (task.scheduledAt != null) {
        // Use precise scheduled_at minus reminder offset
        final reminderOffset = Duration(minutes: task.reminderMinutes);
        final reminderTime = task.scheduledAt!.subtract(reminderOffset);

        scheduledLocal = tz.TZDateTime(
          tz.local,
          reminderTime.year,
          reminderTime.month,
          reminderTime.day,
          reminderTime.hour,
          reminderTime.minute,
        );
      } else if (task.dueDate != null) {
        // Fallback: 8 AM on the due date
        final dueDate = DateTime.tryParse(task.dueDate!);
        if (dueDate == null) return;

        scheduledLocal = tz.TZDateTime(
          tz.local,
          dueDate.year,
          dueDate.month,
          dueDate.day,
          8,
        );
      } else {
        return; // No date info, can't schedule
      }

      // If the scheduled time is in the past, fire immediately instead
      final now = tz.TZDateTime.now(tz.local);
      if (scheduledLocal.isBefore(now)) {
        await showImmediateNotification(task, isOverdue: true);
        return;
      }

      // Format time for notification body
      final taskTime = task.scheduledAt != null
          ? '${task.scheduledAt!.hour.toString().padLeft(2, '0')}:${task.scheduledAt!.minute.toString().padLeft(2, '0')}'
          : 'today';

      await _plugin.zonedSchedule(
        task.id!,
        '⏰ Task Reminder',
        '${task.title} is due at $taskTime',
        scheduledLocal,
        _notificationDetails(),
        androidScheduleMode: AndroidScheduleMode.inexactAllowWhileIdle,
        uiLocalNotificationDateInterpretation:
            UILocalNotificationDateInterpretation.absoluteTime,
        payload: task.id.toString(),
      );

      debugPrint(
        '[NotificationService] Scheduled task ${task.id} "${task.title}" at $scheduledLocal (reminder ${task.reminderMinutes}min before)',
      );
    } catch (e) {
      debugPrint(
        '[NotificationService] Failed to schedule task ${task.id}: $e',
      );
    }
  }

  /// Show an immediate notification (e.g. for overdue tasks).
  Future<void> showImmediateNotification(
    Task task, {
    bool isOverdue = false,
  }) async {
    if (task.id == null) return;

    try {
      final title = isOverdue ? '⚠️ Overdue Task' : '📋 Task Reminder';
      final timeStr = task.scheduledAt != null
          ? ' (${task.scheduledAt!.hour.toString().padLeft(2, '0')}:${task.scheduledAt!.minute.toString().padLeft(2, '0')})'
          : '';
      final body = isOverdue
          ? '${task.title} is overdue!$timeStr'
          : '${task.title} — ${task.statusLabel}$timeStr';

      await _plugin.show(
        task.id!,
        title,
        body,
        _notificationDetails(),
        payload: task.id.toString(),
      );
    } catch (e) {
      debugPrint(
        '[NotificationService] Failed to show immediate notification: $e',
      );
    }
  }

  /// Cancel a scheduled notification for a task.
  Future<void> cancelTaskReminder(int taskId) async {
    try {
      await _plugin.cancel(taskId);
    } catch (e) {
      debugPrint('[NotificationService] Failed to cancel task $taskId: $e');
    }
  }

  /// Cancel all scheduled notifications.
  Future<void> cancelAll() async {
    try {
      await _plugin.cancelAll();
      debugPrint('[NotificationService] All notifications cancelled');
    } catch (e) {
      debugPrint('[NotificationService] Failed to cancel all: $e');
    }
  }

  /// Schedule reminders for all incomplete tasks with dates.
  Future<void> scheduleAllTaskReminders(List<Task> tasks) async {
    await cancelAll();

    int scheduled = 0;
    for (final task in tasks) {
      if (task.status == 'completed') continue;
      if (task.scheduledAt == null && task.dueDate == null) continue;
      await scheduleTaskReminder(task);
      scheduled++;
    }
    debugPrint(
      '[NotificationService] Scheduled $scheduled reminders out of ${tasks.length} tasks',
    );
  }

  /// Build platform-specific notification details.
  NotificationDetails _notificationDetails() {
    return const NotificationDetails(
      android: AndroidNotificationDetails(
        _channelId,
        _channelName,
        channelDescription: _channelDesc,
        importance: Importance.high,
        priority: Priority.high,
        playSound: true,
        enableVibration: true,
        showWhen: true,
        icon: '@mipmap/ic_launcher',
      ),
      iOS: DarwinNotificationDetails(
        presentAlert: true,
        presentBadge: true,
        presentSound: true,
      ),
    );
  }
}
