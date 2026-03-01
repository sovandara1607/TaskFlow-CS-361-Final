import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_final_project_app_with_full_ui_and_api_crud_integration/widgets/TextTheme.dart';
import 'package:provider/provider.dart';
import '../services/app_settings_provider.dart';
import '../services/auth_provider.dart';
import '../services/api_service.dart';
import '../l10n/app_localizations.dart';
import '../utils/constants.dart';
import 'app_dialogs.dart';

/// Frosted-glass navigation drawer with grouped sections and modern layout.
class AppDrawer extends StatelessWidget {
  const AppDrawer({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final settings = context.watch<AppSettingsProvider>();
    final auth = context.watch<AuthProvider>();
    final lang = settings.locale;
    final displayName = auth.userName ?? 'User';
    final displayEmail = auth.userEmail ?? '—';
    final topPad = MediaQuery.of(context).padding.top;

    return Drawer(
      backgroundColor: Colors.transparent,
      child: ClipRRect(
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 24, sigmaY: 24),
          child: Container(
            color: isDark
                ? Colors.black.withValues(alpha: 0.55)
                : Colors.white.withValues(alpha: 0.80),
            child: Column(
              children: [
                // ── Profile header ──
                Container(
                  width: double.infinity,
                  padding: EdgeInsets.fromLTRB(24, topPad + 28, 24, 24),
                  decoration: BoxDecoration(
                    border: Border(
                      bottom: BorderSide(
                        color: isDark
                            ? Colors.white.withValues(alpha: 0.06)
                            : Colors.grey.withValues(alpha: 0.12),
                      ),
                    ),
                  ),
                  child: Row(
                    children: [
                      Container(
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: isDark
                                ? Colors.white.withValues(alpha: 0.15)
                                : AppConstants.primaryColor.withValues(
                                    alpha: 0.2,
                                  ),
                            width: 2.5,
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: AppConstants.primaryColor.withValues(
                                alpha: 0.15,
                              ),
                              blurRadius: 12,
                            ),
                          ],
                        ),
                        child: CircleAvatar(
                          radius: 26,
                          backgroundColor: AppConstants.primaryColor,
                          child: Text(
                            displayName.isNotEmpty
                                ? displayName[0].toUpperCase()
                                : '?',
                            style: AppFonts.of(context, 
                              fontSize: 20,
                              fontWeight: FontWeight.w700,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 14),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              displayName,
                              style: AppFonts.of(context, 
                                fontWeight: FontWeight.w700,
                                fontSize: 16,
                                color: isDark
                                    ? Colors.white
                                    : AppConstants.textPrimary,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                            const SizedBox(height: 2),
                            Text(
                              displayEmail,
                              style: AppFonts.of(context, 
                                fontSize: 12,
                                color: isDark
                                    ? Colors.white54
                                    : AppConstants.textSecondary,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),

                // ── Scrollable menu ──
                Expanded(
                  child: ListView(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 14,
                      vertical: 16,
                    ),
                    children: [
                      // Navigation group
                      _SectionLabel(
                        label: AppLocalizations.tr(
                          'navigation',
                          lang,
                        ).toUpperCase(),
                        isDark: isDark,
                      ),
                      const SizedBox(height: 6),
                      _GlassNavGroup(
                        isDark: isDark,
                        children: [
                          _DrawerNavItem(
                            icon: Icons.wb_sunny_outlined,
                            title: AppLocalizations.tr('today', lang),
                            onTap: () => _navigate(context, '/'),
                            isDark: isDark,
                          ),
                          _DrawerNavItem(
                            icon: Icons.checklist_rounded,
                            title: AppLocalizations.tr('tasks', lang),
                            onTap: () => _navigate(context, '/tasks'),
                            isDark: isDark,
                          ),
                          _DrawerNavItem(
                            icon: Icons.add_circle_outline_rounded,
                            title: AppLocalizations.tr('add_task', lang),
                            onTap: () {
                              Navigator.pop(context);
                              Navigator.pushNamed(context, '/add');
                            },
                            isDark: isDark,
                          ),
                        ],
                      ),

                      const SizedBox(height: 20),

                      // Account group
                      _SectionLabel(
                        label: AppLocalizations.tr(
                          'account',
                          lang,
                        ).toUpperCase(),
                        isDark: isDark,
                      ),
                      const SizedBox(height: 6),
                      _GlassNavGroup(
                        isDark: isDark,
                        children: [
                          _DrawerNavItem(
                            icon: Icons.person_outline_rounded,
                            title: AppLocalizations.tr('profile', lang),
                            onTap: () => _navigate(context, '/profile'),
                            isDark: isDark,
                          ),
                          _DrawerNavItem(
                            icon: Icons.settings_outlined,
                            title: AppLocalizations.tr('settings', lang),
                            onTap: () {
                              Navigator.pop(context);
                              Navigator.pushNamed(context, '/settings');
                            },
                            isDark: isDark,
                          ),
                          _DrawerNavItem(
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
                                    style: AppFonts.of(context, fontSize: 13),
                                  ),
                                ],
                              );
                            },
                            isDark: isDark,
                          ),
                        ],
                      ),
                    ],
                  ),
                ),

                // ── Logout pinned at bottom ──
                Container(
                  padding: const EdgeInsets.fromLTRB(14, 0, 14, 12),
                  child: SafeArea(
                    top: false,
                    child: _GlassNavGroup(
                      isDark: isDark,
                      children: [
                        _DrawerNavItem(
                          icon: Icons.logout_rounded,
                          title: AppLocalizations.tr('log_out', lang),
                          iconColor: AppConstants.errorColor,
                          titleColor: AppConstants.errorColor,
                          onTap: () async {
                            final confirmed = await AppDialogs.showConfirmation(
                              context: context,
                              title: AppLocalizations.tr('log_out', lang),
                              message: AppLocalizations.tr(
                                'log_out_confirm',
                                lang,
                              ),
                              confirmText: AppLocalizations.tr('log_out', lang),
                              confirmColor: AppConstants.errorColor,
                            );
                            if (!confirmed || !context.mounted) return;
                            final auth = context.read<AuthProvider>();
                            await auth.logout();
                            ApiService.setToken(null);
                            if (context.mounted) {
                              Navigator.pushNamedAndRemoveUntil(
                                context,
                                '/login',
                                (_) => false,
                              );
                            }
                          },
                          isDark: isDark,
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
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

// ── Section label ──
class _SectionLabel extends StatelessWidget {
  final String label;
  final bool isDark;
  const _SectionLabel({required this.label, required this.isDark});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(left: 8, bottom: 2),
      child: Text(
        label,
        style: AppFonts.of(context, 
          fontSize: 11,
          fontWeight: FontWeight.w700,
          letterSpacing: 1.0,
          color: isDark ? Colors.white38 : AppConstants.textLight,
        ),
      ),
    );
  }
}

// ── Frosted group container ──
class _GlassNavGroup extends StatelessWidget {
  final bool isDark;
  final List<Widget> children;
  const _GlassNavGroup({required this.isDark, required this.children});

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(16),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
        child: Container(
          decoration: BoxDecoration(
            color: isDark
                ? Colors.white.withValues(alpha: 0.07)
                : Colors.white.withValues(alpha: 0.65),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: isDark
                  ? Colors.white.withValues(alpha: 0.08)
                  : Colors.white.withValues(alpha: 0.80),
            ),
          ),
          child: Column(
            children: [
              for (int i = 0; i < children.length; i++) ...[
                children[i],
                if (i < children.length - 1)
                  Divider(
                    height: 1,
                    thickness: 0.5,
                    indent: 52,
                    color: isDark
                        ? Colors.white.withValues(alpha: 0.06)
                        : Colors.grey.withValues(alpha: 0.12),
                  ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

// ── Single nav item inside a glass group ──
class _DrawerNavItem extends StatelessWidget {
  final IconData icon;
  final String title;
  final VoidCallback onTap;
  final bool isDark;
  final Color? iconColor;
  final Color? titleColor;

  const _DrawerNavItem({
    required this.icon,
    required this.title,
    required this.onTap,
    required this.isDark,
    this.iconColor,
    this.titleColor,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(14),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 13),
          child: Row(
            children: [
              Container(
                width: 32,
                height: 32,
                decoration: BoxDecoration(
                  color: (iconColor ?? AppConstants.primaryLight).withValues(
                    alpha: isDark ? 0.12 : 0.08,
                  ),
                  borderRadius: BorderRadius.circular(9),
                ),
                child: Icon(
                  icon,
                  size: 18,
                  color:
                      iconColor ??
                      (isDark ? Colors.white70 : AppConstants.textSecondary),
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Text(
                  title,
                  style: AppFonts.of(context, 
                    fontWeight: FontWeight.w500,
                    fontSize: 14,
                    color:
                        titleColor ??
                        (isDark ? Colors.white : AppConstants.textPrimary),
                  ),
                ),
              ),
              Icon(
                Icons.chevron_right_rounded,
                size: 18,
                color: isDark
                    ? Colors.white24
                    : Colors.grey.withValues(alpha: 0.3),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
