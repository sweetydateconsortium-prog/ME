import 'package:flutter/material.dart';

enum AppScreen { live, programmes, reels, notifications, settings }

class AppStateProvider extends ChangeNotifier {
  AppScreen _currentScreen = AppScreen.live;
  bool _showSplash = true;
  int _currentReelIndex = 0;
  String? _selectedProgramCategory = 'all';
  String _selectedProgramDay = 'today';
  
  // Getters
  AppScreen get currentScreen => _currentScreen;
  bool get showSplash => _showSplash;
  int get currentReelIndex => _currentReelIndex;
  String? get selectedProgramCategory => _selectedProgramCategory;
  String get selectedProgramDay => _selectedProgramDay;
  
  // Navigation
  void navigateToScreen(AppScreen screen) {
    if (_currentScreen != screen) {
      _currentScreen = screen;
      notifyListeners();
    }
  }
  
  void navigateToLive() => navigateToScreen(AppScreen.live);
  void navigateToProgrammes() => navigateToScreen(AppScreen.programmes);
  void navigateToReels() => navigateToScreen(AppScreen.reels);
  void navigateToNotifications() => navigateToScreen(AppScreen.notifications);
  void navigateToSettings() => navigateToScreen(AppScreen.settings);
  
  // Splash screen
  void hideSplash() {
    _showSplash = false;
    notifyListeners();
  }
  
  // Reels
  void setCurrentReelIndex(int index) {
    if (_currentReelIndex != index) {
      _currentReelIndex = index;
      notifyListeners();
    }
  }
  
  void nextReel(int totalReels) {
    if (_currentReelIndex < totalReels - 1) {
      _currentReelIndex++;
      notifyListeners();
    }
  }
  
  void previousReel() {
    if (_currentReelIndex > 0) {
      _currentReelIndex--;
      notifyListeners();
    }
  }
  
  // Programs
  void setProgramCategory(String? category) {
    if (_selectedProgramCategory != category) {
      _selectedProgramCategory = category;
      notifyListeners();
    }
  }
  
  void setProgramDay(String day) {
    if (_selectedProgramDay != day) {
      _selectedProgramDay = day;
      notifyListeners();
    }
  }
  
  // Helper methods
  String getScreenName(AppScreen screen) {
    switch (screen) {
      case AppScreen.live:
        return 'live';
      case AppScreen.programmes:
        return 'programmes';
      case AppScreen.reels:
        return 'reels';
      case AppScreen.notifications:
        return 'notifications';
      case AppScreen.settings:
        return 'settings';
    }
  }
  
  AppScreen getScreenFromName(String name) {
    switch (name.toLowerCase()) {
      case 'live':
        return AppScreen.live;
      case 'programmes':
      case 'programs':
        return AppScreen.programmes;
      case 'reels':
        return AppScreen.reels;
      case 'notifications':
        return AppScreen.notifications;
      case 'settings':
        return AppScreen.settings;
      default:
        return AppScreen.live;
    }
  }
  
  int getScreenIndex(AppScreen screen) {
    switch (screen) {
      case AppScreen.live:
        return 0;
      case AppScreen.programmes:
        return 1;
      case AppScreen.reels:
        return 2;
      case AppScreen.settings:
        return 3;
      default:
        return 0;
    }
  }
  
  AppScreen getScreenFromIndex(int index) {
    switch (index) {
      case 0:
        return AppScreen.live;
      case 1:
        return AppScreen.programmes;
      case 2:
        return AppScreen.reels;
      case 3:
        return AppScreen.settings;
      default:
        return AppScreen.live;
    }
  }
}