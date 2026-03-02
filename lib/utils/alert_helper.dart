import 'package:flutter/material.dart';
import 'package:flutter_final_project_app_with_full_ui_and_api_crud_integration/widgets/TextTheme.dart';
import 'constants.dart';

/// Consistent on-screen alert notifications for all activities.
class AlertHelper {
  AlertHelper._();

  /// Show a success alert (green) with an icon.
  static void showSuccess(BuildContext context, String message) {
    _show(
      context,
      message,
      AppConstants.successColor,
      Icons.check_circle_rounded,
    );
  }

  /// Show an error alert (red) with an icon.
  static void showError(BuildContext context, String message) {
    _show(context, message, AppConstants.errorColor, Icons.error_rounded);
  }

  /// Show a warning alert (orange) with an icon.
  static void showWarning(BuildContext context, String message) {
    _show(context, message, AppConstants.warningColor, Icons.warning_rounded);
  }

  /// Show an info alert (blue-grey) with an icon.
  static void showInfo(BuildContext context, String message) {
    _show(context, message, const Color(0xFF607D8B), Icons.info_rounded);
  }

  static void _show(
    BuildContext context,
    String message,
    Color color,
    IconData icon,
  ) {
    ScaffoldMessenger.of(context).clearSnackBars();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Icon(icon, color: Colors.white, size: 20),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                message,
                style: AppFonts.of(context, color: Colors.white, fontSize: 14),
              ),
            ),
          ],
        ),
        backgroundColor: color,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        margin: const EdgeInsets.fromLTRB(16, 0, 16, 16),
        duration: const Duration(seconds: 2),
        elevation: 6,
      ),
    );
  }
}
