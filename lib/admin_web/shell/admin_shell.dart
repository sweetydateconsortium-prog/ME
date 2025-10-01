import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../core/theme/app_colors.dart';

class AdminShell extends StatelessWidget {
  final Widget child;
  const AdminShell({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    final String location = GoRouterState.of(context).uri.toString();
    final int selectedIndex = _locationToIndex(location);

    return Scaffold(
      body: Row(
        children: [
          NavigationRail(
            backgroundColor: Theme.of(context).colorScheme.surface,
            selectedIndex: selectedIndex,
            onDestinationSelected: (index) {
              final String path = _indexToPath(index);
              if (path.isNotEmpty) context.go(path);
            },
            labelType: NavigationRailLabelType.all,
            selectedIconTheme: const IconThemeData(color: AppColors.primary),
            selectedLabelTextStyle: TextStyle(
              color: Theme.of(context).colorScheme.primary,
              fontWeight: FontWeight.w600,
            ),
            destinations: const [
              NavigationRailDestination(
                icon: Icon(Icons.dashboard_outlined),
                selectedIcon: Icon(Icons.dashboard),
                label: Text('Dashboard'),
              ),
              NavigationRailDestination(
                icon: Icon(Icons.tv_outlined),
                selectedIcon: Icon(Icons.tv),
                label: Text('Programs'),
              ),
              NavigationRailDestination(
                icon: Icon(Icons.videocam_outlined),
                selectedIcon: Icon(Icons.videocam),
                label: Text('Live'),
              ),
              NavigationRailDestination(
                icon: Icon(Icons.movie_outlined),
                selectedIcon: Icon(Icons.movie),
                label: Text('Reels'),
              ),
              NavigationRailDestination(
                icon: Icon(Icons.notifications_outlined),
                selectedIcon: Icon(Icons.notifications),
                label: Text('Notifications'),
              ),
              NavigationRailDestination(
                icon: Icon(Icons.people_alt_outlined),
                selectedIcon: Icon(Icons.people_alt),
                label: Text('Users'),
              ),
              NavigationRailDestination(
                icon: Icon(Icons.settings_outlined),
                selectedIcon: Icon(Icons.settings),
                label: Text('Settings'),
              ),
            ],
          ),
          const VerticalDivider(width: 1),
          Expanded(
            child: Container(
              color: Theme.of(context).colorScheme.background,
              child: child,
            ),
          ),
        ],
      ),
    );
  }

  int _locationToIndex(String location) {
    if (location.startsWith('/admin/dashboard')) return 0;
    if (location.startsWith('/admin/programs')) return 1;
    if (location.startsWith('/admin/live')) return 2;
    if (location.startsWith('/admin/reels')) return 3;
    if (location.startsWith('/admin/notifications')) return 4;
    if (location.startsWith('/admin/users')) return 5;
    if (location.startsWith('/admin/settings')) return 6;
    return 0;
  }

  String _indexToPath(int index) {
    switch (index) {
      case 0:
        return '/admin/dashboard';
      case 1:
        return '/admin/programs';
      case 2:
        return '/admin/live';
      case 3:
        return '/admin/reels';
      case 4:
        return '/admin/notifications';
      case 5:
        return '/admin/users';
      case 6:
        return '/admin/settings';
      default:
        return '/admin/dashboard';
    }
  }
}

