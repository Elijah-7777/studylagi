import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../state/app_state.dart';
import '../../theme/app_theme.dart';
import '../../widgets/format_utils.dart';
import '../../widgets/section_card.dart';
import 'add_student_sheet.dart';
import 'announcement_form_sheet.dart';
import 'assignment_form_sheet.dart';
import 'class_form_sheet.dart';
import 'teacher_assignment_detail_screen.dart';

class ClassDetailScreen extends StatelessWidget {
  final String classId;
  const ClassDetailScreen({super.key, required this.classId});

  void _openSheet(BuildContext context, Widget sheet) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => sheet,
    );
  }

  Future<void> _confirmDelete(BuildContext context) async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Delete this class?'),
        content: const Text(
          'Its assignments, submissions and announcements will be removed too.',
        ),
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
      context.read<AppState>().deleteClass(classId);
      Navigator.of(context).pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    final state = context.watch<AppState>();
    final c = state.classById(classId);

    if (c == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Class')),
        body: const Center(child: Text('This class no longer exists.')),
      );
    }

    final students = state.studentsOf(classId);
    final assignments = state.assignmentsForClass(classId);
    final announcements = state.announcementsForClass(classId);

    return Scaffold(
      appBar: AppBar(
        title: Text(c.name, style: const TextStyle(fontSize: 20)),
        actions: [
          IconButton(
            tooltip: 'Edit class',
            icon: const Icon(Icons.edit_outlined),
            onPressed: () => _openSheet(context, ClassFormSheet(existingClass: c)),
          ),
          IconButton(
            tooltip: 'Delete class',
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
                  c.subject,
                  style: const TextStyle(
                    fontWeight: FontWeight.w800,
                    fontSize: 16,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Strand: ${c.strand} · ${students.length} students · ${assignments.length} assignments',
                  style: const TextStyle(color: AppColors.textSecondary),
                ),
              ],
            ),
          ),
          const SizedBox(height: 22),

          _SectionHeader(
            title: 'Students (${students.length})',
            actionLabel: 'Add',
            onAction: () => _openSheet(context, AddStudentSheet(classId: classId)),
          ),
          const SizedBox(height: 8),
          if (students.isEmpty)
            const SectionCard(
              child: Text(
                'No students yet. Tap "Add" to enroll students from this strand.',
                style: TextStyle(color: AppColors.textSecondary),
              ),
            )
          else
            ...students.map(
              (s) => Padding(
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
                            Text(
                              '${s.gradeLevel} · ${s.strand}',
                              style: const TextStyle(
                                fontSize: 12,
                                color: AppColors.textSecondary,
                              ),
                            ),
                          ],
                        ),
                      ),
                      IconButton(
                        tooltip: 'Remove from class',
                        icon: const Icon(
                          Icons.person_remove_outlined,
                          color: AppColors.danger,
                        ),
                        onPressed: () => context
                            .read<AppState>()
                            .removeStudentFromClass(classId, s.id),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          const SizedBox(height: 22),

          _SectionHeader(
            title: 'Assignments (${assignments.length})',
            actionLabel: 'New',
            onAction: () =>
                _openSheet(context, AssignmentFormSheet(classId: classId)),
          ),
          const SizedBox(height: 8),
          if (assignments.isEmpty)
            const SectionCard(
              child: Text(
                'No assignments yet. Tap "New" to assign work to this class.',
                style: TextStyle(color: AppColors.textSecondary),
              ),
            )
          else
            ...assignments.map((a) {
              final submitted = state
                  .submissionsFor(a.id)
                  .where((s) => c.studentIds.contains(s.studentId))
                  .length;
              return Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: GestureDetector(
                  onTap: () => Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (_) =>
                          TeacherAssignmentDetailScreen(assignmentId: a.id),
                    ),
                  ),
                  child: SectionCard(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 14,
                      vertical: 12,
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.assignment, color: AppColors.primary),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                a.title,
                                style: const TextStyle(
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                              Text(
                                'Due ${formatDate(a.dueDate)} · $submitted/${students.length} submitted',
                                style: const TextStyle(
                                  fontSize: 12,
                                  color: AppColors.textSecondary,
                                ),
                              ),
                            ],
                          ),
                        ),
                        const Icon(
                          Icons.chevron_right,
                          color: AppColors.textSecondary,
                        ),
                      ],
                    ),
                  ),
                ),
              );
            }),
          const SizedBox(height: 22),

          _SectionHeader(
            title: 'Announcements (${announcements.length})',
            actionLabel: 'Post',
            onAction: () =>
                _openSheet(context, AnnouncementFormSheet(classId: classId)),
          ),
          const SizedBox(height: 8),
          if (announcements.isEmpty)
            const SectionCard(
              child: Text(
                'Nothing posted yet. Announcements appear on your students\' dashboards.',
                style: TextStyle(color: AppColors.textSecondary),
              ),
            )
          else
            ...announcements.map(
              (n) => Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: SectionCard(
                  padding: const EdgeInsets.fromLTRB(14, 12, 6, 12),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Icon(Icons.campaign, color: AppColors.warning),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              n.title,
                              style: const TextStyle(fontWeight: FontWeight.w700),
                            ),
                            const SizedBox(height: 2),
                            Text(n.message, style: const TextStyle(fontSize: 13)),
                            const SizedBox(height: 4),
                            Text(
                              formatDateTime(n.postedAt),
                              style: const TextStyle(
                                fontSize: 11,
                                color: AppColors.textSecondary,
                              ),
                            ),
                          ],
                        ),
                      ),
                      IconButton(
                        tooltip: 'Delete announcement',
                        icon: const Icon(
                          Icons.delete_outline,
                          color: AppColors.danger,
                        ),
                        onPressed: () =>
                            context.read<AppState>().deleteAnnouncement(n.id),
                      ),
                    ],
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

class _SectionHeader extends StatelessWidget {
  final String title;
  final String actionLabel;
  final VoidCallback onAction;
  const _SectionHeader({
    required this.title,
    required this.actionLabel,
    required this.onAction,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          title,
          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w800),
        ),
        TextButton.icon(
          onPressed: onAction,
          icon: const Icon(Icons.add, size: 18),
          label: Text(actionLabel),
        ),
      ],
    );
  }
}
