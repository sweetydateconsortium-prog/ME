import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
// ...existing code...
import 'package:provider/provider.dart';

import '../providers/auth_provider.dart';
import '../providers/app_state_provider.dart';
import '../../features/splash/splash_screen.dart';
import '../../features/auth/auth_screen.dart';
import '../../features/home/main_screen.dart';
// ...existing code...

class AppRouter {
  static final GoRouter router = GoRouter(
    initialLocation: '/splash',
    redirect: (context, state) {
      final authProvider = context.read<AuthProvider>();
      final appStateProvider = context.read<AppStateProvider>();

      // Show splash screen first
      if (appStateProvider.showSplash) {
        return '/splash';
      }

      // If not authenticated and not on auth screen, redirect to auth
      if (!authProvider.isAuthenticated && state.uri.toString() != '/auth') {
        return '/auth';
      }

      // If authenticated and on auth/splash screen, redirect to main
      if (authProvider.isAuthenticated &&
          (state.uri.toString() == '/auth' ||
              state.uri.toString() == '/splash')) {
        return '/main';
      }

      return null; // No redirect needed
    },
    routes: [
      // ...existing code...
      GoRoute(
        path: '/splash',
        builder: (context, state) => SplashScreen(
          onComplete: () {
            context.read<AppStateProvider>().hideSplash();
            context.go('/auth');
          },
        ),
      ),
      GoRoute(
        path: '/auth',
        builder: (context, state) => AuthScreen(
          onAuthSuccess: () {
            context.go('/main');
          },
        ),
      ),
      GoRoute(
        path: '/main',
        builder: (context, state) => const MainScreen(),
      ),
    ],
  );
}
