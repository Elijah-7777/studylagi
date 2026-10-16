import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../state/app_state.dart';
import '../../theme/app_theme.dart';
import '../../widgets/format_utils.dart';
import '../../widgets/section_card.dart';
import '../../widgets/status_chip.dart';
import 'assignment_form_sheet.dart';
import 'grade_sheet.dart';

class TeacherAssignmentDetailScreen extends StatelessWidget {
  final String assignmentId;
  const TeacherAssignmentDetailScreen({super.key, required this.assignmentId});

  Future<void> _confirmDelete(BuildContext context) async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Delete this assignment?'),
        content: const Text('All submissions for it will be removed too.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(true),
            child: const Text(
              'Delete',
              style: TextStyle(color: AppColors.danger),
            ),
          ),
        ],
      ),
    );
    if (ok == true && context.mounted) {
      context.read<AppState>().deleteAssignment(assignmentId);
      Navigator.of(context).pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    final state = context.watch<AppState>();
    final a = state.assignmentById(assignmentId);

    if (a == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Assignment')),
        body: const Center(child: Text('This assignment no longer exists.')),
      );
    }

    final students = state.studentsOf(a.classId);
    final now = DateTime.now();
    final isPastDue = a.dueDate.isBefore(now);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Assignment'),
        actions: [
          IconButton(
            tooltip: 'Edit assignment',
            icon: const Icon(Icons.edit_outlined),
            onPressed: () => showModalBottomSheet(
              context: context,
              isScrollControlled: true,
              backgroundColor: Colors.transparent,
              builder: (_) => AssignmentFormSheet(existingAssignment: a),
            ),
          ),
          IconButton(
            tooltip: 'Delete assignment',
            icon: const Icon(Icons.delete_outline, color: AppColors.danger),
            onPressed: () => _confirmDelete(context),
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(20, 8, 20, 40),
        children: [
          SectionCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  a.title,
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  '${state.classNameOf(a.classId)} · ${state.subjectOfClass(a.classId)}',
                  style: const TextStyle(color: AppColors.textSecondary),
                ),
                const SizedBox(height: 10),
                Wrap(
                  spacing: 8,
                  runSpacing: 6,
                  children: [
                    StatusChip(
                      label: 'Due ${formatDate(a.dueDate)}',
                      color: isPastDue
                          ? AppColors.danger
                          : AppColors.primary,
                    ),
                    StatusChip(
                      label: 'Max score ${a.maxScore}',
                      color: AppColors.textSecondary,
                    ),
                    StatusChip(
                      label: '+${a.kpReward} KP',
                      color: AppColors.kpGold,
                    ),
                  ],
                ),
                if (a.description.isNotEmpty) ...[
                  const SizedBox(height: 12),
                  Text(a.description),
                ],
              ],
            ),
          ),
          const SizedBox(height: 22),
          Text(
            'Submissions (${students.length} students)',
            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w800),
          ),
          const SizedBox(height: 8),
          if (students.isEmpty)
            const SectionCard(
              child: Text(
                'No students are enrolled in this class yet.',
                style: TextStyle(color: AppColors.textSecondary),
              ),
            )
          else
            ...students.map((s) {
              final sub = state.submissionFor(a.id, s.id);
              final String label;
              final Color color;
              if (sub == null) {
                label = isPastDue ? 'Missing' : 'Not submitted';
                color = isPastDue ? AppColors.danger : AppColors.textSecondary;
              } else if (sub.isGraded) {
                label = 'Graded ${sub.score}/${a.maxScore}';
                color = AppColors.success;
              } else {
                label = 'Needs grading';
                color = AppColors.warning;
              }

              return Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: SectionCard(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 14,
                    vertical: 10,
                  ),
                  child: Row(
                    children: [
                      CircleAvatar(
                        radius: 18,
                        backgroundColor: AppColors.primary.withOpacity(0.12),
                        child: Text(
                          s.name.substring(0, 1),
                          style: const TextStyle(
                            color: AppColors.primary,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              s.name,
                              style: const TextStyle(fontWeight: FontWeight.w700),
                            ),
                            const SizedBox(height: 4),
                            Align(
                              alignment: Alignment.centerLeft,
                              child: StatusChip(label: label, color: color),
                            ),
                            if (sub != null && sub.isGraded && sub.feedback.isNotEmpty)
                              Padding(
                                padding: const EdgeInsets.only(top: 6),
                                child: Text(
                                  'Feedback: ${sub.feedback}',
                                  style: const TextStyle(
                                    fontSize: 12,
                                    color: AppColors.textSecondary,
                                  ),
                                ),
                              ),
                          ],
                        ),
                      ),
                      if (sub != null)
                        TextButton(
                          onPressed: () => showModalBottomSheet(
                            context: context,
                            isScrollControlled: true,
                            backgroundColor: Colors.transparent,
                            builder: (_) => GradeSheet(
                              assignmentId: a.id,
                              studentId: s.id,
                            ),
                          ),
                          child: Text(sub.isGraded ? 'Edit' : 'Grade'),
                        ),
                    ],
                  ),
                ),
              );
            }),
        ],
      ),
    );
  }
}
