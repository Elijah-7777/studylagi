import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../constants.dart';
import '../../models/school_class.dart';
import '../../state/app_state.dart';
import '../../widgets/sheet_frame.dart';

class ClassFormSheet extends StatefulWidget {
  final SchoolClass? existingClass;
  const ClassFormSheet({super.key, this.existingClass});

  @override
  State<ClassFormSheet> createState() => _ClassFormSheetState();
}

class _ClassFormSheetState extends State<ClassFormSheet> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _nameController;
  late String _subject;
  late String _strand;

  bool get isEditing => widget.existingClass != null;

  @override
  void initState() {
    super.initState();
    final c = widget.existingClass;
    _nameController = TextEditingController(text: c?.name ?? '');
    _subject = c?.subject ?? kSubjects.first;
    _strand = c?.strand ?? kStrands.first;
  }

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  void _save() {
    if (!_formKey.currentState!.validate()) return;
    final state = context.read<AppState>();
    if (isEditing) {
      state.updateClass(
        widget.existingClass!.id,
        name: _nameController.text,
        subject: _subject,
        strand: _strand,
      );
    } else {
      state.createClass(
        name: _nameController.text,
        subject: _subject,
        strand: _strand,
      );
    }
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    return SheetFrame(
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              isEditing ? 'Edit Class' : 'New Class',
              style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w800),
            ),
            const SizedBox(height: 18),
            TextFormField(
              controller: _nameController,
              decoration: const InputDecoration(
                labelText: 'Class name (e.g. Gen Math 11-STEM A)',
              ),
              validator: (v) =>
                  (v == null || v.trim().isEmpty) ? 'Enter a class name' : null,
            ),
            const SizedBox(height: 14),
            DropdownButtonFormField<String>(
              value: _subject,
              isExpanded: true,
              decoration: const InputDecoration(labelText: 'Subject'),
              items: kSubjects
                  .map((s) => DropdownMenuItem(value: s, child: Text(s)))
                  .toList(),
              onChanged: (v) => setState(() => _subject = v ?? _subject),
            ),
            const SizedBox(height: 14),
            DropdownButtonFormField<String>(
              value: _strand,
              decoration: const InputDecoration(labelText: 'Strand'),
              items: kStrands
                  .map((s) => DropdownMenuItem(value: s, child: Text(s)))
                  .toList(),
              onChanged: (v) => setState(() => _strand = v ?? _strand),
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: _save,
              child: Text(isEditing ? 'Save Changes' : 'Create Class'),
            ),
          ],
        ),
      ),
    );
  }
}
