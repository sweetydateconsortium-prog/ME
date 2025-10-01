import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/providers/app_state_provider.dart';
import '../../core/providers/language_provider.dart';
import '../../core/theme/app_colors.dart';

class CustomBottomNavigation extends StatelessWidget {
  const CustomBottomNavigation({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer2<AppStateProvider, LanguageProvider>(
      builder: (context, appState, language, child) {
        final items = [
          _NavigationItem(
            icon: Icons.tv,
            label: language.translate('live'),
            screen: AppScreen.live,
          ),
          _NavigationItem(
            icon: Icons.calendar_today_outlined,
            label: language.translate('programmes'),
            screen: AppScreen.programmes,
          ),
          _NavigationItem(
            icon: Icons.play_circle_outline,
            label: language.translate('reels'),
            screen: AppScreen.reels,
          ),
          _NavigationItem(
            icon: Icons.settings_outlined,
            label: language.translate('settings'),
            screen: AppScreen.settings,
          ),
        ];

        return Container(
          decoration: BoxDecoration(
            color: Theme.of(context).scaffoldBackgroundColor,
            border: Border(
              top: BorderSide(
                color: Theme.of(context).dividerColor.withOpacity(0.2),
              ),
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.1),
                blurRadius: 8,
                offset: const Offset(0, -2),
              ),
            ],
          ),
          child: SafeArea(
            child: Container(
              height: 60,
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: items.map((item) {
                  final isSelected = appState.currentScreen == item.screen;
                  return Expanded(
                    child: InkWell(
                      onTap: () => appState.navigateToScreen(item.screen),
                      borderRadius: BorderRadius.circular(8),
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          vertical: 8,
                          horizontal: 4,
                        ),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              isSelected ? _getFilledIcon(item.icon) : item.icon,
                              color: isSelected
                                  ? AppColors.primary
                                  : Theme.of(context)
                                      .iconTheme
                                      .color
                                      ?.withOpacity(0.6),
                              size: 22,
                            ),
                            const SizedBox(height: 2),
                            Text(
                              item.label,
                              style: TextStyle(
                                fontSize: 10,
                                fontWeight: isSelected
                                    ? FontWeight.w600
                                    : FontWeight.normal,
                                color: isSelected
                                    ? AppColors.primary
                                    : Theme.of(context)
                                        .textTheme
                                        .bodySmall
                                        ?.color
                                        ?.withOpacity(0.7),
                              ),
                              textAlign: TextAlign.center,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ],
                        ),
                      ),
                    ),
                  );
                }).toList(),
              ),
            ),
          ),
        );
      },
    );
  }

  IconData _getFilledIcon(IconData outlineIcon) {
    switch (outlineIcon) {
      case Icons.tv:
        return Icons.tv;
      case Icons.calendar_today_outlined:
        return Icons.calendar_today;
      case Icons.play_circle_outline:
        return Icons.play_circle;
      case Icons.settings_outlined:
        return Icons.settings;
      default:
        return outlineIcon;
    }
  }
}

class _NavigationItem {
  final IconData icon;
  final String label;
  final AppScreen screen;

  const _NavigationItem({
    required this.icon,
    required this.label,
    required this.screen,
  });
}