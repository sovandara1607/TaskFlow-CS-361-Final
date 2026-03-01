import 'package:flutter/material.dart';
import 'package:flutter_final_project_app_with_full_ui_and_api_crud_integration/widgets/TextTheme.dart';
import 'package:provider/provider.dart';
import '../services/app_settings_provider.dart';
import '../services/auth_provider.dart';
import '../services/api_service.dart';
import '../services/task_provider.dart';
import '../services/notification_service.dart';
import '../l10n/app_localizations.dart';
import '../utils/constants.dart';
import '../widgets/glass_container.dart';

/// Settings Screen — All toggles wired to AppSettingsProvider for persistence.
class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final settings = context.watch<AppSettingsProvider>();
    final lang = settings.locale;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          AppLocalizations.tr('settings', lang),
          style: AppFonts.of(context, 
            fontWeight: FontWeight.w700,
            color: isDark ? Colors.white : AppConstants.textPrimary,
          ),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.all(AppConstants.defaultPadding),
        children: [
          // ── Appearance ──
          _SectionHeader(
            icon: Icons.palette_outlined,
            title: AppLocalizations.tr('appearance', lang).toUpperCase(),
            isDark: isDark,
          ),
          _SettingsCard(
            isDark: isDark,
            children: [
              SwitchListTile(
                secondary: Icon(
                  Icons.dark_mode_outlined,
                  color: isDark ? Colors.white70 : AppConstants.textSecondary,
                ),
                title: Text(
                  AppLocalizations.tr('dark_mode', lang),
                  style: AppFonts.of(context, 
                    fontWeight: FontWeight.w500,
                    color: isDark ? Colors.white : AppConstants.textPrimary,
                  ),
                ),
                subtitle: Text(
                  AppLocalizations.tr('use_dark_theme', lang),
                  style: AppFonts.of(context, 
                    fontSize: 12,
                    color: isDark ? Colors.white54 : AppConstants.textSecondary,
                  ),
                ),
                value: settings.themeMode == ThemeMode.dark,
                activeTrackColor: AppConstants.primaryColor,
                onChanged: (v) => settings.toggleDarkMode(v),
              ),
              Divider(
                height: 1,
                color: isDark
                    ? Colors.white12
                    : AppConstants.primaryLight.withValues(alpha: 0.2),
              ),
              ListTile(
                leading: Icon(
                  Icons.language_rounded,
                  color: isDark ? Colors.white70 : AppConstants.textSecondary,
                ),
                title: Text(
                  AppLocalizations.tr('language', lang),
                  style: AppFonts.of(context, 
                    fontWeight: FontWeight.w500,
                    color: isDark ? Colors.white : AppConstants.textPrimary,
                  ),
                ),
                trailing: DropdownButton<String>(
                  value: lang,
                  underline: const SizedBox(),
                  dropdownColor: isDark
                      ? AppConstants.glassDialogDark
                      : AppConstants.glassDialogLight,
                  style: AppFonts.of(context, 
                    fontSize: 14,
                    color: isDark ? Colors.white : AppConstants.textPrimary,
                  ),
                  items: AppLocalizations.supportedLocales
                      .map(
                        (code) => DropdownMenuItem(
                          value: code,
                          child: Text(AppLocalizations.localeName(code)),
                        ),
                      )
                      .toList(),
                  onChanged: (v) {
                    if (v != null) settings.setLocale(v);
                  },
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),

          // ── Notifications & Security ──
          _SectionHeader(
            icon: Icons.notifications_outlined,
            title: AppLocalizations.tr('notifications', lang).toUpperCase(),
            isDark: isDark,
          ),
          _SettingsCard(
            isDark: isDark,
            children: [
              SwitchListTile(
                secondary: Icon(
                  Icons.mark_email_unread_outlined,
                  color: isDark ? Colors.white70 : AppConstants.textSecondary,
                ),
                title: Text(
                  AppLocalizations.tr('push_notifications', lang),
                  style: AppFonts.of(context, 
                    fontWeight: FontWeight.w500,
                    color: isDark ? Colors.white : AppConstants.textPrimary,
                  ),
                ),
                value: settings.notificationsEnabled,
                activeTrackColor: AppConstants.primaryColor,
                onChanged: (_) async {
                  final newValue = !settings.notificationsEnabled;
                  await settings.setNotifications(newValue);
                  if (newValue) {
                    // Re-schedule all task reminders
                    if (context.mounted) {
                      final tasks = context.read<TaskProvider>().tasks;
                      await NotificationService.instance
                          .scheduleAllTaskReminders(tasks);
                    }
                  } else {
                    // Cancel all notifications
                    await NotificationService.instance.cancelAll();
                  }
                },
              ),
              Divider(
                height: 1,
                color: isDark
                    ? Colors.white12
                    : AppConstants.primaryLight.withValues(alpha: 0.2),
              ),
            ],
          ),
          const SizedBox(height: 20),

          // ── Account ──
          _SectionHeader(
            icon: Icons.person_outline_rounded,
            title: AppLocalizations.tr('account', lang).toUpperCase(),
            isDark: isDark,
          ),
          _SettingsCard(
            isDark: isDark,
            children: [
              ListTile(
                leading: Icon(
                  Icons.key_rounded,
                  color: isDark ? Colors.white70 : AppConstants.textSecondary,
                ),
                title: Text(
                  AppLocalizations.tr('privacy_policy', lang),
                  style: AppFonts.of(context, 
                    fontWeight: FontWeight.w500,
                    color: isDark ? Colors.white : AppConstants.textPrimary,
                  ),
                ),
                trailing: Icon(
                  Icons.chevron_right_rounded,
                  color: isDark ? Colors.white24 : AppConstants.textLight,
                ),
                onTap: () {
                  showDialog(
                    context: context,
                    builder: (_) => AlertDialog(
                      backgroundColor: isDark
                          ? AppConstants.glassDialogDark
                          : AppConstants.glassDialogLight,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(
                          AppConstants.cardRadius,
                        ),
                      ),
                      title: Text(
                        '${AppLocalizations.tr('privacy_policy', lang)}',
                        style: AppFonts.of(context, 
                          fontWeight: FontWeight.w700,
                          color: isDark
                              ? Colors.white
                              : AppConstants.textPrimary,
                        ),
                      ),
                      content: Text(
                        'Your privacy is important to us. TaskFlow does not '
                        'collect personal data beyond what is needed for '
                        'functionality. All data is transmitted securely.',
                        style: AppFonts.of(context, 
                          color: isDark
                              ? Colors.white54
                              : AppConstants.textSecondary,
                          height: 1.5,
                        ),
                      ),
                      actions: [
                        TextButton(
                          onPressed: () => Navigator.pop(context),
                          child: Text(
                            AppLocalizations.tr('close', lang),
                            style: AppFonts.of(context, 
                              color: AppConstants.primaryColor,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ],
          ),
          const SizedBox(height: 24),

          // ── About ──
          Center(
            child: Column(
              children: [
                Text(
                  '${AppConstants.appName} v1.0.0',
                  style: AppFonts.of(context, 
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: isDark ? Colors.white54 : AppConstants.textSecondary,
                  ),
                ),
                const SizedBox(height: 4),
                // Text(
                //   'CS361 — Mobile App Development',
                //   style: AppFonts.of(context, 
                //     fontSize: 12,
                //     color: isDark ? Colors.white38 : AppConstants.textLight,
                //   ),
                // ),
              ],
            ),
          ),
          const SizedBox(height: 32),

          // ── Log Out ──
          SizedBox(
            width: double.infinity,
            height: 52,
            child: OutlinedButton.icon(
              icon: const Icon(
                Icons.logout_rounded,
                size: 20,
                color: Color(0xFFFF6B6B),
              ),
              label: Text(
                AppLocalizations.tr('log_out', lang),
                style: AppFonts.of(context, 
                  color: const Color(0xFFFF6B6B),
                  fontWeight: FontWeight.w600,
                ),
              ),
              style: OutlinedButton.styleFrom(
                side: const BorderSide(color: Color(0xFFFF6B6B)),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
              ),
              onPressed: () {
                showDialog(
                  context: context,
                  builder: (_) => AlertDialog(
                    backgroundColor: isDark
                        ? AppConstants.glassDialogDark
                        : AppConstants.glassDialogLight,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(
                        AppConstants.cardRadius,
                      ),
                    ),
                    title: Text(
                      '${AppLocalizations.tr('log_out', lang)}',
                      style: AppFonts.of(context, 
                        fontWeight: FontWeight.w700,
                        color: isDark ? Colors.white : AppConstants.textPrimary,
                      ),
                    ),
                    content: Text(
                      AppLocalizations.tr('confirm_logout', lang),
                      style: AppFonts.of(context, 
                        color: isDark
                            ? Colors.white54
                            : AppConstants.textSecondary,
                      ),
                    ),
                    actions: [
                      TextButton(
                        onPressed: () => Navigator.pop(context),
                        child: Text(
                          AppLocalizations.tr('cancel', lang),
                          style: AppFonts.of(context, 
                            color: isDark
                                ? Colors.white54
                                : AppConstants.textSecondary,
                          ),
                        ),
                      ),
                      ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFFFF6B6B),
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        onPressed: () async {
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
                        child: Text(
                          AppLocalizations.tr('log_out', lang),
                          style: AppFonts.of(context, 
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
          const SizedBox(height: 32),
        ],
      ),
    );
  }
}

// ── Soft rounded card wrapper ──
class _SettingsCard extends StatelessWidget {
  final List<Widget> children;
  final bool isDark;
  const _SettingsCard({required this.children, required this.isDark});

  @override
  Widget build(BuildContext context) {
    return GlassContainer(
      borderRadius: AppConstants.cardRadius,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(AppConstants.cardRadius),
        child: Column(children: children),
      ),
    );
  }
}

// ── Section header with icon ──
class _SectionHeader extends StatelessWidget {
  final IconData icon;
  final String title;
  final bool isDark;
  const _SectionHeader({
    required this.icon,
    required this.title,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(
        children: [
          Icon(
            icon,
            size: 18,
            color: isDark ? Colors.white54 : AppConstants.textSecondary,
          ),
          const SizedBox(width: 6),
          Text(
            title,
            style: AppFonts.of(context, 
              fontSize: 12,
              fontWeight: FontWeight.w700,
              letterSpacing: 1.2,
              color: isDark ? Colors.white54 : AppConstants.textSecondary,
            ),
          ),
        ],
      ),
    );
  }
}
