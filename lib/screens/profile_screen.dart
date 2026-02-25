import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../models/task.dart';
import '../services/api_service.dart';
import '../services/auth_provider.dart';
import '../services/app_settings_provider.dart';
import '../l10n/app_localizations.dart';
import '../utils/constants.dart';

/// Profile screen that displays the authenticated user's real credentials
/// and live task statistics fetched from the API.
class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  List<Task>? _tasks;
  bool _loadingTasks = true;

  @override
  void initState() {
    super.initState();
    _loadTasks();
  }

  Future<void> _loadTasks() async {
    try {
      final tasks = await ApiService().fetchTasks();
      if (mounted)
        setState(() {
          _tasks = tasks;
          _loadingTasks = false;
        });
    } catch (_) {
      if (mounted) setState(() => _loadingTasks = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final auth = context.watch<AuthProvider>();
    final settings = context.watch<AppSettingsProvider>();
    final lang = settings.locale;

    final username = auth.userName ?? 'User';
    final email = auth.userEmail ?? '—';
    final userId = auth.userId;
    final initial = username.isNotEmpty ? username[0].toUpperCase() : '?';

    // Task stats
    final total = _tasks?.length ?? 0;
    final completed = _tasks?.where((t) => t.status == 'completed').length ?? 0;
    final pending = total - completed;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          AppLocalizations.tr('profile', lang),
          style: GoogleFonts.poppins(
            fontWeight: FontWeight.w700,
            color: isDark ? Colors.white : AppConstants.textPrimary,
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(
              Icons.refresh_rounded,
              color: AppConstants.primaryColor,
            ),
            tooltip: 'Refresh',
            onPressed: () {
              setState(() => _loadingTasks = true);
              _loadTasks();
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(AppConstants.defaultPadding),
        child: Column(
          children: [
            // ── Avatar ──
            Center(
              child: Container(
                width: 116,
                height: 116,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: const LinearGradient(
                    colors: [
                      AppConstants.primaryLight,
                      AppConstants.accentPink,
                    ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: AppConstants.primaryColor.withValues(alpha: 0.2),
                      blurRadius: 20,
                      offset: const Offset(0, 6),
                    ),
                  ],
                ),
                child: Padding(
                  padding: const EdgeInsets.all(3),
                  child: CircleAvatar(
                    radius: 54,
                    backgroundColor: isDark
                        ? AppConstants.darkCard
                        : Colors.grey[200],
                    child: Text(
                      initial,
                      style: GoogleFonts.poppins(
                        fontSize: 40,
                        fontWeight: FontWeight.w700,
                        color: AppConstants.primaryColor,
                      ),
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 16),

            // ── Username ──
            Text(
              username,
              style: GoogleFonts.poppins(
                fontSize: 22,
                fontWeight: FontWeight.w700,
                color: isDark ? Colors.white : AppConstants.textPrimary,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              email,
              style: GoogleFonts.poppins(
                fontSize: 14,
                color: isDark ? Colors.white54 : AppConstants.textSecondary,
              ),
            ),
            const SizedBox(height: 28),

            // ── Task Statistics ──
            _SectionHeader(
              title: AppLocalizations.tr('task_statistics', lang),
              isDark: isDark,
            ),
            const SizedBox(height: 10),
            Row(
              children: [
                _StatCard(
                  label: 'Total',
                  value: _loadingTasks ? '…' : '$total',
                  color: AppConstants.primaryColor,
                  isDark: isDark,
                ),
                const SizedBox(width: 10),
                _StatCard(
                  label: 'Done',
                  value: _loadingTasks ? '…' : '$completed',
                  color: AppConstants.successColor,
                  isDark: isDark,
                ),
                const SizedBox(width: 10),
                _StatCard(
                  label: 'Pending',
                  value: _loadingTasks ? '…' : '$pending',
                  color: AppConstants.warningColor,
                  isDark: isDark,
                ),
              ],
            ),
            const SizedBox(height: 28),

            // ── Account Details ──
            _SectionHeader(
              title: AppLocalizations.tr('account_details', lang),
              isDark: isDark,
            ),
            const SizedBox(height: 10),

            _InfoCard(
              icon: Icons.person_rounded,
              title: 'Username',
              subtitle: username,
              isDark: isDark,
            ),
            _InfoCard(
              icon: Icons.email_rounded,
              title: 'Email',
              subtitle: email,
              isDark: isDark,
            ),
            if (userId != null)
              _InfoCard(
                icon: Icons.tag_rounded,
                title: 'User ID',
                subtitle: '#$userId',
                isDark: isDark,
              ),
            _InfoCard(
              icon: Icons.verified_user_rounded,
              title: 'Auth Status',
              subtitle: auth.isAuthenticated
                  ? 'Authenticated'
                  : 'Not signed in',
              isDark: isDark,
            ),

            const SizedBox(height: 28),

            // ── App Info ──
            _SectionHeader(title: 'App Info', isDark: isDark),
            const SizedBox(height: 10),

            _InfoCard(
              icon: Icons.school_rounded,
              title: AppLocalizations.tr('university', lang),
              subtitle: 'Royal University of Phnom Penh',
              isDark: isDark,
            ),
            _InfoCard(
              icon: Icons.menu_book_rounded,
              title: AppLocalizations.tr('course', lang),
              subtitle: 'CS361 — Mobile App Development',
              isDark: isDark,
            ),
            _InfoCard(
              icon: Icons.calendar_today_rounded,
              title: AppLocalizations.tr('semester', lang),
              subtitle: 'Spring 2026',
              isDark: isDark,
            ),

            const SizedBox(height: 28),

            // ── Logout button ──
            SizedBox(
              width: double.infinity,
              height: 50,
              child: OutlinedButton.icon(
                icon: const Icon(
                  Icons.logout_rounded,
                  color: AppConstants.errorColor,
                ),
                label: Text(
                  AppLocalizations.tr('logout', lang),
                  style: GoogleFonts.poppins(
                    fontWeight: FontWeight.w600,
                    color: AppConstants.errorColor,
                  ),
                ),
                style: OutlinedButton.styleFrom(
                  side: const BorderSide(color: AppConstants.errorColor),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                ),
                onPressed: () async {
                  final auth = context.read<AuthProvider>();
                  await auth.logout();
                  ApiService.setToken(null);
                  if (mounted) {
                    Navigator.pushNamedAndRemoveUntil(
                      context,
                      '/login',
                      (_) => false,
                    );
                  }
                },
              ),
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }
}

// ── Section header ──
class _SectionHeader extends StatelessWidget {
  final String title;
  final bool isDark;
  const _SectionHeader({required this.title, required this.isDark});

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.centerLeft,
      child: Text(
        title,
        style: GoogleFonts.poppins(
          fontSize: 16,
          fontWeight: FontWeight.w700,
          color: isDark ? Colors.white70 : AppConstants.textPrimary,
        ),
      ),
    );
  }
}

// ── Stat card ──
class _StatCard extends StatelessWidget {
  final String label;
  final String value;
  final Color color;
  final bool isDark;
  const _StatCard({
    required this.label,
    required this.value,
    required this.color,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 18),
        decoration: BoxDecoration(
          color: isDark ? AppConstants.darkCard : Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: isDark
              ? []
              : [
                  BoxShadow(
                    color: color.withValues(alpha: 0.1),
                    blurRadius: 12,
                    offset: const Offset(0, 4),
                  ),
                ],
        ),
        child: Column(
          children: [
            Text(
              value,
              style: GoogleFonts.poppins(
                fontSize: 26,
                fontWeight: FontWeight.w800,
                color: color,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              label,
              style: GoogleFonts.poppins(
                fontSize: 12,
                fontWeight: FontWeight.w500,
                color: isDark ? Colors.white54 : AppConstants.textSecondary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ── Info card ──
class _InfoCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final bool isDark;

  const _InfoCard({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      decoration: BoxDecoration(
        color: isDark ? AppConstants.darkCard : Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: isDark
            ? []
            : [
                BoxShadow(
                  color: AppConstants.primaryColor.withValues(alpha: 0.05),
                  blurRadius: 10,
                  offset: const Offset(0, 3),
                ),
              ],
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
        leading: Container(
          width: 42,
          height: 42,
          decoration: BoxDecoration(
            color: AppConstants.accentLavender.withValues(alpha: 0.4),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Center(
            child: Icon(icon, size: 22, color: AppConstants.primaryColor),
          ),
        ),
        title: Text(
          title,
          style: GoogleFonts.poppins(
            fontWeight: FontWeight.w600,
            fontSize: 14,
            color: isDark ? Colors.white : AppConstants.textPrimary,
          ),
        ),
        subtitle: Text(
          subtitle,
          style: GoogleFonts.poppins(
            fontSize: 13,
            color: isDark ? Colors.white54 : AppConstants.textSecondary,
          ),
        ),
      ),
    );
  }
}
