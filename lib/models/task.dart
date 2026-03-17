/// Task model representing a task from the Laravel API.
class Task {
  final int? id;
  final String title;
  final String description;
  final String status; // pending, in_progress, completed
  final String category; // general, school, work, home, personal
  final String? dueDate; // yyyy-MM-dd
  final DateTime? scheduledAt; // full date+time
  final DateTime? endsAt; // optional end date+time
  final int reminderMinutes; // minutes before to notify
  final String? createdAt;
  final String? updatedAt;

  Task({
    this.id,
    required this.title,
    required this.description,
    this.status = 'pending',
    this.category = 'general',
    this.dueDate,
    this.scheduledAt,
    this.endsAt,
    this.reminderMinutes = 15,
    this.createdAt,
    this.updatedAt,
  });

  /// Create a Task from JSON returned by the Laravel API.
  factory Task.fromJson(Map<String, dynamic> json) {
    // due_date may arrive as "2026-03-01T00:00:00.000000Z" — extract date part.
    String? rawDue = json['due_date'] as String?;
    if (rawDue != null && rawDue.contains('T')) {
      rawDue = rawDue.split('T').first;
    }

    // Parse scheduled_at from ISO string
    DateTime? parsedScheduledAt;
    if (json['scheduled_at'] != null) {
      final parsed = DateTime.tryParse(json['scheduled_at'] as String);
      if (parsed != null) {
        parsedScheduledAt = parsed.isUtc ? parsed.toLocal() : parsed;
      }
    }

    DateTime? parsedEndsAt;
    if (json['ends_at'] != null) {
      final parsed = DateTime.tryParse(json['ends_at'] as String);
      if (parsed != null) {
        parsedEndsAt = parsed.isUtc ? parsed.toLocal() : parsed;
      }
    }

    return Task(
      id: json['id'] as int?,
      title: json['title'] as String? ?? '',
      description: json['description'] as String? ?? '',
      status: json['status'] as String? ?? 'pending',
      category: json['category'] as String? ?? 'general',
      dueDate: rawDue,
      scheduledAt: parsedScheduledAt,
      endsAt: parsedEndsAt,
      reminderMinutes: json['reminder_minutes'] as int? ?? 15,
      createdAt: json['created_at'] as String?,
      updatedAt: json['updated_at'] as String?,
    );
  }

  /// Convert Task to JSON for POST / PUT requests.
  Map<String, dynamic> toJson() {
    return {
      'title': title,
      'description': description,
      'status': status,
      'category': category,
      'due_date': dueDate,
      if (scheduledAt != null)
        'scheduled_at': scheduledAt!.toUtc().toIso8601String(),
      if (endsAt != null) 'ends_at': endsAt!.toUtc().toIso8601String(),
      'reminder_minutes': reminderMinutes,
    };
  }

  /// Create a copy with modified fields.
  Task copyWith({
    int? id,
    String? title,
    String? description,
    String? status,
    String? category,
    String? dueDate,
    DateTime? scheduledAt,
    DateTime? endsAt,
    bool clearEndsAt = false,
    bool clearScheduledAt = false,
    int? reminderMinutes,
    String? createdAt,
    String? updatedAt,
  }) {
    return Task(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      status: status ?? this.status,
      category: category ?? this.category,
      dueDate: dueDate ?? this.dueDate,
      scheduledAt: clearScheduledAt ? null : (scheduledAt ?? this.scheduledAt),
      endsAt: clearEndsAt ? null : (endsAt ?? this.endsAt),
      reminderMinutes: reminderMinutes ?? this.reminderMinutes,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  /// Human-readable status label.
  String get statusLabel {
    switch (status) {
      case 'in_progress':
        return 'In Progress';
      case 'completed':
        return 'Completed';
      default:
        return 'Pending';
    }
  }

  /// Whether the task is overdue.
  bool get isOverdue {
    if (status == 'completed') return false;
    // Check scheduledAt first
    if (scheduledAt != null) {
      return scheduledAt!.isBefore(DateTime.now());
    }
    // Fallback to dueDate
    if (dueDate == null) return false;
    try {
      final due = DateTime.parse(dueDate!);
      return due.isBefore(DateTime.now());
    } catch (_) {
      return false;
    }
  }

  /// Whether the task is scheduled for today.
  bool get isToday {
    final now = DateTime.now();
    if (scheduledAt != null) {
      return scheduledAt!.year == now.year &&
          scheduledAt!.month == now.month &&
          scheduledAt!.day == now.day;
    }
    if (dueDate != null) {
      try {
        final due = DateTime.parse(dueDate!);
        return due.year == now.year &&
            due.month == now.month &&
            due.day == now.day;
      } catch (_) {
        return false;
      }
    }
    return false;
  }

  /// Whether the task is upcoming (in the future and not completed).
  bool get isUpcoming {
    if (status == 'completed') return false;
    if (scheduledAt != null) {
      return scheduledAt!.isAfter(DateTime.now());
    }
    if (dueDate != null) {
      try {
        final due = DateTime.parse(dueDate!);
        return due.isAfter(DateTime.now());
      } catch (_) {
        return false;
      }
    }
    return false;
  }

  /// The effective date for this task (scheduledAt or dueDate).
  DateTime? get effectiveDate {
    if (scheduledAt != null) return scheduledAt;
    if (dueDate != null) {
      try {
        return DateTime.parse(dueDate!);
      } catch (_) {
        return null;
      }
    }
    return null;
  }
}
