import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../services/app_settings_provider.dart';
import '../services/auth_provider.dart';
import '../services/api_service.dart';
import '../l10n/app_localizations.dart';
import '../utils/constants.dart';

/// Tiimo‑style Drawer with gradient header — dark mode + provider.
class AppDrawer extends StatelessWidget {
  const AppDrawer({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final settings = context.watch<AppSettingsProvider>();
    final auth = context.watch<AuthProvider>();
    final lang = settings.locale;

    // Use auth user info if available, fall back to settings
    final displayName = auth.userName ?? settings.userName;
    final displayEmail = auth.userEmail ?? settings.userEmail;

    return Drawer(
      backgroundColor: isDark
          ? AppConstants.darkBackground
          : AppConstants.backgroundColor,
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          // ── Gradient header ──
          UserAccountsDrawerHeader(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [Color(0xFF9B8EC5), Color(0xFFB8ACE6)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
            currentAccountPicture: Container(
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(color: Colors.white, width: 2),
              ),
              child: CircleAvatar(
                backgroundColor: AppConstants.primaryColor,
                child: Text(
                  displayName.isNotEmpty ? displayName[0].toUpperCase() : '?',
                  style: GoogleFonts.poppins(
                    fontSize: 24,
                    fontWeight: FontWeight.w700,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
            accountName: Text(
              displayName,
              style: GoogleFonts.poppins(
                fontWeight: FontWeight.w700,
                fontSize: 17,
              ),
            ),
            accountEmail: Text(
              displayEmail,
              style: GoogleFonts.poppins(fontSize: 13),
            ),
          ),
          _DrawerItem(
            icon: Icons.wb_sunny_outlined,
            title: AppLocalizations.tr('today', lang),
            onTap: () => _navigate(context, '/'),
            isDark: isDark,
          ),
          _DrawerItem(
            icon: Icons.checklist_rounded,
            title: AppLocalizations.tr('tasks', lang),
            onTap: () => _navigate(context, '/tasks'),
            isDark: isDark,
          ),
          _DrawerItem(
            icon: Icons.add_circle_outline_rounded,
            title: AppLocalizations.tr('add_task', lang),
            onTap: () {
              Navigator.pop(context);
              Navigator.pushNamed(context, '/add');
            },
            isDark: isDark,
          ),
          _DrawerItem(
            icon: Icons.person_outline_rounded,
            title: AppLocalizations.tr('profile', lang),
            onTap: () => _navigate(context, '/profile'),
            isDark: isDark,
          ),
          Divider(
            indent: 16,
            endIndent: 16,
            color: isDark ? Colors.white12 : null,
          ),
          _DrawerItem(
            icon: Icons.settings_outlined,
            title: AppLocalizations.tr('settings', lang),
            onTap: () {
              Navigator.pop(context);
              Navigator.pushNamed(context, '/settings');
            },
            isDark: isDark,
          ),
          _DrawerItem(
            icon: Icons.info_outline_rounded,
            title: AppLocalizations.tr('about', lang),
            onTap: () {
              Navigator.pop(context);
              showAboutDialog(
                context: context,
                applicationName: AppConstants.appName,
                applicationVersion: '1.0.0',
                applicationIcon: const Icon(
                  Icons.check_circle_rounded,
                  size: 36,
                  color: AppConstants.primaryColor,
                ),
                children: [
                  Text(
                    AppLocalizations.tr('about_text', lang),
                    style: GoogleFonts.poppins(fontSize: 13),
                  ),
                ],
              );
            },
            isDark: isDark,
          ),
          Divider(
            indent: 16,
            endIndent: 16,
            color: isDark ? Colors.white12 : null,
          ),
          _DrawerItem(
            icon: Icons.logout_rounded,
            title: AppLocalizations.tr('log_out', lang),
            onTap: () async {
              Navigator.pop(context);
              final auth = context.read<AuthProvider>();
              await auth.logout();
              ApiService.setToken(null);
              if (context.mounted) {
                Navigator.pushNamedAndRemoveUntil(
                  context,
                  '/login',
                  (route) => false,
                );
              }
            },
            isDark: isDark,
          ),
        ],
      ),
    );
  }

  void _navigate(BuildContext context, String route) {
    Navigator.pop(context);
    if (ModalRoute.of(context)?.settings.name != route) {
      Navigator.pushReplacementNamed(context, route);
    }
  }
}

class _DrawerItem extends StatelessWidget {
  final IconData icon;
  final String title;
  final VoidCallback onTap;
  final bool isDark;

  const _DrawerItem({
    required this.icon,
    required this.title,
    required this.onTap,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: Icon(
        icon,
        size: 22,
        color: isDark ? Colors.white70 : AppConstants.textSecondary,
      ),
      title: Text(
        title,
        style: GoogleFonts.poppins(
          fontWeight: FontWeight.w500,
          color: isDark ? Colors.white : AppConstants.textPrimary,
        ),
      ),
      onTap: onTap,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
    );
  }
}
