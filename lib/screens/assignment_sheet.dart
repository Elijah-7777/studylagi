import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../state/app_state.dart';
import '../theme/app_theme.dart';
import '../widgets/format_utils.dart';
import '../widgets/sheet_frame.dart';
import '../widgets/status_chip.dart';

class AssignmentSheet extends StatefulWidget {
  final String assignmentId;
  const AssignmentSheet({super.key, required this.assignmentId});

  @override
  State<AssignmentSheet> createState() => _AssignmentSheetState();
}

class _AssignmentSheetState extends State<AssignmentSheet> {
  final _noteController = TextEditingController();

  @override
  void dispose() {
    _noteController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final state = context.watch<AppState>();
    final a = state.assignmentById(widget.assignmentId);
    if (a == null) {
      return const SheetFrame(child: Text('This assignment is no longer available.'));
    }

    final sub = state.mySubmission(a.id);
    final now = DateTime.now();
    final isOverdue = sub == null && a.dueDate.isBefore(now);

    return SheetFrame(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            a.title,
            style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w800),
          ),
          const SizedBox(height: 4),
          Text(
            '${state.subjectOfClass(a.classId)} · ${state.teacherNameOfClass(a.classId)}',
            style: const TextStyle(color: AppColors.textSecondary),
          ),
          const SizedBox(height: 10),
          Wrap(
            spacing: 8,
            runSpacing: 6,
            children: [
              StatusChip(
                label: 'Due ${formatDate(a.dueDate)}',
                color: isOverdue ? AppColors.danger : AppColors.primary,
              ),
              StatusChip(
                label: 'Max score ${a.maxScore}',
                color: AppColors.textSecondary,
              ),
              StatusChip(label: '+${a.kpReward} KP', color: AppColors.kpGold),
            ],
          ),
          if (a.description.isNotEmpty) ...[
            const SizedBox(height: 14),
            Text(a.description),
          ],
          const SizedBox(height: 18),
          if (sub == null) ...[
            TextField(
              controller: _noteController,
              maxLines: 2,
              decoration: const InputDecoration(
                labelText: 'Note to your teacher (optional)',
              ),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () {
                final message = context
                    .read<AppState>()
                    .submitAssignment(a.id, note: _noteController.text);
                final messenger = ScaffoldMessenger.of(context);
                Navigator.of(context).pop();
                messenger.showSnackBar(
                  SnackBar(
                    content: Text(message),
                    duration: const Duration(seconds: 2),
                  ),
                );
              },
              child: Text(isOverdue ? 'Submit Late (half KP)' : 'Submit Assignment'),
            ),
          ] else if (!sub.isGraded) ...[
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: AppColors.warning.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(14),
              ),
              child: Text(
                'Submitted ${formatDateTime(sub.submittedAt)}. Waiting for your teacher to grade it.',
                style: const TextStyle(fontWeight: FontWeight.w600),
              ),
            ),
          ] else ...[
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppColors.success.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(14),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Graded: ${sub.score}/${a.maxScore}',
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                  if (sub.feedback.isNotEmpty) ...[
                    const SizedBox(height: 8),
                    Text('Teacher feedback: ${sub.feedback}'),
                  ],
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }
}
