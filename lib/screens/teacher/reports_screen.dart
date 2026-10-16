import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/assignment.dart';
import '../../models/student_profile.dart';
import '../../state/app_state.dart';
import '../../theme/app_theme.dart';
import '../../widgets/format_utils.dart';
import '../../widgets/section_card.dart';
import '../../widgets/sheet_frame.dart';
import '../../widgets/stat_tile.dart';
import '../../widgets/status_chip.dart';

class ReportsScreen extends StatefulWidget {
  const ReportsScreen({super.key});

  @override
  State<ReportsScreen> createState() => _ReportsScreenState();
}

class _ReportsScreenState extends State<ReportsScreen> {
  String? _classId;

  @override
  Widget build(BuildContext context) {
    final state = context.watch<AppState>();
    final classes = state.myClasses;

    final classStillExists = _classId == null || classes.any((c) => c.id == _classId);
    final selectedClassId = classStillExists ? _classId : null;

    final List<StudentProfile> students = selectedClassId == null
        ? state.myStudents
        : state.studentsOf(selectedClassId);

    final statsList = students
        .map((s) => state.statsFor(s.id, classId: selectedClassId))
        .toList();

    final withWork = statsList.where((s) => s.assigned > 0).toList();
    final avgCompletion = withWork.isEmpty
        ? null
        : withWork.map((s) => s.completionRate).reduce((a, b) => a + b) /
            withWork.length;
    final scored = statsList.where((s) => s.averagePercent != null).toList();
    final avgScore = scored.isEmpty
        ? null
        : scored.map((s) => s.averagePercent!).reduce((a, b) => a + b) /
            scored.length;
    final needSupportCount = statsList.where((s) => s.needsSupport).length;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(title: const Text('Student Progress')),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(20, 8, 20, 40),
        children: [
          DropdownButtonFormField<String?>(
            value: selectedClassId,
            isExpanded: true,
            decoration: const InputDecoration(labelText: 'Class'),
            items: [
              const DropdownMenuItem<String?>(
                value: null,
                child: Text('All classes'),
              ),
              ...classes.map(
                (c) => DropdownMenuItem<String?>(
                  value: c.id,
                  child: Text(c.name),
                ),
              ),
            ],
            onChanged: (v) => setState(() => _classId = v),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: StatTile(
                  icon: Icons.task_alt,
                  iconColor: AppColors.success,
                  value: avgCompletion == null
                      ? '-'
                      : '${(avgCompletion * 100).round()}%',
                  label: 'Avg. submission rate',
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: StatTile(
                  icon: Icons.grade,
                  iconColor: AppColors.kpGold,
                  value: avgScore == null ? '-' : '${avgScore.round()}%',
                  label: 'Avg. score',
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          SectionCard(
            child: Row(
              children: [
                Icon(
                  needSupportCount > 0
                      ? Icons.warning_amber_rounded
                      : Icons.check_circle_outline,
                  color: needSupportCount > 0
                      ? AppColors.warning
                      : AppColors.success,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    needSupportCount > 0
                        ? '$needSupportCount student(s) may need support: low submission rate or an average score under 75%.'
                        : 'No students are flagged right now.',
                    style: const TextStyle(fontWeight: FontWeight.w600),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 22),
          Text(
            'Students (${students.length})',
            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w800),
          ),
          const SizedBox(height: 8),
          if (students.isEmpty)
            const SectionCard(
              child: Text(
                'No students yet. Add students to a class to see their progress here.',
                style: TextStyle(color: AppColors.textSecondary),
              ),
            )
          else
            ...List.generate(students.length, (i) {
              final s = students[i];
              final stats = statsList[i];
              return Padding(
                padding: const EdgeInsets.only(bottom: 10),
                child: GestureDetector(
                  onTap: () => showModalBottomSheet(
                    context: context,
                    isScrollControlled: true,
                    backgroundColor: Colors.transparent,
                    builder: (_) => _StudentReportSheet(
                      studentId: s.id,
                      classId: selectedClassId,
                    ),
                  ),
                  child: SectionCard(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Expanded(
                              child: Text(
                                s.name,
                                style: const TextStyle(
                                  fontWeight: FontWeight.w800,
                                  fontSize: 16,
                                ),
                              ),
                            ),
                            if (stats.needsSupport)
                              const StatusChip(
                                label: 'Needs support',
                                color: AppColors.danger,
                              ),
                          ],
                        ),
                        Text(
                          '${s.gradeLevel} · ${s.strand}',
                          style: const TextStyle(
                            color: AppColors.textSecondary,
                            fontSize: 12,
                          ),
                        ),
                        const SizedBox(height: 10),
                        ClipRRect(
                          borderRadius: BorderRadius.circular(999),
                          child: LinearProgressIndicator(
                            value: stats.completionRate,
                            minHeight: 8,
                            backgroundColor: const Color(0xFFE5E7EB),
                            valueColor: AlwaysStoppedAnimation<Color>(
                              stats.completionRate < 0.5
                                  ? AppColors.danger
                                  : AppColors.primary,
                            ),
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          '${stats.submitted}/${stats.assigned} submitted · '
                          '${stats.averagePercent == null ? 'no grades yet' : 'avg ${stats.averagePercent!.round()}%'}',
                          style: const TextStyle(fontSize: 12),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          '★ ${s.kp} KP · ${s.streak} day streak',
                          style: const TextStyle(
                            fontSize: 12,
                            color: AppColors.textSecondary,
                          ),
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

class _StudentReportSheet extends StatelessWidget {
  final String studentId;
  final String? classId;
  const _StudentReportSheet({required this.studentId, required this.classId});

  @override
  Widget build(BuildContext context) {
    final state = context.watch<AppState>();
    final student = state.studentById(studentId);
    if (student == null) {
      return const SheetFrame(child: Text('Student not found.'));
    }

    final now = DateTime.now();
    final List<Assignment> assignments = state.teacherAssignments.where((a) {
      if (classId != null && a.classId != classId) return false;
      final c = state.classById(a.classId);
      return c != null && c.studentIds.contains(studentId);
    }).toList();

    return SheetFrame(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            student.name,
            style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w800),
          ),
          Text(
            '${student.gradeLevel} · ${student.strand} · ★ ${student.kp} KP · ${student.streak} day streak',
            style: const TextStyle(color: AppColors.textSecondary),
          ),
          const SizedBox(height: 16),
          if (assignments.isEmpty)
            const Text(
              'No assignments have been given to this student yet.',
              style: TextStyle(color: AppColors.textSecondary),
            )
          else
            ...assignments.map((a) {
              final sub = state.submissionFor(a.id, studentId);
              final String label;
              final Color color;
              if (sub == null) {
                final missing = a.dueDate.isBefore(now);
                label = missing ? 'Missing' : 'Not submitted';
                color = missing ? AppColors.danger : AppColors.textSecondary;
              } else if (sub.isGraded) {
                label = '${sub.score}/${a.maxScore}';
                color = AppColors.success;
              } else {
                label = 'Needs grading';
                color = AppColors.warning;
              }
              return Container(
                margin: const EdgeInsets.only(bottom: 8),
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            a.title,
                            style: const TextStyle(fontWeight: FontWeight.w700),
                          ),
                        ),
                        StatusChip(label: label, color: color),
                      ],
                    ),
                    Text(
                      '${state.classNameOf(a.classId)} · Due ${formatDate(a.dueDate)}',
                      style: const TextStyle(
                        fontSize: 12,
                        color: AppColors.textSecondary,
                      ),
                    ),
                    if (sub != null && sub.isGraded && sub.feedback.isNotEmpty)
                      Padding(
                        padding: const EdgeInsets.only(top: 6),
                        child: Text(
                          'Feedback: ${sub.feedback}',
                          style: const TextStyle(fontSize: 12),
                        ),
                      ),
                  ],
                ),
              );
            }),
        ],
      ),
    );
  }
}
