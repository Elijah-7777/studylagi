import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../state/app_state.dart';
import '../../theme/app_theme.dart';
import '../../widgets/format_utils.dart';
import '../../widgets/section_card.dart';
import '../../widgets/stat_tile.dart';
import '../profile_screen.dart';
import 'grade_sheet.dart';
import 'teacher_assignment_detail_screen.dart';

class TeacherDashboardScreen extends StatelessWidget {
  const TeacherDashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final state = context.watch<AppState>();
    final user = state.currentUser;
    final toGrade = state.needsGrading;
    final now = DateTime.now();
    final upcoming = state.teacherAssignments
        .where((a) => a.dueDate.isAfter(now))
        .take(3)
        .toList();

    return ListView(
      padding: const EdgeInsets.all(20),
      children: [
        Row(
          children: [
            Expanded(
              child: Text(
                'Hello, ${state.displayName}! 👋',
                style: const TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.w800,
                  color: AppColors.textPrimary,
                ),
              ),
            ),
            IconButton(
              icon: const CircleAvatar(
                backgroundColor: AppColors.primary,
                child: Icon(Icons.person, color: Colors.white),
              ),
              onPressed: () => Navigator.of(context).push(
                MaterialPageRoute(builder: (_) => const ProfileScreen()),
              ),
            ),
          ],
        ),
        Text(
          'Teacher · ${user?.subjectSpecialization ?? ''} · ${user?.school ?? ''}',
          style: const TextStyle(color: AppColors.textSecondary),
        ),
        const SizedBox(height: 20),
        Row(
          children: [
            Expanded(
              child: StatTile(
                icon: Icons.groups,
                iconColor: AppColors.primary,
                value: '${state.myClasses.length}',
                label: 'Classes',
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: StatTile(
                icon: Icons.school,
                iconColor: AppColors.success,
                value: '${state.myStudents.length}',
                label: 'Students',
              ),
            ),
          ],
        ),
        const SizedBox(height: 14),
        Row(
          children: [
            Expanded(
              child: StatTile(
                icon: Icons.assignment,
                iconColor: AppColors.warning,
                value: '${state.teacherAssignments.length}',
                label: 'Assignments',
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: StatTile(
                icon: Icons.rate_review,
                iconColor: AppColors.danger,
                value: '${toGrade.length}',
                label: 'Waiting to be graded',
              ),
            ),
          ],
        ),
        const SizedBox(height: 24),
        const Text(
          'Needs Grading',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800),
        ),
        const SizedBox(height: 8),
        if (toGrade.isEmpty)
          const SectionCard(
            child: Text(
              'All caught up. No submissions are waiting. 🎉',
              style: TextStyle(color: AppColors.textSecondary),
            ),
          )
        else
          ...toGrade.take(4).map(
                (item) => Padding(
                  padding: const EdgeInsets.only(bottom: 10),
                  child: GestureDetector(
                    onTap: () => showModalBottomSheet(
                      context: context,
                      isScrollControlled: true,
                      backgroundColor: Colors.transparent,
                      builder: (_) => GradeSheet(
                        assignmentId: item.assignment.id,
                        studentId: item.student.id,
                      ),
                    ),
                    child: SectionCard(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 14,
                      ),
                      child: Row(
                        children: [
                          CircleAvatar(
                            radius: 18,
                            backgroundColor: AppColors.primary.withOpacity(0.12),
                            child: Text(
                              item.student.name.substring(0, 1),
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
                                  item.student.name,
                                  style: const TextStyle(
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                                Text(
                                  '${item.assignment.title} · ${formatDateTime(item.submission.submittedAt)}',
                                  style: const TextStyle(
                                    fontSize: 12,
                                    color: AppColors.textSecondary,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const Text(
                            'Grade',
                            style: TextStyle(
                              color: AppColors.primary,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
        const SizedBox(height: 24),
        const Text(
          'Upcoming Deadlines',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800),
        ),
        const SizedBox(height: 8),
        if (upcoming.isEmpty)
          const SectionCard(
            child: Text(
              'No upcoming deadlines. Create an assignment from the Tasks tab.',
              style: TextStyle(color: AppColors.textSecondary),
            ),
          )
        else
          ...upcoming.map((a) {
            final enrolled = state.studentsOf(a.classId).length;
            final submitted = state
                .submissionsFor(a.id)
                .where((s) => state.studentsOf(a.classId).any((st) => st.id == s.studentId))
                .length;
            return Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: GestureDetector(
                onTap: () => Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (_) =>
                        TeacherAssignmentDetailScreen(assignmentId: a.id),
                  ),
                ),
                child: SectionCard(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 14,
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.event, color: AppColors.warning),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              a.title,
                              style: const TextStyle(fontWeight: FontWeight.w700),
                            ),
                            Text(
                              '${state.classNameOf(a.classId)} · Due ${formatDate(a.dueDate)}',
                              style: const TextStyle(
                                fontSize: 12,
                                color: AppColors.textSecondary,
                              ),
                            ),
                          ],
                        ),
                      ),
                      Text(
                        '$submitted/$enrolled',
                        style: const TextStyle(fontWeight: FontWeight.w800),
                      ),
                    ],
                  ),
                ),
              ),
            );
          }),
      ],
    );
  }
}
