import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/task.dart';
import '../services/task_provider.dart';
import '../widgets/custom_text_field.dart';
import '../widgets/app_dialogs.dart';
import '../utils/validators.dart';

/// Add Task Screen — form to create a new task (POST to API).
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Add Task')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // ── Task Title ──
              CustomTextField(
                controller: _titleCtrl,
                label: 'Task Title',
                hint: 'Enter task title',
                prefixIcon: Icons.title,
                validator: Validators.minLength3,
              ),

              // ── Description ──
              CustomTextField(
                controller: _descCtrl,
                label: 'Description',
                hint: 'Enter task description',
                prefixIcon: Icons.description,
                maxLines: 3,
                validator: Validators.required,
              ),

              // ── Due Date Picker ──
              Padding(
                padding: const EdgeInsets.only(bottom: 16),
                child: InkWell(
                  onTap: _pickDate,
                  borderRadius: BorderRadius.circular(12),
                  child: InputDecorator(
                    decoration: InputDecoration(
                      labelText: 'Due Date',
                      prefixIcon: const Icon(Icons.calendar_today),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      filled: true,
                      fillColor: Theme.of(context).colorScheme.surface,
                    ),
                    child: Text(
                      _dueDate != null
                          ? '${_dueDate!.year}-${_dueDate!.month.toString().padLeft(2, '0')}-${_dueDate!.day.toString().padLeft(2, '0')}'
                          : 'Select due date',
                      style: TextStyle(
                        color: _dueDate != null ? null : Colors.grey[600],
                      ),
                    ),
                  ),
                ),
              ),

              // ── Status dropdown ──
              Padding(
                padding: const EdgeInsets.only(bottom: 24),
                child: DropdownButtonFormField<String>(
                  initialValue: _status,
                  decoration: InputDecoration(
                    labelText: 'Status',
                    prefixIcon: const Icon(Icons.flag),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    filled: true,
                    fillColor: Theme.of(context).colorScheme.surface,
                  ),
                  items: _statuses.entries.map((e) {
                    return DropdownMenuItem(value: e.key, child: Text(e.value));
                  }).toList(),
                  onChanged: (v) => setState(() => _status = v!),
                ),
              ),

              // ── Submit Button (ElevatedButton) ──
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
                      : const Icon(Icons.add_task),
                  label: Text(
                    _isSaving ? 'Saving…' : 'Create Task',
                    style: const TextStyle(fontSize: 16),
                  ),
                  style: ElevatedButton.styleFrom(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  onPressed: _isSaving ? null : _submit,
                ),
              ),
              const SizedBox(height: 12),

              // ── Cancel Button (TextButton) ──
              SizedBox(
                height: 48,
                child: TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('Cancel'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
