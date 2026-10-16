import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../state/app_state.dart';
import '../../theme/app_theme.dart';
import '../../widgets/format_utils.dart';

class GradeSheet extends StatefulWidget {
  final String assignmentId;
  final String studentId;
  const GradeSheet({
    super.key,
    required this.assignmentId,
    required this.studentId,
  });

  @override
  State<GradeSheet> createState() => _GradeSheetState();
}

class _GradeSheetState extends State<GradeSheet> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _scoreController;
  late final TextEditingController _feedbackController;

  @override
  void initState() {
    super.initState();
    final state = context.read<AppState>();
    final sub = state.submissionFor(widget.assignmentId, widget.studentId);
    _scoreController = TextEditingController(
      text: sub?.score != null ? '${sub!.score}' : '',
    );
    _feedbackController = TextEditingController(text: sub?.feedback ?? '');
  }

  @override
  void dispose() {
    _scoreController.dispose();
    _feedbackController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final state = context.watch<AppState>();
    final assignment = state.assignmentById(widget.assignmentId);
    final student = state.studentById(widget.studentId);
    final sub = state.submissionFor(widget.assignmentId, widget.studentId);

    if (assignment == null || student == null || sub == null) {
      return const SizedBox(
        height: 120,
        child: Center(child: Text('This submission is no longer available.')),
      );
    }

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
                  student.name,
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  '${assignment.title} · submitted ${formatDateTime(sub.submittedAt)}',
                  style: const TextStyle(color: AppColors.textSecondary),
                ),
                if (sub.note.isNotEmpty) ...[
                  const SizedBox(height: 12),
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text('Student note: ${sub.note}'),
                  ),
                ],
                const SizedBox(height: 18),
                TextFormField(
                  controller: _scoreController,
                  keyboardType: TextInputType.number,
                  decoration: InputDecoration(
                    labelText: 'Score (out of ${assignment.maxScore})',
                  ),
                  validator: (v) {
                    final n = int.tryParse((v ?? '').trim());
                    if (n == null) return 'Enter a whole number';
                    if (n < 0 || n > assignment.maxScore) {
                      return 'Enter 0 to ${assignment.maxScore}';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 14),
                TextFormField(
                  controller: _feedbackController,
                  maxLines: 3,
                  decoration: const InputDecoration(
                    labelText: 'Feedback for the student',
                  ),
                ),
                const SizedBox(height: 22),
                ElevatedButton(
                  onPressed: () {
                    if (!_formKey.currentState!.validate()) return;
                    context.read<AppState>().gradeSubmission(
                          assignmentId: widget.assignmentId,
                          studentId: widget.studentId,
                          score: int.parse(_scoreController.text.trim()),
                          feedback: _feedbackController.text,
                        );
                    Navigator.of(context).pop();
                  },
                  child: Text(sub.isGraded ? 'Update Grade' : 'Save Grade'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
