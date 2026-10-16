class Announcement {
  final String id;
  final String classId;
  String title;
  String message;
  final DateTime postedAt;

  Announcement({
    required this.id,
    required this.classId,
    required this.title,
    required this.message,
    required this.postedAt,
  });
}
