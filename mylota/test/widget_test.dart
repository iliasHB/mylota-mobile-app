// This is a basic Flutter widget test.
//
// To perform an interaction with a widget in your test, use the WidgetTester
// utility in the flutter_test package. For example, you can send tap and scroll
// gestures. You can also use WidgetTester to find child widgets in the widget
// tree, read text, and verify that the values of widget properties are correct.

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:mylota/main.dart';

void main() {
  testWidgets('Counter increments smoke test', (WidgetTester tester) async {
    // Build our app and trigger a frame.
    await tester.pumpWidget(const MyApp());

    // Verify that our counter starts at 0.
    expect(find.text('0'), findsOneWidget);
    expect(find.text('1'), findsNothing);

    // Tap the '+' icon and trigger a frame.
    await tester.tap(find.byIcon(Icons.add));
    await tester.pump();

    // Verify that our counter has incremented.
    expect(find.text('0'), findsNothing);
    expect(find.text('1'), findsOneWidget);
  });
}



// // This is a basic Flutter widget test.
// //
// // To perform an interaction with a widget in your test, use the WidgetTester
// // utility in the flutter_test package. For example, you can send tap and scroll
// // gestures. You can also use WidgetTester to find child widgets in the widget
// // tree, read text, and verify that the values of widget properties are correct.
//
// import 'package:flutter/material.dart';
// import 'package:flutter_test/flutter_test.dart';
// import 'package:integration_test/integration_test.dart';
//
// import 'package:mylota/main.dart';
// import 'package:mylota/screens/login_page.dart';
//
// void main() {
//   IntegrationTestWidgetsFlutterBinding.ensureInitialized();
//
//   testWidgets('Full app smoke test', (WidgetTester tester) async {
//   //   app.main();
//   //   await tester.pumpAndSettle();
//
//   //   // Example: Find and tap login button
//   //   final loginButton = find.text('Login');
//   //   expect(loginButton, findsOneWidget);
//   //   await tester.tap(loginButton);
//   //   await tester.pumpAndSettle();
//   //
//     // Add more navigation and interaction tests here
//   });
//
//   testWidgets('Counter increments smoke test', (WidgetTester tester) async {
//     // Build our app and trigger a frame.
//     await tester.pumpWidget(const MyApp());
//
//     // Verify that our counter starts at 0.
//     expect(find.text('0'), findsOneWidget);
//     expect(find.text('1'), findsNothing);
//
//     // Tap the '+' icon and trigger a frame.
//     await tester.tap(find.byIcon(Icons.add));
//     await tester.pump();
//
//     // Verify that our counter has incremented.
//     expect(find.text('0'), findsNothing);
//     expect(find.text('1'), findsOneWidget);
//   });
//
//   group('Score Logic', () {
//     test('Score increments when task is correct', () {
//       int score = 0;
//       bool correct = true;
//       if (correct) score++;
//       expect(score, 1);
//     });
//
//     test('Score does not increment when task is incorrect', () {
//       int score = 0;
//       bool correct = false;
//       if (correct) score++;
//       expect(score, 0);
//     });
//   });
//
//   testWidgets('Login page has email and password fields', (WidgetTester tester) async {
//     await tester.pumpWidget(MaterialApp(home: LoginPage()));
//
//     expect(find.byType(TextField), findsNWidgets(2));
//     expect(find.text('Email'), findsOneWidget);
//     expect(find.text('Password'), findsOneWidget);
//   });
// }
