import 'package:flutter/material.dart';

class Achievement {
  final String id;
  final String title;
  final String description;
  final IconData icon;
  final int target;
  int progress;
  bool claimed;

  Achievement({
    required this.id,
    required this.title,
    required this.description,
    required this.icon,
    required this.target,
    this.progress = 0,
    this.claimed = false,
  });

  bool get isComplete => progress >= target;
}
