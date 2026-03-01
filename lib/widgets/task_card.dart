import 'package:flutter/material.dart';
import 'package:flutter_final_project_app_with_full_ui_and_api_crud_integration/widgets/TextTheme.dart';
import '../models/task.dart';
import '../utils/constants.dart';
import 'glass_container.dart';

/// Playful pastel task card — soft tinted backgrounds, bold title,
/// category subtitle, and a frosted status pill.
class TaskCard extends StatelessWidget {
  final Task task;
  final VoidCallback? onTap;
  final VoidCallback? onEdit;
  final VoidCallback? onDelete;
  final ValueChanged<String>? onStatusChange;

  const TaskCard({
    super.key,
    required this.task,
    this.onTap,
    this.onEdit,
    this.onDelete,
    this.onStatusChange,
  });

  // ── helpers ──────────────────────────────────────────────────

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

  void _showStatusMenu(BuildContext context, Offset position) async {
    final statuses = [
      (
        'pending',
        'Pending',
        Icons.radio_button_unchecked,
        AppConstants.primaryColor,
      ),
      (
        'in_progress',
        'In Progress',
        Icons.timelapse_rounded,
        AppConstants.warningColor,
      ),
      (
        'completed',
        'Completed',
        Icons.check_circle_rounded,
        AppConstants.successColor,
      ),
    ];

    final selected = await showMenu<String>(
      context: context,
      position: RelativeRect.fromLTRB(
        position.dx,
        position.dy,
        position.dx + 1,
        position.dy + 1,
      ),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      items: statuses.map((s) {
        final isActive = task.status == s.$1;
        return PopupMenuItem<String>(
          value: s.$1,
          child: Row(
            children: [
              Icon(s.$3, size: 18, color: s.$4),
              const SizedBox(width: 10),
              Text(
                s.$2,
                style: AppFonts.of(context, 
                  fontSize: 13,
                  fontWeight: isActive ? FontWeight.w700 : FontWeight.w500,
                  color: isActive ? s.$4 : null,
                ),
              ),
              if (isActive) ...[
                const Spacer(),
                Icon(Icons.check_rounded, size: 16, color: s.$4),
              ],
            ],
          ),
        );
      }).toList(),
    );

    if (selected != null && selected != task.status) {
      onStatusChange?.call(selected);
    }
  }

  // ── build ───────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final isCompleted = task.status == 'completed';
    final statusClr = AppConstants.statusColor(task.status);

    return GlassContainer(
      borderRadius: 20,
      margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 7),
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(20),
        child: InkWell(
          borderRadius: BorderRadius.circular(20),
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.fromLTRB(20, 18, 20, 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // ── Top row: category icon + due date ──
                Row(
                  children: [
                    Container(
                      width: 32,
                      height: 32,
                      decoration: BoxDecoration(
                        color: isDark
                            ? Colors.white.withValues(alpha: 0.16)
                            : Colors.white.withValues(alpha: 0.65),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Icon(
                        AppConstants.categoryIcon(task.category),
                        size: 17,
                        color: isDark
                            ? Colors.white
                            : AppConstants.textSecondary,
                      ),
                    ),
                    const Spacer(),
                    if (task.dueDate != null)
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: isDark
                              ? Colors.white.withValues(alpha: 0.12)
                              : Colors.white.withValues(alpha: 0.60),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          _shortDate(task.dueDate),
                          style: AppFonts.of(context, 
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: task.isOverdue
                                ? AppConstants.errorColor
                                : (isDark
                                      ? Colors.white
                                      : AppConstants.textSecondary),
                          ),
                        ),
                      ),
                  ],
                ),

                const SizedBox(height: 14),

                // ── Title ──
                Text(
                  task.title,
                  style: AppFonts.of(context, 
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                    height: 1.25,
                    color: isCompleted
                        ? (isDark ? Colors.white60 : AppConstants.textSecondary)
                        : (isDark ? Colors.white : AppConstants.textPrimary),
                    decoration: isCompleted ? TextDecoration.lineThrough : null,
                    decorationColor: isDark
                        ? Colors.white38
                        : AppConstants.textLight,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),

                const SizedBox(height: 14),

                // ── Bottom row: category label + status pill ──
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: AppConstants.categoryColor(
                          task.category,
                        ).withValues(alpha: isDark ? 0.25 : 0.12),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Text(
                        AppConstants.categoryLabel(task.category),
                        style: AppFonts.of(context, 
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                          color: isDark
                              ? Colors.white
                              : AppConstants.textSecondary,
                        ),
                      ),
                    ),
                    const Spacer(),
                    GestureDetector(
                      onTapDown: onStatusChange != null
                          ? (d) => _showStatusMenu(context, d.globalPosition)
                          : null,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 14,
                          vertical: 6,
                        ),
                        decoration: BoxDecoration(
                          color: isDark
                              ? Colors.white.withValues(alpha: 0.12)
                              : Colors.white.withValues(alpha: 0.75),
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(
                            color: statusClr.withValues(alpha: 0.3),
                          ),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Container(
                              width: 7,
                              height: 7,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: statusClr,
                              ),
                            ),
                            const SizedBox(width: 6),
                            Text(
                              task.statusLabel,
                              style: AppFonts.of(context, 
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                                color: isDark
                                    ? Colors.white
                                    : AppConstants.textPrimary,
                              ),
                            ),
                            if (onStatusChange != null) ...[
                              const SizedBox(width: 2),
                              Icon(
                                Icons.keyboard_arrow_down_rounded,
                                size: 14,
                                color: isDark
                                    ? Colors.white70
                                    : AppConstants.textSecondary,
                              ),
                            ],
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
