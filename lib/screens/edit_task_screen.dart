import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_final_project_app_with_full_ui_and_api_crud_integration/widgets/TextTheme.dart';
import 'package:provider/provider.dart';
import '../models/task.dart';
import '../services/task_provider.dart';
import '../services/app_settings_provider.dart';
import '../l10n/app_localizations.dart';
import '../widgets/app_dialogs.dart';
import '../utils/constants.dart';
import '../utils/validators.dart';

/// Edit Task Screen — Tiimo‑style form with category, dark mode.
class EditTaskScreen extends StatefulWidget {
  final Task task;

  const EditTaskScreen({super.key, required this.task});

  @override
  State<EditTaskScreen> createState() => _EditTaskScreenState();
}

class _EditTaskScreenState extends State<EditTaskScreen> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _titleCtrl;
  late TextEditingController _descCtrl;
  late String _status;
  late String _category;
  DateTime? _dueDate;
  bool _isSaving = false;

  static const _statuses = {
    'pending': 'Pending',
    'in_progress': 'In Progress',
    'completed': 'Completed',
  };

  @override
  void initState() {
    super.initState();
    _titleCtrl = TextEditingController(text: widget.task.title);
    _descCtrl = TextEditingController(text: widget.task.description);
    _status = widget.task.status;
    _category = widget.task.category;
    if (widget.task.dueDate != null) {
      try {
        _dueDate = DateTime.parse(widget.task.dueDate!);
      } catch (_) {}
    }
  }

  @override
  void dispose() {
    _titleCtrl.dispose();
    _descCtrl.dispose();
    super.dispose();
  }

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _dueDate ?? DateTime.now(),
      firstDate: DateTime(2020),
      lastDate: DateTime.now().add(const Duration(days: 365)),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: Theme.of(
              context,
            ).colorScheme.copyWith(primary: AppConstants.primaryColor),
          ),
          child: child!,
        );
      },
    );
    if (picked != null) {
      setState(() => _dueDate = picked);
    }
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isSaving = true);

    final updatedTask = widget.task.copyWith(
      title: _titleCtrl.text.trim(),
      description: _descCtrl.text.trim(),
      status: _status,
      category: _category,
      dueDate: _dueDate != null
          ? '${_dueDate!.year}-${_dueDate!.month.toString().padLeft(2, '0')}-${_dueDate!.day.toString().padLeft(2, '0')}'
          : widget.task.dueDate,
    );

    final success = await context.read<TaskProvider>().updateTask(updatedTask);

    if (!mounted) return;
    setState(() => _isSaving = false);

    if (success) {
      await AppDialogs.showSuccess(
        context: context,
        message: 'Task updated successfully!',
      );
      if (mounted) Navigator.pop(context);
    } else {
      await AppDialogs.showError(
        context: context,
        message: 'Failed to update task. Please try again.',
      );
    }
  }

  Future<void> _deleteTask() async {
    final nav = Navigator.of(context);
    final messenger = ScaffoldMessenger.of(context);
    final provider = context.read<TaskProvider>();
    final confirmed = await AppDialogs.showConfirmation(
      context: context,
      title: 'Delete Task',
      message: 'Delete "${widget.task.title}"?',
    );
    if (!confirmed || !mounted) return;
    await provider.deleteTask(widget.task.id!);
    if (!mounted) return;
    messenger.showSnackBar(
      SnackBar(
        content: const Text('Task deleted.'),
        backgroundColor: AppConstants.successColor,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
    );
    nav.pop();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final lang = context.watch<AppSettingsProvider>().locale;
    final headerColor = isDark
        ? const Color(0xFF1E1E1E)
        : AppConstants.primaryColor;
    final cardColor = isDark ? AppConstants.darkBackground : Colors.white;
    final dateStr = _dueDate != null
        ? '${_dueDate!.day.toString().padLeft(2, '0')} / ${_dueDate!.month.toString().padLeft(2, '0')} / ${_dueDate!.year}'
        : AppLocalizations.tr('select_due_date', lang);

    return Scaffold(
      backgroundColor: headerColor,
      body: Form(
        key: _formKey,
        child: Column(
          children: [
            // ── COLORED HEADER ──
            SafeArea(
              bottom: false,
              child: Padding(
                padding: const EdgeInsets.fromLTRB(6, 4, 6, 0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Nav bar
                    Row(
                      children: [
                        IconButton(
                          icon: const Icon(
                            Icons.arrow_back_ios_rounded,
                            color: Colors.white,
                            size: 20,
                          ),
                          onPressed: () => Navigator.pop(context),
                        ),
                        Expanded(
                          child: Text(
                            AppLocalizations.tr('edit_task', lang),
                            textAlign: TextAlign.center,
                            style: AppFonts.of(context, 
                              fontSize: 18,
                              fontWeight: FontWeight.w700,
                              color: Colors.white,
                            ),
                          ),
                        ),
                        IconButton(
                          icon: const Icon(
                            Icons.delete_outline_rounded,
                            color: Color(0xFFFF6B6B),
                            size: 22,
                          ),
                          onPressed: _deleteTask,
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    // Title + Date in header
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            AppLocalizations.tr('task_title', lang),
                            style: AppFonts.of(context, 
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                              color: Colors.white60,
                            ),
                          ),
                          const SizedBox(height: 8),
                          ClipRRect(
                            borderRadius: BorderRadius.circular(14),
                            child: BackdropFilter(
                              filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
                              child: Container(
                                decoration: BoxDecoration(
                                  color: Colors.white.withValues(alpha: 0.12),
                                  borderRadius: BorderRadius.circular(14),
                                  border: Border.all(
                                    color: Colors.white.withValues(alpha: 0.20),
                                  ),
                                ),
                                child: TextFormField(
                                  controller: _titleCtrl,
                                  validator: Validators.minLength3,
                                  style: AppFonts.of(context, 
                                    color: Colors.white,
                                    fontSize: 16,
                                    fontWeight: FontWeight.w600,
                                  ),
                                  decoration: InputDecoration(
                                    hintText: AppLocalizations.tr(
                                      'enter_task_title',
                                      lang,
                                    ),
                                    hintStyle: AppFonts.of(context, 
                                      color: Colors.white30,
                                      fontSize: 16,
                                    ),
                                    errorStyle: AppFonts.of(context, 
                                      color: const Color(0xFFFF6B6B),
                                      fontSize: 12,
                                    ),
                                    border: InputBorder.none,
                                    enabledBorder: InputBorder.none,
                                    focusedBorder: InputBorder.none,
                                    contentPadding: const EdgeInsets.symmetric(
                                      horizontal: 16,
                                      vertical: 14,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(height: 14),
                          Text(
                            AppLocalizations.tr('due_date', lang),
                            style: AppFonts.of(context, 
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                              color: Colors.white60,
                            ),
                          ),
                          const SizedBox(height: 6),
                          GestureDetector(
                            onTap: _pickDate,
                            child: Row(
                              children: [
                                const Icon(
                                  Icons.calendar_today_rounded,
                                  size: 16,
                                  color: Colors.white70,
                                ),
                                const SizedBox(width: 8),
                                Text(
                                  dateStr,
                                  style: AppFonts.of(context, 
                                    fontSize: 15,
                                    fontWeight: FontWeight.w500,
                                    color: _dueDate != null
                                        ? Colors.white
                                        : Colors.white38,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 24),
                  ],
                ),
              ),
            ),

            // ── WHITE FORM CARD ──
            Expanded(
              child: Container(
                width: double.infinity,
                decoration: BoxDecoration(
                  color: cardColor,
                  borderRadius: const BorderRadius.vertical(
                    top: Radius.circular(28),
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.08),
                      blurRadius: 16,
                      offset: const Offset(0, -4),
                    ),
                  ],
                ),
                child: SingleChildScrollView(
                  padding: const EdgeInsets.fromLTRB(24, 28, 24, 40),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // ── Description ──
                      Text(
                        AppLocalizations.tr('description', lang),
                        style: AppFonts.of(context, 
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                          color: isDark
                              ? Colors.white
                              : AppConstants.textPrimary,
                        ),
                      ),
                      const SizedBox(height: 8),
                      TextFormField(
                        controller: _descCtrl,
                        maxLines: 3,
                        validator: Validators.required,
                        style: AppFonts.of(context, 
                          fontSize: 14,
                          color: isDark
                              ? Colors.white
                              : AppConstants.textPrimary,
                        ),
                        decoration: InputDecoration(
                          hintText: AppLocalizations.tr(
                            'enter_description',
                            lang,
                          ),
                          hintStyle: AppFonts.of(context, 
                            fontSize: 14,
                            color: isDark
                                ? Colors.white30
                                : AppConstants.textLight,
                          ),
                          filled: true,
                          fillColor: isDark
                              ? Colors.white.withValues(alpha: 0.06)
                              : const Color(0xFFF8F8F8),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(14),
                            borderSide: BorderSide.none,
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(14),
                            borderSide: BorderSide.none,
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(14),
                            borderSide: BorderSide(
                              color: AppConstants.primaryColor.withValues(
                                alpha: 0.3,
                              ),
                            ),
                          ),
                          contentPadding: const EdgeInsets.all(16),
                        ),
                      ),
                      const SizedBox(height: 24),

                      // ── Category ──
                      Text(
                        AppLocalizations.tr('category', lang),
                        style: AppFonts.of(context, 
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                          color: isDark
                              ? Colors.white
                              : AppConstants.textPrimary,
                        ),
                      ),
                      const SizedBox(height: 12),
                      Wrap(
                        spacing: 10,
                        runSpacing: 10,
                        children: AppConstants.categories.map((cat) {
                          final selected = _category == cat;
                          return GestureDetector(
                            onTap: () => setState(() => _category = cat),
                            child: AnimatedContainer(
                              duration: const Duration(milliseconds: 200),
                              padding: const EdgeInsets.symmetric(
                                horizontal: 18,
                                vertical: 10,
                              ),
                              decoration: BoxDecoration(
                                color: selected
                                    ? AppConstants.primaryColor
                                    : (isDark
                                          ? Colors.white.withValues(alpha: 0.08)
                                          : const Color(0xFFF0F0F0)),
                                borderRadius: BorderRadius.circular(24),
                                border: Border.all(
                                  color: selected
                                      ? AppConstants.primaryColor
                                      : (isDark
                                            ? Colors.white.withValues(
                                                alpha: 0.15,
                                              )
                                            : const Color(0xFFE0E0E0)),
                                  width: 1.5,
                                ),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(
                                    AppConstants.categoryIcon(cat),
                                    size: 15,
                                    color: selected
                                        ? Colors.white
                                        : (isDark
                                              ? Colors.white60
                                              : AppConstants.textSecondary),
                                  ),
                                  const SizedBox(width: 6),
                                  Text(
                                    AppConstants.categoryLabel(cat),
                                    style: AppFonts.of(context, 
                                      fontSize: 13,
                                      fontWeight: selected
                                          ? FontWeight.w600
                                          : FontWeight.w400,
                                      color: selected
                                          ? Colors.white
                                          : (isDark
                                                ? Colors.white70
                                                : AppConstants.textPrimary),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          );
                        }).toList(),
                      ),
                      const SizedBox(height: 24),

                      // ── Status ──
                      Text(
                        AppLocalizations.tr('status', lang),
                        style: AppFonts.of(context, 
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                          color: isDark
                              ? Colors.white
                              : AppConstants.textPrimary,
                        ),
                      ),
                      const SizedBox(height: 12),
                      Row(
                        children: _statuses.entries.map((e) {
                          final selected = _status == e.key;
                          final color = AppConstants.statusColor(e.key);
                          return Expanded(
                            child: Padding(
                              padding: EdgeInsets.only(
                                right: e.key != 'completed' ? 8 : 0,
                              ),
                              child: GestureDetector(
                                onTap: () => setState(() => _status = e.key),
                                child: AnimatedContainer(
                                  duration: const Duration(milliseconds: 200),
                                  padding: const EdgeInsets.symmetric(
                                    vertical: 12,
                                  ),
                                  decoration: BoxDecoration(
                                    color: selected
                                        ? color.withValues(alpha: 0.15)
                                        : (isDark
                                              ? Colors.white.withValues(
                                                  alpha: 0.06,
                                                )
                                              : const Color(0xFFF8F8F8)),
                                    borderRadius: BorderRadius.circular(14),
                                    border: Border.all(
                                      color: selected
                                          ? color
                                          : (isDark
                                                ? Colors.white12
                                                : const Color(0xFFE8E8E8)),
                                      width: selected ? 2 : 1,
                                    ),
                                  ),
                                  child: Column(
                                    children: [
                                      Icon(
                                        AppConstants.statusIcon(e.key),
                                        size: 22,
                                        color: selected
                                            ? color
                                            : (isDark
                                                  ? Colors.white38
                                                  : AppConstants.textLight),
                                      ),
                                      const SizedBox(height: 4),
                                      Text(
                                        e.value,
                                        style: AppFonts.of(context, 
                                          fontSize: 11,
                                          fontWeight: selected
                                              ? FontWeight.w700
                                              : FontWeight.w500,
                                          color: selected
                                              ? color
                                              : (isDark
                                                    ? Colors.white54
                                                    : AppConstants
                                                          .textSecondary),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          );
                        }).toList(),
                      ),

                      const SizedBox(height: 36),

                      // ── Update Task button (solid, rounded) ──
                      SizedBox(
                        width: double.infinity,
                        height: 54,
                        child: ElevatedButton.icon(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppConstants.primaryColor,
                            foregroundColor: Colors.white,
                            elevation: 0,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(16),
                            ),
                          ),
                          icon: _isSaving
                              ? const SizedBox(
                                  width: 20,
                                  height: 20,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    color: Colors.white,
                                  ),
                                )
                              : const Icon(Icons.save_rounded, size: 20),
                          label: Text(
                            _isSaving
                                ? AppLocalizations.tr('saving', lang)
                                : AppLocalizations.tr('update_task', lang),
                            style: AppFonts.of(context, 
                              fontWeight: FontWeight.w600,
                              fontSize: 16,
                            ),
                          ),
                          onPressed: _isSaving ? null : _submit,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
