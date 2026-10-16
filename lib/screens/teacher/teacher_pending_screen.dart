import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../state/app_state.dart';
import '../../theme/app_theme.dart';
import '../../widgets/section_card.dart';
import '../welcome_screen.dart';
import 'teacher_shell.dart';

class TeacherPendingScreen extends StatelessWidget {
  const TeacherPendingScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final state = context.watch<AppState>();
    final teacher = state.pendingTeacher;
    if (teacher == null) {
      return const Scaffold(body: SizedBox.shrink());
    }

    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(28),
          child: Column(
            children: [
              const Spacer(),
              Container(
                width: 88,
                height: 88,
                decoration: BoxDecoration(
                  color: AppColors.warning.withOpacity(0.15),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.hourglass_top,
                  size: 44,
                  color: AppColors.warning,
                ),
              ),
              const SizedBox(height: 22),
              const Text(
                'Awaiting Admin Verification',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.w900),
              ),
              const SizedBox(height: 10),
              const Text(
                'Your teacher account was submitted. The school '
                'administrator must verify your credentials before you can '
                'open the teacher dashboard.',
                textAlign: TextAlign.center,
                style: TextStyle(color: AppColors.textSecondary, height: 1.4),
              ),
              const SizedBox(height: 22),
              SectionCard(
                child: Column(
                  children: [
                    _Row(label: 'Name', value: teacher.name),
                    const Divider(height: 22),
                    _Row(label: 'Email', value: teacher.email),
                    const Divider(height: 22),
                    _Row(
                      label: 'Specialization',
                      value: teacher.subjectSpecialization,
                    ),
                    const Divider(height: 22),
                    _Row(label: 'School', value: teacher.school),
                  ],
                ),
              ),
              const Spacer(),
              ElevatedButton(
                onPressed: () {
                  state.approvePendingTeacher();
                  Navigator.of(context).pushAndRemoveUntil(
                    MaterialPageRoute(builder: (_) => const TeacherShell()),
                    (route) => false,
                  );
                },
                child: const Text('Check approval status'),
              ),
              const SizedBox(height: 6),
              TextButton(
                onPressed: () {
                  state.cancelPendingTeacher();
                  Navigator.of(context).pushAndRemoveUntil(
                    MaterialPageRoute(builder: (_) => const WelcomeScreen()),
                    (route) => false,
                  );
                },
                child: const Text('Back to Welcome'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _Row extends StatelessWidget {
  final String label;
  final String value;
  const _Row({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(color: AppColors.textSecondary)),
        const SizedBox(width: 16),
        Expanded(
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
