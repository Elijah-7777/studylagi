import 'package:flutter/material.dart';
import '../models/achievement.dart';
import '../models/announcement.dart';
import '../models/app_user.dart';
import '../models/assignment.dart';
import '../models/leaderboard_entry.dart';
import '../models/school_class.dart';
import '../models/store_item.dart';
import '../models/student_profile.dart';
import '../models/task.dart';
import 'student_data.dart';

class StudentStats {
  final int assigned;
  final int submitted;
  final int graded;
  final double? averagePercent;

  const StudentStats({
    required this.assigned,
    required this.submitted,
    required this.graded,
    required this.averagePercent,
  });

  double get completionRate => assigned == 0 ? 0 : submitted / assigned;

  bool get needsSupport =>
      assigned > 0 &&
      (completionRate < 0.5 ||
          (averagePercent != null && averagePercent! < 75));
}

class GradingItem {
  final Assignment assignment;
  final Submission submission;
  final StudentProfile student;

  const GradingItem({
    required this.assignment,
    required this.submission,
    required this.student,
  });
}

class AppState extends ChangeNotifier {
  AppState() {
    _seed();
  }

  int _idCounter = 100;
  String _newId(String prefix) => '$prefix${_idCounter++}';

  int _clampInt(int value, int low, int high) =>
      value < low ? low : (value > high ? high : value);

  final List<RegisteredUser> _users = [];
  RegisteredUser? _currentUser;

  RegisteredUser? pendingTeacher;

  RegisteredUser? get currentUser => _currentUser;
  bool get isLoggedIn => _currentUser != null;
  bool get isTeacher => _currentUser?.isTeacher ?? false;
  bool get isStudent => _currentUser?.isStudent ?? false;
  String get displayName => _currentUser?.name ?? '';

  bool _emailTaken(String normalizedEmail) =>
      _users.any((u) => u.email == normalizedEmail);

  String? registerStudent({
    required String name,
    required String email,
    required String password,
    required String gradeLevel,
    required String strand,
  }) {
    final normalized = email.trim().toLowerCase();
    if (_emailTaken(normalized)) {
      return 'An account with this email already exists. Try logging in instead.';
    }
    final id = _newId('stu_');
    final user = RegisteredUser(
      id: id,
      role: UserRole.student,
      name: name.trim(),
      email: normalized,
      password: password,
      gradeLevel: gradeLevel,
      strand: strand,
    );
    _users.add(user);
    _students.add(StudentProfile(
      id: id,
      name: user.name,
      gradeLevel: gradeLevel,
      strand: strand,
    ));
    _studentData[id] = StudentData.fresh();
    pendingTeacher = null;
    _currentUser = user;
    notifyListeners();
    return null;
  }

  String? registerTeacher({
    required String name,
    required String email,
    required String password,
    required String subjectSpecialization,
    required String school,
  }) {
    final normalized = email.trim().toLowerCase();
    if (_emailTaken(normalized)) {
      return 'An account with this email already exists. Try logging in instead.';
    }
    final user = RegisteredUser(
      id: _newId('tea_'),
      role: UserRole.teacher,
      name: name.trim(),
      email: normalized,
      password: password,
      subjectSpecialization: subjectSpecialization.trim(),
      school: school.trim(),
      approved: false,
    );
    _users.add(user);
    _currentUser = null;
    pendingTeacher = user;
    notifyListeners();
    return null;
  }

  LoginResult authenticate({required String email, required String password}) {
    final normalized = email.trim().toLowerCase();
    RegisteredUser? user;
    for (final u in _users) {
      if (u.email == normalized) {
        user = u;
        break;
      }
    }
    if (user == null) return LoginResult.notFound;
    if (user.password != password) return LoginResult.wrongPassword;

    if (user.isTeacher && !user.approved) {
      _currentUser = null;
      pendingTeacher = user;
      notifyListeners();
      return LoginResult.pendingApproval;
    }

    pendingTeacher = null;
    _currentUser = user;
    notifyListeners();
    return LoginResult.success;
  }

