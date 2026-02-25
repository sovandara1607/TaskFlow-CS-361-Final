import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../models/task.dart';
import '../services/task_provider.dart';
import '../services/app_settings_provider.dart';
import '../l10n/app_localizations.dart';
import '../widgets/custom_text_field.dart';
import '../widgets/app_dialogs.dart';
import '../utils/constants.dart';
import '../utils/validators.dart';

/// Add Task Screen — Tiimo‑style form with category selector.
class AddTaskScreen extends StatefulWidget {
  const AddTaskScreen({super.key});

  @override
  State<AddTaskScreen> createState() => _AddTaskScreenState();
}

class _AddTaskScreenState extends State<AddTaskScreen> {
  final _formKey = GlobalKey<FormState>();
  final _titleCtrl = TextEditingController();
  final _descCtrl = TextEditingController();
  String _status = 'pending';
  String _category = 'general';
  DateTime? _dueDate;
  bool _isSaving = false;

  static const _statuses = {
    'pending': 'Pending',
    'in_progress': 'In Progress',
    'completed': 'Completed',
  };

  @override
  void dispose() {
    _titleCtrl.dispose();
    _descCtrl.dispose();
    super.dispose();
  }

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _dueDate ?? DateTime.now().add(const Duration(days: 1)),
      firstDate: DateTime.now(),
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

    final task = Task(
      title: _titleCtrl.text.trim(),
      description: _descCtrl.text.trim(),
      status: _status,
      category: _category,
      dueDate: _dueDate != null
          ? '${_dueDate!.year}-${_dueDate!.month.toString().padLeft(2, '0')}-${_dueDate!.day.toString().padLeft(2, '0')}'
          : null,
    );

    final success = await context.read<TaskProvider>().addTask(task);

    if (!mounted) return;
    setState(() => _isSaving = false);

