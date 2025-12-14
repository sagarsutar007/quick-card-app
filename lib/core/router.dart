import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import 'package:quickcard/features/auth/presentation/screens/login_screen.dart';
import 'package:quickcard/features/auth/presentation/screens/root_screen.dart';
import 'package:quickcard/features/dashboard/presentation/screens/dashboard_screen.dart';
import 'package:quickcard/features/profile/presentation/screens/my_profile_screen.dart';
import 'package:quickcard/features/schools/presentation/screens/school_list_screen.dart';
import 'package:quickcard/features/schools/presentation/screens/school_students_screen.dart';
import 'package:quickcard/features/schools/presentation/screens/add_authority_screen.dart';
import 'package:quickcard/features/schools/presentation/screens/student_list_screen.dart';

import 'app_shell.dart';

final GoRouter router = GoRouter(
  initialLocation: '/',
  routes: [
    GoRoute(
      path: '/',
      pageBuilder: (context, state) => _slide(state, const RootScreen()),
    ),
    GoRoute(
      path: '/login',
      pageBuilder: (context, state) => _slide(state, const LoginScreen()),
    ),
    ShellRoute(
      builder: (context, state, child) {
        return AppShell(location: state.uri.toString(), child: child);
      },
      routes: [
        GoRoute(
          path: '/dashboard',
          pageBuilder: (context, state) =>
              _slide(state, const DashboardScreen()),
        ),

        GoRoute(
          path: '/schools',
          pageBuilder: (context, state) =>
              _slide(state, const SchoolListScreen()),
          routes: [
            GoRoute(
              path: ':id/students',
              pageBuilder: (context, state) {
                final schoolId = int.parse(state.pathParameters['id']!);
                return _slide(state, SchoolStudentsScreen(schoolId: schoolId));
              },
            ),
            GoRoute(
              path: ':id/add-authority',
              pageBuilder: (context, state) {
                final schoolId = int.parse(state.pathParameters['id']!);
                return _slide(state, AddAuthorityScreen(schoolId: schoolId));
              },
            ),
          ],
        ),

        GoRoute(
          path: '/students',
          pageBuilder: (context, state) {
            final status = state.uri.queryParameters['status'];
            return _slide(state, StudentsListScreen(status: status));
          },
        ),

        GoRoute(
          path: '/profile',
          pageBuilder: (context, state) =>
              _slide(state, const MyProfileScreen()),
        ),
      ],
    ),
  ],
);

CustomTransitionPage _slide(GoRouterState state, Widget child) {
  return CustomTransitionPage(
    key: state.pageKey,
    child: child,
    transitionsBuilder: (context, animation, secondaryAnimation, child) {
      const begin = Offset(1.0, 0.0);
      const end = Offset.zero;
      const curve = Curves.easeInOut;

      final tween = Tween(
        begin: begin,
        end: end,
      ).chain(CurveTween(curve: curve));

      return SlideTransition(position: animation.drive(tween), child: child);
    },
  );
}
