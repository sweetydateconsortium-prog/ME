import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ThemeProvider extends ChangeNotifier {
  static const String _themeKey = 'theme_mode';
  
  ThemeMode _themeMode = ThemeMode.light;
  bool _isInitialized = false;
  
  ThemeMode get themeMode => _themeMode;
  bool get isDarkMode => _themeMode == ThemeMode.dark;
  bool get isInitialized => _isInitialized;
  
  ThemeProvider() {
    _loadThemeMode();
  }
  
  Future<void> _loadThemeMode() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final themeModeIndex = prefs.getInt(_themeKey);
      
      if (themeModeIndex != null) {
        _themeMode = ThemeMode.values[themeModeIndex];
      } else {
        // Default to system theme if no preference is saved
        _themeMode = ThemeMode.system;
      }
      
      _isInitialized = true;
      notifyListeners();
    } catch (e) {
      debugPrint('Error loading theme mode: $e');
      _isInitialized = true;
      notifyListeners();
    }
  }
  
  Future<void> setThemeMode(ThemeMode themeMode) async {
    if (_themeMode == themeMode) return;
    
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setInt(_themeKey, themeMode.index);
      
      _themeMode = themeMode;
      notifyListeners();
    } catch (e) {
      debugPrint('Error saving theme mode: $e');
    }
  }
  
  Future<void> toggleTheme() async {
    final newThemeMode = _themeMode == ThemeMode.light 
        ? ThemeMode.dark 
        : ThemeMode.light;
    await setThemeMode(newThemeMode);
  }
  
  Future<void> setLightTheme() async {
    await setThemeMode(ThemeMode.light);
  }
  
  Future<void> setDarkTheme() async {
    await setThemeMode(ThemeMode.dark);
  }
  
  Future<void> setSystemTheme() async {
    await setThemeMode(ThemeMode.system);
  }
  
  // Helper to get current brightness based on theme mode and system brightness
  Brightness getCurrentBrightness(BuildContext context) {
    switch (_themeMode) {
      case ThemeMode.light:
        return Brightness.light;
      case ThemeMode.dark:
        return Brightness.dark;
      case ThemeMode.system:
        return MediaQuery.of(context).platformBrightness;
    }
  }
  
  // Helper to check if current theme is dark
  bool isDark(BuildContext context) {
    return getCurrentBrightness(context) == Brightness.dark;
  }
}