  void approvePendingTeacher() {
    final t = pendingTeacher;
    if (t == null) return;
    t.approved = true;
    pendingTeacher = null;
    _currentUser = t;
    notifyListeners();
  }

  void cancelPendingTeacher() {
    pendingTeacher = null;
    notifyListeners();
  }

  void logout() {
    _currentUser = null;
    pendingTeacher = null;
    notifyListeners();
  }

  final List<StudentProfile> _students = [];
  final Map<String, StudentData> _studentData = {};

  List<StudentProfile> get students => List.unmodifiable(_students);

  StudentProfile? studentById(String id) {
    for (final s in _students) {
      if (s.id == id) return s;
    }
    return null;
  }

  StudentProfile? get _profileOrNull {
    final u = _currentUser;
    if (u == null || !u.isStudent) return null;
    return studentById(u.id);
  }

  StudentData? get _dataOrNull {
    final u = _currentUser;
    if (u == null || !u.isStudent) return null;
    return _studentData[u.id];
  }

  String get studentName => _currentUser?.name ?? '';
  String get gradeLevel => _currentUser?.gradeLevel ?? '';
  String get strand => _currentUser?.strand ?? '';
  int get knowledgePoints => _profileOrNull?.kp ?? 0;
  int get kpGainedThisWeek => _profileOrNull?.kpWeek ?? 0;
  int get streakDays => _profileOrNull?.streak ?? 0;
  bool get streakLoggedToday => _dataOrNull?.streakLoggedToday ?? false;

  void _awardKp(StudentProfile p, StudentData d, int amount) {
    p.kp += amount;
    p.kpWeek += amount;
    _bump(d, 'kp_1000', amount);
    _bump(d, 'kp_10000', amount);
  }

  void _bump(StudentData d, String achievementId, int amount) {
    for (final a in d.achievements) {
      if (a.id == achievementId) {
        a.progress = _clampInt(a.progress + amount, 0, a.target);
        return;
      }
    }
  }

  List<StudyTask> get tasks =>
      List.unmodifiable(_dataOrNull?.tasks ?? <StudyTask>[]);

  void addTask({
    required String title,
    required String subject,
    required DateTime dueDate,
    required TaskPriority priority,
  }) {
    final d = _dataOrNull;
    if (d == null) return;
    d.tasks.add(
      StudyTask(
        id: 't${d.nextTaskId++}',
        title: title,
        subject: subject,
        dueDate: dueDate,
        priority: priority,
      ),
    );
    notifyListeners();
  }

  StudyTask? taskById(String id) {
    for (final t in tasks) {
      if (t.id == id) return t;
    }
    return null;
  }

  void updateTask(
    String id, {
    String? title,
    String? subject,
    DateTime? dueDate,
    TaskPriority? priority,
  }) {
    final d = _dataOrNull;
    if (d == null) return;
    final index = d.tasks.indexWhere((t) => t.id == id);
    if (index == -1) return;
    d.tasks[index] = d.tasks[index].copyWith(
      title: title,
      subject: subject,
      dueDate: dueDate,
      priority: priority,
    );
    notifyListeners();
  }

  void toggleTaskComplete(String id) {
    final p = _profileOrNull;
    final d = _dataOrNull;
    if (p == null || d == null) return;
    final index = d.tasks.indexWhere((t) => t.id == id);
    if (index == -1) return;
    final task = d.tasks[index];
    final nowComplete = !task.completed;
    d.tasks[index] = task.copyWith(completed: nowComplete);

    if (nowComplete) {
      _awardKp(p, d, task.kpReward);
      _bump(d, 'tasks_done', 1);
      _bump(d, 'first_day', 1);
    } else {
      p.kp = _clampInt(p.kp - task.kpReward, 0, 1 << 30);
      p.kpWeek = _clampInt(p.kpWeek - task.kpReward, 0, 1 << 30);
    }
    notifyListeners();
  }

