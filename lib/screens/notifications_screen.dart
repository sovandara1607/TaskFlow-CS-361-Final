import 'package:flutter/material.dart';
import 'package:flutter_final_project_app_with_full_ui_and_api_crud_integration/widgets/TextTheme.dart';
import 'package:provider/provider.dart';
import '../models/app_notification.dart';
import '../services/notification_provider.dart';
import '../services/app_settings_provider.dart';
import '../l10n/app_localizations.dart';
import '../utils/constants.dart';
import '../widgets/glass_container.dart';

/// Notifications screen showing server-side notifications with
/// mark-as-read, swipe-to-delete, and clear-all functionality.
class NotificationsScreen extends StatefulWidget {
  const NotificationsScreen({super.key});

  @override
  State<NotificationsScreen> createState() => _NotificationsScreenState();
}

class _NotificationsScreenState extends State<NotificationsScreen> {
  @override
  void initState() {
    super.initState();
    // Fetch notifications when screen is first shown
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<NotificationProvider>().fetchNotifications();
    });
  }

  @override
  Widget build(BuildContext context) {
    final settings = context.watch<AppSettingsProvider>();
    final lang = settings.locale;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final provider = context.watch<NotificationProvider>();
    final notifications = provider.notifications;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          AppLocalizations.tr('notifications', lang),
          style: AppFonts.of(context, fontWeight: FontWeight.w700),
        ),
        actions: [
          if (notifications.isNotEmpty) ...[
            // Mark all as read
            if (provider.unreadCount > 0)
              IconButton(
                tooltip: AppLocalizations.tr('mark_all_read', lang),
                icon: Icon(
                  Icons.done_all_rounded,
                  size: 20,
                  color: isDark ? Colors.white70 : AppConstants.textSecondary,
                ),
                onPressed: () => provider.markAllAsRead(),
              ),
            // Clear all
            IconButton(
              tooltip: AppLocalizations.tr('clear_all', lang),
              icon: Icon(
                Icons.delete_sweep_rounded,
                size: 20,
                color: isDark ? Colors.white70 : AppConstants.textSecondary,
              ),
              onPressed: () => _confirmClearAll(context, provider, lang),
            ),
          ],
        ],
      ),
      body: provider.isLoading && notifications.isEmpty
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              onRefresh: provider.fetchNotifications,
              child: notifications.isEmpty
                  ? _EmptyState(isDark: isDark, lang: lang)
                  : ListView.builder(
                      padding: EdgeInsets.fromLTRB(
                        20,
                        12,
                        20,
                        AppConstants.bottomNavBarSpace,
                      ),
                      itemCount: notifications.length,
                      itemBuilder: (context, index) {
                        final notif = notifications[index];
                        return _NotificationCard(
                          notification: notif,
                          isDark: isDark,
                          onTap: () {
                            if (!notif.isRead) {
                              provider.markAsRead(notif.id);
                            }
                          },
                          onDismissed: () {
                            provider.deleteNotification(notif.id);
                          },
                        );
                      },
                    ),
            ),
    );
  }

  void _confirmClearAll(
    BuildContext context,
    NotificationProvider provider,
    String lang,
  ) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(
          AppLocalizations.tr('clear_all_notifications', lang),
          style: AppFonts.of(context, fontWeight: FontWeight.w600),
        ),
        content: Text(
          AppLocalizations.tr('clear_all_confirm', lang),
          style: AppFonts.of(context, 
            fontSize: 14,
            color: isDark ? Colors.white70 : AppConstants.textSecondary,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text(
              AppLocalizations.tr('cancel', lang),
              style: AppFonts.of(context),
            ),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(ctx);
              provider.deleteAllNotifications();
            },
            child: Text(
              AppLocalizations.tr('clear_all', lang),
              style: AppFonts.of(context, color: AppConstants.errorColor),
            ),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Empty state
// ─────────────────────────────────────────────────────────────────────────────
class _EmptyState extends StatelessWidget {
  final bool isDark;
  final String lang;
  const _EmptyState({required this.isDark, required this.lang});

  @override
  Widget build(BuildContext context) {
    return ListView(
      children: [
        Padding(
          padding: const EdgeInsets.only(top: 100),
          child: Center(
            child: Column(
              children: [
                Icon(
                  Icons.notifications_off_outlined,
                  size: 48,
                  color: isDark ? Colors.white30 : AppConstants.textLight,
                ),
                const SizedBox(height: 12),
                Text(
                  AppLocalizations.tr('no_notifications', lang),
                  style: AppFonts.of(context, 
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: isDark ? Colors.white70 : AppConstants.textPrimary,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  AppLocalizations.tr('notifications_empty_hint', lang),
                  style: AppFonts.of(context, 
                    fontSize: 13,
                    color: isDark ? Colors.white38 : AppConstants.textSecondary,
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Notification card with swipe-to-delete
// ─────────────────────────────────────────────────────────────────────────────
class _NotificationCard extends StatelessWidget {
  final AppNotification notification;
  final bool isDark;
  final VoidCallback onTap;
  final VoidCallback onDismissed;

  const _NotificationCard({
    required this.notification,
    required this.isDark,
    required this.onTap,
    required this.onDismissed,
  });

  @override
  Widget build(BuildContext context) {
    return Dismissible(
      key: ValueKey(notification.id),
      direction: DismissDirection.endToStart,
      background: Container(
        margin: const EdgeInsets.only(bottom: 10),
        padding: const EdgeInsets.only(right: 20),
        alignment: Alignment.centerRight,
        decoration: BoxDecoration(
          color: AppConstants.errorColor.withValues(alpha: 0.15),
          borderRadius: BorderRadius.circular(14),
        ),
        child: Icon(
          Icons.delete_rounded,
          color: AppConstants.errorColor,
          size: 24,
        ),
      ),
      onDismissed: (_) => onDismissed(),
      child: GestureDetector(
        onTap: onTap,
        child: GlassContainer(
          margin: const EdgeInsets.only(bottom: 10),
          borderRadius: 14,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // ── Icon ──
                Container(
                  width: 42,
                  height: 42,
                  decoration: BoxDecoration(
                    color: notification.color.withValues(
                      alpha: isDark ? 0.25 : 0.15,
                    ),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(
                    notification.icon,
                    color: isDark
                        ? notification.color.withValues(alpha: 0.9)
                        : notification.color,
                    size: 20,
                  ),
                ),
                const SizedBox(width: 12),
                // ── Content ──
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              notification.title,
                              style: AppFonts.of(context, 
                                fontSize: 14,
                                fontWeight: notification.isRead
                                    ? FontWeight.w500
                                    : FontWeight.w700,
                                color: isDark
                                    ? Colors.white
                                    : AppConstants.textPrimary,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          // Unread indicator dot
                          if (!notification.isRead) ...[
                            const SizedBox(width: 8),
                            Container(
                              width: 8,
                              height: 8,
                              decoration: BoxDecoration(
                                color: AppConstants.accentSky,
                                shape: BoxShape.circle,
                              ),
                            ),
                          ],
                        ],
                      ),
                      const SizedBox(height: 3),
                      Text(
                        notification.message,
                        style: AppFonts.of(context, 
                          fontSize: 12,
                          color: isDark
                              ? Colors.white54
                              : AppConstants.textSecondary,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 6),
                      Text(
                        notification.timeAgo,
                        style: AppFonts.of(context, 
                          fontSize: 11,
                          color: isDark
                              ? Colors.white30
                              : AppConstants.textLight,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
