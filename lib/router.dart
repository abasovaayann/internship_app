// ignore_for_file: unnecessary_underscores

import 'package:go_router/go_router.dart';

import 'services/auth_service.dart';
import 'features/auth/login_page.dart';
import 'features/auth/register_page.dart';
import 'features/dashboard/dashboard_page.dart';
import 'features/diary/diary_page.dart';
import 'features/history/history_page.dart';
import 'features/settings/settings_page.dart';

final GoRouter router = GoRouter(
  initialLocation: '/login',
  redirect: (context, state) {
    final loggedIn = AuthService.isLoggedIn;
    final loc = state.matchedLocation;
    final goingAuth = loc == '/login' || loc == '/register';

    if (!loggedIn && !goingAuth) return '/login';
    if (loggedIn && goingAuth) return '/home';

    return null;
  },
  routes: [
    GoRoute(path: '/login', builder: (_, __) => const LoginPage()),
    GoRoute(path: '/register', builder: (_, __) => const RegisterPage()),
    GoRoute(path: '/home', builder: (_, __) => const DashboardPage()),
    GoRoute(path: '/diary', builder: (_, __) => const DiaryPage()),
    GoRoute(path: '/history', builder: (_, __) => const HistoryPage()),
    GoRoute(path: '/settings', builder: (_, __) => const SettingsPage()),
  ],
);