  void deleteTask(String id) {
    final d = _dataOrNull;
    if (d == null) return;
    d.tasks.removeWhere((t) => t.id == id);
    notifyListeners();
  }

  List<StudyTask> get pendingTasks =>
      tasks.where((t) => !t.completed).toList()
        ..sort((a, b) => a.dueDate.compareTo(b.dueDate));

  List<StudyTask> get completedTasks =>
      tasks.where((t) => t.completed).toList();

  Map<String, double> get subjectBreakdown {
    final Map<String, List<StudyTask>> bySubject = {};
    for (final t in tasks) {
      bySubject.putIfAbsent(t.subject, () => <StudyTask>[]).add(t);
    }
    return bySubject.map((subject, list) {
      final done = list.where((t) => t.completed).length;
      return MapEntry(subject, list.isEmpty ? 0.0 : done / list.length);
    });
  }

  void logStudySessionToday() {
    final p = _profileOrNull;
    final d = _dataOrNull;
    if (p == null || d == null) return;
    if (d.streakLoggedToday) return;
    p.streak += 1;
    d.streakLoggedToday = true;
    _bump(d, 'streak_7', 1);
    _bump(d, 'streak_30', 1);
    _bump(d, 'first_day', 1);
    notifyListeners();
  }

  List<Achievement> get achievements =>
      _dataOrNull?.achievements ?? <Achievement>[];

  void claimAchievement(String id) {
    final d = _dataOrNull;
    if (d == null) return;
    for (final a in d.achievements) {
      if (a.id == id) {
        if (a.isComplete && !a.claimed) {
          a.claimed = true;
          notifyListeners();
        }
        return;
      }
    }
  }

  List<StoreItem> get storeItems => _dataOrNull?.storeItems ?? <StoreItem>[];

  String buyItem(String id) {
    final p = _profileOrNull;
    final d = _dataOrNull;
    if (p == null || d == null) return 'Please log in as a student.';
    for (final item in d.storeItems) {
      if (item.id == id) {
        if (item.owned) return 'Already owned';
        if (p.kp < item.price) return 'Not enough coins';
        p.kp -= item.price;
        item.owned = true;
        notifyListeners();
        return 'Purchased!';
      }
    }
    return 'Item not found';
  }

  List<LeaderboardEntry> get leaderboard {
    final me = _currentUser?.id;
    final list = _students
        .map((s) => LeaderboardEntry(
              name: s.id == me ? '${s.name} (Ikaw)' : s.name,
              gradeLevel: s.gradeLevel,
              kp: s.kp,
              streak: s.streak,
              isYou: s.id == me,
            ))
        .toList();
    list.sort((a, b) => b.kp.compareTo(a.kp));
    return list;
  }

  final List<SchoolClass> _classes = [];
  final List<Assignment> _assignments = [];
  final List<Submission> _submissions = [];
  final List<Announcement> _announcements = [];

  SchoolClass? classById(String id) {
    for (final c in _classes) {
      if (c.id == id) return c;
    }
    return null;
  }

  Assignment? assignmentById(String id) {
    for (final a in _assignments) {
      if (a.id == id) return a;
    }
    return null;
  }

  Submission? submissionFor(String assignmentId, String studentId) {
    for (final s in _submissions) {
      if (s.assignmentId == assignmentId && s.studentId == studentId) {
        return s;
      }
    }
    return null;
  }

  List<Submission> submissionsFor(String assignmentId) =>
      _submissions.where((s) => s.assignmentId == assignmentId).toList();

  String classNameOf(String classId) => classById(classId)?.name ?? 'Class';

  String subjectOfClass(String classId) =>
      classById(classId)?.subject ?? 'Subject';

  String teacherNameOfClass(String classId) {
    final c = classById(classId);
    if (c == null) return 'Teacher';
    for (final u in _users) {
      if (u.id == c.teacherId) return u.name;
    }
    return 'Teacher';
  }

  String? get _teacherId {
    final u = _currentUser;
    if (u == null || !u.isTeacher) return null;
    return u.id;
  }

