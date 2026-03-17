import 'package:flutter/material.dart';
import 'package:flutter_final_project_app_with_full_ui_and_api_crud_integration/widgets/TextTheme.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../l10n/app_localizations.dart';
import '../models/task.dart';
import '../services/app_settings_provider.dart';
import '../services/task_provider.dart';
import '../utils/constants.dart';

/// Weekly timetable schedule screen.
class ScheduleScreen extends StatefulWidget {
  const ScheduleScreen({super.key});

  @override
  State<ScheduleScreen> createState() => _ScheduleScreenState();
}

enum _TaskAdjustAction { moveEarlier, moveLater, pickDateTime }

enum _TaskDurationAction {
  shorten15,
  extend15,
  extend30,
  extend60,
  pickEndTime,
}

class _ScheduleScreenState extends State<ScheduleScreen> {
  static const List<int> _visibleWeekdays = <int>[
    DateTime.monday,
    DateTime.tuesday,
    DateTime.wednesday,
    DateTime.thursday,
    DateTime.friday,
  ];

  static const double _timeLabelWidth = 52;
  static const double _dayColumnWidth = 62;
  static const double _hourRowHeight = 58;
  static const int _startHour = 7;
  static const int _endHour = 24;

  late DateTime _weekStart;

  @override
  void initState() {
    super.initState();
    _weekStart = _startOfWeek(DateTime.now());

    WidgetsBinding.instance.addPostFrameCallback((_) {
      final provider = context.read<TaskProvider>();
      if (provider.tasks.isEmpty && !provider.isLoading) {
        provider.fetchTasks();
      }
    });
  }

  DateTime _startOfWeek(DateTime day) {
    final normalized = DateTime(day.year, day.month, day.day);
    final diff = normalized.weekday - DateTime.monday;
    return normalized.subtract(Duration(days: diff));
  }

  bool _isInVisibleWeek(DateTime dateTime) {
    final start = _weekStart;
    final end = _weekStart.add(const Duration(days: 5));
    final normalized = DateTime(dateTime.year, dateTime.month, dateTime.day);
    return !normalized.isBefore(start) && normalized.isBefore(end);
  }

  void _shiftWeek(int deltaWeeks) {
    setState(() {
      _weekStart = _weekStart.add(Duration(days: deltaWeeks * 7));
    });
  }

