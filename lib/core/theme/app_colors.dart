import 'package:flutter/material.dart';

class AppColors {
  // Brand Colors - Moi Église TV
  static const Color primary = Color(0xFF003399); // Bleu dégradé start
  static const Color primaryLight = Color(0xFF3399FF); // Bleu dégradé end
  static const Color accent = Color(0xFFE30613); // Rouge vif
  
  // Light Theme Colors
  static const Color background = Color(0xFFFFFFFF);
  static const Color surface = Color(0xFFF8F9FA);
  static const Color surfaceVariant = Color(0xFFF1F3F4);
  
  // Text Colors Light
  static const Color textPrimary = Color(0xFF1A1A1A);
  static const Color textSecondary = Color(0xFF6B7280);
  static const Color textTertiary = Color(0xFF9CA3AF);
  
  // Border Colors Light
  static const Color border = Color(0xFFE5E7EB);
  static const Color borderLight = Color(0xFFF3F4F6);
  
  // Input Colors Light
  static const Color inputBackground = Color(0xFFF9FAFB);
  
  // Dark Theme Colors
  static const Color backgroundDark = Color(0xFF111827);
  static const Color surfaceDark = Color(0xFF1F2937);
  static const Color surfaceVariantDark = Color(0xFF374151);
  
  // Brand Colors Dark Mode
  static const Color primaryDark = Color(0xFF60A5FA); // Lighter blue for dark mode
  static const Color accentDark = Color(0xFFFF4757); // Slightly lighter red
  
  // Text Colors Dark
  static const Color textPrimaryDark = Color(0xFFF9FAFB);
  static const Color textSecondaryDark = Color(0xFFD1D5DB);
  static const Color textTertiaryDark = Color(0xFF9CA3AF);
  
  // Border Colors Dark
  static const Color borderDark = Color(0xFF374151);
  static const Color borderLightDark = Color(0xFF4B5563);
  
  // Input Colors Dark
  static const Color inputBackgroundDark = Color(0xFF374151);
  
  // Status Colors
  static const Color success = Color(0xFF10B981);
  static const Color warning = Color(0xFFF59E0B);
  static const Color error = Color(0xFFEF4444);
  static const Color info = Color(0xFF3B82F6);
  
  // Gradient Colors
  static const LinearGradient primaryGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [primary, primaryLight],
  );
  
  static const LinearGradient primaryGradientDark = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFF1E3A8A), primaryDark],
  );
  
  // Category Colors for Programs
  static const Color cultColor = Color(0xFF3B82F6); // Blue
  static const Color enseignementColor = Color(0xFF10B981); // Green
  static const Color musiqueColor = Color(0xFF8B5CF6); // Purple
  static const Color jeunesseColor = Color(0xFFF59E0B); // Yellow
  static const Color specialColor = Color(0xFFEF4444); // Red
  static const Color emissionsColor = Color(0xFFF97316); // Orange
  
  // Live Status Colors
  static const Color liveRed = Color(0xFFDC2626);
  static const Color liveRedBackground = Color(0xFFFEE2E2);
  
  // Social Colors
  static const Color googleColor = Color(0xFF4285F4);
  static const Color facebookColor = Color(0xFF1877F2);
  static const Color appleColor = Color(0xFF000000);
  
  // Transparency Helpers
  static Color withOpacity(Color color, double opacity) {
    return color.withOpacity(opacity);
  }
  
  // Category Color Helper
  static Color getCategoryColor(String category) {
    switch (category.toLowerCase()) {
      case 'culte':
        return cultColor;
      case 'enseignement':
        return enseignementColor;
      case 'musique':
        return musiqueColor;
      case 'jeunesse':
        return jeunesseColor;
      case 'special':
        return specialColor;
      case 'emissions':
        return emissionsColor;
      default:
        return textSecondary;
    }
  }
  
  // Category Color with Opacity
  static Color getCategoryColorWithOpacity(String category, {double opacity = 0.1}) {
    return getCategoryColor(category).withOpacity(opacity);
  }
}