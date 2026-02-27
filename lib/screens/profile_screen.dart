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
      if (mounted) {
        setState(() {
          _tasks = tasks;
          _loadingTasks = false;
        });
      }
    } catch (_) {
      if (mounted) setState(() => _loadingTasks = false);
    }
  }

  /// Opens a bottom sheet allowing the user to edit their profile.
  /// Saves changes to the server via AuthProvider.updateProfile.
  void _showEditProfileSheet(BuildContext context) {
    final auth = context.read<AuthProvider>();
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final nameCtrl = TextEditingController(text: auth.userName ?? '');
    final emailCtrl = TextEditingController(text: auth.userEmail ?? '');
    final phoneCtrl = TextEditingController(text: auth.userPhone ?? '');

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: isDark ? AppConstants.darkCard : Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) {
        return Padding(
          padding: EdgeInsets.only(
            left: 24,
            right: 24,
            top: 24,
            bottom: MediaQuery.of(ctx).viewInsets.bottom + 24,
          ),
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Handle bar
                Center(
                  child: Container(
                    width: 40,
                    height: 4,
                    decoration: BoxDecoration(
                      color: isDark ? Colors.white24 : Colors.grey[300],
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                Text(
                  'Edit Profile',
                  style: GoogleFonts.poppins(
                    fontSize: 20,
                    fontWeight: FontWeight.w700,
                    color: isDark ? Colors.white : AppConstants.textPrimary,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  'Changes are saved to the server.',
                  style: GoogleFonts.poppins(
                    fontSize: 13,
                    color: isDark ? Colors.white54 : AppConstants.textSecondary,
                  ),
                ),
                const SizedBox(height: 24),
                // Name field
                _ProfileTextField(
                  controller: nameCtrl,
                  label: 'Username',
                  icon: Icons.person_outline_rounded,
                  isDark: isDark,
                ),
                const SizedBox(height: 16),
                // Email field
                _ProfileTextField(
                  controller: emailCtrl,
                  label: 'Email',
                  icon: Icons.email_outlined,
                  isDark: isDark,
                  keyboardType: TextInputType.emailAddress,
                ),
                const SizedBox(height: 16),
                // Phone field
                _ProfileTextField(
                  controller: phoneCtrl,
                  label: 'Phone',
                  icon: Icons.phone_outlined,
                  isDark: isDark,
                  keyboardType: TextInputType.phone,
                ),
                const SizedBox(height: 28),
                // Save button
                _SaveProfileButton(
                  nameCtrl: nameCtrl,
                  emailCtrl: emailCtrl,
                  phoneCtrl: phoneCtrl,
                  isDark: isDark,
                  parentContext: context,
                ),
                const SizedBox(height: 8),
              ],
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final auth = context.watch<AuthProvider>();
    final settings = context.watch<AppSettingsProvider>();
    final lang = settings.locale;

    // All profile data comes from the real authenticated user
    final username = auth.userName ?? 'User';
    final email = auth.userEmail ?? '—';
    final phone = auth.userPhone ?? '';
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
            _InfoCard(
              icon: Icons.phone_rounded,
              title: 'Phone',
              subtitle: phone.isNotEmpty ? phone : '—',
              isDark: isDark,
            ),
            const SizedBox(height: 16),

            // ── Edit Profile button ──
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton.icon(
                icon: const Icon(Icons.edit_rounded, size: 18),
                label: Text(
                  'Edit Profile',
                  style: GoogleFonts.poppins(
                    fontWeight: FontWeight.w600,
                    fontSize: 15,
                  ),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppConstants.primaryColor,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                  elevation: 0,
                ),
                onPressed: () => _showEditProfileSheet(context),
              ),
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
            color: AppConstants.accentLavender,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Center(
            child: Icon(icon, size: 22, color: AppConstants.textPrimary),
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

// ── Save profile button with loading state ──
class _SaveProfileButton extends StatefulWidget {
  final TextEditingController nameCtrl;
  final TextEditingController emailCtrl;
  final TextEditingController phoneCtrl;
  final bool isDark;
  final BuildContext parentContext;

  const _SaveProfileButton({
    required this.nameCtrl,
    required this.emailCtrl,
    required this.phoneCtrl,
    required this.isDark,
    required this.parentContext,
  });

  @override
  State<_SaveProfileButton> createState() => _SaveProfileButtonState();
}

class _SaveProfileButtonState extends State<_SaveProfileButton> {
  bool _saving = false;

  Future<void> _save() async {
    final name = widget.nameCtrl.text.trim();
    final email = widget.emailCtrl.text.trim();
    final phone = widget.phoneCtrl.text.trim();

    if (name.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Username cannot be empty',
            style: GoogleFonts.poppins(fontSize: 13),
          ),
          backgroundColor: AppConstants.errorColor,
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }

    setState(() => _saving = true);

    try {
      await widget.parentContext.read<AuthProvider>().updateProfile(
        username: name,
        email: email,
        phone: phone.isNotEmpty ? phone : null,
      );

      if (mounted) {
        Navigator.pop(context);
        ScaffoldMessenger.of(widget.parentContext).showSnackBar(
          SnackBar(
            content: Text(
              'Profile updated successfully!',
              style: GoogleFonts.poppins(fontSize: 13),
            ),
            backgroundColor: AppConstants.successColor,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Failed: ${e.toString().replaceFirst('Exception: ', '')}',
              style: GoogleFonts.poppins(fontSize: 13),
            ),
            backgroundColor: AppConstants.errorColor,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: 52,
      child: ElevatedButton.icon(
        icon: _saving
            ? const SizedBox(
                width: 18,
                height: 18,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  color: Colors.white,
                ),
              )
            : const Icon(Icons.check_rounded, size: 20),
        label: Text(
          _saving ? 'Saving…' : 'Save Changes',
          style: GoogleFonts.poppins(fontWeight: FontWeight.w600, fontSize: 15),
        ),
        style: ElevatedButton.styleFrom(
          backgroundColor: AppConstants.primaryColor,
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
          elevation: 0,
        ),
        onPressed: _saving ? null : _save,
      ),
    );
  }
}

// ── Text field used in the edit-profile bottom sheet ──
class _ProfileTextField extends StatelessWidget {
  final TextEditingController controller;
  final String label;
  final IconData icon;
  final bool isDark;
  final TextInputType keyboardType;

  const _ProfileTextField({
    required this.controller,
    required this.label,
    required this.icon,
    required this.isDark,
    this.keyboardType = TextInputType.text,
  });

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      keyboardType: keyboardType,
      style: GoogleFonts.poppins(
        fontSize: 14,
        color: isDark ? Colors.white : AppConstants.textPrimary,
      ),
      decoration: InputDecoration(
        labelText: label,
        labelStyle: GoogleFonts.poppins(
          fontSize: 13,
          color: isDark ? Colors.white54 : AppConstants.textSecondary,
        ),
        prefixIcon: Icon(
          icon,
          size: 20,
          color: isDark ? Colors.white54 : AppConstants.primaryColor,
        ),
        filled: true,
        fillColor: isDark
            ? AppConstants.darkSurface
            : AppConstants.backgroundColor,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide(
            color: isDark
                ? Colors.white12
                : AppConstants.primaryLight.withValues(alpha: 0.3),
          ),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
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
    );
  }
}