  Future<void> _saveAdjustedSchedule(
    Task task,
    DateTime scheduledAt, {
    DateTime? endsAt,
  }) async {
    final provider = context.read<TaskProvider>();
    final resolvedEndsAt = (endsAt != null && endsAt.isAfter(scheduledAt))
        ? endsAt
        : null;

    final updatedTask = task.copyWith(
      scheduledAt: scheduledAt,
      dueDate: DateFormat('yyyy-MM-dd').format(scheduledAt),
      endsAt: resolvedEndsAt,
      clearEndsAt: resolvedEndsAt == null,
    );

    final success = await provider.updateTask(updatedTask);
    if (!mounted) return;

    final message = success
        ? 'Task schedule updated'
        : (provider.error ?? 'Failed to update task schedule');

    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(content: Text(message)));
  }

  Future<void> _showAdjustScheduleSheet(Task task) async {
    final baseDateTime = _taskDateTime(task) ?? DateTime.now();

    final action = await showModalBottomSheet<_TaskAdjustAction>(
      context: context,
      showDragHandle: true,
      builder: (sheetContext) {
        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                leading: const Icon(Icons.schedule_rounded),
                title: const Text('Adjust task schedule'),
                subtitle: Text(
                  '${DateFormat('EEE, MMM d').format(baseDateTime)} • ${DateFormat('h:mm a').format(baseDateTime)}',
                ),
              ),
              const Divider(height: 1),
              ListTile(
                leading: const Icon(Icons.remove_circle_outline_rounded),
                title: const Text('Move 1 hour earlier'),
                onTap: () {
                  Navigator.pop(sheetContext, _TaskAdjustAction.moveEarlier);
                },
              ),
              ListTile(
                leading: const Icon(Icons.add_circle_outline_rounded),
                title: const Text('Move 1 hour later'),
                onTap: () {
                  Navigator.pop(sheetContext, _TaskAdjustAction.moveLater);
                },
              ),
              ListTile(
                leading: const Icon(Icons.edit_calendar_rounded),
                title: const Text('Pick date and time'),
                onTap: () {
                  Navigator.pop(sheetContext, _TaskAdjustAction.pickDateTime);
                },
              ),
              const SizedBox(height: 8),
            ],
          ),
        );
      },
    );

    if (!mounted || action == null) return;

    late final DateTime nextDateTime;
    switch (action) {
      case _TaskAdjustAction.moveEarlier:
        nextDateTime = baseDateTime.subtract(const Duration(hours: 1));
        break;
      case _TaskAdjustAction.moveLater:
        nextDateTime = baseDateTime.add(const Duration(hours: 1));
        break;
      case _TaskAdjustAction.pickDateTime:
        final pickedDate = await showDatePicker(
          context: context,
          initialDate: baseDateTime,
          firstDate: DateTime(2020, 1, 1),
          lastDate: DateTime(2100, 12, 31),
        );
        if (pickedDate == null || !mounted) return;

        final pickedTime = await showTimePicker(
          context: context,
          initialTime: TimeOfDay.fromDateTime(baseDateTime),
        );
        if (pickedTime == null) return;

        nextDateTime = DateTime(
          pickedDate.year,
          pickedDate.month,
          pickedDate.day,
          pickedTime.hour,
          pickedTime.minute,
        );
        break;
    }

    final durationMinutes = _taskDurationMinutes(task);
    final nextEndsAt = nextDateTime.add(Duration(minutes: durationMinutes));
    await _saveAdjustedSchedule(task, nextDateTime, endsAt: nextEndsAt);
  }

  String _formatDurationLabel(int minutes) {
    final hours = minutes ~/ 60;
    final mins = minutes % 60;
    if (hours > 0 && mins > 0) {
      return '${hours}h ${mins}m';
    }
    if (hours > 0) {
      return '${hours}h';
    }
    return '${mins}m';
  }

  Future<void> _showDurationAdjustSheet(Task task) async {
    final start = _taskDateTime(task);
    final currentEnd = _taskEndDateTime(task);
    if (start == null || currentEnd == null) return;

    final currentDuration = currentEnd.difference(start).inMinutes;

    final action = await showModalBottomSheet<_TaskDurationAction>(
      context: context,
      showDragHandle: true,
      builder: (sheetContext) {
        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                leading: const Icon(Icons.timelapse_rounded),
                title: const Text('Adjust task duration'),
                subtitle: Text(
                  'Current duration: ${_formatDurationLabel(currentDuration)}',
                ),
              ),
              const Divider(height: 1),
              ListTile(
                leading: const Icon(Icons.add_rounded),
                title: const Text('Extend by 15 minutes'),
                onTap: () {
                  Navigator.pop(sheetContext, _TaskDurationAction.extend15);
                },
              ),
              ListTile(
                leading: const Icon(Icons.add_rounded),
                title: const Text('Extend by 30 minutes'),
                onTap: () {
                  Navigator.pop(sheetContext, _TaskDurationAction.extend30);
                },
              ),
              ListTile(
                leading: const Icon(Icons.add_rounded),
                title: const Text('Extend by 1 hour'),
                onTap: () {
                  Navigator.pop(sheetContext, _TaskDurationAction.extend60);
                },
              ),
              ListTile(
                leading: const Icon(Icons.remove_rounded),
                title: const Text('Shorten by 15 minutes'),
                onTap: () {
                  Navigator.pop(sheetContext, _TaskDurationAction.shorten15);
                },
              ),
              ListTile(
                leading: const Icon(Icons.access_time_rounded),
                title: const Text('Set end time'),
                onTap: () {
                  Navigator.pop(sheetContext, _TaskDurationAction.pickEndTime);
                },
              ),
              const SizedBox(height: 8),
            ],
          ),
        );
      },
    );

    if (!mounted || action == null) return;

    DateTime nextEnd = currentEnd;
    switch (action) {
      case _TaskDurationAction.shorten15:
        final nextMinutes = (currentDuration - 15).clamp(15, 720);
        nextEnd = start.add(Duration(minutes: nextMinutes));
        break;
      case _TaskDurationAction.extend15:
        final nextMinutes = (currentDuration + 15).clamp(15, 720);
        nextEnd = start.add(Duration(minutes: nextMinutes));
        break;
      case _TaskDurationAction.extend30:
        final nextMinutes = (currentDuration + 30).clamp(15, 720);
        nextEnd = start.add(Duration(minutes: nextMinutes));
        break;
      case _TaskDurationAction.extend60:
        final nextMinutes = (currentDuration + 60).clamp(15, 720);
        nextEnd = start.add(Duration(minutes: nextMinutes));
        break;
      case _TaskDurationAction.pickEndTime:
        final pickedTime = await showTimePicker(
          context: context,
          initialTime: TimeOfDay.fromDateTime(currentEnd),
        );
        if (pickedTime == null) return;

        final pickedEnd = DateTime(
          start.year,
          start.month,
          start.day,
          pickedTime.hour,
          pickedTime.minute,
        );

        if (!pickedEnd.isAfter(start)) {
          if (!mounted) return;
          ScaffoldMessenger.of(context)
            ..hideCurrentSnackBar()
            ..showSnackBar(
              SnackBar(
                content: Text(
                  AppLocalizations.tr(
                    'invalid_time_range',
                    context.read<AppSettingsProvider>().locale,
                  ),
                ),
              ),
            );
          return;
        }

        final boundedMinutes = pickedEnd
            .difference(start)
            .inMinutes
            .clamp(15, 720);
        nextEnd = start.add(Duration(minutes: boundedMinutes));
        break;
    }

    await _saveAdjustedSchedule(task, start, endsAt: nextEnd);
  }

  Future<void> _onTaskDropped(Task task, DateTime newStart) async {
    final durationMinutes = _taskDurationMinutes(task);
    final nextEndsAt = newStart.add(Duration(minutes: durationMinutes));
    await _saveAdjustedSchedule(task, newStart, endsAt: nextEndsAt);
  }

  Future<void> _onTaskEdgeResize(
    Task task,
    DateTime newStart,
    DateTime newEnd,
  ) async {
    if (!newEnd.isAfter(newStart)) return;
    await _saveAdjustedSchedule(task, newStart, endsAt: newEnd);
  }

  DateTime? _taskDateTime(Task task) {
    final dateTime = task.scheduledAt ?? task.effectiveDate;
    if (dateTime == null) return null;

    final isMidnightValue =
        dateTime.hour == 0 &&
        dateTime.minute == 0 &&
        dateTime.second == 0 &&
        dateTime.millisecond == 0 &&
        dateTime.microsecond == 0;

    // Date-only tasks should still be visible in day view.
    if (task.scheduledAt == null && isMidnightValue) {
      return DateTime(dateTime.year, dateTime.month, dateTime.day, 9);
    }

    return dateTime;
  }

  DateTime? _taskEndDateTime(Task task) {
    final start = _taskDateTime(task);
    if (start == null) return null;

    if (task.endsAt != null && task.endsAt!.isAfter(start)) {
      return task.endsAt;
    }

    return start.add(const Duration(hours: 1));
  }

  int _minutesOfDay(DateTime dateTime) {
    return dateTime.hour * 60 + dateTime.minute;
  }

  int _taskDurationMinutes(Task task) {
    final start = _taskDateTime(task);
    final end = _taskEndDateTime(task);
    if (start == null || end == null) return 60;

    final minutes = end.difference(start).inMinutes;
    return minutes.clamp(15, 720);
  }

  Color _taskColor(Task task) {
    if (task.status == 'completed') {
      return AppConstants.successColor;
    }

    switch (task.category) {
      case 'school':
        return const Color(0xFF4CAF50);
      case 'work':
        return const Color(0xFFE91E63);
      case 'personal':
        return const Color(0xFF00BCD4);
      case 'home':
        return const Color(0xFFFF9800);
      default:
        return AppConstants.primaryColor;
    }
  }

  List<_PlacedTask> _layoutWeekTasks(List<Task> tasks) {
    final dayBuckets = <int, List<Task>>{};

    for (final task in tasks) {
      final dateTime = _taskDateTime(task);
      if (dateTime == null) continue;
      if (!_visibleWeekdays.contains(dateTime.weekday)) continue;
      if (!_isInVisibleWeek(dateTime)) continue;

      dayBuckets.putIfAbsent(dateTime.weekday, () => <Task>[]).add(task);
    }

    final placed = <_PlacedTask>[];

    for (final entry in dayBuckets.entries) {
      final weekdayTasks = entry.value;
      weekdayTasks.sort((a, b) {
        final aDate = _taskDateTime(a)!;
        final bDate = _taskDateTime(b)!;
        return aDate.compareTo(bDate);
      });

      final laneEndMinutes = <int>[];
      final dayPlaced = <_TempPlacedTask>[];

      for (final task in weekdayTasks) {
        final startDateTime = _taskDateTime(task)!;
        final startMin = _minutesOfDay(startDateTime);
        final endMin = startMin + _taskDurationMinutes(task);

        var lane = laneEndMinutes.indexWhere((laneEnd) => laneEnd <= startMin);
        if (lane == -1) {
          lane = laneEndMinutes.length;
          laneEndMinutes.add(endMin);
        } else {
          laneEndMinutes[lane] = endMin;
        }

        dayPlaced.add(
          _TempPlacedTask(task: task, startDateTime: startDateTime, lane: lane),
        );
      }

      final laneCount = laneEndMinutes.isEmpty ? 1 : laneEndMinutes.length;
      for (final item in dayPlaced) {
        placed.add(
          _PlacedTask(
            task: item.task,
            startDateTime: item.startDateTime,
            lane: item.lane,
            laneCount: laneCount,
          ),
        );
      }
    }

    return placed;
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final lang = context.watch<AppSettingsProvider>().locale;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          AppLocalizations.tr('schedule', lang),
          style: AppFonts.of(context, fontWeight: FontWeight.w700),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.today_rounded),
            onPressed: () => setState(() {
              _weekStart = _startOfWeek(DateTime.now());
            }),
          ),
          IconButton(
            icon: const Icon(Icons.refresh_rounded),
            onPressed: () => context.read<TaskProvider>().fetchTasks(),
          ),
        ],
      ),
      body: Consumer<TaskProvider>(
        builder: (context, provider, _) {
          if (provider.isLoading && provider.tasks.isEmpty) {
            return const Center(child: CircularProgressIndicator());
          }

          final placedTasks = _layoutWeekTasks(provider.tasks);

          return Column(
            children: [
              _ScheduleHeader(
                isDark: isDark,
                weekLabel:
                    '${DateFormat('MMM d').format(_weekStart)} - ${DateFormat('MMM d').format(_weekStart.add(const Duration(days: 4)))}',
                taskCount: placedTasks.length,
                onPrevWeek: () => _shiftWeek(-1),
                onNextWeek: () => _shiftWeek(1),
              ),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(12, 8, 12, 8),
                  child: _TimetableGrid(
                    isDark: isDark,
                    weekStart: _weekStart,
                    placedTasks: placedTasks,
                    dayColumnWidth: _dayColumnWidth,
                    timeLabelWidth: _timeLabelWidth,
                    hourRowHeight: _hourRowHeight,
                    startHour: _startHour,
                    endHour: _endHour,
                    visibleWeekdays: _visibleWeekdays,
                    colorForTask: _taskColor,
                    taskDurationMinutes: _taskDurationMinutes,
                    taskEndDateTime: _taskEndDateTime,
                    onTaskTap: (task) async {
                      await Navigator.pushNamed(
                        context,
                        '/edit',
                        arguments: task,
                      );
                      if (context.mounted) {
                        context.read<TaskProvider>().fetchTasks();
                      }
                    },
                    onTaskAdjust: _showAdjustScheduleSheet,
                    onTaskDurationAdjust: _showDurationAdjustSheet,
                    onTaskDrop: _onTaskDropped,
                    onTaskEdgeResize: _onTaskEdgeResize,
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}

class _ScheduleHeader extends StatelessWidget {
  final bool isDark;
  final String weekLabel;
  final int taskCount;
  final VoidCallback onPrevWeek;
  final VoidCallback onNextWeek;

  const _ScheduleHeader({
    required this.isDark,
    required this.weekLabel,
    required this.taskCount,
    required this.onPrevWeek,
    required this.onNextWeek,
  });

  @override
  Widget build(BuildContext context) {
    final isCompact = MediaQuery.sizeOf(context).width < 390;

    return Container(
      margin: const EdgeInsets.fromLTRB(12, 10, 12, 0),
      padding: const EdgeInsets.fromLTRB(8, 8, 8, 12),
      decoration: BoxDecoration(
        color: isDark ? AppConstants.darkSurface : Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: isDark ? 0.25 : 0.08),
            blurRadius: 16,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            children: [
              IconButton(
                onPressed: onPrevWeek,
                icon: const Icon(Icons.chevron_left_rounded),
              ),
              Expanded(
                child: Column(
                  children: [
                    Text(
                      'WEEKLY SCHEDULE',
                      style: AppFonts.of(
                        context,
                        fontSize: isCompact ? 18 : 22,
                        fontWeight: FontWeight.w700,
                        letterSpacing: isCompact ? 0.8 : 1.2,
                        color: AppConstants.primaryColor,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      weekLabel,
                      style: AppFonts.of(
                        context,
                        fontSize: isCompact ? 12 : 13,
                        color: isDark
                            ? Colors.white54
                            : AppConstants.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
              IconButton(
                onPressed: onNextWeek,
                icon: const Icon(Icons.chevron_right_rounded),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Container(
            height: 3,
            decoration: BoxDecoration(
              color: AppConstants.primaryColor.withValues(alpha: 0.85),
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(height: 8),
          Align(
            alignment: Alignment.centerRight,
            child: Text(
              '$taskCount task${taskCount == 1 ? '' : 's'} this week',
              style: AppFonts.of(
                context,
                fontSize: isCompact ? 11 : 12,
                color: isDark ? Colors.white54 : AppConstants.textSecondary,
              ),
            ),
          ),
        ])
    );
  }
}

class _TimetableGrid extends StatelessWidget {
  final bool isDark;
  final DateTime weekStart;
  final List<_PlacedTask> placedTasks;
  final double dayColumnWidth;
  final double timeLabelWidth;
  final double hourRowHeight;
  final int startHour;
  final int endHour;
  final List<int> visibleWeekdays;
  final Color Function(Task task) colorForTask;
  final int Function(Task task) taskDurationMinutes;
  final DateTime? Function(Task task) taskEndDateTime;
  final ValueChanged<Task> onTaskTap;
  final ValueChanged<Task> onTaskAdjust;
  final ValueChanged<Task> onTaskDurationAdjust;
  final Future<void> Function(Task task, DateTime newStart) onTaskDrop;
  final Future<void> Function(Task task, DateTime newStart, DateTime newEnd)
  onTaskEdgeResize;

  const _TimetableGrid({
    required this.isDark,
    required this.weekStart,
    required this.placedTasks,
    required this.dayColumnWidth,
    required this.timeLabelWidth,
    required this.hourRowHeight,
    required this.startHour,
    required this.endHour,
    required this.visibleWeekdays,
    required this.colorForTask,
    required this.taskDurationMinutes,
    required this.taskEndDateTime,
    required this.onTaskTap,
    required this.onTaskAdjust,
    required this.onTaskDurationAdjust,
    required this.onTaskDrop,
    required this.onTaskEdgeResize,
  });

  _TaskWindow _resizeTaskWindow({
    required DateTime initialStart,
    required DateTime initialEnd,
    required bool isStartHandle,
    required int deltaMinutes,
  }) {
    var nextStart = initialStart;
    var nextEnd = initialEnd;

    if (isStartHandle) {
      nextStart = nextStart.add(Duration(minutes: deltaMinutes));
    } else {
      nextEnd = nextEnd.add(Duration(minutes: deltaMinutes));
    }

    final dayAnchor = DateTime(
      initialStart.year,
      initialStart.month,
      initialStart.day,
    );
    final minDateTime = dayAnchor.add(Duration(hours: startHour));
    final maxDateTime = dayAnchor.add(Duration(hours: endHour));

    if (nextStart.isBefore(minDateTime)) {
      nextStart = minDateTime;
    }
    if (nextEnd.isAfter(maxDateTime)) {
      nextEnd = maxDateTime;
    }

    if (!nextEnd.isAfter(nextStart)) {
      if (isStartHandle) {
        nextStart = nextEnd.subtract(const Duration(minutes: 15));
      } else {
        nextEnd = nextStart.add(const Duration(minutes: 15));
      }
    }

    if (nextStart.isBefore(minDateTime)) {
      nextStart = minDateTime;
      nextEnd = nextStart.add(const Duration(minutes: 15));
    }
    if (nextEnd.isAfter(maxDateTime)) {
      nextEnd = maxDateTime;
      nextStart = nextEnd.subtract(const Duration(minutes: 15));
    }

    return _TaskWindow(start: nextStart, end: nextEnd);
  }

  @override
  Widget build(BuildContext context) {
    final gridHeight = (endHour - startHour) * hourRowHeight;
    final lineColor = isDark ? Colors.white12 : const Color(0xFFE0E1E5);

    return Container(
      decoration: BoxDecoration(
        color: isDark ? AppConstants.darkSurface : Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: isDark ? 0.22 : 0.06),
            blurRadius: 12,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: LayoutBuilder(
        builder: (context, constraints) {
          final dragTargetKey = GlobalKey();
          final viewportWidth = constraints.maxWidth;
          final fittedDayWidth =
              (viewportWidth - timeLabelWidth) / visibleWeekdays.length;
          final resolvedDayWidth = fittedDayWidth < dayColumnWidth
              ? dayColumnWidth
              : fittedDayWidth;
          final resolvedGridWidth =
              timeLabelWidth + (visibleWeekdays.length * resolvedDayWidth);
          final useHorizontalScroll = resolvedGridWidth > viewportWidth + 0.5;

          return SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: SizedBox(
              width: useHorizontalScroll ? resolvedGridWidth : viewportWidth,
              height: constraints.maxHeight,
              child: Column(
                children: [
                  _WeekDayHeader(
                    isDark: isDark,
                    weekStart: weekStart,
                    visibleWeekdays: visibleWeekdays,
                    dayColumnWidth: resolvedDayWidth,
                    timeLabelWidth: timeLabelWidth,
                  ),
                  Divider(height: 1, thickness: 1, color: lineColor),
                  Expanded(
                    child: SingleChildScrollView(
                      child: SizedBox(
                        height: gridHeight,
                        child: DragTarget<_DraggedTaskData>(
                          key: dragTargetKey,
                          onWillAcceptWithDetails: (_) => true,
                          onAcceptWithDetails: (details) {
                            final targetContext = dragTargetKey.currentContext;
                            if (targetContext == null) return;

                            final renderObject = targetContext
                                .findRenderObject();
                            if (renderObject is! RenderBox) return;

                            final local = renderObject.globalToLocal(
                              details.offset,
                            );

                            final x = local.dx;
                            final y = local.dy;

                            if (x < timeLabelWidth || y < 0 || y > gridHeight) {
                              return;
                            }

                            final dayIndex =
                                ((x - timeLabelWidth) / resolvedDayWidth)
                                    .floor();
                            if (dayIndex < 0 ||
                                dayIndex >= visibleWeekdays.length) {
                              return;
                            }

                            final rawMinutes =
                                ((y / hourRowHeight) * 60).round() +
                                (startHour * 60);

                            final snappedMinutes =
                                ((rawMinutes / 15).round() * 15);

                            final maxStartMinutes =
                                (endHour * 60) - details.data.durationMinutes;
                            final safeMaxStart =
                                maxStartMinutes < (startHour * 60)
                                ? (startHour * 60)
                                : maxStartMinutes;

                            final clampedStart = snappedMinutes.clamp(
                              startHour * 60,
                              safeMaxStart,
                            );

                            final dayDate = weekStart.add(
                              Duration(days: dayIndex),
                            );

                            final newStart = DateTime(
                              dayDate.year,
                              dayDate.month,
                              dayDate.day,
                              clampedStart ~/ 60,
                              clampedStart % 60,
                            );

                            onTaskDrop(details.data.task, newStart);
                          },
                          builder: (context, _, rejectedData) => Stack(
                            children: [
                              ..._gridLines(
                                context,
                                lineColor,
                                gridHeight,
                                resolvedDayWidth,
                              ),
                              ...placedTasks.map((placed) {
                                final baseStart = placed.startDateTime;
                                final baseDuration = taskDurationMinutes(
                                  placed.task,
                                );
                                final baseEnd =
                                    taskEndDateTime(placed.task) ??
                                    baseStart.add(
                                      Duration(minutes: baseDuration),
                                    );

                                DateTime previewStart = baseStart;
                                DateTime previewEnd = baseEnd;
                                double startHandleDy = 0;
                                double endHandleDy = 0;

                                return StatefulBuilder(
                                  builder: (context, setBlockState) {
                                    final effectiveStart = previewStart;
                                    final effectiveEnd = previewEnd;

                                    final startMin =
                                        (effectiveStart.hour * 60) +
                                        effectiveStart.minute;
                                    final endMin =
                                        (effectiveEnd.hour * 60) +
                                        effectiveEnd.minute;
                                    final visibleStart = startHour * 60;
                                    final visibleEnd = endHour * 60;

                                    final clippedStart = startMin.clamp(
                                      visibleStart,
                                      visibleEnd,
                                    );
                                    final clippedEnd = endMin.clamp(
                                      visibleStart,
                                      visibleEnd,
                                    );

                                    if (clippedEnd <= clippedStart) {
                                      return const SizedBox.shrink();
                                    }

                                    final minutesFromTop =
                                        clippedStart - visibleStart;
                                    final top =
                                        (minutesFromTop / 60.0) *
                                            hourRowHeight +
                                        3;

                                    final blockHeight =
                                        ((((clippedEnd - clippedStart) / 60.0) *
                                                    hourRowHeight) -
                                                6)
                                            .clamp(38.0, 220.0)
                                            .toDouble();

                                    final dayIndex = visibleWeekdays.indexOf(
                                      effectiveStart.weekday,
                                    );
                                    if (dayIndex == -1) {
                                      return const SizedBox.shrink();
                                    }

                                    final laneGap = 4.0;
                                    final availableWidth =
                                        resolvedDayWidth - 12;
                                    final laneWidth =
                                        (availableWidth -
                                            (placed.laneCount - 1) * laneGap) /
                                        placed.laneCount;

                                    final left =
                                        timeLabelWidth +
                                        (dayIndex * resolvedDayWidth) +
                                        6 +
                                        (placed.lane * (laneWidth + laneGap));

                                    final displayDuration = effectiveEnd
                                        .difference(effectiveStart)
                                        .inMinutes
                                        .clamp(15, 720);
                                    final displayLabel =
                                        '${DateFormat('h:mm a').format(effectiveStart)} - ${DateFormat('h:mm a').format(effectiveEnd)}';

                                    return Positioned(
                                      top: top,
                                      left: left,
                                      width: laneWidth,
                                      height: blockHeight,
                                      child: Stack(
                                        clipBehavior: Clip.none,
                                        children: [
                                          Positioned.fill(
                                            child: Draggable<_DraggedTaskData>(
                                              data: _DraggedTaskData(
                                                task: placed.task,
                                                durationMinutes:
                                                    displayDuration,
                                              ),
                                              maxSimultaneousDrags: 1,
                                              dragAnchorStrategy:
                                                  pointerDragAnchorStrategy,
                                              feedback: Material(
                                                color: Colors.transparent,
                                                child: Opacity(
                                                  opacity: 0.92,
                                                  child: SizedBox(
                                                    width: laneWidth,
                                                    height: blockHeight,
                                                    child: _TaskBlock(
                                                      task: placed.task,
                                                      color: colorForTask(
                                                        placed.task,
                                                      ),
                                                      timeLabel: displayLabel,
                                                      onTap: () {},
                                                    ),
                                                  ),
                                                ),
                                              ),
                                              childWhenDragging: Opacity(
                                                opacity: 0.24,
                                                child: _TaskBlock(
                                                  task: placed.task,
                                                  color: colorForTask(
                                                    placed.task,
                                                  ),
                                                  timeLabel: displayLabel,
                                                  onTap: () {},
                                                ),
                                              ),
                                              child: _TaskBlock(
                                                task: placed.task,
                                                color: colorForTask(
                                                  placed.task,
                                                ),
                                                timeLabel: displayLabel,
                                                onTap: () =>
                                                    onTaskTap(placed.task),
                                                onLongPress: () =>
                                                    onTaskDurationAdjust(
                                                      placed.task,
                                                    ),
                                                onDoubleTap: () =>
                                                    onTaskAdjust(placed.task),
                                              ),
                                            ),
                                          ),
                                          Positioned(
                                            top: -2,
                                            left: 8,
                                            right: 8,
                                            height: 14,
                                            child: GestureDetector(
                                              behavior:
                                                  HitTestBehavior.translucent,
                                              onVerticalDragStart: (_) {
                                                startHandleDy = 0;
                                              },
                                              onVerticalDragUpdate: (details) {
                                                startHandleDy +=
                                                    details.delta.dy;
                                                final rawDeltaMinutes =
                                                    ((startHandleDy /
                                                                hourRowHeight) *
                                                            60)
                                                        .round();
                                                final snappedDeltaMinutes =
                                                    ((rawDeltaMinutes / 15)
                                                        .round() *
                                                    15);
                                                final preview =
                                                    _resizeTaskWindow(
                                                      initialStart: baseStart,
                                                      initialEnd: baseEnd,
                                                      isStartHandle: true,
                                                      deltaMinutes:
                                                          snappedDeltaMinutes,
                                                    );
                                                setBlockState(() {
                                                  previewStart = preview.start;
                                                  previewEnd = preview.end;
                                                });
                                              },
                                              onVerticalDragEnd: (_) async {
                                                final rawDeltaMinutes =
                                                    ((startHandleDy /
                                                                hourRowHeight) *
                                                            60)
                                                        .round();
                                                final snappedDeltaMinutes =
                                                    ((rawDeltaMinutes / 15)
                                                        .round() *
                                                    15);

                                                if (snappedDeltaMinutes == 0) {
                                                  startHandleDy = 0;
                                                  return;
                                                }

                                                final resized =
                                                    _resizeTaskWindow(
                                                      initialStart: baseStart,
                                                      initialEnd: baseEnd,
                                                      isStartHandle: true,
                                                      deltaMinutes:
                                                          snappedDeltaMinutes,
                                                    );
                                                setBlockState(() {
                                                  previewStart = resized.start;
                                                  previewEnd = resized.end;
                                                });
                                                await onTaskEdgeResize(
                                                  placed.task,
                                                  resized.start,
                                                  resized.end,
                                                );
                                                startHandleDy = 0;
                                              },
                                              child: Align(
                                                alignment: Alignment.topCenter,
                                                child: Container(
                                                  width: laneWidth * 0.45,
                                                  height: 4,
                                                  decoration: BoxDecoration(
                                                    color: Colors.white
                                                        .withValues(
                                                          alpha: 0.92,
                                                        ),
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                          99,
                                                        ),
                                                  ),
                                                ),
                                              ),
                                            ),
                                          ),
                                          Positioned(
                                            bottom: -2,
                                            left: 8,
                                            right: 8,
                                            height: 14,
                                            child: GestureDetector(
                                              behavior:
                                                  HitTestBehavior.translucent,
                                              onVerticalDragStart: (_) {
                                                endHandleDy = 0;
                                              },
                                              onVerticalDragUpdate: (details) {
                                                endHandleDy += details.delta.dy;
                                                final rawDeltaMinutes =
                                                    ((endHandleDy /
                                                                hourRowHeight) *
                                                            60)
                                                        .round();
                                                final snappedDeltaMinutes =
                                                    ((rawDeltaMinutes / 15)
                                                        .round() *
                                                    15);
                                                final preview =
                                                    _resizeTaskWindow(
                                                      initialStart: baseStart,
                                                      initialEnd: baseEnd,
                                                      isStartHandle: false,
                                                      deltaMinutes:
                                                          snappedDeltaMinutes,
                                                    );
                                                setBlockState(() {
                                                  previewStart = preview.start;
                                                  previewEnd = preview.end;
                                                });
                                              },
                                              onVerticalDragEnd: (_) async {
                                                final rawDeltaMinutes =
                                                    ((endHandleDy /
                                                                hourRowHeight) *
                                                            60)
                                                        .round();
                                                final snappedDeltaMinutes =
                                                    ((rawDeltaMinutes / 15)
                                                        .round() *
                                                    15);

                                                if (snappedDeltaMinutes == 0) {
                                                  endHandleDy = 0;
                                                  return;
                                                }

                                                final resized =
                                                    _resizeTaskWindow(
                                                      initialStart: baseStart,
                                                      initialEnd: baseEnd,
                                                      isStartHandle: false,
                                                      deltaMinutes:
                                                          snappedDeltaMinutes,
                                                    );
                                                setBlockState(() {
                                                  previewStart = resized.start;
                                                  previewEnd = resized.end;
                                                });
                                                await onTaskEdgeResize(
                                                  placed.task,
                                                  resized.start,
                                                  resized.end,
                                                );
                                                endHandleDy = 0;
                                              },
                                              child: Align(
                                                alignment:
                                                    Alignment.bottomCenter,
                                                child: Container(
                                                  width: laneWidth * 0.45,
                                                  height: 4,
                                                  decoration: BoxDecoration(
                                                    color: Colors.white
                                                        .withValues(
                                                          alpha: 0.92,
                                                        ),
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                          99,
                                                        ),
                                                  ),
                                                ),
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                    );
                                  },
                                );
                              }),
                              if (placedTasks.isEmpty)
                                Positioned.fill(
                                  child: IgnorePointer(
                                    child: Center(
                                      child: Text(
                                        'No scheduled tasks this week',
                                        style: AppFonts.of(
                                          context,
                                          fontSize: 14,
                                          color: isDark
                                              ? Colors.white54
                                              : AppConstants.textSecondary,
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  List<Widget> _gridLines(
    BuildContext context,
    Color lineColor,
    double gridHeight,
    double resolvedDayWidth,
  ) {
    final lines = <Widget>[];

    for (var hour = startHour; hour <= endHour; hour++) {
      final top = (hour - startHour) * hourRowHeight;
      lines.add(
        Positioned(
          top: top,
          left: 0,
          right: 0,
          child: Container(height: 1, color: lineColor),
        ),
      );

      if (hour <= endHour) {
        final label = hour == endHour
            ? '12 AM'
            : DateFormat('h a').format(DateTime(2000, 1, 1, hour));
        lines.add(
          Positioned(
            top: hour == endHour ? top - 16 : top + 4,
            left: 6,
            width: timeLabelWidth - 10,
            child: Text(
              label,
              textAlign: TextAlign.right,
              style: AppFonts.of(
                context,
                fontSize: 11,
                color: isDark ? Colors.white54 : AppConstants.textSecondary,
              ),
            ),
          ),
        );
      }
    }

    for (var i = 0; i <= visibleWeekdays.length; i++) {
      final left = timeLabelWidth + (i * resolvedDayWidth);
      lines.add(
        Positioned(
          top: 0,
          bottom: 0,
          left: left,
          child: Container(width: 1, color: lineColor),
        ),
      );
    }

    lines.add(
      Positioned(
        top: 0,
        bottom: 0,
        left: 0,
        child: Container(width: 1, color: lineColor),
      ),
    );

    lines.add(
      Positioned(
        top: 0,
        bottom: 0,
        right: 0,
        child: Container(width: 1, color: lineColor),
      ),
    );

    lines.add(
      Positioned(
        top: gridHeight - 1,
        left: 0,
        right: 0,
        child: Container(height: 1, color: lineColor),
      ),
    );

    return lines;
  }
}

class _WeekDayHeader extends StatelessWidget {
  final bool isDark;
  final DateTime weekStart;
  final List<int> visibleWeekdays;
  final double dayColumnWidth;
  final double timeLabelWidth;

  const _WeekDayHeader({
    required this.isDark,
    required this.weekStart,
    required this.visibleWeekdays,
    required this.dayColumnWidth,
    required this.timeLabelWidth,
  });

  @override
  Widget build(BuildContext context) {
    final lineColor = isDark ? Colors.white12 : const Color(0xFFE0E1E5);

    return SizedBox(
      height: 56,
      child: Row(
        children: [
          SizedBox(width: timeLabelWidth),
          ...visibleWeekdays.map((weekday) {
            final dayDate = weekStart.add(
              Duration(days: weekday - DateTime.monday),
            );
            final isToday = _isSameDay(dayDate, DateTime.now());
            return Container(
              width: dayColumnWidth,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                border: Border(left: BorderSide(color: lineColor)),
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    DateFormat('EEE').format(dayDate).toUpperCase(),
                    style: AppFonts.of(
                      context,
                      fontSize: 15,
                      fontWeight: FontWeight.w700,
                      color: isDark ? Colors.white70 : AppConstants.textPrimary,
                    ),
                  ),
                  Text(
                    DateFormat('d').format(dayDate),
                    style: AppFonts.of(
                      context,
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: isToday
                          ? AppConstants.primaryColor
                          : (isDark
                                ? Colors.white54
                                : AppConstants.textSecondary),
                    ),
                  ),
                ],
              ),
            );
          }),
        ],
      ),
    );
  }

  bool _isSameDay(DateTime a, DateTime b) {
    return a.year == b.year && a.month == b.month && a.day == b.day;
  }
}

class _TaskBlock extends StatelessWidget {
  final Task task;
  final Color color;
  final String timeLabel;
  final VoidCallback onTap;
  final VoidCallback? onLongPress;
  final VoidCallback? onDoubleTap;

  const _TaskBlock({
    required this.task,
    required this.color,
    required this.timeLabel,
    required this.onTap,
    this.onLongPress,
    this.onDoubleTap,
  });

  @override
  Widget build(BuildContext context) {
    final categoryLabel = AppConstants.categoryLabel(task.category);

    return LayoutBuilder(
      builder: (context, constraints) {
        final isVeryShort = constraints.maxHeight < 46;
        final isShort = constraints.maxHeight < 64;
        final verticalPadding = isVeryShort ? 4.0 : 6.0;
        final showTime = !isVeryShort;
        final showCategory = !isShort;

        return Material(
          color: Colors.transparent,
          child: InkWell(
            borderRadius: BorderRadius.circular(6),
            onTap: onTap,
            onLongPress: onLongPress,
            onDoubleTap: onDoubleTap,
            child: Ink(
              decoration: BoxDecoration(
                color: color,
                borderRadius: BorderRadius.circular(6),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.16),
                    blurRadius: 6,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Padding(
                padding: EdgeInsets.fromLTRB(
                  8,
                  verticalPadding,
                  8,
                  verticalPadding,
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      task.title,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: AppFonts.of(
                        context,
                        fontSize: isVeryShort ? 11 : 13,
                        fontWeight: FontWeight.w700,
                        color: Colors.white,
                      ),
                    ),
                    if (showTime) ...[
                      const SizedBox(height: 2),
                      Text(
                        timeLabel,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: AppFonts.of(
                          context,
                          fontSize: isShort ? 10 : 12,
                          fontWeight: FontWeight.w600,
                          color: Colors.white.withValues(alpha: 0.96),
                        ),
                      ),
                    ],
                    if (showCategory) ...[
                      const SizedBox(height: 2),
                      Text(
                        categoryLabel,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: AppFonts.of(
                          context,
                          fontSize: 11,
                          color: Colors.white.withValues(alpha: 0.92),
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}

class _TaskWindow {
  final DateTime start;
  final DateTime end;

  const _TaskWindow({required this.start, required this.end});
}

class _DraggedTaskData {
  final Task task;
  final int durationMinutes;

  const _DraggedTaskData({required this.task, required this.durationMinutes});
}

class _TempPlacedTask {
  final Task task;
  final DateTime startDateTime;
  final int lane;

  const _TempPlacedTask({
    required this.task,
    required this.startDateTime,
    required this.lane,
  });
}

class _PlacedTask {
  final Task task;
  final DateTime startDateTime;
  final int lane;
  final int laneCount;

  const _PlacedTask({
    required this.task,
    required this.startDateTime,
    required this.lane,
    required this.laneCount,
  });
}
