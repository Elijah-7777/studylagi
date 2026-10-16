import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../state/app_state.dart';
import '../theme/app_theme.dart';
import '../widgets/section_card.dart';

class ProgressReportScreen extends StatelessWidget {
  const ProgressReportScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final state = context.watch<AppState>();
    final breakdown = state.subjectBreakdown;
    final now = DateTime.now();
    const months = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];

    return Scaffold(
      appBar: AppBar(title: const Text('My Progress Report')),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          Text('Last Updated: ${months[now.month - 1]} ${now.day}, ${now.year}',
              style: const TextStyle(color: AppColors.textSecondary)),
          const SizedBox(height: 18),
          Row(
            children: [
              Expanded(
                child: _StatCard(
                  icon: Icons.star_border,
                  iconColor: AppColors.primary,
                  value: '${state.knowledgePoints} KP',
                  label: 'Total Knowledge Points',
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: _StatCard(
                  icon: Icons.trending_up,
                  iconColor: AppColors.primary,
                  value: '+${state.kpGainedThisWeek} KP',
                  label: 'KP Gained (Last Week)',
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          Row(
            children: [
              Expanded(
                child: _StatCard(
                  icon: Icons.check_circle_outline,
                  iconColor: AppColors.textPrimary,
                  value: '${state.completedTasks.length}/${state.tasks.length}',
                  label: 'Tasks Completed',
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: _StatCard(
                  icon: Icons.local_fire_department,
                  iconColor: AppColors.streakFlame,
                  value: '${state.streakDays} Days',
                  label: 'Current Study Streak',
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          SectionCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Row(
                  children: [
                    Icon(Icons.menu_book_outlined, size: 20),
                    SizedBox(width: 8),
                    Text('Subject Breakdown', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w800)),
                  ],
                ),
                const Divider(height: 24),
                if (breakdown.isEmpty)
                  const Text('Add tasks per subject to see a breakdown here.',
                      style: TextStyle(color: AppColors.textSecondary))
                else
                  ...breakdown.entries.map((e) {
                    final pct = (e.value * 100).round();
                    final label = pct >= 90 ? 'Excellent' : (pct >= 75 ? 'Good' : 'Needs Improvement');
                    final color = pct >= 90
                        ? AppColors.primary
                        : (pct >= 75 ? AppColors.textPrimary : AppColors.danger);
                    return Padding(
                      padding: const EdgeInsets.symmetric(vertical: 8),
                      child: Row(
                        children: [
                          Expanded(child: Text(e.key, style: const TextStyle(fontWeight: FontWeight.w600))),
                          Text(label, style: TextStyle(color: color, fontWeight: FontWeight.w700)),
                          const SizedBox(width: 10),
                          SizedBox(
                            width: 46,
                            child: Text('$pct%', textAlign: TextAlign.end, style: const TextStyle(fontWeight: FontWeight.w800)),
                          ),
                        ],
                      ),
                    );
                  }),
              ],
            ),
          ),
          if (state.myGradedWork.isNotEmpty) ...[
            const SizedBox(height: 18),
            SectionCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Row(
                    children: [
                      Icon(Icons.grade_outlined, size: 20),
                      SizedBox(width: 8),
                      Text('Teacher Grades',
                          style: TextStyle(fontSize: 16, fontWeight: FontWeight.w800)),
                    ],
                  ),
                  const Divider(height: 24),
                  ...state.myGradedWork.map((entry) {
                    final a = entry.key;
                    final s = entry.value;
                    return Padding(
                      padding: const EdgeInsets.symmetric(vertical: 8),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Expanded(
                                child: Text(a.title,
                                    style: const TextStyle(fontWeight: FontWeight.w700)),
                              ),
                              Text('${s.score}/${a.maxScore}',
                                  style: const TextStyle(fontWeight: FontWeight.w900)),
                            ],
                          ),
                          Text(state.subjectOfClass(a.classId),
                              style: const TextStyle(
                                  fontSize: 12, color: AppColors.textSecondary)),
                          if (s.feedback.isNotEmpty)
                            Padding(
                              padding: const EdgeInsets.only(top: 4),
                              child: Text('Feedback: ${s.feedback}',
                                  style: const TextStyle(fontSize: 12)),
                            ),
                        ],
                      ),
                    );
                  }),
                ],
              ),
            ),
          ],
          const SizedBox(height: 18),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppColors.primary.withValues(alpha: 0.08),
              borderRadius: BorderRadius.circular(16),
              border: const Border(left: BorderSide(color: AppColors.primary, width: 4)),
            ),
            child: Row(
              children: [
                const Icon(Icons.lightbulb_outline, color: AppColors.primary),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    _tipText(breakdown),
                    style: const TextStyle(fontWeight: FontWeight.w600),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  String _tipText(Map<String, double> breakdown) {
    if (breakdown.isEmpty) return 'Add and complete tasks to get personalized study tips!';
    final weakest = breakdown.entries.reduce((a, b) => a.value < b.value ? a : b);
    return 'Focus on ${weakest.key} this week to improve your overall completion rate!';
  }
}

class _StatCard extends StatelessWidget {
  final IconData icon;
  final Color iconColor;
  final String value;
  final String label;
  const _StatCard({required this.icon, required this.iconColor, required this.value, required this.label});

  @override
  Widget build(BuildContext context) {
    return SectionCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: iconColor),
          const SizedBox(height: 10),
          Text(value, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w900)),
          const SizedBox(height: 4),
          Text(label, style: const TextStyle(color: AppColors.textSecondary, fontSize: 12)),
        ],
      ),
    );
  }
}
