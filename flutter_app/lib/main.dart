import 'package:flutter/material.dart';

import 'core/theme/app_theme.dart';
import 'models/user_model.dart';
import 'screens/admin/admin_screen.dart';
import 'screens/auth/login_screen.dart';
import 'screens/home/home_screen.dart';
import 'services/auth_service.dart';

void main() {
  runApp(const ToeicApp());
}

class ToeicApp extends StatelessWidget {
  const ToeicApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'TOEIC Master',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      home: const SplashGate(),
    );
  }
}

class SplashGate extends StatelessWidget {
  const SplashGate({super.key});

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<UserModel?>(
      future: AuthService().getStartupUser(),
      builder: (context, snapshot) {
        if (snapshot.connectionState != ConnectionState.done) {
          return const Scaffold(
            body: Center(
              child: CircularProgressIndicator(),
            ),
          );
        }

        if (snapshot.hasError) {
          return const LoginScreen();
        }

        final user = snapshot.data;

        if (user == null) {
          return const LoginScreen();
        }

        if (user.role.toLowerCase() == 'admin') {
          return const AdminScreen();
        }

        return const HomeScreen();
      },
    );
  }
}