    if (success) {
      await AppDialogs.showSuccess(
        context: context,
        message: 'Task created successfully!',
      );
      if (mounted) Navigator.pop(context);
    } else {
      await AppDialogs.showError(
        context: context,
        message: 'Failed to create task. Please try again.',
      );
    }
  }

  InputDecoration _fieldDecoration(String label, IconData icon, bool isDark) {
    return InputDecoration(
      labelText: label,
      labelStyle: GoogleFonts.poppins(
        color: isDark ? Colors.white54 : AppConstants.textSecondary,
      ),
      prefixIcon: Icon(icon, color: AppConstants.primaryColor),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: BorderSide(
          color: AppConstants.primaryLight.withValues(alpha: 0.3),
        ),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: BorderSide(
          color: isDark
              ? Colors.white12
              : AppConstants.primaryLight.withValues(alpha: 0.3),
        ),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: const BorderSide(
          color: AppConstants.primaryColor,
          width: 2,
        ),
      ),
      filled: true,
      fillColor: isDark ? AppConstants.darkCard : AppConstants.backgroundColor,
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final lang = context.watch<AppSettingsProvider>().locale;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          AppLocalizations.tr('add_task', lang),
          style: GoogleFonts.poppins(
            fontWeight: FontWeight.w700,
            color: isDark ? Colors.white : AppConstants.textPrimary,
          ),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(
          horizontal: AppConstants.defaultPadding,
          vertical: 12,
        ),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // ── Icon header ──
              Center(
                child: Container(
                  width: 56,
                  height: 56,
                  decoration: BoxDecoration(
                    color: AppConstants.accentLavender.withValues(alpha: 0.4),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: const Center(
                    child: Icon(
                      Icons.edit_note_rounded,
                      size: 28,
                      color: AppConstants.primaryColor,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 18),

              // ── Task Title ──
              CustomTextField(
                controller: _titleCtrl,
                label: AppLocalizations.tr('task_title', lang),
                hint: AppLocalizations.tr('enter_title', lang),
                prefixIcon: Icons.title_rounded,
                validator: Validators.minLength3,
              ),

              // ── Description ──
              CustomTextField(
                controller: _descCtrl,
                label: AppLocalizations.tr('description', lang),
                hint: AppLocalizations.tr('enter_description', lang),
                prefixIcon: Icons.description_rounded,
                maxLines: 3,
                validator: Validators.required,
              ),

              // ── Due Date Picker ──
              Padding(
                padding: const EdgeInsets.only(bottom: 16),
                child: InkWell(
                  onTap: _pickDate,
                  borderRadius: BorderRadius.circular(16),
                  child: InputDecorator(
                    decoration: _fieldDecoration(
                      AppLocalizations.tr('due_date', lang),
                      Icons.calendar_today_rounded,
                      isDark,
                    ),
                    child: Text(
                      _dueDate != null
                          ? '${_dueDate!.year}-${_dueDate!.month.toString().padLeft(2, '0')}-${_dueDate!.day.toString().padLeft(2, '0')}'
                          : AppLocalizations.tr('select_date', lang),
                      style: GoogleFonts.poppins(
                        color: _dueDate != null
                            ? (isDark ? Colors.white : AppConstants.textPrimary)
                            : (isDark
                                  ? Colors.white38
                                  : AppConstants.textLight),
                      ),
                    ),
                  ),
                ),
              ),

              // ── Category selector ──
              Padding(
                padding: const EdgeInsets.only(bottom: 16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Padding(
                      padding: const EdgeInsets.only(left: 4, bottom: 8),
                      child: Text(
                        AppLocalizations.tr('category', lang),
                        style: GoogleFonts.poppins(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          color: isDark
                              ? Colors.white70
                              : AppConstants.textSecondary,
                        ),
                      ),
                    ),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: AppConstants.categories.map((cat) {
                        final selected = _category == cat;
                        return GestureDetector(
                          onTap: () => setState(() => _category = cat),
                          child: AnimatedContainer(
                            duration: const Duration(milliseconds: 200),
                            padding: const EdgeInsets.symmetric(
                              horizontal: 14,
                              vertical: 10,
                            ),
                            decoration: BoxDecoration(
                              color: selected
                                  ? AppConstants.categoryColor(
                                      cat,
                                    ).withValues(alpha: 0.2)
                                  : (isDark
                                        ? AppConstants.darkCard
                                        : Colors.white),
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(
                                color: selected
                                    ? AppConstants.categoryColor(cat)
                                    : (isDark
                                          ? Colors.white12
                                          : AppConstants.primaryLight
                                                .withValues(alpha: 0.3)),
                                width: selected ? 2 : 1,
                              ),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(
                                  AppConstants.categoryIcon(cat),
                                  size: 16,
                                  color: selected
                                      ? AppConstants.categoryColor(cat)
                                      : (isDark
                                            ? Colors.white54
                                            : AppConstants.textSecondary),
                                ),
                                const SizedBox(width: 6),
                                Text(
                                  AppConstants.categoryLabel(cat),
                                  style: GoogleFonts.poppins(
                                    fontSize: 13,
                                    fontWeight: selected
                                        ? FontWeight.w600
                                        : FontWeight.w400,
                                    color: selected
                                        ? AppConstants.categoryColor(cat)
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
                  ],
                ),
              ),

              // ── Status dropdown ──
              Padding(
                padding: const EdgeInsets.only(bottom: 28),
                child: DropdownButtonFormField<String>(
                  value: _status,
                  style: GoogleFonts.poppins(
                    color: isDark ? Colors.white : AppConstants.textPrimary,
                    fontSize: 14,
                  ),
                  dropdownColor: isDark ? AppConstants.darkCard : Colors.white,
                  decoration: _fieldDecoration(
                    AppLocalizations.tr('status', lang),
                    Icons.flag_rounded,
                    isDark,
                  ),
                  items: _statuses.entries.map((e) {
                    return DropdownMenuItem(value: e.key, child: Text(e.value));
                  }).toList(),
                  onChanged: (v) => setState(() => _status = v!),
                ),
              ),

              // ── Submit ──
              SizedBox(
                height: 52,
                child: ElevatedButton.icon(
                  icon: _isSaving
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: Colors.white,
                          ),
                        )
                      : const Icon(Icons.add_task_rounded),
                  label: Text(
                    _isSaving
                        ? AppLocalizations.tr('saving', lang)
                        : AppLocalizations.tr('create_task', lang),
                    style: GoogleFonts.poppins(
                      fontWeight: FontWeight.w600,
                      fontSize: 16,
                    ),
                  ),
                  onPressed: _isSaving ? null : _submit,
                ),
              ),
              const SizedBox(height: 12),

              // ── Cancel ──
              SizedBox(
                height: 48,
                child: TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: Text(
                    AppLocalizations.tr('cancel', lang),
                    style: GoogleFonts.poppins(
                      color: isDark
                          ? Colors.white54
                          : AppConstants.textSecondary,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
