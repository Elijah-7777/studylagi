import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../state/app_state.dart';
import '../theme/app_theme.dart';
import '../widgets/section_card.dart';

class LeaderboardScreen extends StatelessWidget {
  const LeaderboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final state = context.watch<AppState>();
    final sorted = [...state.leaderboard]..sort((a, b) => b.kp.compareTo(a.kp));

    return ListView(
      padding: const EdgeInsets.all(20),
      children: [
        const Text('School Leaderboards', style: TextStyle(fontSize: 24, fontWeight: FontWeight.w900)),
        const Text('St. Matthew Academy', style: TextStyle(color: AppColors.textSecondary)),
        const SizedBox(height: 18),
        const Row(
          children: [
            Expanded(
              child: SectionCard(
                padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('All Students', style: TextStyle(fontWeight: FontWeight.w700)),
                    Icon(Icons.keyboard_arrow_down, size: 18),
                  ],
                ),
              ),
            ),
            SizedBox(width: 10),
            Expanded(
              child: SectionCard(
                padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Flexible(
                      child: Text(
                        'Sort: Knowledge Points',
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(fontWeight: FontWeight.w700, color: AppColors.primary, fontSize: 12),
                      ),
                    ),
                    Icon(Icons.swap_vert, size: 18, color: AppColors.primary),
                  ],
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        ...List.generate(sorted.length, (i) {
          final entry = sorted[i];
          final rank = i + 1;
          final isTop3 = rank <= 3;
          return Padding(
            padding: const EdgeInsets.only(bottom: 10),
            child: SectionCard(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
              borderColor: entry.isYou
                  ? AppColors.primary
                  : isTop3
                      ? AppColors.kpGold
                      : null,
              child: Row(
                children: [
                  SizedBox(
                    width: 28,
                    child: Text(
                      '$rank',
                      style: TextStyle(
                        fontWeight: FontWeight.w900,
                        fontSize: 16,
                        color: isTop3 ? AppColors.kpGold : AppColors.textSecondary,
                      ),
                    ),
                  ),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          entry.name,
                          style: TextStyle(
                            fontWeight: FontWeight.w800,
                            color: entry.isYou ? AppColors.primary : AppColors.textPrimary,
                          ),
                        ),
                        Text(entry.gradeLevel, style: const TextStyle(fontSize: 12, color: AppColors.textSecondary)),
                      ],
                    ),
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text('★ ${entry.kp} KP',
                          style: TextStyle(
                            fontWeight: FontWeight.w800,
                            color: entry.isYou ? AppColors.primary : AppColors.kpGold,
                          )),
                      Text('${entry.streak} 🔥', style: const TextStyle(fontSize: 12)),
                    ],
                  ),
                ],
              ),
            ),
          );
        }),
      ],
    );
  }
}
