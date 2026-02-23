/// Task model representing a task from the Laravel API.
class Task {
  final int? id;
  final String title;
  final String description;
  final String status; // pending, in_progress, completed
  final String? dueDate; // yyyy-MM-dd
  final String? createdAt;
  final String? updatedAt;

  Task({
    this.id,
    required this.title,
    required this.description,
    this.status = 'pending',
    this.dueDate,
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

    return Task(
      id: json['id'] as int?,
      title: json['title'] as String? ?? '',
      description: json['description'] as String? ?? '',
      status: json['status'] as String? ?? 'pending',
      dueDate: rawDue,
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
      'due_date': dueDate,
    };
  }

  /// Create a copy with modified fields.
  Task copyWith({
    int? id,
    String? title,
    String? description,
    String? status,
    String? dueDate,
    String? createdAt,
    String? updatedAt,
  }) {
    return Task(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      status: status ?? this.status,
      dueDate: dueDate ?? this.dueDate,
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
    if (dueDate == null || status == 'completed') return false;
    try {
      final due = DateTime.parse(dueDate!);
      return due.isBefore(DateTime.now());
    } catch (_) {
      return false;
    }
  }
}
