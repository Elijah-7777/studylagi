enum UserRole { student, teacher }

enum LoginResult { success, notFound, wrongPassword, pendingApproval }

class RegisteredUser {
  final String id;
  final UserRole role;
  String name;
  final String email;
  final String password;

  String gradeLevel;
  String strand;

  String subjectSpecialization;
  String school;

  bool approved;

  RegisteredUser({
    required this.id,
    required this.role,
    required this.name,
    required this.email,
    required this.password,
    this.gradeLevel = '',
    this.strand = '',
    this.subjectSpecialization = '',
    this.school = '',
    this.approved = true,
  });

  bool get isTeacher => role == UserRole.teacher;
  bool get isStudent => role == UserRole.student;
}
