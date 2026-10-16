import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'state/app_state.dart';
import 'theme/app_theme.dart';
import 'screens/welcome_screen.dart';

void main() {
  runApp(const StudyLagiApp());
}

class StudyLagiApp extends StatelessWidget {
  const StudyLagiApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => AppState(),
      child: MaterialApp(
        title: 'StudyLagi',
        debugShowCheckedModeBanner: false,
        theme: AppTheme.theme,
        home: const WelcomeScreen(),
      ),
    );
  }
}
