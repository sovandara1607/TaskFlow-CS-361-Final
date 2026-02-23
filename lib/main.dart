import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'models/task.dart';
import 'services/task_provider.dart';
import 'screens/main_shell.dart';
import 'screens/add_task_screen.dart';
import 'screens/edit_task_screen.dart';
import 'screens/settings_screen.dart';
import 'utils/constants.dart';

void main() {
  runApp(
    ChangeNotifierProvider(create: (_) => TaskProvider(), child: const MyApp()),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: AppConstants.appName,
      debugShowCheckedModeBanner: false,
      // ── Theme ──
      theme: ThemeData(
        useMaterial3: true,
        colorSchemeSeed: AppConstants.primaryColor,
        brightness: Brightness.light,
        appBarTheme: const AppBarTheme(centerTitle: true, elevation: 0),
        cardTheme: CardThemeData(
          elevation: 1,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppConstants.defaultRadius),
          ),
        ),
        inputDecorationTheme: InputDecorationTheme(
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(AppConstants.defaultRadius),
          ),
        ),
      ),
      // ── Named Routes ──
      initialRoute: '/',
      routes: {
        '/': (context) => const MainShell(initialIndex: 0),
        '/tasks': (context) => const MainShell(initialIndex: 1),
        '/profile': (context) => const MainShell(initialIndex: 2),
        '/add': (context) => const AddTaskScreen(),
        '/settings': (context) => const SettingsScreen(),
      },
      onGenerateRoute: (settings) {
        // Handle the /edit route which receives a Task argument.
        if (settings.name == '/edit') {
          final task = settings.arguments as Task;
          return MaterialPageRoute(
            builder: (_) => EditTaskScreen(task: task),
            settings: settings,
          );
        }
        return null;
      },
    );
  }
}
