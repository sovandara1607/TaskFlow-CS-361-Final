import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/app_settings_provider.dart';
import '../l10n/app_localizations.dart';
import '../utils/constants.dart';
import 'home_screen.dart';
import 'task_list_screen.dart';
import 'profile_screen.dart';

/// Main shell with bottom navigation — dark mode aware.
class MainShell extends StatefulWidget {
  final int initialIndex;

  const MainShell({super.key, this.initialIndex = 0});

  @override
  State<MainShell> createState() => _MainShellState();
}

class _MainShellState extends State<MainShell> {
  late int _currentIndex;

  final _pages = const <Widget>[
    HomeScreen(),
    TaskListScreen(),
    ProfileScreen(),
  ];

  @override
  void initState() {
    super.initState();
    _currentIndex = widget.initialIndex;
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final lang = context.watch<AppSettingsProvider>().locale;

    return Scaffold(
      body: IndexedStack(index: _currentIndex, children: _pages),
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: isDark ? AppConstants.darkSurface : Colors.white,
          boxShadow: isDark
              ? []
              : [
                  BoxShadow(
                    color: AppConstants.primaryColor.withValues(alpha: 0.08),
                    blurRadius: 20,
                    offset: const Offset(0, -4),
                  ),
                ],
        ),
        child: NavigationBar(
          selectedIndex: _currentIndex,
          onDestinationSelected: (i) => setState(() => _currentIndex = i),
          labelBehavior: NavigationDestinationLabelBehavior.alwaysShow,
          destinations: [
            NavigationDestination(
              icon: const Icon(Icons.wb_sunny_outlined),
              selectedIcon: const Icon(Icons.wb_sunny_rounded),
              label: AppLocalizations.tr('today', lang),
            ),
            NavigationDestination(
              icon: const Icon(Icons.checklist_rounded),
              selectedIcon: const Icon(Icons.checklist_rounded),
              label: AppLocalizations.tr('tasks', lang),
            ),
            NavigationDestination(
              icon: const Icon(Icons.person_outline_rounded),
              selectedIcon: const Icon(Icons.person_rounded),
              label: AppLocalizations.tr('profile', lang),
            ),
          ],
        ),
      ),
    );
  }
}
