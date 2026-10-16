import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/assignment.dart';
import '../../state/app_state.dart';
import '../../theme/app_theme.dart';
import '../../widgets/format_utils.dart';
import '../../widgets/sheet_frame.dart';

class AssignmentFormSheet extends StatefulWidget {
  final String? classId;
  final Assignment? existingAssignment;
  const AssignmentFormSheet({
    super.key,
    this.classId,
    this.existingAssignment,
  });

  @override
  State<AssignmentFormSheet> createState() => _AssignmentFormSheetState();
}

class _AssignmentFormSheetState extends State<AssignmentFormSheet> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _titleController;
  late final TextEditingController _descriptionController;
  late final TextEditingController _maxScoreController;
  late DateTime _dueDate;
  String? _classId;

  bool get isEditing => widget.existingAssignment != null;

  @override
  void initState() {
    super.initState();
    final a = widget.existingAssignment;
    _titleController = TextEditingController(text: a?.title ?? '');
    _descriptionController = TextEditingController(text: a?.description ?? '');
    _maxScoreController = TextEditingController(text: '${a?.maxScore ?? 100}');
    final base = DateTime.now().add(const Duration(days: 3));
    _dueDate = a?.dueDate ?? DateTime(base.year, base.month, base.day, 23, 59);
    _classId = a?.classId ?? widget.classId;
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    _maxScoreController.dispose();
    super.dispose();
  }

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _dueDate,
      firstDate: DateTime.now().subtract(const Duration(days: 365)),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );
    if (picked != null) {
      setState(() {
        _dueDate = DateTime(picked.year, picked.month, picked.day, 23, 59);
      });
    }
  }

  void _save() {
    if (!_formKey.currentState!.validate()) return;
    final state = context.read<AppState>();
    final maxScore = int.parse(_maxScoreController.text.trim());
    if (isEditing) {
      state.updateAssignment(
        widget.existingAssignment!.id,
        title: _titleController.text,
        description: _descriptionController.text,
        dueDate: _dueDate,
        maxScore: maxScore,
      );
    } else {
      state.createAssignment(
        classId: _classId!,
        title: _titleController.text,
        description: _descriptionController.text,
        dueDate: _dueDate,
        maxScore: maxScore,
      );
    }
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    final state = context.watch<AppState>();
    final classes = state.myClasses;
    final needsClassPicker = !isEditing && widget.classId == null;

    if (needsClassPicker && classes.isEmpty) {
      return const SheetFrame(
        child: Padding(
          padding: EdgeInsets.symmetric(vertical: 24),
          child: Text(
            'Create a class first, then you can assign work to it.',
            textAlign: TextAlign.center,
            style: TextStyle(color: AppColors.textSecondary),
          ),
        ),
      );
    }

    if (needsClassPicker && _classId == null) {
      _classId = classes.first.id;
    }

    return SheetFrame(
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              isEditing ? 'Edit Assignment' : 'New Assignment',
              style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w800),
            ),
            const SizedBox(height: 18),
            if (needsClassPicker) ...[
              DropdownButtonFormField<String>(
                value: _classId,
                isExpanded: true,
                decoration: const InputDecoration(labelText: 'Class'),
                items: classes
                    .map((c) => DropdownMenuItem(value: c.id, child: Text(c.name)))
                    .toList(),
                onChanged: (v) => setState(() => _classId = v ?? _classId),
              ),
              const SizedBox(height: 14),
            ],
            TextFormField(
              controller: _titleController,
              decoration: const InputDecoration(labelText: 'Title'),
              validator: (v) =>
                  (v == null || v.trim().isEmpty) ? 'Enter a title' : null,
            ),
            const SizedBox(height: 14),
            TextFormField(
              controller: _descriptionController,
              maxLines: 3,
              decoration: const InputDecoration(
                labelText: 'Instructions for students',
              ),
            ),
            const SizedBox(height: 14),
            InkWell(
              onTap: _pickDate,
              child: InputDecorator(
                decoration: const InputDecoration(labelText: 'Due date'),
                child: Text(formatDate(_dueDate)),
              ),
            ),
            const SizedBox(height: 14),
            TextFormField(
              controller: _maxScoreController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(labelText: 'Maximum score'),
              validator: (v) {
                final n = int.tryParse((v ?? '').trim());
                if (n == null || n <= 0) return 'Enter a number above 0';
                return null;
              },
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: _save,
              child: Text(isEditing ? 'Save Changes' : 'Assign to Class'),
            ),
          ],
        ),
      ),
    );
  }
}
