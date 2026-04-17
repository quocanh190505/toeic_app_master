import 'package:flutter/material.dart';

import '../home/home_screen.dart';
import 'admin_screen.dart';
import 'moderator_screen.dart';
import 'teacher_screen.dart';

Widget homeForRole(String role) {
  switch (role.toLowerCase()) {
    case 'admin':
      return const AdminScreen();
    case 'teacher':
      return const TeacherScreen();
    case 'moderator':
      return const ModeratorScreen();
    default:
      return const HomeScreen();
  }
}
