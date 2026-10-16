class Assignment {
  final String id;
  final String classId;
  final String teacherId;
  String title;
  String description;
  DateTime dueDate;
  int maxScore;
  final int kpReward;

  Assignment({
    required this.id,
    required this.classId,
    required this.teacherId,
    required this.title,
    required this.description,
    required this.dueDate,
    this.maxScore = 100,
    this.kpReward = 100,
  });
}

enum SubmissionStatus { notSubmitted, submitted, graded }

class Submission {
  final String assignmentId;
  final String studentId;
  final DateTime submittedAt;
  String note;
  int? score;
  String feedback;

  Submission({
    required this.assignmentId,
    required this.studentId,
    required this.submittedAt,
    this.note = '',
    this.score,
    this.feedback = '',
  });

  bool get isGraded => score != null;

  SubmissionStatus get status =>
      isGraded ? SubmissionStatus.graded : SubmissionStatus.submitted;
}
