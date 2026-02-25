import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../models/task.dart';
import '../services/task_provider.dart';
import '../services/app_settings_provider.dart';
import '../l10n/app_localizations.dart';
import '../utils/constants.dart';

/// Notifications screen showing overdue, due-today, and upcoming tasks.
class NotificationsScreen extends StatelessWidget {
  const NotificationsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final settings = context.watch<AppSettingsProvider>();
    final lang = settings.locale;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final tasks = context.watch<TaskProvider>().tasks;

    final now = DateTime.now();
    final todayStr =
        '${now.year}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')}';

    final overdue = tasks.where((t) => t.isOverdue).toList();
    final dueToday = tasks
        .where((t) => t.dueDate == todayStr && t.status != 'completed')
        .toList();
    final upcoming = tasks.where((t) {
      if (t.dueDate == null || t.status == 'completed') return false;
      try {
        final due = DateTime.parse(t.dueDate!);
        return due.isAfter(now) && t.dueDate != todayStr;
      } catch (_) {
        return false;
      }
    }).toList();

    return Scaffold(
      appBar: AppBar(
        title: Text(
          AppLocalizations.tr('notifications', lang),
          style: GoogleFonts.poppins(fontWeight: FontWeight.w700),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          if (overdue.isEmpty && dueToday.isEmpty && upcoming.isEmpty)
            Padding(
              padding: const EdgeInsets.only(top: 80),
              child: Center(
                child: Column(
                  children: [
                    Icon(
                      Icons.notifications_off_outlined,
                      size: 48,
                      color: isDark ? Colors.white30 : AppConstants.textLight,
                    ),
                    const SizedBox(height: 12),
                    Text(
                      AppLocalizations.tr('no_notifications', lang),
                      style: GoogleFonts.poppins(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: isDark
                            ? Colors.white70
                            : AppConstants.textPrimary,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          if (overdue.isNotEmpty) ...[
            _NotifSection(
              icon: Icons.error_outline_rounded,
              iconColor: AppConstants.errorColor,
              title: AppLocalizations.tr('overdue_tasks', lang),
              count: overdue.length,
              isDark: isDark,
            ),
            ...overdue.map(
              (t) => _NotifTile(task: t, type: 'overdue', isDark: isDark),
            ),
            const SizedBox(height: 20),
          ],
          if (dueToday.isNotEmpty) ...[
            _NotifSection(
              icon: Icons.warning_amber_rounded,
              iconColor: AppConstants.warningColor,
              title: AppLocalizations.tr('due_today', lang),
              count: dueToday.length,
              isDark: isDark,
            ),
            ...dueToday.map(
              (t) => _NotifTile(task: t, type: 'today', isDark: isDark),
            ),
            const SizedBox(height: 20),
          ],
          if (upcoming.isNotEmpty) ...[
            _NotifSection(
              icon: Icons.schedule_rounded,
              iconColor: AppConstants.accentSky,
              title: AppLocalizations.tr('upcoming', lang),
              count: upcoming.length,
              isDark: isDark,
            ),
            ...upcoming.map(
              (t) => _NotifTile(task: t, type: 'upcoming', isDark: isDark),
            ),
          ],
        ],
      ),
    );
  }
}

class _NotifSection extends StatelessWidget {
  final IconData icon;
  final Color iconColor;
  final String title;
  final int count;
  final bool isDark;
  const _NotifSection({
    required this.icon,
    required this.iconColor,
    required this.title,
    required this.count,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(
        children: [
          Icon(icon, size: 18, color: iconColor),
          const SizedBox(width: 8),
          Text(
            title,
            style: GoogleFonts.poppins(
              fontSize: 14,
              fontWeight: FontWeight.w700,
              color: isDark ? Colors.white70 : AppConstants.textPrimary,
            ),
          ),
          const SizedBox(width: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
            decoration: BoxDecoration(
              color: AppConstants.primaryLight.withValues(alpha: 0.3),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              '$count',
              style: GoogleFonts.poppins(
                fontSize: 12,
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

class _NotifTile extends StatelessWidget {
  final Task task;
  final String type;
  final bool isDark;
  const _NotifTile({
    required this.task,
    required this.type,
    required this.isDark,
  });

  IconData get _icon {
    switch (type) {
      case 'overdue':
        return Icons.warning_amber_rounded;
      case 'today':
        return Icons.today_rounded;
      default:
        return Icons.schedule_rounded;
    }
  }

  Color get _iconColor {
    switch (type) {
      case 'overdue':
        return AppConstants.errorColor;
      case 'today':
        return AppConstants.warningColor;
      default:
        return AppConstants.accentSky;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      decoration: BoxDecoration(
        color: isDark ? Colors.white.withValues(alpha: 0.08) : Colors.white,
        borderRadius: BorderRadius.circular(14),
        boxShadow: isDark
            ? []
            : [
                BoxShadow(
                  color: AppConstants.primaryColor.withValues(alpha: 0.05),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 4),
        leading: Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: _iconColor.withValues(alpha: 0.15),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(_icon, color: _iconColor, size: 20),
        ),
        title: Text(
          task.title,
          style: GoogleFonts.poppins(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: isDark ? Colors.white : AppConstants.textPrimary,
          ),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        subtitle: Text(
          task.dueDate ?? '',
          style: GoogleFonts.poppins(
            fontSize: 12,
            color: isDark ? Colors.white54 : AppConstants.textSecondary,
          ),
        ),
        trailing: Icon(
          Icons.chevron_right_rounded,
          color: isDark ? Colors.white30 : AppConstants.textLight,
        ),
        onTap: () {
          Navigator.pushNamed(context, '/edit', arguments: task);
        },
      ),
    );
  }
}
