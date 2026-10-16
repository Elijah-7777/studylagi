import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../constants.dart';
import '../models/app_user.dart';
import '../state/app_state.dart';
import '../theme/app_theme.dart';
import 'home_shell.dart';
import 'teacher/teacher_pending_screen.dart';
import 'teacher/teacher_shell.dart';

enum AuthMode { login, signup }

class AuthScreen extends StatefulWidget {
  final AuthMode mode;
  const AuthScreen({super.key, required this.mode});

  @override
  State<AuthScreen> createState() => _AuthScreenState();
}

class _AuthScreenState extends State<AuthScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _subjectController = TextEditingController();
  final _schoolController = TextEditingController(text: kSchoolName);

  UserRole _role = UserRole.student;
  String _gradeLevel = kGradeLevels.first;
  String _strand = kStrands.first;
  String? _errorText;

  bool get isSignup => widget.mode == AuthMode.signup;
  bool get _isTeacherForm => isSignup && _role == UserRole.teacher;

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _subjectController.dispose();
    _schoolController.dispose();
    super.dispose();
  }

  void _submit() {
    setState(() => _errorText = null);
    if (!_formKey.currentState!.validate()) return;

    final state = context.read<AppState>();

    if (isSignup) {
      String? error;
      if (_role == UserRole.student) {
        error = state.registerStudent(
          name: _nameController.text,
          email: _emailController.text,
          password: _passwordController.text,
          gradeLevel: _gradeLevel,
          strand: _strand,
        );
      } else {
        error = state.registerTeacher(
          name: _nameController.text,
          email: _emailController.text,
          password: _passwordController.text,
          subjectSpecialization: _subjectController.text,
          school: _schoolController.text,
        );
      }
      if (error != null) {
        setState(() => _errorText = error);
        return;
      }
      _goToDashboard();
      return;
    }

    final result = state.authenticate(
      email: _emailController.text,
      password: _passwordController.text,
    );
    switch (result) {
      case LoginResult.success:
      case LoginResult.pendingApproval:
        _goToDashboard();
        break;
      case LoginResult.notFound:
        setState(() => _errorText =
            'No account found for that email. Try Sign Up instead.');
        break;
      case LoginResult.wrongPassword:
        setState(() => _errorText = 'Incorrect password. Please try again.');
        break;
    }
  }

  void _goToDashboard() {
    final state = context.read<AppState>();
    Widget next;
    if (state.isLoggedIn) {
      next = state.isTeacher ? const TeacherShell() : const HomeShell();
    } else if (state.pendingTeacher != null) {
      next = const TeacherPendingScreen();
    } else {
      return;
    }
    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(builder: (_) => next),
      (route) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(isSignup ? 'Sign Up' : 'Log In')),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                if (isSignup) ...[
                  const Text(
                    'I am a...',
                    style: TextStyle(
                      color: AppColors.textSecondary,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 8),
                  SegmentedButton<UserRole>(
                    segments: const [
                      ButtonSegment(
                        value: UserRole.student,
                        label: Text('Student'),
                        icon: Icon(Icons.school_outlined),
                      ),
                      ButtonSegment(
                        value: UserRole.teacher,
                        label: Text('Teacher'),
                        icon: Icon(Icons.badge_outlined),
                      ),
                    ],
                    selected: {_role},
                    onSelectionChanged: (s) => setState(() {
                      _role = s.first;
                      _errorText = null;
                    }),
                  ),
                  const SizedBox(height: 18),
                  TextFormField(
                    controller: _nameController,
                    decoration: const InputDecoration(labelText: 'Full Name'),
                    validator: (v) =>
                        (v == null || v.trim().isEmpty) ? 'Required' : null,
                  ),
                  const SizedBox(height: 14),
                ],
                TextFormField(
                  controller: _emailController,
                  keyboardType: TextInputType.emailAddress,
                  decoration: const InputDecoration(labelText: 'Email'),
                  validator: (v) => (v == null || !v.contains('@'))
                      ? 'Enter a valid email'
                      : null,
                ),
                const SizedBox(height: 14),
                TextFormField(
                  controller: _passwordController,
                  obscureText: true,
                  decoration: const InputDecoration(labelText: 'Password'),
                  validator: (v) => (v == null || v.length < 4)
                      ? 'At least 4 characters'
                      : null,
                ),
                if (isSignup && _role == UserRole.student) ...[
                  const SizedBox(height: 14),
                  DropdownButtonFormField<String>(
                    initialValue: _gradeLevel,
                    decoration: const InputDecoration(labelText: 'Grade Level'),
                    items: kGradeLevels
                        .map((g) => DropdownMenuItem(value: g, child: Text(g)))
                        .toList(),
                    onChanged: (v) =>
                        setState(() => _gradeLevel = v ?? _gradeLevel),
                  ),
                  const SizedBox(height: 14),
                  DropdownButtonFormField<String>(
                    initialValue: _strand,
                    decoration: const InputDecoration(labelText: 'Strand'),
                    items: kStrands
                        .map((s) => DropdownMenuItem(value: s, child: Text(s)))
                        .toList(),
                    onChanged: (v) => setState(() => _strand = v ?? _strand),
                  ),
                ],
                if (_isTeacherForm) ...[
                  const SizedBox(height: 14),
                  TextFormField(
                    controller: _subjectController,
                    decoration: const InputDecoration(
                      labelText: 'Subject Specialization',
                    ),
                    validator: (v) =>
                        (v == null || v.trim().isEmpty) ? 'Required' : null,
                  ),
                  const SizedBox(height: 14),
                  TextFormField(
                    controller: _schoolController,
                    decoration:
                        const InputDecoration(labelText: 'School Affiliation'),
                    validator: (v) =>
                        (v == null || v.trim().isEmpty) ? 'Required' : null,
                  ),
                  const SizedBox(height: 14),
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: AppColors.primary.withValues(alpha: 0.08),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: const Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Icon(Icons.verified_user_outlined,
                            color: AppColors.primary, size: 18),
                        SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            'Teacher accounts are verified by the school '
                            'administrator before the dashboard unlocks.',
                            style: TextStyle(fontSize: 12),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
                if (_errorText != null) ...[
                  const SizedBox(height: 14),
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: AppColors.danger.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.error_outline,
                            color: AppColors.danger, size: 18),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            _errorText!,
                            style: const TextStyle(
                              color: AppColors.danger,
                              fontSize: 13,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
                const SizedBox(height: 28),
                ElevatedButton(
                  onPressed: _submit,
                  child: Text(isSignup ? 'Create Account' : 'Log In'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
