import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../state/app_state.dart';
import '../../theme/app_theme.dart';
import '../../widgets/format_utils.dart';
import '../../widgets/section_card.dart';
import '../../widgets/status_chip.dart';
import 'assignment_form_sheet.dart';
import 'teacher_assignment_detail_screen.dart';

class TeacherAssignmentsScreen extends StatelessWidget {
  const TeacherAssignmentsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final state = context.watch<AppState>();
    final assignments = state.teacherAssignments;
    final now = DateTime.now();

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(title: const Text('Assignments')),
      floatingActionButton: FloatingActionButton.extended(
        backgroundColor: AppColors.primary,
        icon: const Icon(Icons.add, color: Colors.white),
        label: const Text(
          'New Assignment',
          style: TextStyle(color: Colors.white),
        ),
        onPressed: () => showModalBottomSheet(
          context: context,
          isScrollControlled: true,
          backgroundColor: Colors.transparent,
          builder: (_) => const AssignmentFormSheet(),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(20, 8, 20, 100),
        children: [
          if (assignments.isEmpty)
            const SectionCard(
              child: Text(
                'No assignments yet. Tap "New Assignment" to give work to one '
                'of your classes.',
                style: TextStyle(color: AppColors.textSecondary),
              ),
            )
          else
            ...assignments.map((a) {
              final students = state.studentsOf(a.classId);
              final subs = state
                  .submissionsFor(a.id)
                  .where((s) => students.any((st) => st.id == s.studentId))
                  .toList();
              final gradedCount = subs.where((s) => s.isGraded).length;
              final toGrade = subs.length - gradedCount;
              final isPastDue = a.dueDate.isBefore(now);

              return Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: GestureDetector(
                  onTap: () => Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (_) =>
                          TeacherAssignmentDetailScreen(assignmentId: a.id),
                    ),
                  ),
                  child: SectionCard(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Expanded(
                              child: Text(
                                a.title,
                                style: const TextStyle(
                                  fontWeight: FontWeight.w800,
                                  fontSize: 16,
                                ),
                              ),
                            ),
                            StatusChip(
                              label: isPastDue ? 'Past due' : 'Open',
                              color: isPastDue
                                  ? AppColors.textSecondary
                                  : AppColors.success,
                            ),
                          ],
                        ),
                        const SizedBox(height: 4),
                        Text(
                          '${state.classNameOf(a.classId)} · Due ${formatDate(a.dueDate)}',
                          style: const TextStyle(
                            color: AppColors.textSecondary,
                            fontSize: 13,
                          ),
                        ),
                        const SizedBox(height: 10),
                        Wrap(
                          spacing: 8,
                          runSpacing: 6,
                          children: [
                            StatusChip(
                              label:
                                  '${subs.length}/${students.length} submitted',
                              color: AppColors.primary,
                            ),
                            if (toGrade > 0)
                              StatusChip(
                                label: '$toGrade to grade',
                                color: AppColors.warning,
                              ),
                            if (gradedCount > 0)
                              StatusChip(
                                label: '$gradedCount graded',
                                color: AppColors.success,
                              ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              );
            }),
        ],
      ),
    );
  }
}
