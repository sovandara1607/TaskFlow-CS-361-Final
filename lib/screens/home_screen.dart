import 'package:flutter/material.dart';
import 'package:flutter_final_project_app_with_full_ui_and_api_crud_integration/widgets/TextTheme.dart';
import 'package:provider/provider.dart';
import '../models/task.dart';
import '../services/task_provider.dart';
import '../services/app_settings_provider.dart';
import '../services/auth_provider.dart';
import '../l10n/app_localizations.dart';
import '../utils/constants.dart';
import '../widgets/app_drawer.dart';
import '../widgets/glass_container.dart';

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
    final auth = context.watch<AuthProvider>();
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
              style: AppFonts.of(context, 
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
                      style: AppFonts.of(context, 
                        fontSize: 30,
                        fontWeight: FontWeight.w700,
                        color: isDark ? Colors.white : AppConstants.textPrimary,
                      ),
                    ),
                    Text(
                      '$monthName ${now.day}, ${now.year}',
                      style: AppFonts.of(context, 
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

              // ── Greeting card (animated by time of day) ──
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: _GreetingCard(
                  greeting: _greeting(lang),
                  userName: (auth.userName ?? 'User').split(' ').first,
                  subtitle: AppLocalizations.tr('whats_your_plan', lang),
                  buttonLabel: AppLocalizations.tr('new_task', lang),
                  onNewTask: () => Navigator.pushNamed(context, '/add'),
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
                              style: AppFonts.of(context, 
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
                              style: AppFonts.of(context, 
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
                      SizedBox(height: AppConstants.bottomNavBarSpace),
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
      child: Column(
        children: [
          GlassContainer(
            borderRadius: 16,
            padding: const EdgeInsets.symmetric(vertical: 18),
            child: Center(
              child: Icon(
                icon,
                size: 28,
                color: isDark ? Colors.white : color,
              ),
            ),
          ),
          const SizedBox(height: 6),
          Text(
            value,
            style: AppFonts.of(context, 
              fontSize: 20,
              fontWeight: FontWeight.w700,
              color: isDark ? Colors.white : AppConstants.textPrimary,
            ),
          ),
          Text(
            label,
            style: AppFonts.of(context, 
              fontSize: 11,
              color: isDark ? Colors.white70 : AppConstants.textSecondary,
            ),
          ),
        ],
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
            style: AppFonts.of(context, 
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
              style: AppFonts.of(context, 
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
    final provider = context.read<TaskProvider>();

    return Dismissible(
      key: ValueKey('home_task_${task.id}'),
      // Swipe right to complete
      background: Container(
        margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 5),
        decoration: BoxDecoration(
          color: AppConstants.successColor.withValues(alpha: 0.7),
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
          color: AppConstants.errorColor.withValues(alpha: 0.7),
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
              backgroundColor: Theme.of(ctx).brightness == Brightness.dark
                  ? AppConstants.glassDialogDark
                  : AppConstants.glassDialogLight,
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
      child: GlassContainer(
        borderRadius: 16,
        margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 5),
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
                      color: AppConstants.statusBgColorGlass(task.status),
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
                          style: AppFonts.of(context, 
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
                            style: AppFonts.of(context, 
                              fontSize: 12,
                              color: isDark
                                  ? Colors.white38
                                  : AppConstants.textSecondary,
                            ),
                          ),
                      ],
                    ),
                  ),
                  GestureDetector(
                    onTap: () => provider.toggleTaskStatus(task),
                    child: Container(
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
                          ? const Icon(
                              Icons.check,
                              color: Colors.white,
                              size: 14,
                            )
                          : null,
                    ),
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

// ── Animated greeting card based on time of day ──
class _GreetingCard extends StatefulWidget {
  final String greeting;
  final String userName;
  final String subtitle;
  final String buttonLabel;
  final VoidCallback onNewTask;

  const _GreetingCard({
    required this.greeting,
    required this.userName,
    required this.subtitle,
    required this.buttonLabel,
    required this.onNewTask,
  });

  @override
  State<_GreetingCard> createState() => _GreetingCardState();
}

class _GreetingCardState extends State<_GreetingCard>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _floatAnim;
  late Animation<double> _fadeAnim;
  late Animation<double> _glowAnim;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 3),
    )..repeat(reverse: true);

    _floatAnim = Tween<double>(
      begin: 0,
      end: -8,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeInOut));
    _fadeAnim = Tween<double>(
      begin: 0.6,
      end: 1.0,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeInOut));
    _glowAnim = Tween<double>(
      begin: 0.15,
      end: 0.35,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeInOut));
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  ({
    List<Color> gradient,
    IconData icon,
    Color iconColor,
    Color shadowColor,
    Color buttonFg,
  })
  _timeTheme() {
    final h = DateTime.now().hour;
    if (h >= 5 && h < 12) {
      // Morning — warm sunrise
      return (
        gradient: [const Color(0xFFFFA751), const Color(0xFFFFE259)],
        icon: Icons.wb_sunny_rounded,
        iconColor: const Color(0xFFFFF3C4),
        shadowColor: const Color(0xFFFFA751),
        buttonFg: const Color(0xFFE8930C),
      );
    } else if (h >= 12 && h < 17) {
      // Afternoon — bright sky
      return (
        gradient: [const Color(0xFF56CCF2), const Color(0xFF2F80ED)],
        icon: Icons.wb_cloudy_rounded,
        iconColor: const Color(0xFFD6EFFF),
        shadowColor: const Color(0xFF2F80ED),
        buttonFg: const Color(0xFF2F80ED),
      );
    } else if (h >= 17 && h < 20) {
      // Evening — sunset
      return (
        gradient: [const Color(0xFFFF6B6B), const Color(0xFFFF8E53)],
        icon: Icons.wb_twilight_rounded,
        iconColor: const Color(0xFFFFDDD2),
        shadowColor: const Color(0xFFFF6B6B),
        buttonFg: const Color(0xFFE85D3A),
      );
    } else {
      // Night — deep charcoal
      return (
        gradient: [const Color(0xFF263238), const Color(0xFF455A64)],
        icon: Icons.nightlight_round,
        iconColor: const Color(0xFFCFD8DC),
        shadowColor: const Color(0xFF263238),
        buttonFg: const Color(0xFF455A64),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = _timeTheme();

    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return DecoratedBox(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: theme.gradient,
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(AppConstants.cardRadius),
            boxShadow: [
              BoxShadow(
                color: theme.shadowColor.withValues(alpha: _glowAnim.value),
                blurRadius: 24,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Row(
              children: [
                // ── Text + button ──
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '${widget.greeting}, ${widget.userName}!',
                        style: AppFonts.of(context, 
                          fontSize: 20,
                          fontWeight: FontWeight.w700,
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        widget.subtitle,
                        style: AppFonts.of(context, 
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
                            widget.buttonLabel,
                            style: AppFonts.of(context, 
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.white,
                            foregroundColor: theme.buttonFg,
                            elevation: 0,
                            shape: const StadiumBorder(),
                          ),
                          onPressed: widget.onNewTask,
                        ),
                      ),
                    ],
                  ),
                ),
                // ── Floating time icon ──
                Transform.translate(
                  offset: Offset(0, _floatAnim.value),
                  child: Opacity(
                    opacity: _fadeAnim.value,
                    child: Icon(theme.icon, size: 64, color: theme.iconColor),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