  List<SchoolClass> get myClasses {
    final t = _teacherId;
    if (t == null) return <SchoolClass>[];
    return _classes.where((c) => c.teacherId == t).toList();
  }

  void createClass({
    required String name,
    required String subject,
    required String strand,
  }) {
    final t = _teacherId;
    if (t == null) return;
    _classes.add(SchoolClass(
      id: _newId('c'),
      teacherId: t,
      name: name.trim(),
      subject: subject,
      strand: strand,
    ));
    notifyListeners();
  }

  void updateClass(String id, {String? name, String? subject, String? strand}) {
    final c = classById(id);
    if (c == null) return;
    if (name != null) c.name = name.trim();
    if (subject != null) c.subject = subject;
    if (strand != null) c.strand = strand;
    notifyListeners();
  }

  void deleteClass(String id) {
    final assignmentIds =
        _assignments.where((a) => a.classId == id).map((a) => a.id).toSet();
    _submissions.removeWhere((s) => assignmentIds.contains(s.assignmentId));
    _assignments.removeWhere((a) => a.classId == id);
    _announcements.removeWhere((n) => n.classId == id);
    _classes.removeWhere((c) => c.id == id);
    notifyListeners();
  }

  List<StudentProfile> studentsOf(String classId) {
    final c = classById(classId);
    final list = <StudentProfile>[];
    if (c == null) return list;
    for (final sid in c.studentIds) {
      final s = studentById(sid);
      if (s != null) list.add(s);
    }
    return list;
  }

  List<StudentProfile> availableStudentsFor(String classId) {
    final c = classById(classId);
    if (c == null) return <StudentProfile>[];
    return _students
        .where((s) => s.strand == c.strand && !c.studentIds.contains(s.id))
        .toList();
  }

  void enrollStudent(String classId, String studentId) {
    final c = classById(classId);
    if (c == null || c.studentIds.contains(studentId)) return;
    c.studentIds.add(studentId);
    notifyListeners();
  }

  void removeStudentFromClass(String classId, String studentId) {
    final c = classById(classId);
    if (c == null) return;
    c.studentIds.remove(studentId);
    notifyListeners();
  }

  List<Assignment> get teacherAssignments {
    final classIds = myClasses.map((c) => c.id).toSet();
    final list =
        _assignments.where((a) => classIds.contains(a.classId)).toList();
    list.sort((a, b) => a.dueDate.compareTo(b.dueDate));
    return list;
  }

  List<Assignment> assignmentsForClass(String classId) {
    final list = _assignments.where((a) => a.classId == classId).toList();
    list.sort((a, b) => a.dueDate.compareTo(b.dueDate));
    return list;
  }

  void createAssignment({
    required String classId,
    required String title,
    required String description,
    required DateTime dueDate,
    required int maxScore,
  }) {
    final t = _teacherId;
    if (t == null) return;
    _assignments.add(Assignment(
      id: _newId('a'),
      classId: classId,
      teacherId: t,
      title: title.trim(),
      description: description.trim(),
      dueDate: dueDate,
      maxScore: maxScore,
    ));
    notifyListeners();
  }

  void updateAssignment(
    String id, {
    String? title,
    String? description,
    DateTime? dueDate,
    int? maxScore,
  }) {
    final a = assignmentById(id);
    if (a == null) return;
    if (title != null) a.title = title.trim();
    if (description != null) a.description = description.trim();
    if (dueDate != null) a.dueDate = dueDate;
    if (maxScore != null) a.maxScore = maxScore;
    notifyListeners();
  }

  void deleteAssignment(String id) {
    _submissions.removeWhere((s) => s.assignmentId == id);
    _assignments.removeWhere((a) => a.id == id);
    notifyListeners();
  }

  void gradeSubmission({
    required String assignmentId,
    required String studentId,
    required int score,
    required String feedback,
  }) {
    final a = assignmentById(assignmentId);
    final s = submissionFor(assignmentId, studentId);
    if (a == null || s == null) return;
    s.score = _clampInt(score, 0, a.maxScore);
    s.feedback = feedback.trim();
    notifyListeners();
  }

