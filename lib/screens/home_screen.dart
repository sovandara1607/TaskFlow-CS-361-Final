import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/task_provider.dart';
import '../utils/constants.dart';
import '../widgets/app_drawer.dart';

/// Home Screen — dashboard with stats, local & network images, quick actions.
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

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.task_alt_rounded, color: theme.colorScheme.primary),
            const SizedBox(width: 8),
            const Text('TaskFlow'),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.notifications_outlined),
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('No new notifications')),
              );
            },
          ),
        ],
      ),
      drawer: const AppDrawer(),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(AppConstants.defaultPadding),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── Welcome banner with Network Image ──
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    AppConstants.primaryColor,
                    AppConstants.primaryColor.withValues(alpha: 0.75),
                  ],
                ),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Hello, Dara! 👋',
                          style: theme.textTheme.headlineSmall?.copyWith(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Organize your tasks and boost productivity.',
                          style: theme.textTheme.bodyMedium?.copyWith(
                            color: Colors.white70,
                          ),
                        ),
                        const SizedBox(height: 16),
                        ElevatedButton.icon(
                          icon: const Icon(Icons.add),
                          label: const Text('New Task'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.white,
                            foregroundColor: AppConstants.primaryColor,
                          ),
                          onPressed: () => Navigator.pushNamed(context, '/add'),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 12),
                  // ── Network Image ──
                  ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: Image.network(
                      'https://picsum.photos/seed/taskflow/120/120',
                      width: 80,
                      height: 80,
                      fit: BoxFit.cover,
                      errorBuilder: (_, _, _) => Container(
                        width: 80,
                        height: 80,
                        color: Colors.white24,
                        child: const Icon(
                          Icons.image,
                          color: Colors.white54,
                          size: 36,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // ── Stats Row ──
            Text(
              'Task Overview',
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),
            Consumer<TaskProvider>(
              builder: (_, provider, _) => Row(
                children: [
                  _StatCard(
                    icon: Icons.list_alt,
                    label: 'Total',
                    value: '${provider.totalTasks}',
                    color: AppConstants.primaryColor,
                  ),
                  const SizedBox(width: 10),
                  _StatCard(
                    icon: Icons.radio_button_unchecked,
                    label: 'Pending',
                    value: '${provider.pendingTasks}',
                    color: AppConstants.warningColor,
                  ),
                  const SizedBox(width: 10),
                  _StatCard(
                    icon: Icons.timelapse,
                    label: 'Active',
                    value: '${provider.inProgressTasks}',
                    color: Colors.blue,
                  ),
                  const SizedBox(width: 10),
                  _StatCard(
                    icon: Icons.check_circle,
                    label: 'Done',
                    value: '${provider.completedTasks}',
                    color: AppConstants.successColor,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // ── Local Image Section ──
            Text(
              'App Logo (Local Asset)',
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),
            ClipRRect(
              borderRadius: BorderRadius.circular(14),
              child: Image.asset(
                'assets/images/placeholder.png',
                height: 120,
                width: double.infinity,
                fit: BoxFit.cover,
                errorBuilder: (_, _, _) => Container(
                  height: 120,
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: AppConstants.primaryColor.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.task_alt,
                          size: 48,
                          color: AppConstants.primaryColor,
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'TaskFlow',
                          style: TextStyle(
                            color: AppConstants.primaryColor,
                            fontWeight: FontWeight.bold,
                            fontSize: 18,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 24),

            // ── Quick Actions ──
            Text(
              'Quick Actions',
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),
            Wrap(
              spacing: 12,
              runSpacing: 12,
              children: [
                ElevatedButton.icon(
                  icon: const Icon(Icons.add_task),
                  label: const Text('Add Task'),
                  onPressed: () => Navigator.pushNamed(context, '/add'),
                ),
                OutlinedButton.icon(
                  icon: const Icon(Icons.list),
                  label: const Text('View Tasks'),
                  onPressed: () =>
                      Navigator.pushReplacementNamed(context, '/tasks'),
                ),
                TextButton.icon(
                  icon: const Icon(Icons.person),
                  label: const Text('Profile'),
                  onPressed: () =>
                      Navigator.pushReplacementNamed(context, '/profile'),
                ),
              ],
            ),
            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }
}

class _StatCard extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final Color color;

  const _StatCard({
    required this.icon,
    required this.label,
    required this.value,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 8),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.08),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: color.withValues(alpha: 0.25)),
        ),
        child: Column(
          children: [
            Icon(icon, color: color, size: 24),
            const SizedBox(height: 6),
            Text(
              value,
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
            Text(
              label,
              style: Theme.of(
                context,
              ).textTheme.labelSmall?.copyWith(color: Colors.grey[600]),
            ),
          ],
        ),
      ),
    );
  }
}
