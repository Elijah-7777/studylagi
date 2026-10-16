import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/achievement.dart';
import '../state/app_state.dart';
import '../theme/app_theme.dart';
import '../widgets/section_card.dart';

class AchievementsScreen extends StatelessWidget {
  const AchievementsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final state = context.watch<AppState>();
    final streakOnes = state.achievements.where((a) => a.id.startsWith('streak') || a.id == 'first_day').toList();
    final kpOnes = state.achievements.where((a) => a.id.startsWith('kp')).toList();
    final other = state.achievements.where((a) => !streakOnes.contains(a) && !kpOnes.contains(a)).toList();

    return ListView(
      padding: const EdgeInsets.all(20),
      children: [
        const Text('Your Achievements', style: TextStyle(fontSize: 24, fontWeight: FontWeight.w900)),
        const Text('Track your progress and unlock rewards!', style: TextStyle(color: AppColors.textSecondary)),
        const SizedBox(height: 20),
        const _SectionHeader(emoji: '🔥', title: 'Study Streak Milestones'),
        const SizedBox(height: 10),
        ...streakOnes.map((a) => _AchievementCard(achievement: a)),
        const SizedBox(height: 20),
        const _SectionHeader(emoji: '💡', title: 'Knowledge Points (KP) Collector'),
        const SizedBox(height: 10),
        ...kpOnes.map((a) => _AchievementCard(achievement: a)),
        if (other.isNotEmpty) ...[
          const SizedBox(height: 20),
          const _SectionHeader(emoji: '🏆', title: 'Other Achievements'),
          const SizedBox(height: 10),
          ...other.map((a) => _AchievementCard(achievement: a)),
        ],
      ],
    );
  }
}

class _SectionHeader extends StatelessWidget {
  final String emoji;
  final String title;
  const _SectionHeader({required this.emoji, required this.title});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Text(emoji, style: const TextStyle(fontSize: 20)),
        const SizedBox(width: 8),
        Text(title, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w800)),
      ],
    );
  }
}

class _AchievementCard extends StatelessWidget {
  final Achievement achievement;
  const _AchievementCard({required this.achievement});

  @override
  Widget build(BuildContext context) {
    final complete = achievement.isComplete;
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: SectionCard(
        borderColor: complete && !achievement.claimed ? AppColors.primary : null,
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(
              complete ? Icons.emoji_events : Icons.lock_outline,
              color: complete ? AppColors.primary : AppColors.locked,
              size: 28,
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(achievement.title, style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 16)),
                  const SizedBox(height: 4),
                  Text(achievement.description, style: const TextStyle(color: AppColors.textSecondary, fontSize: 13)),
                  const SizedBox(height: 10),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(999),
                    child: LinearProgressIndicator(
                      value: (achievement.progress / achievement.target).clamp(0, 1),
                      minHeight: 8,
                      backgroundColor: const Color(0xFFE5E7EB),
                      valueColor: const AlwaysStoppedAnimation(AppColors.primary),
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    complete
                        ? (achievement.claimed ? 'Claimed' : 'Completed! 🎉')
                        : 'Progress: ${achievement.progress} / ${achievement.target}',
                    style: TextStyle(
                      color: complete ? AppColors.primary : AppColors.textSecondary,
                      fontWeight: FontWeight.w700,
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ),
            if (complete && !achievement.claimed)
              ElevatedButton(
                style: ElevatedButton.styleFrom(minimumSize: const Size(80, 38)),
                onPressed: () => context.read<AppState>().claimAchievement(achievement.id),
                child: const Text('Claim'),
              ),
          ],
        ),
      ),
    );
  }
}
