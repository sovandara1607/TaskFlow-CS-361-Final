import 'package:flutter/material.dart';
import '../utils/constants.dart';

/// Reusable Drawer widget with profile section and navigation links.
class AppDrawer extends StatelessWidget {
  const AppDrawer({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          // ── User profile header ──
          UserAccountsDrawerHeader(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  AppConstants.primaryColor,
                  AppConstants.primaryColor.withValues(alpha: 0.7),
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
            // ── Network image for profile ──
            currentAccountPicture: const CircleAvatar(
              backgroundImage: NetworkImage('https://i.pravatar.cc/150?img=12'),
            ),
            accountName: const Text(
              'Dara Student',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
            ),
            accountEmail: const Text('dara@university.edu'),
          ),
          // ── Menu items ──
          _DrawerItem(
            icon: Icons.home_rounded,
            title: 'Home',
            onTap: () => _navigate(context, '/'),
          ),
          _DrawerItem(
            icon: Icons.task_alt_rounded,
            title: 'Tasks',
            onTap: () => _navigate(context, '/tasks'),
          ),
          _DrawerItem(
            icon: Icons.add_task_rounded,
            title: 'Add Task',
            onTap: () {
              Navigator.pop(context);
              Navigator.pushNamed(context, '/add');
            },
          ),
          _DrawerItem(
            icon: Icons.person_rounded,
            title: 'Profile',
            onTap: () => _navigate(context, '/profile'),
          ),
          const Divider(),
          _DrawerItem(
            icon: Icons.settings_rounded,
            title: 'Settings',
            onTap: () {
              Navigator.pop(context);
              Navigator.pushNamed(context, '/settings');
            },
          ),
          _DrawerItem(
            icon: Icons.info_outline_rounded,
            title: 'About',
            onTap: () {
              Navigator.pop(context);
              showAboutDialog(
                context: context,
                applicationName: AppConstants.appName,
                applicationVersion: '1.0.0',
                applicationIcon: Icon(
                  Icons.task_alt_rounded,
                  size: 48,
                  color: theme.colorScheme.primary,
                ),
                children: const [
                  Text(
                    'TaskFlow is a modern task management app built with '
                    'Flutter and Laravel REST API for the CS361 final project.',
                  ),
                ],
              );
            },
          ),
        ],
      ),
    );
  }

  void _navigate(BuildContext context, String route) {
    Navigator.pop(context); // close drawer
    if (ModalRoute.of(context)?.settings.name != route) {
      Navigator.pushReplacementNamed(context, route);
    }
  }
}

class _DrawerItem extends StatelessWidget {
  final IconData icon;
  final String title;
  final VoidCallback onTap;

  const _DrawerItem({
    required this.icon,
    required this.title,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: Icon(icon),
      title: Text(title),
      onTap: onTap,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
    );
  }
}
