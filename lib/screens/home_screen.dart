import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../models/task.dart';
import '../services/task_provider.dart';
import '../services/app_settings_provider.dart';
import '../l10n/app_localizations.dart';
import '../utils/constants.dart';
import '../widgets/app_drawer.dart';

/// Tiimo‑style Home Screen — "Today" view with date header, stats and tasks.
class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final provider = context.read<TaskProvider>();
      if (provider.tasks.isEmpty && !provider.isLoading) {
        provider.fetchTasks();
      }
    });
  }

  String _greeting(String lang) {
    final h = DateTime.now().hour;
    if (h < 12) return AppLocalizations.tr('good_morning', lang);
    if (h < 17) return AppLocalizations.tr('good_afternoon', lang);
    return AppLocalizations.tr('good_evening', lang);
  }

  static const _weekdays = [
    'Monday',
    'Tuesday',
    'Wednesday',
    'Thursday',
    'Friday',
    'Saturday',
    'Sunday',
  ];
  static const _months = [
    'January',
    'February',
    'March',
    'April',
    'May',
    'June',
    'July',
    'August',
    'September',
    'October',
    'November',
    'December',
  ];

  @override
  Widget build(BuildContext context) {
    final now = DateTime.now();
    final dayName = _weekdays[now.weekday - 1];
    final monthName = _months[now.month - 1];
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final settings = context.watch<AppSettingsProvider>();
    final lang = settings.locale;

    return Scaffold(
      appBar: AppBar(
        title: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.check_circle_rounded,
              size: 22,
              color: AppConstants.primaryColor,
            ),
            const SizedBox(width: 6),
            Text(
              AppConstants.appName,
              style: GoogleFonts.poppins(
                fontWeight: FontWeight.w700,
                color: isDark ? Colors.white : AppConstants.textPrimary,
              ),
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.notifications_none_rounded),
            onPressed: () => Navigator.pushNamed(context, '/notifications'),
          ),
        ],
      ),
      drawer: const AppDrawer(),
      body: RefreshIndicator(
        color: AppConstants.primaryColor,
        onRefresh: () => context.read<TaskProvider>().fetchTasks(),
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ── Date header ──
              Padding(
                padding: const EdgeInsets.fromLTRB(24, 8, 24, 0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      dayName,
                      style: GoogleFonts.poppins(
                        fontSize: 30,
                        fontWeight: FontWeight.w700,
                        color: isDark ? Colors.white : AppConstants.textPrimary,
                      ),
                    ),
                    Text(
                      '$monthName ${now.day}, ${now.year}',
                      style: GoogleFonts.poppins(
                        fontSize: 15,
                        color: isDark
                            ? Colors.white54
                            : AppConstants.textSecondary,
                        fontWeight: FontWeight.w400,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),

              // ── Greeting card ──
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [Color(0xFF9B8EC5), Color(0xFFB8ACE6)],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(
                      AppConstants.cardRadius,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: AppConstants.primaryColor.withValues(
                          alpha: 0.25,
                        ),
                        blurRadius: 20,
                        offset: const Offset(0, 8),
                      ),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '${_greeting(lang)}, ${settings.userName.split(' ').first}!',
                        style: GoogleFonts.poppins(
                          fontSize: 20,
                          fontWeight: FontWeight.w700,
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        AppLocalizations.tr('whats_your_plan', lang),
                        style: GoogleFonts.poppins(
                          fontSize: 14,
                          color: Colors.white70,
                        ),
                      ),
                      const SizedBox(height: 18),
                      SizedBox(
                        height: 42,
                        child: ElevatedButton.icon(
                          icon: const Icon(Icons.add_rounded, size: 20),
                          label: Text(
                            AppLocalizations.tr('new_task', lang),
                            style: GoogleFonts.poppins(
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.white,
                            foregroundColor: AppConstants.primaryColor,
                            elevation: 0,
                            shape: const StadiumBorder(),
                          ),
                          onPressed: () => Navigator.pushNamed(context, '/add'),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 24),

              // ── Stats row ──
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Consumer<TaskProvider>(
                  builder: (_, provider, __) => Row(
                    children: [
                      _StatBubble(
                        icon: Icons.assignment_outlined,
                        value: '${provider.totalTasks}',
                        label: AppLocalizations.tr('total', lang),
                        color: AppConstants.accentLavender,
                        isDark: isDark,
                      ),
                      const SizedBox(width: 10),
                      _StatBubble(
                        icon: Icons.pending_actions_rounded,
                        value: '${provider.pendingTasks}',
                        label: AppLocalizations.tr('pending', lang),
                        color: AppConstants.accentPeach,
                        isDark: isDark,
                      ),
                      const SizedBox(width: 10),
                      _StatBubble(
                        icon: Icons.sync_rounded,
                        value: '${provider.inProgressTasks}',
                        label: AppLocalizations.tr('active', lang),
                        color: AppConstants.accentSky,
                        isDark: isDark,
                      ),
                      const SizedBox(width: 10),
                      _StatBubble(
                        icon: Icons.check_circle_outline_rounded,
                        value: '${provider.completedTasks}',
                        label: AppLocalizations.tr('done', lang),
                        color: AppConstants.accentMint,
                        isDark: isDark,
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 28),

              // ── Task sections ──
              Consumer<TaskProvider>(
                builder: (_, provider, __) {
                  if (provider.isLoading && provider.tasks.isEmpty) {
                    return const Padding(
                      padding: EdgeInsets.only(top: 60),
                      child: Center(child: CircularProgressIndicator()),
                    );
                  }
                  if (provider.tasks.isEmpty) {
                    return Padding(
                      padding: const EdgeInsets.only(top: 60),
                      child: Center(
                        child: Column(
                          children: [
                            Icon(
                              Icons.wb_sunny_outlined,
                              size: 48,
                              color: isDark
                                  ? Colors.white38
                                  : AppConstants.textLight,
                            ),
                            const SizedBox(height: 12),
                            Text(
                              AppLocalizations.tr('no_tasks_yet', lang),
                              style: GoogleFonts.poppins(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                                color: isDark
                                    ? Colors.white
                                    : AppConstants.textPrimary,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              AppLocalizations.tr('tap_to_create', lang),
                              style: GoogleFonts.poppins(
                                fontSize: 13,
                                color: isDark
                                    ? Colors.white54
                                    : AppConstants.textSecondary,
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  }

                  final pending = provider.tasks
                      .where((t) => t.status == 'pending')
                      .toList();
                  final inProgress = provider.tasks
                      .where((t) => t.status == 'in_progress')
                      .toList();
                  final completed = provider.tasks
                      .where((t) => t.status == 'completed')
                      .toList();

                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      if (pending.isNotEmpty) ...[
                        _SectionHeader(
                          icon: Icons.radio_button_unchecked,
                          title: AppLocalizations.tr(
                            'pending',
                            lang,
                          ).toUpperCase(),
                          count: pending.length,
                          isDark: isDark,
                        ),
                        ...pending.map(
                          (t) => _MiniTaskTile(
                            task: t,
                            parentContext: context,
                            isDark: isDark,
                          ),
                        ),
                        const SizedBox(height: 16),
                      ],
                      if (inProgress.isNotEmpty) ...[
                        _SectionHeader(
                          icon: Icons.timelapse_rounded,
                          title: AppLocalizations.tr(
                            'in_progress',
                            lang,
                          ).toUpperCase(),
                          count: inProgress.length,
                          isDark: isDark,
                        ),
                        ...inProgress.map(
                          (t) => _MiniTaskTile(
                            task: t,
                            parentContext: context,
                            isDark: isDark,
                          ),
                        ),
                        const SizedBox(height: 16),
                      ],
                      if (completed.isNotEmpty) ...[
                        _SectionHeader(
                          icon: Icons.check_circle_rounded,
                          title: AppLocalizations.tr(
                            'completed',
                            lang,
                          ).toUpperCase(),
                          count: completed.length,
                          isDark: isDark,
                        ),
                        ...completed.map(
                          (t) => _MiniTaskTile(
                            task: t,
                            parentContext: context,
                            isDark: isDark,
                          ),
                        ),
                      ],
                      const SizedBox(height: 32),
                    ],
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ── Stat bubble ──
class _StatBubble extends StatelessWidget {
  final IconData icon;
  final String value;
  final String label;
  final Color color;
  final bool isDark;

  const _StatBubble({
    required this.icon,
    required this.value,
    required this.label,
    required this.color,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 14),
        decoration: BoxDecoration(
          color: isDark
              ? color.withValues(alpha: 0.15)
              : color.withValues(alpha: 0.35),
          borderRadius: BorderRadius.circular(16),
        ),
        child: Column(
          children: [
            Icon(
              icon,
              size: 22,
              color: isDark ? Colors.white70 : AppConstants.textPrimary,
            ),
            const SizedBox(height: 4),
            Text(
              value,
              style: GoogleFonts.poppins(
                fontSize: 20,
                fontWeight: FontWeight.w700,
                color: isDark ? Colors.white : AppConstants.textPrimary,
              ),
            ),
            Text(
              label,
              style: GoogleFonts.poppins(
                fontSize: 11,
                color: isDark ? Colors.white54 : AppConstants.textSecondary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ── Section header ──
class _SectionHeader extends StatelessWidget {
  final IconData icon;
  final String title;
  final int count;
  final bool isDark;

  const _SectionHeader({
    required this.icon,
    required this.title,
    required this.count,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 0, 24, 8),
      child: Row(
        children: [
          Icon(
            icon,
            size: 16,
            color: isDark ? Colors.white54 : AppConstants.textSecondary,
          ),
          const SizedBox(width: 6),
          Text(
            title,
            style: GoogleFonts.poppins(
              fontSize: 12,
              fontWeight: FontWeight.w700,
              color: isDark ? Colors.white54 : AppConstants.textSecondary,
              letterSpacing: 1.2,
            ),
          ),
          const SizedBox(width: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 1),
            decoration: BoxDecoration(
              color: AppConstants.primaryLight.withValues(alpha: 0.3),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              '$count',
              style: GoogleFonts.poppins(
                fontSize: 11,
                fontWeight: FontWeight.w600,
                color: AppConstants.primaryDark,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ── Mini task tile for the home screen with swipe gestures ──
class _MiniTaskTile extends StatelessWidget {
  final Task task;
  final BuildContext parentContext;
  final bool isDark;

  const _MiniTaskTile({
    required this.task,
    required this.parentContext,
    required this.isDark,
  });

  String _shortDate(String? raw) {
    if (raw == null) return '';
    try {
      final d = DateTime.parse(raw);
      const months = [
        'Jan',
        'Feb',
        'Mar',
        'Apr',
        'May',
        'Jun',
        'Jul',
        'Aug',
        'Sep',
        'Oct',
        'Nov',
        'Dec',
      ];
      return '${months[d.month - 1]} ${d.day}';
    } catch (_) {
      return raw.length > 10 ? raw.substring(0, 10) : raw;
    }
  }

  @override
  Widget build(BuildContext context) {
    final isCompleted = task.status == 'completed';
    final bgColor = AppConstants.statusBgColor(task.status);
    final provider = context.read<TaskProvider>();

    return Dismissible(
      key: ValueKey('home_task_${task.id}'),
      // Swipe right to complete
      background: Container(
        margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 5),
        decoration: BoxDecoration(
          color: AppConstants.successColor,
          borderRadius: BorderRadius.circular(16),
        ),
        alignment: Alignment.centerLeft,
        padding: const EdgeInsets.only(left: 20),
        child: const Row(
          children: [
            Icon(Icons.check_circle_rounded, color: Colors.white),
            SizedBox(width: 8),
            Text(
              'Complete',
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
      // Swipe left to delete
      secondaryBackground: Container(
        margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 5),
        decoration: BoxDecoration(
          color: AppConstants.errorColor,
          borderRadius: BorderRadius.circular(16),
        ),
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 20),
        child: const Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            Text(
              'Delete',
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w600,
              ),
            ),
            SizedBox(width: 8),
            Icon(Icons.delete_rounded, color: Colors.white),
          ],
        ),
      ),
      confirmDismiss: (direction) async {
        if (direction == DismissDirection.startToEnd) {
          // Complete
          await provider.toggleTaskStatus(task);
          return false; // Don't remove from list, just update
        } else {
          // Delete - show confirmation
          final confirmed = await showDialog<bool>(
            context: parentContext,
            builder: (ctx) => AlertDialog(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              title: const Text('Delete Task'),
              content: Text('Delete "${task.title}"?'),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(ctx, false),
                  child: const Text('Cancel'),
                ),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppConstants.errorColor,
                    foregroundColor: Colors.white,
                  ),
                  onPressed: () => Navigator.pop(ctx, true),
                  child: const Text('Delete'),
                ),
              ],
            ),
          );
          if (confirmed == true) {
            await provider.deleteTask(task.id!);
            return false;
          }
          return false;
        }
      },
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 5),
        decoration: BoxDecoration(
          color: isCompleted
              ? (isDark
                    ? AppConstants.accentMint.withValues(alpha: 0.08)
                    : AppConstants.accentMint.withValues(alpha: 0.1))
              : (isDark ? AppConstants.darkCard : Colors.white),
          borderRadius: BorderRadius.circular(16),
          border: isCompleted
              ? Border.all(
                  color: AppConstants.successColor.withValues(alpha: 0.25),
                  width: 1,
                )
              : null,
          boxShadow: isDark
              ? []
              : [
                  BoxShadow(
                    color: AppConstants.primaryColor.withValues(alpha: 0.05),
                    blurRadius: 10,
                    offset: const Offset(0, 3),
                  ),
                ],
        ),
        child: Material(
          color: Colors.transparent,
          borderRadius: BorderRadius.circular(16),
          child: InkWell(
            borderRadius: BorderRadius.circular(16),
            onTap: () =>
                Navigator.pushNamed(parentContext, '/edit', arguments: task),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
              child: Row(
                children: [
                  Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: bgColor.withValues(alpha: 0.45),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Center(
                      child: Icon(
                        AppConstants.statusIcon(task.status),
                        size: 20,
                        color: AppConstants.statusColor(task.status),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          task.title,
                          style: GoogleFonts.poppins(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: isCompleted
                                ? (isDark
                                      ? Colors.white54
                                      : AppConstants.textSecondary)
                                : (isDark
                                      ? Colors.white
                                      : AppConstants.textPrimary),
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        if (task.dueDate != null)
                          Text(
                            _shortDate(task.dueDate),
                            style: GoogleFonts.poppins(
                              fontSize: 12,
                              color: isDark
                                  ? Colors.white38
                                  : AppConstants.textSecondary,
                            ),
                          ),
                      ],
                    ),
                  ),
                  Container(
                    width: 24,
                    height: 24,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: isCompleted
                          ? AppConstants.successColor
                          : Colors.transparent,
                      border: Border.all(
                        color: isCompleted
                            ? AppConstants.successColor
                            : (isDark
                                  ? Colors.white24
                                  : AppConstants.textLight),
                        width: 2,
                      ),
                    ),
                    child: isCompleted
                        ? const Icon(Icons.check, color: Colors.white, size: 14)
                        : null,
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
