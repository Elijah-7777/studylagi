import 'package:flutter/material.dart';
import '../models/achievement.dart';
import '../models/store_item.dart';
import '../models/task.dart';

class StudentData {
  final List<StudyTask> tasks;
  final List<Achievement> achievements;
  final List<StoreItem> storeItems;
  int nextTaskId;
  bool streakLoggedToday;

  StudentData({
    required this.tasks,
    required this.achievements,
    required this.storeItems,
    this.nextTaskId = 1,
    this.streakLoggedToday = false,
  });

  factory StudentData.fresh() {
    return StudentData(
      tasks: <StudyTask>[],
      achievements: defaultAchievements(),
      storeItems: defaultStoreItems(),
    );
  }

  static List<Achievement> defaultAchievements() {
    return [
      Achievement(
        id: 'first_day',
        title: 'First Day!',
        description: 'Complete your first study session.',
        icon: Icons.emoji_events,
        target: 1,
      ),
      Achievement(
        id: 'streak_7',
        title: '7-Day Streak',
        description: 'Log study sessions for a week.',
        icon: Icons.lock_outline,
        target: 7,
      ),
      Achievement(
        id: 'streak_30',
        title: '30-Day Master',
        description: 'Achieve a 30-day continuous study streak.',
        icon: Icons.lock_outline,
        target: 30,
      ),
      Achievement(
        id: 'kp_1000',
        title: '1,000 KP Club',
        description: 'Earn 1,000 total Knowledge Points.',
        icon: Icons.emoji_events,
        target: 1000,
      ),
      Achievement(
        id: 'kp_10000',
        title: 'KP Tycoon',
        description: 'Earn 10,000 total Knowledge Points.',
        icon: Icons.lock_outline,
        target: 10000,
      ),
      Achievement(
        id: 'tasks_done',
        title: 'Task Conqueror',
        description: 'Complete 10 study tasks.',
        icon: Icons.lock_outline,
        target: 10,
      ),
    ];
  }

  static List<StoreItem> defaultStoreItems() {
    return [
      StoreItem(
        id: 's1',
        name: 'Scholar Robes',
        category: 'Outfit',
        price: 300,
        icon: Icons.menu_book,
        tint: const Color(0xFFB2F1D6),
      ),
      StoreItem(
        id: 's2',
        name: 'Serene Library',
        category: 'Theme',
        price: 500,
        icon: Icons.museum,
        tint: const Color(0xFFDDD6FE),
      ),
      StoreItem(
        id: 's3',
        name: 'Gentle Rain',
        category: 'Sound',
        price: 150,
        icon: Icons.water_drop,
        tint: const Color(0xFFDBEAFE),
      ),
      StoreItem(
        id: 's4',
        name: 'Magnifying Glass',
        category: 'Accessory',
        price: 100,
        icon: Icons.search,
        tint: const Color(0xFFFFE4D1),
      ),
    ];
  }
}
