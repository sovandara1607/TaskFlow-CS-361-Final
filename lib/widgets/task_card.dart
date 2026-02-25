import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../models/task.dart';
import '../utils/constants.dart';

/// Tiimo‑style minimal task card with modern completion indicator.
class TaskCard extends StatelessWidget {
  final Task task;
  final VoidCallback? onTap;
  final VoidCallback? onEdit;
  final VoidCallback? onDelete;

  const TaskCard({
    super.key,
    required this.task,
    this.onTap,
    this.onEdit,
    this.onDelete,
  });

  /// Format "2026-03-01" → "Mar 1"
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
    final bgColor = AppConstants.statusBgColor(task.status);
    final statusIconData = AppConstants.statusIcon(task.status);
    final isCompleted = task.status == 'completed';
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final catColor = AppConstants.categoryColor(task.category);

    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 6),
      decoration: BoxDecoration(
        color: isCompleted
            ? (isDark
                  ? AppConstants.accentMint.withValues(alpha: 0.1)
                  : AppConstants.accentMint.withValues(alpha: 0.12))
            : (isDark ? AppConstants.darkCard : Colors.white),
        borderRadius: BorderRadius.circular(AppConstants.cardRadius),
        border: isCompleted
            ? Border.all(
                color: AppConstants.successColor.withValues(alpha: 0.3),
                width: 1.5,
              )
            : null,
        boxShadow: isDark
            ? []
            : [
                BoxShadow(
                  color: AppConstants.primaryColor.withValues(alpha: 0.06),
                  blurRadius: 16,
                  offset: const Offset(0, 4),
                ),
              ],
      ),
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(AppConstants.cardRadius),
        child: InkWell(
          borderRadius: BorderRadius.circular(AppConstants.cardRadius),
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                // ── Icon bubble ──
                Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    color: bgColor.withValues(alpha: 0.5),
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: Center(
                    child: Icon(
                      statusIconData,
                      size: 24,
                      color: AppConstants.statusColor(task.status),
                    ),
                  ),
                ),
                const SizedBox(width: 14),
                // ── Title + meta ──
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        task.title,
                        style: GoogleFonts.poppins(
                          fontSize: 15,
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
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          if (task.dueDate != null) ...[
                            Icon(
                              Icons.schedule_rounded,
                              size: 13,
                              color: task.isOverdue
                                  ? AppConstants.errorColor
                                  : (isDark
                                        ? Colors.white38
                                        : AppConstants.textSecondary),
                            ),
                            const SizedBox(width: 3),
                            Text(
                              _shortDate(task.dueDate),
                              style: GoogleFonts.poppins(
                                fontSize: 12,
                                color: task.isOverdue
                                    ? AppConstants.errorColor
                                    : (isDark
                                          ? Colors.white38
                                          : AppConstants.textSecondary),
                                fontWeight: task.isOverdue
                                    ? FontWeight.w600
                                    : FontWeight.w400,
                              ),
                            ),
                            const SizedBox(width: 8),
                          ],
                          // ── Status badge ──
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 2,
                            ),
                            decoration: BoxDecoration(
                              color: bgColor.withValues(alpha: 0.4),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Text(
                              task.statusLabel,
                              style: GoogleFonts.poppins(
                                fontSize: 11,
                                fontWeight: FontWeight.w600,
                                color: AppConstants.statusColor(task.status),
                              ),
                            ),
                          ),
                          const SizedBox(width: 6),
                          // ── Category badge ──
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 6,
                              vertical: 2,
                            ),
                            decoration: BoxDecoration(
                              color: catColor.withValues(alpha: 0.35),
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: Icon(
                              AppConstants.categoryIcon(task.category),
                              size: 12,
                              color: catColor,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 8),
                // ── Circle checkbox indicator ──
                Container(
                  width: 28,
                  height: 28,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: isCompleted
                        ? AppConstants.successColor
                        : Colors.transparent,
                    border: Border.all(
                      color: isCompleted
                          ? AppConstants.successColor
                          : (isDark ? Colors.white24 : AppConstants.textLight),
                      width: 2,
                    ),
                  ),
                  child: isCompleted
                      ? const Icon(Icons.check, color: Colors.white, size: 16)
                      : null,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
