import 'package:flutter_test/flutter_test.dart';
import 'package:studylagi_mobile/models/app_user.dart';
import 'package:studylagi_mobile/state/app_state.dart';

void main() {
  group('authentication and roles', () {
    test('demo student logs in as a student', () {
      final s = AppState();
      final result =
          s.authenticate(email: 'kylie@smac.edu.ph', password: 'study123');
      expect(result, LoginResult.success);
      expect(s.isStudent, isTrue);
      expect(s.isTeacher, isFalse);
    });

    test('demo teacher logs in as a teacher', () {
      final s = AppState();
      final result =
          s.authenticate(email: 'teacher@smac.edu.ph', password: 'teach123');
      expect(result, LoginResult.success);
      expect(s.isTeacher, isTrue);
      expect(s.isStudent, isFalse);
    });

    test('unknown email and wrong password are rejected', () {
      final s = AppState();
      expect(
        s.authenticate(email: 'nobody@smac.edu.ph', password: 'whatever'),
        LoginResult.notFound,
      );
      expect(
        s.authenticate(email: 'teacher@smac.edu.ph', password: 'wrong'),
        LoginResult.wrongPassword,
      );
      expect(s.isLoggedIn, isFalse);
    });

    test('a new teacher waits for admin approval before entering', () {
      final s = AppState();
      final error = s.registerTeacher(
        name: 'Mr. Cruz',
        email: 'cruz@smac.edu.ph',
        password: 'abcd',
        subjectSpecialization: 'Science',
        school: 'St. Matthew Academy of Cavite',
      );
      expect(error, isNull);
      expect(s.isLoggedIn, isFalse);
      expect(s.pendingTeacher, isNotNull);

      final login =
          s.authenticate(email: 'cruz@smac.edu.ph', password: 'abcd');
      expect(login, LoginResult.pendingApproval);
      expect(s.isLoggedIn, isFalse);

      s.approvePendingTeacher();
      expect(s.isTeacher, isTrue);
      expect(s.pendingTeacher, isNull);
    });

    test('duplicate email is rejected', () {
      final s = AppState();
      final error = s.registerStudent(
        name: 'Copy Cat',
        email: 'KYLIE@smac.edu.ph',
        password: 'abcd',
        gradeLevel: 'Grade 11',
        strand: 'STEM',
      );
      expect(error, isNotNull);
    });

    test('a new student starts fresh', () {
      final s = AppState();
      final error = s.registerStudent(
        name: 'New Student',
        email: 'new@smac.edu.ph',
        password: 'abcd',
        gradeLevel: 'Grade 12',
        strand: 'ABM',
      );
      expect(error, isNull);
      expect(s.isStudent, isTrue);
      expect(s.knowledgePoints, 0);
      expect(s.tasks, isEmpty);
      expect(s.leaderboard.any((e) => e.isYou), isTrue);
    });
  });

  group('teacher to student workflow', () {
    test('class, assignment, submission and grading', () {
      final s = AppState();

      s.authenticate(email: 'teacher@smac.edu.ph', password: 'teach123');
      final classesBefore = s.myClasses.length;
      s.createClass(name: 'Test Class', subject: 'Research', strand: 'STEM');
      expect(s.myClasses.length, classesBefore + 1);
      final cls = s.myClasses.last;

      s.enrollStudent(cls.id, 'stu_kylie');
      expect(s.studentsOf(cls.id).map((x) => x.id), contains('stu_kylie'));

      s.createAssignment(
        classId: cls.id,
        title: 'Test homework',
        description: 'Do it',
        dueDate: DateTime.now().add(const Duration(days: 2)),
        maxScore: 50,
      );
      final assignment = s.assignmentsForClass(cls.id).first;
      s.logout();

      s.authenticate(email: 'kylie@smac.edu.ph', password: 'study123');
      expect(s.studentAssignments.map((a) => a.id), contains(assignment.id));
      final kpBefore = s.knowledgePoints;
      s.submitAssignment(assignment.id, note: 'Done');
      expect(s.mySubmission(assignment.id), isNotNull);
      expect(s.knowledgePoints, kpBefore + assignment.kpReward);
      s.logout();

      s.authenticate(email: 'teacher@smac.edu.ph', password: 'teach123');
      expect(
        s.needsGrading.any((g) => g.assignment.id == assignment.id),
        isTrue,
      );
      s.gradeSubmission(
        assignmentId: assignment.id,
        studentId: 'stu_kylie',
        score: 45,
        feedback: 'Well done',
      );
      final stats = s.statsFor('stu_kylie', classId: cls.id);
      expect(stats.graded, 1);
      expect(stats.averagePercent, 90);
      s.logout();

      s.authenticate(email: 'kylie@smac.edu.ph', password: 'study123');
      final graded = s.mySubmission(assignment.id)!;
      expect(graded.score, 45);
      expect(graded.feedback, 'Well done');
    });

    test('deleting a class removes its assignments', () {
      final s = AppState();
      s.authenticate(email: 'teacher@smac.edu.ph', password: 'teach123');
      s.deleteClass('c1');
      expect(s.assignmentsForClass('c1'), isEmpty);
      expect(s.classById('c1'), isNull);
    });
  });
}
