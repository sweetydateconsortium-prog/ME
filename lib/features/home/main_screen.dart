import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/providers/app_state_provider.dart';
import '../../features/live/live_screen.dart';
import '../../features/programmes/programmes_screen.dart';
import '../../features/reels/reels_screen.dart';
import '../../features/notifications/notifications_screen.dart';
import '../../features/settings/settings_screen.dart';
import '../../shared/widgets/bottom_navigation.dart';

class MainScreen extends StatelessWidget {
  const MainScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<AppStateProvider>(
      builder: (context, appState, child) {
        return Scaffold(
          body: IndexedStack(
            index: appState.getScreenIndex(appState.currentScreen),
            children: const [
              LiveScreen(),
              ProgrammesScreen(),
              ReelsScreen(),
              SettingsScreen(),
            ],
          ),
          bottomNavigationBar: const CustomBottomNavigation(),
        );
      },
    );
  }
}