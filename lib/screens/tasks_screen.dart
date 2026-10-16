import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/task.dart';
import '../state/app_state.dart';
import '../theme/app_theme.dart';
import '../widgets/section_card.dart';
import '../widgets/format_utils.dart';
import '../widgets/status_chip.dart';
import 'assignment_sheet.dart';
import 'task_form_sheet.dart';

class TasksScreen extends StatelessWidget {
  const TasksScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final state = context.watch<AppState>();
    final pending = state.pendingTasks;
    final done = state.completedTasks;
    final assignments = state.studentAssignments;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(title: const Text('Study Tasks')),
      floatingActionButton: FloatingActionButton.extended(
        backgroundColor: AppColors.primary,
        icon: const Icon(Icons.add, color: Colors.white),
        label: const Text('New Task', style: TextStyle(color: Colors.white)),
        onPressed: () => showModalBottomSheet(
          context: context,
          isScrollControlled: true,
          backgroundColor: Colors.transparent,
          builder: (_) => const TaskFormSheet(),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(20, 8, 20, 100),
        children: [
          if (assignments.isNotEmpty) ...[
            Text('From Your Teachers (${assignments.length})',
                style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w800)),
            const SizedBox(height: 10),
            ...assignments.map((a) => _AssignmentTile(assignmentId: a.id)),
            const SizedBox(height: 22),
          ],
          Text('Pending (${pending.length})',
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w800)),
          const SizedBox(height: 10),
          if (pending.isEmpty)
            const SectionCard(child: Text('No pending tasks. Tap "New Task" to add one.'))
          else
            ...pending.map((t) => _TaskTile(task: t)),
          const SizedBox(height: 22),
          Text('Completed (${done.length})',
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w800)),
          const SizedBox(height: 10),
          if (done.isEmpty)
            const SectionCard(child: Text('Nothing completed yet.'))
          else
            ...done.map((t) => _TaskTile(task: t)),
        ],
      ),
    );
  }
}

class _TaskTile extends StatelessWidget {
  final StudyTask task;
  const _TaskTile({required this.task});

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

  @override
  Widget build(BuildContext context) {
    final state = context.read<AppState>();

    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Dismissible(
        key: ValueKey(task.id),
        direction: DismissDirection.endToStart,
        background: Container(
          decoration: BoxDecoration(color: AppColors.danger, borderRadius: BorderRadius.circular(18)),
          alignment: Alignment.centerRight,
          padding: const EdgeInsets.only(right: 20),
          child: const Icon(Icons.delete, color: Colors.white),
        ),
        onDismissed: (_) => state.deleteTask(task.id),
        child: GestureDetector(
          onTap: () => showModalBottomSheet(
            context: context,
            isScrollControlled: true,
            backgroundColor: Colors.transparent,
            builder: (_) => TaskFormSheet(existingTask: task),
          ),
          child: SectionCard(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
            child: Row(
              children: [
                Checkbox(
                  value: task.completed,
                  activeColor: AppColors.primary,
                  onChanged: (_) => state.toggleTaskComplete(task.id),
                ),
                Container(
                  width: 6,
                  height: 34,
                  decoration: BoxDecoration(
                    color: _priorityColor(task.priority),
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        task.title,
                        style: TextStyle(
                          fontWeight: FontWeight.w700,
                          decoration: task.completed ? TextDecoration.lineThrough : null,
                          color: task.completed ? AppColors.textSecondary : AppColors.textPrimary,
                        ),
                      ),
                      Text(
                        '${task.subject} · ${task.priority.label} priority · +${task.kpReward} KP',
                        style: const TextStyle(fontSize: 12, color: AppColors.textSecondary),
                      ),
                    ],
                  ),
                ),
                const Icon(Icons.chevron_right, color: AppColors.textSecondary),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _AssignmentTile extends StatelessWidget {
  final String assignmentId;
  const _AssignmentTile({required this.assignmentId});

  @override
  Widget build(BuildContext context) {
    final state = context.watch<AppState>();
    final a = state.assignmentById(assignmentId);
    if (a == null) return const SizedBox.shrink();

    final sub = state.mySubmission(a.id);
    final String label;
    final Color color;
    if (sub == null) {
      final overdue = a.dueDate.isBefore(DateTime.now());
      label = overdue ? 'Overdue' : 'To submit';
      color = overdue ? AppColors.danger : AppColors.primary;
    } else if (sub.isGraded) {
      label = 'Graded ${sub.score}/${a.maxScore}';
      color = AppColors.success;
    } else {
      label = 'Submitted';
      color = AppColors.warning;
    }

    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: GestureDetector(
        onTap: () => showModalBottomSheet(
          context: context,
          isScrollControlled: true,
          backgroundColor: Colors.transparent,
          builder: (_) => AssignmentSheet(assignmentId: a.id),
        ),
        child: SectionCard(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
          child: Row(
            children: [
              const Icon(Icons.assignment, color: AppColors.primary),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(a.title,
                        style: const TextStyle(fontWeight: FontWeight.w700)),
                    Text(
                      '${state.subjectOfClass(a.classId)} · ${state.teacherNameOfClass(a.classId)} · Due ${formatDate(a.dueDate)}',
                      style: const TextStyle(
                          fontSize: 12, color: AppColors.textSecondary),
                    ),
                    const SizedBox(height: 6),
                    StatusChip(label: label, color: color),
                  ],
                ),
              ),
              const Icon(Icons.chevron_right, color: AppColors.textSecondary),
            ],
          ),
        ),
      ),
    );
  }
}
