import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../shell/admin_shell.dart';
import 'package:provider/provider.dart';
import '../providers/admin_auth_provider.dart';
import '../screens/login_screen.dart';
import '../screens/dashboard_screen.dart';
import '../screens/programs_screen.dart';
import '../screens/live_screen.dart';
import '../screens/reels_screen.dart';
import '../screens/notifications_screen.dart';
import '../screens/users_screen.dart';
import '../screens/settings_screen.dart';

class AdminRouter {
  static final GoRouter router = GoRouter(
    initialLocation: '/admin/dashboard',
    redirect: (context, state) {
      final auth = context.read<AdminAuthProvider>();
      final bool loggingIn = state.uri.toString() == '/admin/login';

      if (auth.isLoading) return null;
      if (!auth.isAuthenticated) {
        return loggingIn ? null : '/admin/login';
      }
      if (auth.isAuthenticated && !auth.isAdmin) {
        return '/admin/login';
      }
      if (auth.isAuthenticated && auth.isAdmin && loggingIn) {
        return '/admin/dashboard';
      }
      return null;
    },
    routes: [
      GoRoute(
        path: '/admin/login',
        builder: (context, state) => const AdminLoginScreen(),
      ),
      ShellRoute(
        builder: (context, state, child) => AdminShell(child: child),
        routes: [
          GoRoute(
            path: '/admin/dashboard',
            builder: (context, state) => const DashboardScreen(),
          ),
          GoRoute(
            path: '/admin/programs',
            builder: (context, state) => const ProgramsScreen(),
          ),
          GoRoute(
            path: '/admin/live',
            builder: (context, state) => const LiveControlScreen(),
          ),
          GoRoute(
            path: '/admin/reels',
            builder: (context, state) => const ReelsScreen(),
          ),
          GoRoute(
            path: '/admin/notifications',
            builder: (context, state) => const NotificationsAdminScreen(),
          ),
          GoRoute(
            path: '/admin/users',
            builder: (context, state) => const UsersScreen(),
          ),
          GoRoute(
            path: '/admin/settings',
            builder: (context, state) => const SettingsAdminScreen(),
          ),
        ],
      ),
    ],
  );
}

