import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/task.dart';
import '../state/app_state.dart';
import '../theme/app_theme.dart';
import '../widgets/format_utils.dart';
import '../widgets/section_card.dart';
import 'assignment_sheet.dart';
import 'profile_screen.dart';
import 'progress_report_screen.dart';

class DashboardScreen extends StatelessWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final state = context.watch<AppState>();
    final upcoming = state.pendingTasks.take(3).toList();
    final toSubmit = state.studentAssignments
        .where((a) => state.mySubmission(a.id) == null)
        .toList();
    final announcements = state.studentAnnouncements.take(2).toList();
    final firstName = state.studentName.split(' ').first;

    return ListView(
      padding: const EdgeInsets.all(20),
      children: [
        Row(
          children: [
            Expanded(
              child: Text(
                'Hi, $firstName! 👋',
                style: const TextStyle(
                  fontSize: 24,
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
          '${state.gradeLevel} · ${state.strand} · St. Matthew Academy of Cavite',
          style: const TextStyle(color: AppColors.textSecondary),
        ),
        const SizedBox(height: 20),

        Row(
          children: [
            Expanded(
              child: SectionCard(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Icon(Icons.star, color: AppColors.kpGold),
                    const SizedBox(height: 8),
                    Text(
                      '${state.knowledgePoints}',
                      style: const TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                    const Text(
                      'Knowledge Points',
                      style: TextStyle(
                        color: AppColors.textSecondary,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: SectionCard(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Icon(
                      Icons.local_fire_department,
                      color: AppColors.streakFlame,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      '${state.streakDays} Days',
                      style: const TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                    const Text(
                      'Study Streak',
                      style: TextStyle(
                        color: AppColors.textSecondary,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 14),

        SectionCard(
          child: Row(
            children: [
              const Icon(Icons.check_circle_outline, color: AppColors.success),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  state.streakLoggedToday
                      ? "Today's session is logged. Nice streak! 🔥"
                      : (state.streakDays > 0
                          ? "Today's session isn't logged yet. Keep the streak going!"
                          : 'Log a study session to start your streak.'),
                  style: const TextStyle(fontWeight: FontWeight.w600),
                ),
              ),
              TextButton(
                onPressed: state.streakLoggedToday
                    ? null
                    : () => state.logStudySessionToday(),
                child: const Text('Log Today'),
              ),
            ],
          ),
        ),
        const SizedBox(height: 24),

        if (toSubmit.isNotEmpty) ...[
          Text(
            'From Your Teachers (${toSubmit.length} to submit)',
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w800),
          ),
          const SizedBox(height: 8),
          ...toSubmit.take(2).map(
                (a) => Padding(
                  padding: const EdgeInsets.only(bottom: 10),
                  child: GestureDetector(
                    onTap: () => showModalBottomSheet(
                      context: context,
                      isScrollControlled: true,
                      backgroundColor: Colors.transparent,
                      builder: (_) => AssignmentSheet(assignmentId: a.id),
                    ),
                    child: SectionCard(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 14,
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
                                  '${state.subjectOfClass(a.classId)} · ${state.teacherNameOfClass(a.classId)} · Due ${formatDate(a.dueDate)}',
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
                ),
              ),
          const SizedBox(height: 14),
        ],

        if (announcements.isNotEmpty) ...[
          const Text(
            'Class Announcements',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800),
          ),
          const SizedBox(height: 8),
          ...announcements.map(
            (n) => Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: SectionCard(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 14,
                ),
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
                          Text(
                            '${state.classNameOf(n.classId)} · ${state.teacherNameOfClass(n.classId)}',
                            style: const TextStyle(
                              fontSize: 12,
                              color: AppColors.textSecondary,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(n.message, style: const TextStyle(fontSize: 13)),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          const SizedBox(height: 14),
        ],

        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              'Upcoming Tasks',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800),
            ),
            TextButton(
              onPressed: () => Navigator.of(context).push(
                MaterialPageRoute(builder: (_) => const ProgressReportScreen()),
              ),
              child: const Text('View Report'),
            ),
          ],
        ),
        const SizedBox(height: 8),

        if (upcoming.isEmpty)
          const SectionCard(
            child: Text(
              'No pending tasks. Nice work! 🎉',
              style: TextStyle(color: AppColors.textSecondary),
            ),
          )
        else
          ...upcoming.map(
            (t) => Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: SectionCard(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 14,
                ),
                child: Row(
                  children: [
                    Container(
                      width: 8,
                      height: 8,
                      decoration: BoxDecoration(
                        color: _priorityColor(t.priority),
                        shape: BoxShape.circle,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            t.title,
                            style: const TextStyle(fontWeight: FontWeight.w700),
                          ),
                          Text(
                            '${t.subject} · Due ${formatDate(t.dueDate)}',
                            style: const TextStyle(
                              fontSize: 12,
                              color: AppColors.textSecondary,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
      ],
    );
  }

  Color _priorityColor(TaskPriority p) {
    switch (p) {
      case TaskPriority.high:
        return AppColors.danger;
      case TaskPriority.medium:
        return AppColors.warning;
      case TaskPriority.low:
        return AppColors.success;
    }
  }
}
