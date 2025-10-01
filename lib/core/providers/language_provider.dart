import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LanguageProvider extends ChangeNotifier {
  static const String _languageKey = 'language_code';
  
  Locale _locale = const Locale('fr'); // Default to French
  bool _isInitialized = false;
  
  Locale get locale => _locale;
  String get languageCode => _locale.languageCode;
  bool get isInitialized => _isInitialized;
  bool get isFrench => _locale.languageCode == 'fr';
  bool get isEnglish => _locale.languageCode == 'en';
  
  LanguageProvider() {
    _loadLanguage();
  }
  
  Future<void> _loadLanguage() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final languageCode = prefs.getString(_languageKey);
      
      if (languageCode != null) {
        _locale = Locale(languageCode);
      }
      
      _isInitialized = true;
      notifyListeners();
    } catch (e) {
      debugPrint('Error loading language: $e');
      _isInitialized = true;
      notifyListeners();
    }
  }
  
  Future<void> setLanguage(String languageCode) async {
    if (_locale.languageCode == languageCode) return;
    
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_languageKey, languageCode);
      
      _locale = Locale(languageCode);
      notifyListeners();
    } catch (e) {
      debugPrint('Error saving language: $e');
    }
  }
  
  Future<void> setFrench() async {
    await setLanguage('fr');
  }
  
  Future<void> setEnglish() async {
    await setLanguage('en');
  }
  
  Future<void> toggleLanguage() async {
    final newLanguage = _locale.languageCode == 'fr' ? 'en' : 'fr';
    await setLanguage(newLanguage);
  }
  
  // Get localized text (simple implementation)
  String translate(String key) {
    return _translations[key]?[_locale.languageCode] ?? key;
  }
  
  // Shorthand for translate
  String t(String key) => translate(key);
}

