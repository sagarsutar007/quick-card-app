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

final GoRouter router = GoRouter(
  initialLocation: '/',
  routes: [
    GoRoute(
      path: '/',
      pageBuilder: (context, state) =>
          _buildSlideTransition(state, const RootScreen()),
    ),
    GoRoute(
      path: '/login',
      pageBuilder: (context, state) =>
          _buildSlideTransition(state, const LoginScreen()),
    ),
    GoRoute(
      path: '/dashboard',
      pageBuilder: (context, state) =>
          _buildSlideTransition(state, const DashboardScreen()),
    ),
    GoRoute(
      path: '/schools',
      pageBuilder: (context, state) =>
          _buildSlideTransition(state, const SchoolListScreen()),
    ),
    GoRoute(
      path: '/school/:id/add-authority',
      pageBuilder: (context, state) {
        final schoolId = int.parse(state.pathParameters['id']!);
        return _buildSlideTransition(
          state,
          AddAuthorityScreen(schoolId: schoolId),
        );
      },
    ),
    GoRoute(
      path: '/school/:id/students',
      pageBuilder: (context, state) {
        final schoolId = state.pathParameters['id']!;
        return _buildSlideTransition(
          state,
          SchoolStudentsScreen(schoolId: int.parse(schoolId)),
        );
      },
    ),
    GoRoute(
      path: '/students',
      builder: (context, state) {
        final status = state.uri.queryParameters['status'];
        return StudentsListScreen(status: status);
      },
    ),
    GoRoute(
      path: '/profile',
      pageBuilder: (context, state) {
        return _buildSlideTransition(state, MyProfileScreen());
      },
    ),
  ],
);

CustomTransitionPage _buildSlideTransition(GoRouterState state, Widget child) {
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
