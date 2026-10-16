class LeaderboardEntry {
  final String name;
  final String gradeLevel;
  int kp;
  int streak;
  final bool isYou;

  LeaderboardEntry({
    required this.name,
    required this.gradeLevel,
    required this.kp,
    required this.streak,
    this.isYou = false,
  });
}
