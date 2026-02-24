import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:internship_app/features/auth/login_page.dart';

/// A minimal router that provides GoRouter context without real navigation.
GoRouter _testRouter() => GoRouter(
  initialLocation: '/login',
  routes: [
    GoRoute(path: '/login', builder: (_, __) => const LoginPage()),
    GoRoute(
      path: '/home',
      builder: (_, __) => const Scaffold(body: Text('Home')),
    ),
    GoRoute(
      path: '/register',
      builder: (_, __) => const Scaffold(body: Text('Register')),
    ),
  ],
);

Widget _wrap() => MaterialApp.router(routerConfig: _testRouter());

/// Give the test a wider surface so the "Don't have an account?" Row
/// doesn't overflow (the default 800×600 is enough width but height matters
/// for scroll; 480×900 mirrors a tall narrow phone comfortably).
const _testSize = Size(480, 900);

/// Applies a fixed screen size to [tester] so the login page doesn't overflow.
void _setTestSize(WidgetTester tester) {
  tester.view.physicalSize = _testSize;
  tester.view.devicePixelRatio = 1.0;
  addTearDown(tester.view.resetPhysicalSize);
  addTearDown(tester.view.resetDevicePixelRatio);
}

void main() {
  group('LoginPage — widget tests', () {
    testWidgets('renders email and password fields', (tester) async {
      _setTestSize(tester);
      await tester.pumpWidget(_wrap());
      await tester.pumpAndSettle();

      expect(find.byType(TextFormField), findsNWidgets(2));
      expect(find.text('Welcome back'), findsOneWidget);
    });

    testWidgets('shows email required error for empty email', (tester) async {
      _setTestSize(tester);
      await tester.pumpWidget(_wrap());
      await tester.pumpAndSettle();

      // Tap Log In without filling anything
      await tester.tap(find.text('Log In'));
      await tester.pumpAndSettle();

      expect(find.text('Email is required'), findsOneWidget);
    });

    testWidgets('shows invalid email error for bad format', (tester) async {
      _setTestSize(tester);
      await tester.pumpWidget(_wrap());
      await tester.pumpAndSettle();

      await tester.enterText(find.byType(TextFormField).first, 'notanemail');
      await tester.tap(find.text('Log In'));
      await tester.pumpAndSettle();

      expect(find.text('Enter a valid email'), findsOneWidget);
    });

    testWidgets('shows password too short error', (tester) async {
      _setTestSize(tester);
      await tester.pumpWidget(_wrap());
      await tester.pumpAndSettle();

      // Fill valid email so only password triggers error
      await tester.enterText(
        find.byType(TextFormField).first,
        'test@email.com',
      );
      await tester.enterText(find.byType(TextFormField).last, 'ab');
      await tester.tap(find.text('Log In'));
      await tester.pumpAndSettle();

      expect(find.text('Minimum 4 characters'), findsOneWidget);
    });

    testWidgets('contains a link to the register page', (tester) async {
      _setTestSize(tester);
      await tester.pumpWidget(_wrap());
      await tester.pumpAndSettle();

      expect(find.text('Create one'), findsOneWidget);
    });
  });
}
