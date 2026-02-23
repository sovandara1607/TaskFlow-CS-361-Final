import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/task.dart';
import '../services/task_provider.dart';
import '../widgets/custom_text_field.dart';
import '../widgets/app_dialogs.dart';
import '../utils/validators.dart';

/// Edit Task Screen — form to update an existing task (PUT to API).
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Edit Task'),
        actions: [
          // ── Delete IconButton in AppBar ──
          IconButton(
            icon: const Icon(Icons.delete_forever, color: Colors.red),
            tooltip: 'Delete Task',
            onPressed: () async {
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
                const SnackBar(
                  content: Text('Task deleted.'),
                  backgroundColor: Colors.green,
                ),
              );
              nav.pop();
            },
          ),
        ],
      ),
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

              // ── Save Button (ElevatedButton) ──
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
                      : const Icon(Icons.save),
                  label: Text(
                    _isSaving ? 'Saving…' : 'Update Task',
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