  List<GradingItem> get needsGrading {
    final items = <GradingItem>[];
    for (final a in teacherAssignments) {
      final c = classById(a.classId);
      if (c == null) continue;
      for (final s in _submissions) {
        if (s.assignmentId != a.id || s.isGraded) continue;
        if (!c.studentIds.contains(s.studentId)) continue;
        final stu = studentById(s.studentId);
        if (stu == null) continue;
        items.add(GradingItem(assignment: a, submission: s, student: stu));
      }
    }
    items.sort(
        (x, y) => x.submission.submittedAt.compareTo(y.submission.submittedAt));
    return items;
  }

  List<StudentProfile> get myStudents {
    final seen = <String>{};
    final list = <StudentProfile>[];
    for (final c in myClasses) {
      for (final s in studentsOf(c.id)) {
        if (seen.add(s.id)) list.add(s);
      }
    }
    return list;
  }

  StudentStats statsFor(String studentId, {String? classId}) {
    var assigned = 0;
    var submitted = 0;
    var graded = 0;
    var percentSum = 0.0;
    for (final a in teacherAssignments) {
      if (classId != null && a.classId != classId) continue;
      final c = classById(a.classId);
      if (c == null || !c.studentIds.contains(studentId)) continue;
      assigned++;
      final s = submissionFor(a.id, studentId);
      if (s != null) {
        submitted++;
        if (s.isGraded && a.maxScore > 0) {
          graded++;
          percentSum += (s.score! / a.maxScore) * 100;
        }
      }
    }
    return StudentStats(
      assigned: assigned,
      submitted: submitted,
      graded: graded,
      averagePercent: graded == 0 ? null : percentSum / graded,
    );
  }

  List<Announcement> announcementsForClass(String classId) {
    final list = _announcements.where((n) => n.classId == classId).toList();
    list.sort((a, b) => b.postedAt.compareTo(a.postedAt));
    return list;
  }

  void postAnnouncement({
    required String classId,
    required String title,
    required String message,
  }) {
    _announcements.add(Announcement(
      id: _newId('n'),
      classId: classId,
      title: title.trim(),
      message: message.trim(),
      postedAt: DateTime.now(),
    ));
    notifyListeners();
  }

  void deleteAnnouncement(String id) {
    _announcements.removeWhere((n) => n.id == id);
    notifyListeners();
  }

  Set<String> get _myClassIds {
    final me = _profileOrNull;
    if (me == null) return <String>{};
    return _classes
        .where((c) => c.studentIds.contains(me.id))
        .map((c) => c.id)
        .toSet();
  }

  List<Assignment> get studentAssignments {
    final ids = _myClassIds;
    final list = _assignments.where((a) => ids.contains(a.classId)).toList();
    list.sort((a, b) => a.dueDate.compareTo(b.dueDate));
    return list;
  }

  Submission? mySubmission(String assignmentId) {
    final me = _profileOrNull;
    if (me == null) return null;
    return submissionFor(assignmentId, me.id);
  }

  int get assignmentsToSubmitCount =>
      studentAssignments.where((a) => mySubmission(a.id) == null).length;

  List<Announcement> get studentAnnouncements {
    final ids = _myClassIds;
    final list = _announcements.where((n) => ids.contains(n.classId)).toList();
    list.sort((a, b) => b.postedAt.compareTo(a.postedAt));
    return list;
  }

  List<MapEntry<Assignment, Submission>> get myGradedWork {
    final result = <MapEntry<Assignment, Submission>>[];
    for (final a in studentAssignments) {
      final s = mySubmission(a.id);
      if (s != null && s.isGraded) result.add(MapEntry(a, s));
    }
    return result;
  }

