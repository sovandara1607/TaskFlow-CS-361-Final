import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/task.dart';
import '../services/task_provider.dart';
import '../widgets/task_card.dart';
import '../widgets/app_dialogs.dart';
import '../utils/constants.dart';

/// Task List Screen — displays all tasks using ListView.builder with CRUD actions.
class TaskListScreen extends StatefulWidget {
  const TaskListScreen({super.key});

  @override
  State<TaskListScreen> createState() => _TaskListScreenState();
}

class _TaskListScreenState extends State<TaskListScreen> {
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

  void _showTaskDetails(Task task) {
    // ── Modal Bottom Sheet showing task details ──
    AppDialogs.showBottomSheet(
      context: context,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Drag handle
          Center(
            child: Container(
              width: 40,
              height: 4,
              margin: const EdgeInsets.only(bottom: 16),
              decoration: BoxDecoration(
                color: Colors.grey[300],
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          // Status icon large
          Center(
            child: Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppConstants.statusColor(
                  task.status,
                ).withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(
                AppConstants.statusIcon(task.status),
                size: 40,
                color: AppConstants.statusColor(task.status),
              ),
            ),
          ),
          const SizedBox(height: 16),
          Text(
            task.title,
            style: Theme.of(
              context,
            ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Chip(
                avatar: Icon(
                  AppConstants.statusIcon(task.status),
                  size: 16,
                  color: AppConstants.statusColor(task.status),
                ),
                label: Text(task.statusLabel),
              ),
              const Spacer(),
              if (task.dueDate != null) ...[
                Icon(Icons.calendar_today, size: 14, color: Colors.grey[600]),
                const SizedBox(width: 4),
                Text(task.dueDate!, style: TextStyle(color: Colors.grey[600])),
              ],
            ],
          ),
          const SizedBox(height: 12),
          Text(
            task.description.isNotEmpty
                ? task.description
                : 'No description provided.',
            style: Theme.of(
              context,
            ).textTheme.bodyMedium?.copyWith(color: Colors.grey[700]),
          ),
          const SizedBox(height: 20),
          Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  icon: const Icon(Icons.edit),
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
                  icon: const Icon(Icons.delete),
                  label: const Text('Delete'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Theme.of(context).colorScheme.error,
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
    return Scaffold(
      appBar: AppBar(
        title: const Text('My Tasks'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            tooltip: 'Refresh',
            onPressed: () => context.read<TaskProvider>().fetchTasks(),
          ),
        ],
      ),
      body: Consumer<TaskProvider>(
        builder: (context, provider, _) {
          // ── Loading state ──
          if (provider.isLoading && provider.tasks.isEmpty) {
            return const Center(child: CircularProgressIndicator());
          }

          // ── Error state ──
          if (provider.error != null && provider.tasks.isEmpty) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(32),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.cloud_off, size: 64, color: Colors.grey),
                    const SizedBox(height: 16),
                    Text(
                      'Could not load tasks',
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      provider.error!,
                      textAlign: TextAlign.center,
                      style: TextStyle(color: Colors.grey[600], fontSize: 13),
                    ),
                    const SizedBox(height: 16),
                    ElevatedButton.icon(
                      icon: const Icon(Icons.refresh),
                      label: const Text('Retry'),
                      onPressed: () => provider.fetchTasks(),
                    ),
                  ],
                ),
              ),
            );
          }

          // ── Empty state ──
          if (provider.tasks.isEmpty) {
            return Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.inbox_rounded, size: 64, color: Colors.grey[400]),
                  const SizedBox(height: 16),
                  Text(
                    'No tasks yet',
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  const SizedBox(height: 8),
                  ElevatedButton.icon(
                    icon: const Icon(Icons.add),
                    label: const Text('Create Your First Task'),
                    onPressed: () => Navigator.pushNamed(context, '/add'),
                  ),
                ],
              ),
            );
          }

          // ── Task list using ListView.builder ──
          return RefreshIndicator(
            onRefresh: () => provider.fetchTasks(),
            child: ListView.builder(
              padding: const EdgeInsets.symmetric(vertical: 8),
              itemCount: provider.tasks.length,
              itemBuilder: (context, index) {
                final task = provider.tasks[index];
                return TaskCard(
                  task: task,
                  onTap: () => _showTaskDetails(task),
                  onEdit: () =>
                      Navigator.pushNamed(context, '/edit', arguments: task),
                  onDelete: () => _deleteTask(task),
                );
              },
            ),
          );
        },
      ),
      // ── FloatingActionButton ──
      floatingActionButton: FloatingActionButton.extended(
        heroTag: 'add_task_fab',
        icon: const Icon(Icons.add),
        label: const Text('New Task'),
        onPressed: () => Navigator.pushNamed(context, '/add'),
      ),
    );
  }
}
