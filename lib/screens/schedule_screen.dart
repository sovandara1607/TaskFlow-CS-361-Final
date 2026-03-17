import 'package:flutter/material.dart';
import 'package:flutter_final_project_app_with_full_ui_and_api_crud_integration/widgets/TextTheme.dart';
import 'package:provider/provider.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:intl/intl.dart';
import '../models/task.dart';
import '../services/task_provider.dart';
import '../services/app_settings_provider.dart';
import '../l10n/app_localizations.dart';
import '../utils/constants.dart';
import '../widgets/glass_container.dart';

/// Schedule Screen — Calendar + Today/Upcoming/Overdue tabs.
class ScheduleScreen extends StatefulWidget {
  const ScheduleScreen({super.key});

  @override
  State<ScheduleScreen> createState() => _ScheduleScreenState();
}

class _ScheduleScreenState extends State<ScheduleScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  CalendarFormat _calendarFormat = CalendarFormat.month;
  DateTime _focusedDay = DateTime.now();
  DateTime? _selectedDay;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _selectedDay = DateTime.now();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      final provider = context.read<TaskProvider>();
      if (provider.tasks.isEmpty && !provider.isLoading) {
        provider.fetchTasks();
      }
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final lang = context.watch<AppSettingsProvider>().locale;

    return Scaffold(
      appBar: AppBar(
        title: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.calendar_month_rounded,
              size: 22,
              color: AppConstants.primaryColor,
            ),
            const SizedBox(width: 6),
            Text(
              AppLocalizations.tr('schedule', lang),
              style: AppFonts.of(
                context,
                fontWeight: FontWeight.w700,
                color: isDark ? Colors.white : AppConstants.textPrimary,
              ),
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.today_rounded),
            tooltip: 'Go to today',
            onPressed: () => setState(() {
              _focusedDay = DateTime.now();
              _selectedDay = DateTime.now();
            }),
          ),
          IconButton(
            icon: const Icon(Icons.refresh_rounded),
            onPressed: () => context.read<TaskProvider>().fetchTasks(),
          ),
        ],
      ),
      body: Consumer<TaskProvider>(
        builder: (context, provider, __) {
          if (provider.isLoading && provider.tasks.isEmpty) {
            return const Center(child: CircularProgressIndicator());
          }

          return Column(
            children: [
              // ── Calendar ──
              _buildCalendar(provider, isDark),

              // ── Tab bar ──
              Container(
                margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                decoration: BoxDecoration(
                  color: isDark
                      ? Colors.white.withValues(alpha: 0.08)
                      : const Color(0xFFF0F0F0),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: TabBar(
                  controller: _tabController,
                  indicator: BoxDecoration(
                    color: isDark
                        ? Colors.white.withValues(alpha: 0.18)
                        : Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.06),
                        blurRadius: 8,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  indicatorSize: TabBarIndicatorSize.tab,
                  dividerColor: Colors.transparent,
                  labelColor: isDark ? Colors.white : AppConstants.textPrimary,
                  unselectedLabelColor: isDark
                      ? Colors.white38
                      : AppConstants.textSecondary,
                  labelStyle: AppFonts.of(
                    context,
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                  ),
                  unselectedLabelStyle: AppFonts.of(
                    context,
                    fontSize: 13,
                    fontWeight: FontWeight.w500,
                  ),
                  tabs: [
                    Tab(
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(Icons.today_rounded, size: 16),
                          const SizedBox(width: 4),
                          Text('Today (${provider.todayTasks.length})'),
                        ],
                      ),
                    ),
                    Tab(
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(Icons.upcoming_rounded, size: 16),
                          const SizedBox(width: 4),
                          Text('Soon (${provider.upcomingTasks.length})'),
                        ],
                      ),
                    ),
                    Tab(
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.warning_amber_rounded,
                            size: 16,
                            color: provider.overdueTasks.isNotEmpty
                                ? AppConstants.errorColor
                                : null,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            'Late (${provider.overdueTasks.length})',
                            style: provider.overdueTasks.isNotEmpty
                                ? TextStyle(color: AppConstants.errorColor)
                                : null,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              // ── Tab content ──
              Expanded(
                child: TabBarView(
                  controller: _tabController,
                  children: [
                    _buildTaskList(provider.todayTasks, isDark, 'today'),
                    _buildTaskList(provider.upcomingTasks, isDark, 'upcoming'),
                    _buildTaskList(provider.overdueTasks, isDark, 'overdue'),
                  ],
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildCalendar(TaskProvider provider, bool isDark) {
    final taskDates = provider.taskDates;

    return GlassContainer(
      borderRadius: 20,
      margin: const EdgeInsets.fromLTRB(16, 4, 16, 4),
      child: TableCalendar(
        firstDay: DateTime.utc(2020, 1, 1),
        lastDay: DateTime.utc(2030, 12, 31),
        focusedDay: _focusedDay,
        calendarFormat: _calendarFormat,
        selectedDayPredicate: (day) => isSameDay(_selectedDay, day),
        onDaySelected: (selectedDay, focusedDay) {
          setState(() {
            _selectedDay = selectedDay;
            _focusedDay = focusedDay;
          });
          // Show tasks for the selected day
          final tasksForDay = provider.tasksForDate(selectedDay);
          if (tasksForDay.isNotEmpty) {
            _showDayTasks(selectedDay, tasksForDay, isDark);
          }
        },
        onFormatChanged: (format) {
          setState(() => _calendarFormat = format);
        },
        onPageChanged: (focusedDay) {
          _focusedDay = focusedDay;
        },
        eventLoader: (day) {
          final normalizedDay = DateTime(day.year, day.month, day.day);
          return taskDates.contains(normalizedDay)
              ? ['task'] // non-empty list means this day has events
              : [];
        },
        calendarStyle: CalendarStyle(
          todayDecoration: BoxDecoration(
            color: AppConstants.primaryColor.withValues(alpha: 0.3),
            shape: BoxShape.circle,
          ),
          selectedDecoration: BoxDecoration(
            color: AppConstants.primaryColor,
            shape: BoxShape.circle,
          ),
          todayTextStyle: AppFonts.of(
            context,
            fontWeight: FontWeight.w700,
            color: isDark ? Colors.white : AppConstants.textPrimary,
          ),
          selectedTextStyle: AppFonts.of(
            context,
            fontWeight: FontWeight.w700,
            color: Colors.white,
          ),
          defaultTextStyle: AppFonts.of(
            context,
            color: isDark ? Colors.white : AppConstants.textPrimary,
          ),
          weekendTextStyle: AppFonts.of(
            context,
            color: isDark ? Colors.white54 : AppConstants.textSecondary,
          ),
          outsideTextStyle: AppFonts.of(
            context,
            color: isDark ? Colors.white24 : AppConstants.textLight,
          ),
          markerDecoration: BoxDecoration(
            color: AppConstants.primaryColor,
            shape: BoxShape.circle,
          ),
          markerSize: 6,
          markersMaxCount: 1,
          markerMargin: const EdgeInsets.only(top: 2),
        ),
        headerStyle: HeaderStyle(
          titleCentered: true,
          formatButtonVisible: true,
          formatButtonDecoration: BoxDecoration(
            border: Border.all(
              color: isDark ? Colors.white24 : AppConstants.textLight,
            ),
            borderRadius: BorderRadius.circular(12),
          ),
          formatButtonTextStyle: AppFonts.of(
            context,
            fontSize: 12,
            color: isDark ? Colors.white70 : AppConstants.textSecondary,
          ),
          titleTextStyle: AppFonts.of(
            context,
            fontSize: 16,
            fontWeight: FontWeight.w700,
            color: isDark ? Colors.white : AppConstants.textPrimary,
          ),
          leftChevronIcon: Icon(
            Icons.chevron_left_rounded,
            color: isDark ? Colors.white70 : AppConstants.textSecondary,
          ),
          rightChevronIcon: Icon(
            Icons.chevron_right_rounded,
            color: isDark ? Colors.white70 : AppConstants.textSecondary,
          ),
        ),
        daysOfWeekStyle: DaysOfWeekStyle(
          weekdayStyle: AppFonts.of(
            context,
            fontSize: 12,
            fontWeight: FontWeight.w600,
            color: isDark ? Colors.white54 : AppConstants.textSecondary,
          ),
          weekendStyle: AppFonts.of(
            context,
            fontSize: 12,
            fontWeight: FontWeight.w600,
            color: isDark ? Colors.white38 : AppConstants.textLight,
          ),
        ),
      ),
    );
  }

  Widget _buildTaskList(List<Task> tasks, bool isDark, String type) {
    if (tasks.isEmpty) {
      IconData emptyIcon;
      String emptyLabel;
      switch (type) {
        case 'today':
          emptyIcon = Icons.wb_sunny_outlined;
          emptyLabel = 'No tasks scheduled for today';
          break;
        case 'upcoming':
          emptyIcon = Icons.event_available_rounded;
          emptyLabel = 'No upcoming tasks';
          break;
        default:
          emptyIcon = Icons.check_circle_outline_rounded;
          emptyLabel = 'No overdue tasks - great job!';
      }

      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              emptyIcon,
              size: 48,
              color: isDark ? Colors.white38 : AppConstants.textLight,
            ),
            const SizedBox(height: 12),
            Text(
              emptyLabel,
              style: AppFonts.of(
                context,
                fontSize: 15,
                fontWeight: FontWeight.w500,
                color: isDark ? Colors.white54 : AppConstants.textSecondary,
              ),
            ),
          ],
        ),
      );
    }

    return RefreshIndicator(
      color: AppConstants.primaryColor,
      onRefresh: () => context.read<TaskProvider>().fetchTasks(),
      child: ListView.builder(
        padding: EdgeInsets.only(
          top: 8,
          bottom: AppConstants.bottomNavBarSpace,
        ),
        itemCount: tasks.length,
        itemBuilder: (context, index) {
          return _ScheduleTaskTile(
            task: tasks[index],
            type: type,
            isDark: isDark,
            onTap: () =>
                Navigator.pushNamed(context, '/edit', arguments: tasks[index]),
          );
        },
      ),
    );
  }

  void _showDayTasks(DateTime day, List<Task> tasks, bool isDark) {
    final dateStr = DateFormat('EEEE, MMM d').format(day);

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: isDark
          ? AppConstants.glassSheetDark
          : AppConstants.glassSheetLight,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) {
        return DraggableScrollableSheet(
          initialChildSize: 0.4,
          minChildSize: 0.3,
          maxChildSize: 0.7,
          expand: false,
          builder: (_, scrollController) {
            return Padding(
              padding: const EdgeInsets.fromLTRB(20, 12, 20, 20),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Center(
                    child: Container(
                      width: 40,
                      height: 4,
                      decoration: BoxDecoration(
                        color: AppConstants.textLight,
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Icon(
                        Icons.calendar_today_rounded,
                        size: 18,
                        color: AppConstants.primaryColor,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        dateStr,
                        style: AppFonts.of(
                          context,
                          fontSize: 18,
                          fontWeight: FontWeight.w700,
                          color: isDark
                              ? Colors.white
                              : AppConstants.textPrimary,
                        ),
                      ),
                      const Spacer(),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: AppConstants.primaryColor.withValues(
                            alpha: 0.12,
                          ),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Text(
                          '${tasks.length} task${tasks.length != 1 ? 's' : ''}',
                          style: AppFonts.of(
                            context,
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: AppConstants.primaryColor,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Expanded(
                    child: ListView.builder(
                      controller: scrollController,
                      itemCount: tasks.length,
                      itemBuilder: (_, i) => _ScheduleTaskTile(
                        task: tasks[i],
                        type: tasks[i].isOverdue ? 'overdue' : 'today',
                        isDark: isDark,
                        onTap: () {
                          Navigator.pop(ctx);
                          Navigator.pushNamed(
                            context,
                            '/edit',
                            arguments: tasks[i],
                          );
                        },
                      ),
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }
}

// ── Schedule task tile with time, status indicator ──
class _ScheduleTaskTile extends StatelessWidget {
  final Task task;
  final String type; // today, upcoming, overdue
  final bool isDark;
  final VoidCallback onTap;

  const _ScheduleTaskTile({
    required this.task,
    required this.type,
    required this.isDark,
    required this.onTap,
  });

  Color get _accentColor {
    switch (type) {
      case 'overdue':
        return AppConstants.errorColor;
      case 'upcoming':
        return AppConstants.accentSky;
      default: // today
        return AppConstants.primaryColor;
    }
  }

  @override
  Widget build(BuildContext context) {
    final isCompleted = task.status == 'completed';
    final timeStr = task.scheduledAt != null
        ? DateFormat('h:mm a').format(task.scheduledAt!)
        : null;
    final dateStr = task.effectiveDate != null
        ? DateFormat('MMM d').format(task.effectiveDate!)
        : null;

    return GlassContainer(
      borderRadius: 16,
      margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 4),
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(16),
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.all(14),
            child: Row(
              children: [
                // Status indicator
                Container(
                  width: 4,
                  height: 44,
                  decoration: BoxDecoration(
                    color: isCompleted
                        ? AppConstants.successColor
                        : _accentColor,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
                const SizedBox(width: 12),
                // Time column
                if (timeStr != null) ...[
                  SizedBox(
                    width: 60,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          timeStr,
                          style: AppFonts.of(
                            context,
                            fontSize: 13,
                            fontWeight: FontWeight.w700,
                            color: isCompleted
                                ? (isDark
                                    ? Colors.white38
                                    : AppConstants.textLight)
                                : (isDark
                                    ? Colors.white
                                    : AppConstants.textPrimary),
                          ),
                        ),
                        if (type == 'upcoming' && dateStr != null)
                          Text(
                            dateStr,
                            style: AppFonts.of(
                              context,
                              fontSize: 11,
                              color: isDark
                                  ? Colors.white38
                                  : AppConstants.textSecondary,
                            ),
                          ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 8),
                ] else if (dateStr != null) ...[
                  SizedBox(
                    width: 60,
                    child: Text(
                      dateStr,
                      style: AppFonts.of(
                        context,
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: isDark
                            ? Colors.white54
                            : AppConstants.textSecondary,
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                ],
                // Title and category
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        task.title,
                        style: AppFonts.of(
                          context,
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: isCompleted
                              ? (isDark
                                  ? Colors.white38
                                  : AppConstants.textLight)
                              : (isDark
                                  ? Colors.white
                                  : AppConstants.textPrimary),
                          decoration: isCompleted
                              ? TextDecoration.lineThrough
                              : null,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 2),
                      Row(
                        children: [
                          Icon(
                            AppConstants.categoryIcon(task.category),
                            size: 12,
                            color: isDark
                                ? Colors.white38
                                : AppConstants.textSecondary,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            AppConstants.categoryLabel(task.category),
                            style: AppFonts.of(
                              context,
                              fontSize: 11,
                              color: isDark
                                  ? Colors.white38
                                  : AppConstants.textSecondary,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                // Status badge
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: isCompleted
                        ? AppConstants.successColor.withValues(alpha: 0.15)
                        : _accentColor.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        isCompleted
                            ? Icons.check_circle_rounded
                            : AppConstants.statusIcon(task.status),
                        size: 14,
                        color: isCompleted
                            ? AppConstants.successColor
                            : _accentColor,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        task.statusLabel,
                        style: AppFonts.of(
                          context,
                          fontSize: 10,
                          fontWeight: FontWeight.w600,
                          color: isCompleted
                              ? AppConstants.successColor
                              : _accentColor,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