  String submitAssignment(String assignmentId, {String note = ''}) {
    final p = _profileOrNull;
    final d = _dataOrNull;
    if (p == null || d == null) return 'Please log in as a student.';
    final a = assignmentById(assignmentId);
    if (a == null) return 'Assignment not found.';
    if (submissionFor(assignmentId, p.id) != null) return 'Already submitted.';

    final now = DateTime.now();
    final isLate = now.isAfter(a.dueDate);
    _submissions.add(Submission(
      assignmentId: assignmentId,
      studentId: p.id,
      submittedAt: now,
      note: note.trim(),
    ));
    final reward = isLate ? a.kpReward ~/ 2 : a.kpReward;
    _awardKp(p, d, reward);
    _bump(d, 'tasks_done', 1);
    _bump(d, 'first_day', 1);
    notifyListeners();
    return isLate ? 'Submitted late: +$reward KP' : 'Submitted! +$reward KP';
  }

  void _seed() {
    final now = DateTime.now();

    _users.addAll([
      RegisteredUser(
        id: 'stu_kylie',
        role: UserRole.student,
        name: 'Kylie P.',
        email: 'kylie@smac.edu.ph',
        password: 'study123',
        gradeLevel: 'Grade 11',
        strand: 'STEM',
      ),
      RegisteredUser(
        id: 'tea_reyes',
        role: UserRole.teacher,
        name: 'Ms. Maria Reyes',
        email: 'teacher@smac.edu.ph',
        password: 'teach123',
        subjectSpecialization: 'General Mathematics',
        school: 'St. Matthew Academy of Cavite',
        approved: true,
      ),
    ]);

    _students.addAll([
      StudentProfile(id: 'stu_cela', name: 'Cela A.', gradeLevel: 'Grade 11', strand: 'STEM', kp: 9500, kpWeek: 380, streak: 12),
      StudentProfile(id: 'stu_sofia', name: 'Sofia M.', gradeLevel: 'Grade 11', strand: 'STEM', kp: 8800, kpWeek: 300, streak: 8),
      StudentProfile(id: 'stu_marco', name: 'Marco R.', gradeLevel: 'Grade 12', strand: 'ABM', kp: 8300, kpWeek: 520, streak: 21),
      StudentProfile(id: 'stu_kylie', name: 'Kylie P.', gradeLevel: 'Grade 11', strand: 'STEM', kp: 7950, kpWeek: 450, streak: 5),
      StudentProfile(id: 'stu_gabriel', name: 'Gabriel T.', gradeLevel: 'Grade 12', strand: 'STEM', kp: 7500, kpWeek: 260, streak: 15),
      StudentProfile(id: 'stu_hannah', name: 'Hannah S.', gradeLevel: 'Grade 11', strand: 'HUMSS', kp: 7200, kpWeek: 150, streak: 3),
      StudentProfile(id: 'stu_jeric', name: 'Jeric C.', gradeLevel: 'Grade 12', strand: 'ABM', kp: 7000, kpWeek: 90, streak: 1),
      StudentProfile(id: 'stu_bea', name: 'Bea D.', gradeLevel: 'Grade 11', strand: 'STEM', kp: 6500, kpWeek: 210, streak: 10),
    ]);

    final kylie = StudentData(
      tasks: <StudyTask>[],
      achievements: StudentData.defaultAchievements(),
      storeItems: StudentData.defaultStoreItems(),
    );
    for (final a in kylie.achievements) {
      if (a.id == 'first_day') a.progress = 1;
      if (a.id == 'streak_7') a.progress = 3;
      if (a.id == 'kp_1000') a.progress = 1000;
      if (a.id == 'kp_10000') a.progress = 1200;
    }
    kylie.tasks.addAll([
      StudyTask(
        id: 't${kylie.nextTaskId++}',
        title: 'Finish Algebra problem set',
        subject: 'Mathematics',
        dueDate: now.add(const Duration(days: 1)),
        priority: TaskPriority.high,
      ),
      StudyTask(
        id: 't${kylie.nextTaskId++}',
        title: 'Read Chapter 4: Cell Biology',
        subject: 'Science',
        dueDate: now.add(const Duration(days: 2)),
        priority: TaskPriority.medium,
      ),
      StudyTask(
        id: 't${kylie.nextTaskId++}',
        title: 'Essay draft: "My Study Habits"',
        subject: 'English',
        dueDate: now.add(const Duration(days: 3)),
        priority: TaskPriority.low,
      ),
      StudyTask(
        id: 't${kylie.nextTaskId++}',
        title: 'Review Photosynthesis notes',
        subject: 'Science',
        dueDate: now.subtract(const Duration(days: 1)),
        priority: TaskPriority.medium,
        completed: true,
      ),
    ]);
    _studentData['stu_kylie'] = kylie;

    _classes.addAll([
      SchoolClass(
        id: 'c1',
        teacherId: 'tea_reyes',
        name: 'Gen Math 11-STEM A',
        subject: 'General Mathematics',
        strand: 'STEM',
        studentIds: ['stu_kylie', 'stu_cela', 'stu_sofia', 'stu_bea'],
      ),
      SchoolClass(
        id: 'c2',
        teacherId: 'tea_reyes',
        name: 'Business Math 12-ABM',
        subject: 'Business Mathematics',
        strand: 'ABM',
        studentIds: ['stu_marco', 'stu_jeric'],
      ),
    ]);

    _assignments.addAll([
      Assignment(
        id: 'a1',
        classId: 'c1',
        teacherId: 'tea_reyes',
        title: 'Algebra problem set',
        description: 'Solve items 1 to 20 on page 45 and show your solutions.',
        dueDate: now.add(const Duration(days: 1)),
      ),
      Assignment(
        id: 'a2',
        classId: 'c1',
        teacherId: 'tea_reyes',
        title: 'Functions worksheet',
        description: 'Complete the worksheet on domain and range.',
        dueDate: now.add(const Duration(days: 4)),
      ),
      Assignment(
        id: 'a3',
        classId: 'c1',
        teacherId: 'tea_reyes',
        title: 'Rational functions reviewer',
        description: 'Answer the reviewer before the Friday quiz.',
        dueDate: now.subtract(const Duration(days: 2)),
      ),
      Assignment(
        id: 'a4',
        classId: 'c2',
        teacherId: 'tea_reyes',
        title: 'Ratio and proportion exercises',
        description: 'Answer exercises 1 to 15 in your workbook.',
        dueDate: now.add(const Duration(days: 3)),
      ),
    ]);

    _submissions.addAll([
      Submission(
        assignmentId: 'a3',
        studentId: 'stu_kylie',
        submittedAt: now.subtract(const Duration(days: 3)),
        note: 'Done! Item 7 was tricky.',
        score: 92,
        feedback: 'Great work! Review item 7 on asymptotes.',
      ),
      Submission(
        assignmentId: 'a3',
        studentId: 'stu_sofia',
        submittedAt: now.subtract(const Duration(days: 3)),
        score: 85,
        feedback: 'Good effort. Please show more steps.',
      ),
      Submission(
        assignmentId: 'a3',
        studentId: 'stu_cela',
        submittedAt: now.subtract(const Duration(days: 2, hours: 5)),
        note: 'Submitted before the deadline.',
      ),
      Submission(
        assignmentId: 'a1',
        studentId: 'stu_cela',
        submittedAt: now.subtract(const Duration(hours: 2)),
      ),
      Submission(
        assignmentId: 'a4',
        studentId: 'stu_marco',
        submittedAt: now.subtract(const Duration(hours: 6)),
        note: 'Please check number 12.',
      ),
    ]);

    _announcements.addAll([
      Announcement(
        id: 'n1',
        classId: 'c1',
        title: 'Quiz on Friday',
        message: 'The quiz covers rational functions. Bring a calculator.',
        postedAt: now.subtract(const Duration(hours: 5)),
      ),
      Announcement(
        id: 'n2',
        classId: 'c2',
        title: 'Workbook reminder',
        message: 'Please bring your workbook on Monday.',
        postedAt: now.subtract(const Duration(days: 1)),
      ),
    ]);
  }
}
