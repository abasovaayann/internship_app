// ignore_for_file: unnecessary_underscores

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:internship_app/features/auth/register_page.dart';

GoRouter _testRouter() => GoRouter(
  initialLocation: '/register',
  routes: [
    GoRoute(path: '/register', builder: (_, __) => const RegisterPage()),
    GoRoute(
      path: '/login',
      builder: (_, __) => const Scaffold(body: Text('Login')),
    ),
    GoRoute(
      path: '/home',
      builder: (_, __) => const Scaffold(body: Text('Home')),
    ),
  ],
);

Widget _wrap() => MaterialApp.router(routerConfig: _testRouter());

void main() {
  group('RegisterPage — widget tests', () {
    testWidgets('renders all five input fields', (tester) async {
      await tester.pumpWidget(_wrap());
      await tester.pumpAndSettle();

      // Full Name, University, Email, Password, Confirm Password = 5 TextFormFields
      expect(find.byType(TextFormField), findsNWidgets(5));
      expect(find.text('Create Account'), findsOneWidget);
    });

    testWidgets('shows Required error for all empty fields on submit', (
      tester,
    ) async {
      await tester.pumpWidget(_wrap());
      await tester.pumpAndSettle();

      // Scroll to bring Register button into view
      await tester.drag(
        find.byType(SingleChildScrollView),
        const Offset(0, -200),
      );
      await tester.pumpAndSettle();

      await tester.tap(find.text('Register'));
      await tester.pumpAndSettle();

      // 5 fields × 'Required'
      expect(find.text('Required'), findsNWidgets(5));
    });

    testWidgets('shows a link back to the login page', (tester) async {
      await tester.pumpWidget(_wrap());
      await tester.pumpAndSettle();

      expect(find.text('Already have an account? Log in'), findsOneWidget);
    });
  });
}
