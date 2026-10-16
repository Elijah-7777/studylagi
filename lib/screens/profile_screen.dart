import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../state/app_state.dart';
import '../theme/app_theme.dart';
import '../widgets/section_card.dart';
import 'welcome_screen.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final state = context.watch<AppState>();
    final user = state.currentUser;
    final isTeacher = state.isTeacher;

    return Scaffold(
      appBar: AppBar(title: const Text('Account')),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          Center(
            child: Column(
              children: [
                const CircleAvatar(
                  radius: 42,
                  backgroundColor: AppColors.primary,
                  child: Icon(Icons.person, size: 42, color: Colors.white),
                ),
                const SizedBox(height: 14),
                Text(
                  state.displayName,
                  style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w900),
                ),
                Text(
                  isTeacher
                      ? 'Teacher · ${user?.subjectSpecialization ?? ''}'
                      : '${state.gradeLevel} · ${state.strand}',
                  style: const TextStyle(color: AppColors.textSecondary),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),
          SectionCard(
            child: Column(
              children: [
                _InfoRow(label: 'Email', value: user?.email ?? ''),
                const Divider(height: 24),
                _InfoRow(
                  label: 'School',
                  value: isTeacher
                      ? (user?.school ?? '')
                      : 'St. Matthew Academy of Cavite',
                ),
                const Divider(height: 24),
                if (isTeacher) ...[
                  _InfoRow(label: 'Classes', value: '${state.myClasses.length}'),
                  const Divider(height: 24),
                  _InfoRow(label: 'Students', value: '${state.myStudents.length}'),
                ] else ...[
                  _InfoRow(
                    label: 'Knowledge Points',
                    value: '${state.knowledgePoints} KP',
                  ),
                  const Divider(height: 24),
                  _InfoRow(
                    label: 'Study Streak',
                    value: '${state.streakDays} days',
                  ),
                ],
              ],
            ),
          ),
          const SizedBox(height: 24),
          OutlinedButton(
            style: OutlinedButton.styleFrom(
              foregroundColor: AppColors.danger,
              side: const BorderSide(color: AppColors.danger),
              minimumSize: const Size.fromHeight(52),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(14),
              ),
            ),
            onPressed: () {
              state.logout();
              Navigator.of(context).pushAndRemoveUntil(
                MaterialPageRoute(builder: (_) => const WelcomeScreen()),
                (route) => false,
              );
            },
            child: const Text('Log Out'),
          ),
        ],
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  final String label;
  final String value;
  const _InfoRow({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: const TextStyle(color: AppColors.textSecondary)),
        const SizedBox(width: 16),
        Flexible(
          child: Text(
            value,
            textAlign: TextAlign.end,
            style: const TextStyle(fontWeight: FontWeight.w700),
          ),
        ),
      ],
    );
  }
}
