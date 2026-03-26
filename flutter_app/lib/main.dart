import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import 'core/theme/app_theme.dart';
import 'services/audio_service.dart';
import 'services/auth_service.dart';
import 'services/progress_service.dart';
import 'screens/auth/login_screen.dart';
import 'screens/auth/register_screen.dart';
import 'screens/home/home_screen.dart';
import 'screens/practice/practice_screen.dart';
import 'screens/profile/profile_screen.dart';
import 'screens/tests/mock_test_screen.dart';

void main() {
  runApp(const ToeicMasterProApp());
}

class ToeicMasterProApp extends StatelessWidget {
  const ToeicMasterProApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthService()),
        ChangeNotifierProvider(create: (_) => ProgressService()),
        Provider(create: (_) => AudioService()),
      ],
      child: Consumer<AuthService>(
        builder: (context, auth, _) {
          final router = GoRouter(
            initialLocation: '/login',
            refreshListenable: auth,
            redirect: (context, state) {
              final loggedIn = auth.isLoggedIn;
              final goingToLogin = state.matchedLocation == '/login';
              final goingToRegister = state.matchedLocation == '/register';

              if (!loggedIn && !goingToLogin && !goingToRegister) {
                return '/login';
              }

              if (loggedIn && (goingToLogin || goingToRegister)) {
                return '/home';
              }

              return null;
            },
            routes: [
              GoRoute(
                path: '/login',
                builder: (_, __) => const LoginScreen(),
              ),
              GoRoute(
                path: '/register',
                builder: (_, __) => const RegisterScreen(),
              ),
              GoRoute(
                path: '/home',
                builder: (_, __) => const HomeScreen(),
              ),
              GoRoute(
                path: '/practice',
                builder: (_, __) => const PracticeScreen(),
              ),
              GoRoute(
                path: '/tests',
                builder: (_, __) => const MockTestScreen(),
              ),
              GoRoute(
                path: '/profile',
                builder: (_, __) => const ProfileScreen(),
              ),
            ],
          );

          return MaterialApp.router(
            title: 'TOEIC Master Pro',
            debugShowCheckedModeBanner: false,
            theme: AppTheme.lightTheme,
            routerConfig: router,
          );
        },
      ),
    );
  }
}