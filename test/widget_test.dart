import 'package:flutter_test/flutter_test.dart';

import 'package:studylagi_mobile/main.dart';

void main() {
  testWidgets('Welcome screen shows Log In and Sign Up buttons', (WidgetTester tester) async {

    await tester.pumpWidget(const StudyLagiApp());

    expect(find.text('Log In'), findsOneWidget);
    expect(find.text('Sign Up'), findsOneWidget);
  });
}
