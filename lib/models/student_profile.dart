class StudentProfile {
  final String id;
  String name;
  String gradeLevel;
  String strand;
  int kp;
  int kpWeek;
  int streak;

  StudentProfile({
    required this.id,
    required this.name,
    required this.gradeLevel,
    required this.strand,
    this.kp = 0,
    this.kpWeek = 0,
    this.streak = 0,
  });
}
