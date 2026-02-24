import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:internship_app/core/auth/auth_service.dart';
import 'package:internship_app/core/models/user_model.dart';
import 'package:internship_app/features/dashboard/dashboard_page.dart';

/// A minimal router for testing DashboardPage.
GoRouter _testRouter() => GoRouter(
  initialLocation: '/home',
  routes: [
    GoRoute(path: '/home', builder: (_, __) => const DashboardPage()),
    GoRoute(
      path: '/login',
      builder: (_, __) => const Scaffold(body: Text('Login')),
    ),
    GoRoute(
      path: '/settings',
      builder: (_, __) => const Scaffold(body: Text('Settings')),
    ),
    GoRoute(
      path: '/diary',
      builder: (_, __) => const Scaffold(body: Text('Diary')),
    ),
    GoRoute(
      path: '/history',
      builder: (_, __) => const Scaffold(body: Text('History')),
    ),
  ],
);

Widget _wrap() => MaterialApp.router(routerConfig: _testRouter());

/// Give the test a larger surface to avoid overflow issues.
const _testSize = Size(480, 900);

void _setTestSize(WidgetTester tester) {
  tester.view.physicalSize = _testSize;
  tester.view.devicePixelRatio = 1.0;
  addTearDown(tester.view.resetPhysicalSize);
  addTearDown(tester.view.resetDevicePixelRatio);
}

/// Fake user for tests.
const _fakeUser = AppUser(
  id: 1,
  name: 'Test User',
  email: 'test@example.com',
  university: 'Test University',
);

void main() {
  setUp(() {
    // Set up a logged-in user before each test
    AuthService.isLoggedIn = true;
    AuthService.currentUser = _fakeUser;
  });

  tearDown(() {
    // Clean up after each test
    AuthService.isLoggedIn = false;
    AuthService.currentUser = null;
  });

  group('Dashboard Daily Check-in — widget tests', () {
    testWidgets('renders Daily Check-in title', (tester) async {
      _setTestSize(tester);
      await tester.pumpWidget(_wrap());
      await tester.pumpAndSettle();

      expect(find.text('Daily Check-in'), findsOneWidget);
    });

    testWidgets('displays all three metric labels', (tester) async {
      _setTestSize(tester);
      await tester.pumpWidget(_wrap());
      await tester.pumpAndSettle();

      expect(find.text('Mood Level'), findsOneWidget);
      expect(find.text('Sleep Quality'), findsOneWidget);
      expect(find.text('Energy Level'), findsOneWidget);
    });

    testWidgets('displays percentage values for metrics', (tester) async {
      _setTestSize(tester);
      await tester.pumpWidget(_wrap());
      await tester.pumpAndSettle();

      // Mood Level = 0.70 => 70%
      expect(find.text('70%'), findsOneWidget);
      // Sleep Quality = 0.85 => 85%
      expect(find.text('85%'), findsOneWidget);
      // Energy Level = 0.45 => 45%
      expect(find.text('45%'), findsOneWidget);
    });

    testWidgets('displays progress bars for each metric', (tester) async {
      _setTestSize(tester);
      await tester.pumpWidget(_wrap());
      await tester.pumpAndSettle();

      // There should be 3 LinearProgressIndicators (one per metric)
      expect(find.byType(LinearProgressIndicator), findsNWidgets(3));
    });

    testWidgets('renders the Update Check-in button', (tester) async {
      _setTestSize(tester);
      await tester.pumpWidget(_wrap());
      await tester.pumpAndSettle();

      expect(find.text('Update Check-in'), findsOneWidget);
      expect(find.byType(OutlinedButton), findsOneWidget);
    });

    testWidgets('Update Check-in button opens dialog', (tester) async {
      _setTestSize(tester);
      await tester.pumpWidget(_wrap());
      await tester.pumpAndSettle();

      // Find and tap the Update Check-in button
      final button = find.text('Update Check-in');
      expect(button, findsOneWidget);

      await tester.tap(button);
      await tester.pumpAndSettle();

      // Dialog should appear with title
      expect(find.byType(AlertDialog), findsOneWidget);
      // Dialog title "Daily Check-in" (now appears twice - card title + dialog)
      expect(find.text('Daily Check-in'), findsNWidgets(2));
    });

    testWidgets('dialog shows sliders for each metric', (tester) async {
      _setTestSize(tester);
      await tester.pumpWidget(_wrap());
      await tester.pumpAndSettle();

      await tester.tap(find.text('Update Check-in'));
      await tester.pumpAndSettle();

      // Should have 3 sliders
      expect(find.byType(Slider), findsNWidgets(3));
    });

    testWidgets('dialog Cancel button closes without saving', (tester) async {
      _setTestSize(tester);
      await tester.pumpWidget(_wrap());
      await tester.pumpAndSettle();

      await tester.tap(find.text('Update Check-in'));
      await tester.pumpAndSettle();

      // Tap Cancel
      await tester.tap(find.text('Cancel'));
      await tester.pumpAndSettle();

      // Dialog should be closed
      expect(find.byType(AlertDialog), findsNothing);
      // Values should remain unchanged
      expect(find.text('70%'), findsOneWidget);
    });

    testWidgets('dialog Save button saves and shows snackbar', (tester) async {
      _setTestSize(tester);
      await tester.pumpWidget(_wrap());
      await tester.pumpAndSettle();

      await tester.tap(find.text('Update Check-in'));
      await tester.pumpAndSettle();

      // Tap Save
      await tester.tap(find.text('Save'));
      await tester.pumpAndSettle();

      // Dialog should be closed
      expect(find.byType(AlertDialog), findsNothing);
      // Snackbar should appear
      expect(find.text('Check-in updated!'), findsOneWidget);
    });

    testWidgets('displays metric icons', (tester) async {
      _setTestSize(tester);
      await tester.pumpWidget(_wrap());
      await tester.pumpAndSettle();

      // Mood icon
      expect(find.byIcon(Icons.sentiment_satisfied), findsOneWidget);
      // Sleep icon
      expect(find.byIcon(Icons.nights_stay), findsOneWidget);
      // Energy icon
      expect(find.byIcon(Icons.bolt), findsOneWidget);
    });
  });
}
