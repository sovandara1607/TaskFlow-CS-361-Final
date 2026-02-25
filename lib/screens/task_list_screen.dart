import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../models/task.dart';
import '../services/task_provider.dart';
import '../services/app_settings_provider.dart';
import '../l10n/app_localizations.dart';
import '../widgets/task_card.dart';
import '../widgets/app_dialogs.dart';
import '../utils/constants.dart';

/// Tiimo‑style Task List Screen — filter chips, swipe gestures, categories.
class TaskListScreen extends StatefulWidget {
  const TaskListScreen({super.key});

  @override
  State<TaskListScreen> createState() => _TaskListScreenState();
}

class _TaskListScreenState extends State<TaskListScreen> {
  String _statusFilter = 'all';
  String _categoryFilter = 'all';
  final _searchCtrl = TextEditingController();
  String _searchQuery = '';

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

  @override
  void dispose() {
    _searchCtrl.dispose();
    super.dispose();
  }

  List<Task> _applyFilter(List<Task> tasks) {
    var result = tasks;
    if (_statusFilter != 'all') {
      result = result.where((t) => t.status == _statusFilter).toList();
    }
    if (_categoryFilter != 'all') {
      result = result.where((t) => t.category == _categoryFilter).toList();
    }
    if (_searchQuery.isNotEmpty) {
      final q = _searchQuery.toLowerCase();
      result = result
          .where(
            (t) =>
                t.title.toLowerCase().contains(q) ||
                t.description.toLowerCase().contains(q),
          )
          .toList();
    }
    return result;
  }

  Future<void> _deleteTask(Task task) async {
    final confirmed = await AppDialogs.showConfirmation(
      context: context,
      title: 'Delete Task',
      message:
          'Are you sure you want to delete "${task.title}"?\nThis action cannot be undone.',
    );
    if (!confirmed || !mounted) return;

    final success = await context.read<TaskProvider>().deleteTask(task.id!);
    if (!mounted) return;
    if (success) {
      await AppDialogs.showSuccess(
        context: context,
        message: '"${task.title}" has been deleted.',
      );
    } else {
      await AppDialogs.showError(
        context: context,
        message: 'Failed to delete task. Please try again.',
      );
    }
  }

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

  void _showTaskDetails(Task task) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    AppDialogs.showBottomSheet(
      context: context,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Center(
            child: Container(
              width: 40,
              height: 4,
              margin: const EdgeInsets.only(bottom: 20),
              decoration: BoxDecoration(
                color: AppConstants.textLight,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          Center(
            child: Container(
              width: 64,
              height: 64,
              decoration: BoxDecoration(
                color: AppConstants.statusBgColor(
                  task.status,
                ).withValues(alpha: 0.5),
                borderRadius: BorderRadius.circular(18),
              ),
              child: Center(
                child: Icon(
                  AppConstants.statusIcon(task.status),
                  size: 30,
                  color: AppConstants.statusColor(task.status),
                ),
              ),
            ),
          ),
          const SizedBox(height: 16),
          Text(
            task.title,
            style: GoogleFonts.poppins(
              fontSize: 20,
              fontWeight: FontWeight.w700,
              color: isDark ? Colors.white : AppConstants.textPrimary,
            ),
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 4,
                ),
                decoration: BoxDecoration(
                  color: AppConstants.statusBgColor(
                    task.status,
                  ).withValues(alpha: 0.4),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  task.statusLabel,
                  style: GoogleFonts.poppins(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: AppConstants.statusColor(task.status),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: AppConstants.categoryColor(
                    task.category,
                  ).withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  '${AppConstants.categoryLabel(task.category)}',
                  style: GoogleFonts.poppins(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: AppConstants.categoryColor(task.category),
                  ),
                ),
              ),
              const Spacer(),
              if (task.dueDate != null) ...[
                Icon(
                  Icons.schedule_rounded,
                  size: 14,
                  color: AppConstants.textSecondary,
                ),
                const SizedBox(width: 4),
                Text(
                  _shortDate(task.dueDate),
                  style: GoogleFonts.poppins(
                    fontSize: 13,
                    color: AppConstants.textSecondary,
                  ),
                ),
              ],
            ],
          ),
          const SizedBox(height: 14),
          Text(
            task.description.isNotEmpty
                ? task.description
                : 'No description provided.',
            style: GoogleFonts.poppins(
              fontSize: 14,
              color: isDark ? Colors.white54 : AppConstants.textSecondary,
              height: 1.5,
            ),
          ),
          const SizedBox(height: 24),
          Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  icon: const Icon(Icons.edit_rounded, size: 18),
                  label: const Text('Edit'),
                  onPressed: () {
                    Navigator.pop(context);
                    Navigator.pushNamed(context, '/edit', arguments: task);
                  },
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: ElevatedButton.icon(
                  icon: const Icon(Icons.delete_rounded, size: 18),
                  label: const Text('Delete'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppConstants.errorColor,
                    foregroundColor: Colors.white,
                  ),
                  onPressed: () {
                    Navigator.pop(context);
                    _deleteTask(task);
                  },
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final lang = context.watch<AppSettingsProvider>().locale;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          AppLocalizations.tr('my_tasks', lang),
          style: GoogleFonts.poppins(
            fontWeight: FontWeight.w700,
            fontSize: 20,
            color: isDark ? Colors.white : AppConstants.textPrimary,
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh_rounded),
            tooltip: AppLocalizations.tr('refresh', lang),
            onPressed: () => context.read<TaskProvider>().fetchTasks(),
          ),
        ],
      ),
      body: Column(
        children: [
          // ── Search bar ──
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 4, 20, 12),
            child: Container(
              decoration: BoxDecoration(
                color: isDark ? AppConstants.darkCard : Colors.white,
                borderRadius: BorderRadius.circular(16),
                boxShadow: isDark
                    ? []
                    : [
                        BoxShadow(
                          color: AppConstants.primaryColor.withValues(
                            alpha: 0.06,
                          ),
                          blurRadius: 12,
                          offset: const Offset(0, 4),
                        ),
                      ],
              ),
              child: TextField(
                controller: _searchCtrl,
                onChanged: (v) => setState(() => _searchQuery = v),
                style: GoogleFonts.poppins(
                  fontSize: 14,
                  color: isDark ? Colors.white : AppConstants.textPrimary,
                ),
                decoration: InputDecoration(
                  hintText: AppLocalizations.tr('search_tasks', lang),
                  hintStyle: GoogleFonts.poppins(
                    color: isDark ? Colors.white38 : AppConstants.textLight,
                    fontSize: 14,
                  ),
                  prefixIcon: Icon(
                    Icons.search_rounded,
                    color: isDark ? Colors.white54 : AppConstants.textSecondary,
                  ),
                  border: InputBorder.none,
                  enabledBorder: InputBorder.none,
                  focusedBorder: InputBorder.none,
                  contentPadding: const EdgeInsets.symmetric(vertical: 14),
                ),
              ),
            ),
          ),

