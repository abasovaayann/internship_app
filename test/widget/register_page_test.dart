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
    testWidgets('renders all four input fields', (tester) async {
      await tester.pumpWidget(_wrap());
      await tester.pumpAndSettle();

      // Full Name, University, Email, Password = 4 TextFormFields
      expect(find.byType(TextFormField), findsNWidgets(4));
      expect(find.text('Create Account'), findsOneWidget);
    });

    testWidgets('shows Required error for all empty fields on submit', (
      tester,
    ) async {
      await tester.pumpWidget(_wrap());
      await tester.pumpAndSettle();

      await tester.tap(find.text('Register'));
      await tester.pumpAndSettle();

      // 4 fields × 'Required'
      expect(find.text('Required'), findsNWidgets(4));
    });

    testWidgets('shows a link back to the login page', (tester) async {
      await tester.pumpWidget(_wrap());
      await tester.pumpAndSettle();

      expect(find.text('Already have an account? Log in'), findsOneWidget);
    });
  });
}
