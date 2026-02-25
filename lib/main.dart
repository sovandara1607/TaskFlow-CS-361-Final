import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

import 'models/task.dart';
import 'services/task_provider.dart';
import 'services/app_settings_provider.dart';
import 'services/auth_provider.dart';
import 'screens/splash_screen.dart';
import 'screens/login_screen.dart';
import 'screens/register_screen.dart';
import 'screens/main_shell.dart';
import 'screens/add_task_screen.dart';
import 'screens/edit_task_screen.dart';
import 'screens/settings_screen.dart';
import 'screens/notifications_screen.dart';
import 'utils/constants.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final settings = AppSettingsProvider();
  await settings.loadSettings();

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => TaskProvider()),
        ChangeNotifierProvider.value(value: settings),
        ChangeNotifierProvider(create: (_) => AuthProvider()),
      ],
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    final settings = context.watch<AppSettingsProvider>();

    return MaterialApp(
      title: AppConstants.appName,
      debugShowCheckedModeBanner: false,
      themeMode: settings.themeMode,

      // ── Light Theme ──
      theme: ThemeData(
        useMaterial3: true,
        colorSchemeSeed: AppConstants.primaryColor,
        brightness: Brightness.light,
        scaffoldBackgroundColor: AppConstants.backgroundColor,
        textTheme: GoogleFonts.poppinsTextTheme(),
        appBarTheme: AppBarTheme(
          centerTitle: true,
          elevation: 0,
          backgroundColor: Colors.transparent,
          foregroundColor: AppConstants.textPrimary,
          titleTextStyle: GoogleFonts.poppins(
            fontSize: 18,
            fontWeight: FontWeight.w600,
            color: AppConstants.textPrimary,
          ),
        ),
        cardTheme: CardThemeData(
          elevation: 0,
          color: AppConstants.cardColor,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppConstants.cardRadius),
          ),
        ),
        inputDecorationTheme: InputDecorationTheme(
          filled: true,
          fillColor: AppConstants.backgroundColor,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(AppConstants.defaultRadius),
            borderSide: BorderSide.none,
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(AppConstants.defaultRadius),
            borderSide: BorderSide(
              color: AppConstants.primaryLight.withValues(alpha: 0.3),
            ),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(AppConstants.defaultRadius),
            borderSide: const BorderSide(
              color: AppConstants.primaryColor,
              width: 1.5,
            ),
          ),
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 14,
          ),
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: AppConstants.primaryColor,
            foregroundColor: Colors.white,
            elevation: 0,
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(AppConstants.defaultRadius),
            ),
            textStyle: GoogleFonts.poppins(
              fontWeight: FontWeight.w600,
              fontSize: 15,
            ),
          ),
        ),
        outlinedButtonTheme: OutlinedButtonThemeData(
          style: OutlinedButton.styleFrom(
            foregroundColor: AppConstants.primaryColor,
            side: const BorderSide(color: AppConstants.primaryLight),
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(AppConstants.defaultRadius),
            ),
          ),
        ),
        floatingActionButtonTheme: const FloatingActionButtonThemeData(
          backgroundColor: AppConstants.primaryColor,
          foregroundColor: Colors.white,
          elevation: 4,
          shape: StadiumBorder(),
        ),
        navigationBarTheme: NavigationBarThemeData(
          backgroundColor: Colors.white,
          elevation: 0,
          height: 70,
          indicatorColor: AppConstants.accentLavender.withValues(alpha: 0.5),
          labelTextStyle: WidgetStateProperty.all(
            GoogleFonts.poppins(fontSize: 12, fontWeight: FontWeight.w500),
          ),
        ),
      ),

      // ── Dark Theme ──
      darkTheme: ThemeData(
        useMaterial3: true,
        colorSchemeSeed: AppConstants.primaryColor,
        brightness: Brightness.dark,
        scaffoldBackgroundColor: AppConstants.darkBackground,
        textTheme: GoogleFonts.poppinsTextTheme(ThemeData.dark().textTheme),
        appBarTheme: AppBarTheme(
          centerTitle: true,
          elevation: 0,
          backgroundColor: Colors.transparent,
          foregroundColor: Colors.white,
          titleTextStyle: GoogleFonts.poppins(
            fontSize: 18,
            fontWeight: FontWeight.w600,
            color: Colors.white,
          ),
        ),
        cardTheme: CardThemeData(
          elevation: 0,
          color: AppConstants.darkCard,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppConstants.cardRadius),
          ),
        ),
        inputDecorationTheme: InputDecorationTheme(
          filled: true,
          fillColor: AppConstants.darkSurface,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(AppConstants.defaultRadius),
            borderSide: BorderSide.none,
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(AppConstants.defaultRadius),
            borderSide: BorderSide(
              color: AppConstants.primaryLight.withValues(alpha: 0.2),
            ),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(AppConstants.defaultRadius),
            borderSide: const BorderSide(
              color: AppConstants.primaryColor,
              width: 1.5,
            ),
          ),
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 14,
          ),
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: AppConstants.primaryColor,
            foregroundColor: Colors.white,
            elevation: 0,
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(AppConstants.defaultRadius),
            ),
            textStyle: GoogleFonts.poppins(
              fontWeight: FontWeight.w600,
              fontSize: 15,
            ),
          ),
        ),
        outlinedButtonTheme: OutlinedButtonThemeData(
          style: OutlinedButton.styleFrom(
            foregroundColor: AppConstants.primaryLight,
            side: BorderSide(
              color: AppConstants.primaryLight.withValues(alpha: 0.5),
            ),
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(AppConstants.defaultRadius),
            ),
          ),
        ),
        floatingActionButtonTheme: const FloatingActionButtonThemeData(
          backgroundColor: AppConstants.primaryColor,
          foregroundColor: Colors.white,
          elevation: 4,
          shape: StadiumBorder(),
        ),
        navigationBarTheme: NavigationBarThemeData(
          backgroundColor: AppConstants.darkSurface,
          elevation: 0,
          height: 70,
          indicatorColor: AppConstants.primaryColor.withValues(alpha: 0.3),
          labelTextStyle: WidgetStateProperty.all(
            GoogleFonts.poppins(fontSize: 12, fontWeight: FontWeight.w500),
          ),
        ),
      ),

      // ── Named Routes ──
      initialRoute: '/splash',
      routes: {
        '/splash': (context) => const SplashScreen(),
        '/login': (context) => const LoginScreen(),
        '/register': (context) => const RegisterScreen(),
        '/': (context) => const MainShell(initialIndex: 0),
        '/tasks': (context) => const MainShell(initialIndex: 1),
        '/profile': (context) => const MainShell(initialIndex: 2),
        '/add': (context) => const AddTaskScreen(),
        '/settings': (context) => const SettingsScreen(),
        '/notifications': (context) => const NotificationsScreen(),
      },
      onGenerateRoute: (settings) {
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