          // ── Status filter chips ──
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: [
                  _FilterChip(
                    label: AppLocalizations.tr('all', lang),
                    icon: Icons.list_alt_rounded,
                    selected: _statusFilter == 'all',
                    isDark: isDark,
                    onTap: () => setState(() => _statusFilter = 'all'),
                  ),
                  const SizedBox(width: 8),
                  _FilterChip(
                    label: AppLocalizations.tr('pending', lang),
                    icon: Icons.radio_button_unchecked,
                    selected: _statusFilter == 'pending',
                    isDark: isDark,
                    onTap: () => setState(() => _statusFilter = 'pending'),
                  ),
                  const SizedBox(width: 8),
                  _FilterChip(
                    label: AppLocalizations.tr('in_progress', lang),
                    icon: Icons.timelapse_rounded,
                    selected: _statusFilter == 'in_progress',
                    isDark: isDark,
                    onTap: () => setState(() => _statusFilter = 'in_progress'),
                  ),
                  const SizedBox(width: 8),
                  _FilterChip(
                    label: AppLocalizations.tr('completed', lang),
                    icon: Icons.check_circle_outline_rounded,
                    selected: _statusFilter == 'completed',
                    isDark: isDark,
                    onTap: () => setState(() => _statusFilter = 'completed'),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 8),

          // ── Category filter chips ──
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: [
                  _FilterChip(
                    label: AppLocalizations.tr('all', lang),
                    icon: Icons.category_outlined,
                    selected: _categoryFilter == 'all',
                    isDark: isDark,
                    onTap: () => setState(() => _categoryFilter = 'all'),
                  ),
                  const SizedBox(width: 8),
                  ...AppConstants.categories.map(
                    (cat) => Padding(
                      padding: const EdgeInsets.only(right: 8),
                      child: _FilterChip(
                        label: AppConstants.categoryLabel(cat),
                        icon: AppConstants.categoryIcon(cat),
                        selected: _categoryFilter == cat,
                        isDark: isDark,
                        onTap: () => setState(() => _categoryFilter = cat),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 12),

          // ── Task list with Slidable gestures ──
          Expanded(
            child: Consumer<TaskProvider>(
              builder: (context, provider, __) {
                if (provider.isLoading && provider.tasks.isEmpty) {
                  return const Center(child: CircularProgressIndicator());
                }

                if (provider.error != null && provider.tasks.isEmpty) {
                  return Center(
                    child: Padding(
                      padding: const EdgeInsets.all(32),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(
                            Icons.cloud_off_rounded,
                            size: 48,
                            color: AppConstants.textLight,
                          ),
                          const SizedBox(height: 16),
                          Text(
                            AppLocalizations.tr('could_not_load', lang),
                            style: GoogleFonts.poppins(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                              color: isDark
                                  ? Colors.white
                                  : AppConstants.textPrimary,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            provider.error!,
                            textAlign: TextAlign.center,
                            style: GoogleFonts.poppins(
                              fontSize: 13,
                              color: isDark
                                  ? Colors.white54
                                  : AppConstants.textSecondary,
                            ),
                          ),
                          const SizedBox(height: 16),
                          ElevatedButton.icon(
                            icon: const Icon(Icons.refresh_rounded),
                            label: Text(AppLocalizations.tr('retry', lang)),
                            onPressed: () => provider.fetchTasks(),
                          ),
                        ],
                      ),
                    ),
                  );
                }

                final filtered = _applyFilter(provider.tasks);

                if (filtered.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.search_off_rounded,
                          size: 48,
                          color: isDark
                              ? Colors.white38
                              : AppConstants.textLight,
                        ),
                        const SizedBox(height: 16),
                        Text(
                          provider.tasks.isEmpty
                              ? AppLocalizations.tr('no_tasks_yet', lang)
                              : AppLocalizations.tr('no_matching', lang),
                          style: GoogleFonts.poppins(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: isDark
                                ? Colors.white
                                : AppConstants.textPrimary,
                          ),
                        ),
                        const SizedBox(height: 8),
                        if (provider.tasks.isEmpty)
                          ElevatedButton.icon(
                            icon: const Icon(Icons.add_rounded),
                            label: Text(
                              AppLocalizations.tr('create_first', lang),
                            ),
                            onPressed: () =>
                                Navigator.pushNamed(context, '/add'),
                          ),
                      ],
                    ),
                  );
                }

                return RefreshIndicator(
                  color: AppConstants.primaryColor,
                  onRefresh: () => provider.fetchTasks(),
                  child: ListView.builder(
                    padding: const EdgeInsets.only(top: 4, bottom: 80),
                    itemCount: filtered.length,
                    itemBuilder: (context, index) {
                      final task = filtered[index];
                      return Slidable(
                        key: ValueKey('slidable_${task.id}'),
                        // Swipe right → toggle complete
                        startActionPane: ActionPane(
                          motion: const BehindMotion(),
                          children: [
                            SlidableAction(
                              onPressed: (_) => provider.toggleTaskStatus(task),
                              backgroundColor: AppConstants.successColor,
                              foregroundColor: Colors.white,
                              icon: task.status == 'completed'
                                  ? Icons.undo_rounded
                                  : Icons.check_circle_rounded,
                              label: task.status == 'completed'
                                  ? 'Undo'
                                  : 'Complete',
                              borderRadius: const BorderRadius.only(
                                topLeft: Radius.circular(16),
                                bottomLeft: Radius.circular(16),
                              ),
                            ),
                          ],
                        ),
                        // Swipe left → delete
                        endActionPane: ActionPane(
                          motion: const BehindMotion(),
                          children: [
                            SlidableAction(
                              onPressed: (_) => _deleteTask(task),
                              backgroundColor: AppConstants.errorColor,
                              foregroundColor: Colors.white,
                              icon: Icons.delete_rounded,
                              label: 'Delete',
                              borderRadius: const BorderRadius.only(
                                topRight: Radius.circular(16),
                                bottomRight: Radius.circular(16),
                              ),
                            ),
                          ],
                        ),
                        child: TaskCard(
                          task: task,
                          onTap: () => _showTaskDetails(task),
                          onEdit: () => Navigator.pushNamed(
                            context,
                            '/edit',
                            arguments: task,
                          ),
                          onDelete: () => _deleteTask(task),
                        ),
                      );
                    },
                  ),
                );
              },
            ),
          ),
        ],
      ),
      // ── FAB ──
      floatingActionButton: FloatingActionButton.extended(
        heroTag: 'add_task_fab',
        icon: const Icon(Icons.add_rounded),
        label: Text(
          AppLocalizations.tr('new_task', lang),
          style: GoogleFonts.poppins(fontWeight: FontWeight.w600),
        ),
        onPressed: () => Navigator.pushNamed(context, '/add'),
      ),
    );
  }
}

// ── Custom filter chip ──
class _FilterChip extends StatelessWidget {
  final String label;
  final IconData icon;
  final bool selected;
  final bool isDark;
  final VoidCallback onTap;

  const _FilterChip({
    required this.label,
    required this.icon,
    required this.selected,
    required this.isDark,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        decoration: BoxDecoration(
          color: selected
              ? AppConstants.primaryColor
              : (isDark ? AppConstants.darkCard : Colors.white),
          borderRadius: BorderRadius.circular(12),
          boxShadow: selected
              ? [
                  BoxShadow(
                    color: AppConstants.primaryColor.withValues(alpha: 0.3),
                    blurRadius: 8,
                    offset: const Offset(0, 3),
                  ),
                ]
              : isDark
              ? []
              : [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.04),
                    blurRadius: 6,
                    offset: const Offset(0, 2),
                  ),
                ],
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              size: 16,
              color: selected
                  ? Colors.white
                  : (isDark ? Colors.white54 : AppConstants.textSecondary),
            ),
            const SizedBox(width: 6),
            Text(
              label,
              style: GoogleFonts.poppins(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: selected
                    ? Colors.white
                    : (isDark ? Colors.white70 : AppConstants.textPrimary),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
