import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/task.dart';
import '../state/app_state.dart';
import '../theme/app_theme.dart';

const _subjects = ['Mathematics', 'Science', 'English', 'Filipino', 'Research', 'PE & Health'];

class TaskFormSheet extends StatefulWidget {
  final StudyTask? existingTask;
  const TaskFormSheet({super.key, this.existingTask});

  @override
  State<TaskFormSheet> createState() => _TaskFormSheetState();
}

class _TaskFormSheetState extends State<TaskFormSheet> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _titleController;
  late String _subject;
  late DateTime _dueDate;
  late TaskPriority _priority;

  bool get isEditing => widget.existingTask != null;

  @override
  void initState() {
    super.initState();
    final t = widget.existingTask;
    _titleController = TextEditingController(text: t?.title ?? '');
    _subject = t?.subject ?? _subjects.first;
    _dueDate = t?.dueDate ?? DateTime.now().add(const Duration(days: 1));
    _priority = t?.priority ?? TaskPriority.medium;
  }

  @override
  void dispose() {
    _titleController.dispose();
    super.dispose();
  }

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _dueDate,
      firstDate: DateTime.now().subtract(const Duration(days: 365)),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );
    if (picked != null) setState(() => _dueDate = picked);
  }

  void _save() {
    if (!_formKey.currentState!.validate()) return;
    final state = context.read<AppState>();
    if (isEditing) {
      state.updateTask(
        widget.existingTask!.id,
        title: _titleController.text.trim(),
        subject: _subject,
        dueDate: _dueDate,
        priority: _priority,
      );
    } else {
      state.addTask(
        title: _titleController.text.trim(),
        subject: _subject,
        dueDate: _dueDate,
        priority: _priority,
      );
    }
    Navigator.of(context).pop();
  }

  void _delete() {
    context.read<AppState>().deleteTask(widget.existingTask!.id);
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
      child: Container(
        decoration: const BoxDecoration(
          color: AppColors.background,
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
        padding: const EdgeInsets.fromLTRB(22, 18, 22, 26),
        child: SingleChildScrollView(
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Center(
                  child: Container(
                    width: 44,
                    height: 5,
                    decoration: BoxDecoration(
                      color: AppColors.locked,
                      borderRadius: BorderRadius.circular(999),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  isEditing ? 'Edit Task' : 'New Study Task',
                  style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w800),
                ),
                const SizedBox(height: 18),
                TextFormField(
                  controller: _titleController,
                  decoration: const InputDecoration(labelText: 'Task title'),
                  validator: (v) => (v == null || v.trim().isEmpty) ? 'Enter a title' : null,
                ),
                const SizedBox(height: 14),
                DropdownButtonFormField<String>(
                  initialValue: _subject,
                  decoration: const InputDecoration(labelText: 'Subject'),
                  items: _subjects
                      .map((s) => DropdownMenuItem(value: s, child: Text(s)))
                      .toList(),
                  onChanged: (v) => setState(() => _subject = v ?? _subject),
                ),
                const SizedBox(height: 14),
                InkWell(
                  onTap: _pickDate,
                  child: InputDecorator(
                    decoration: const InputDecoration(labelText: 'Due date'),
                    child: Text(
                      '${_dueDate.month}/${_dueDate.day}/${_dueDate.year}',
                    ),
                  ),
                ),
                const SizedBox(height: 14),
                const Text('Priority', style: TextStyle(color: AppColors.textSecondary, fontSize: 12)),
                const SizedBox(height: 6),
                SegmentedButton<TaskPriority>(
                  segments: const [
                    ButtonSegment(value: TaskPriority.low, label: Text('Low')),
                    ButtonSegment(value: TaskPriority.medium, label: Text('Medium')),
                    ButtonSegment(value: TaskPriority.high, label: Text('High')),
                  ],
                  selected: {_priority},
                  onSelectionChanged: (s) => setState(() => _priority = s.first),
                ),
                const SizedBox(height: 24),
                ElevatedButton(
                  onPressed: _save,
                  child: Text(isEditing ? 'Save Changes' : 'Add Task'),
                ),
                if (isEditing) ...[
                  const SizedBox(height: 10),
                  OutlinedButton(
                    style: OutlinedButton.styleFrom(
                      foregroundColor: AppColors.danger,
                      side: const BorderSide(color: AppColors.danger),
                      minimumSize: const Size.fromHeight(52),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                    ),
                    onPressed: _delete,
                    child: const Text('Delete Task'),
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}
