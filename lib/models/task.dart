enum TaskPriority { low, medium, high }

extension TaskPriorityX on TaskPriority {
  String get label {
    switch (this) {
      case TaskPriority.low:
        return 'Low';
      case TaskPriority.medium:
        return 'Medium';
      case TaskPriority.high:
        return 'High';
    }
  }
}

class StudyTask {
  String id;
  String title;
  String subject;
  DateTime dueDate;
  TaskPriority priority;
  bool completed;
  final int kpReward;

  StudyTask({
    required this.id,
    required this.title,
    required this.subject,
    required this.dueDate,
    this.priority = TaskPriority.medium,
    this.completed = false,
    this.kpReward = 50,
  });

  StudyTask copyWith({
    String? title,
    String? subject,
    DateTime? dueDate,
    TaskPriority? priority,
    bool? completed,
  }) {
    return StudyTask(
      id: id,
      title: title ?? this.title,
      subject: subject ?? this.subject,
      dueDate: dueDate ?? this.dueDate,
      priority: priority ?? this.priority,
      completed: completed ?? this.completed,
      kpReward: kpReward,
    );
  }
}