// Translations map (same as React app)
const Map<String, Map<String, String>> _translations = {
  // Navigation - New Moi Église TV
  'live': {'fr': 'Live', 'en': 'Live'},
  'programs': {'fr': 'Programmes', 'en': 'Programs'},
  'programmes': {'fr': 'Programmes', 'en': 'Programs'},
  'reels': {'fr': 'Reels', 'en': 'Reels'},
  'notifications': {'fr': 'Notifications', 'en': 'Notifications'},
  'settings': {'fr': 'Paramètres', 'en': 'Settings'},
  
  // Common
  'search': {'fr': 'Rechercher', 'en': 'Search'},
  'save': {'fr': 'Enregistrer', 'en': 'Save'},
  'cancel': {'fr': 'Annuler', 'en': 'Cancel'},
  'delete': {'fr': 'Supprimer', 'en': 'Delete'},
  'share': {'fr': 'Partager', 'en': 'Share'},
  'loading': {'fr': 'Chargement...', 'en': 'Loading...'},
  'edit': {'fr': 'Modifier', 'en': 'Edit'},
  'view': {'fr': 'Voir', 'en': 'View'},
  'play': {'fr': 'Jouer', 'en': 'Play'},
  'viewAll': {'fr': 'Voir tout', 'en': 'View All'},
  
  // Splash & Welcome
  'welcomeMessage': {'fr': 'Bienvenue à Moi Église TV', 'en': 'Welcome to Moi Église TV'},
  'slogan': {'fr': 'La réconciliation des peuples avec Dieu', 'en': 'The reconciliation of people with God'},
  
  // Live Screen
  'live_tv': {'fr': 'Moi Église TV Live', 'en': 'Moi Église TV Live'},
  'live_subtitle': {'fr': 'Diffusion en direct', 'en': 'Live broadcast'},
  'stream_error': {'fr': 'Erreur de connexion au flux', 'en': 'Stream connection error'},
  'video_not_supported': {'fr': 'Votre appareil ne supporte pas la lecture vidéo.', 'en': 'Your device does not support video playback.'},
  'retry': {'fr': 'Réessayer', 'en': 'Retry'},
  'current_program': {'fr': 'Programme en cours', 'en': 'Current program'},
  'program_name': {'fr': 'Culte du Matin', 'en': 'Morning Worship'},
  'program_description': {'fr': 'Rejoignez-nous pour un moment de louange et d\'adoration en direct depuis notre église.', 'en': 'Join us for a moment of praise and worship live from our church.'},
  'watch_replay': {'fr': 'Revoir les émissions', 'en': 'Watch replays'},
  'browse_programs': {'fr': 'Voir les programmes', 'en': 'Browse programs'},
  'watch_now': {'fr': 'Regarder', 'en': 'Watch now'},
  
  // Programs Screen
  'programs_subtitle': {'fr': 'Grille des programmes Moi Église TV', 'en': 'Moi Église TV program schedule'},
  'today': {'fr': 'Aujourd\'hui', 'en': 'Today'},
  'tomorrow': {'fr': 'Demain', 'en': 'Tomorrow'},
  'this_week': {'fr': 'Cette semaine', 'en': 'This week'},
  'filter_by_category': {'fr': 'Filtrer par catégorie', 'en': 'Filter by category'},
  'all': {'fr': 'Tout', 'en': 'All'},
  'worship': {'fr': 'Culte', 'en': 'Worship'},
  'teaching': {'fr': 'Enseignement', 'en': 'Teaching'},
  'music': {'fr': 'Musique', 'en': 'Music'},
  'youth': {'fr': 'Jeunesse', 'en': 'Youth'},
  'special': {'fr': 'Spécial', 'en': 'Special'},
  'no_programs': {'fr': 'Aucun programme pour cette sélection', 'en': 'No programs for this selection'},
  'notification_on': {'fr': 'Rappel activé', 'en': 'Reminder set'},
  'set_reminder': {'fr': 'Me rappeler', 'en': 'Remind me'},
  'view_full_schedule': {'fr': 'Voir la grille complète de la semaine', 'en': 'View full weekly schedule'},
  
  // Reels Screen
  'likes': {'fr': 'J\'aime', 'en': 'Likes'},
  'link_copied': {'fr': 'Lien copié dans le presse-papier', 'en': 'Link copied to clipboard'},
  
  // Auth
  'welcome': {'fr': 'Bienvenue', 'en': 'Welcome'},
  'signIn': {'fr': 'Se connecter', 'en': 'Sign In'},
  'signUp': {'fr': 'S\'inscrire', 'en': 'Sign Up'},
  'email': {'fr': 'Email', 'en': 'Email'},
  'password': {'fr': 'Mot de passe', 'en': 'Password'},
  'firstName': {'fr': 'Prénom', 'en': 'First Name'},
  'lastName': {'fr': 'Nom', 'en': 'Last Name'},
  'continueAsGuest': {'fr': 'Continuer en tant qu\'invité', 'en': 'Continue as Guest'},
  
  // Settings
  'account': {'fr': 'Compte', 'en': 'Account'},
  'profile': {'fr': 'Profil', 'en': 'Profile'},
  'darkMode': {'fr': 'Mode sombre', 'en': 'Dark Mode'},
  'language': {'fr': 'Langue', 'en': 'Language'},
  'about': {'fr': 'À propos', 'en': 'About'},
  'support': {'fr': 'Support', 'en': 'Support'},
  'signOut': {'fr': 'Se déconnecter', 'en': 'Sign Out'},
  'shareApp': {'fr': 'Partager l\'app', 'en': 'Share App'},
  'manageAccount': {'fr': 'Gérer votre compte et préférences', 'en': 'Manage your account and preferences'},
  'updatePersonalInfo': {'fr': 'Mettre à jour vos informations personnelles', 'en': 'Update your personal information'},
  'manageNotificationPrefs': {'fr': 'Gérer les préférences de notification', 'en': 'Manage notification preferences'},
  'switchDarkTheme': {'fr': 'Passer au thème sombre', 'en': 'Switch to dark theme'},
  'shareWithFriends': {'fr': 'Partager avec vos amis', 'en': 'Share with your friends'},
  'rateApp': {'fr': 'Évaluer l\'app', 'en': 'Rate App'},
  'helpImprove': {'fr': 'Aidez-nous à améliorer en évaluant l\'app', 'en': 'Help us improve by rating the app'},
  'aboutMoiEglise': {'fr': 'À propos de Moi Église TV', 'en': 'About Moi Église TV'},
  'learnMission': {'fr': 'En savoir plus sur notre mission', 'en': 'Learn more about our mission'},
  'getHelpContact': {'fr': 'Obtenir de l\'aide et nous contacter', 'en': 'Get help and contact us'},
  'editProfile': {'fr': 'Modifier le profil', 'en': 'Edit Profile'},
  
  // Success Messages
  'accountCreated': {'fr': 'Compte créé avec succès!', 'en': 'Account created successfully!'},
  'loggedIn': {'fr': 'Connecté avec succès!', 'en': 'Logged in successfully!'},
  'loggedOut': {'fr': 'Déconnecté avec succès!', 'en': 'Logged out successfully!'},
  'linkCopied': {'fr': 'Lien copié!', 'en': 'Link copied!'},
};