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
  'welcomeMessage': {
    'fr': 'Bienvenue à Moi Église TV',
    'en': 'Welcome to Moi Église TV'
  },
  'slogan': {
    'fr': 'La réconciliation des peuples avec Dieu',
    'en': 'The reconciliation of people with God'
  },

  // Live Screen
  'live_tv': {'fr': 'Moi Église TV Live', 'en': 'Moi Église TV Live'},
  'live_subtitle': {'fr': 'Diffusion en direct', 'en': 'Live broadcast'},
  'stream_error': {
    'fr': 'Erreur de connexion au flux',
    'en': 'Stream connection error'
  },
  'video_not_supported': {
    'fr': 'Votre appareil ne supporte pas la lecture vidéo.',
    'en': 'Your device does not support video playback.'
  },
  'retry': {'fr': 'Réessayer', 'en': 'Retry'},
  'current_program': {'fr': 'Programme en cours', 'en': 'Current program'},
  'program_name': {'fr': 'Culte du Matin', 'en': 'Morning Worship'},
  'program_description': {
    'fr':
        'Rejoignez-nous pour un moment de louange et d\'adoration en direct depuis notre église.',
    'en': 'Join us for a moment of praise and worship live from our church.'
  },
  'watch_replay': {'fr': 'Revoir les émissions', 'en': 'Watch replays'},
  'browse_programs': {'fr': 'Voir les programmes', 'en': 'Browse programs'},
  'watch_now': {'fr': 'Regarder', 'en': 'Watch now'},

  // Programs Screen
  'programs_subtitle': {
    'fr': 'Grille des programmes Moi Église TV',
    'en': 'Moi Église TV program schedule'
  },
  'today': {'fr': 'Aujourd\'hui', 'en': 'Today'},
  'tomorrow': {'fr': 'Demain', 'en': 'Tomorrow'},
  'this_week': {'fr': 'Cette semaine', 'en': 'This week'},
  'filter_by_category': {
    'fr': 'Filtrer par catégorie',
    'en': 'Filter by category'
  },
  'all': {'fr': 'Tout', 'en': 'All'},
  'worship': {'fr': 'Culte', 'en': 'Worship'},
  'teaching': {'fr': 'Enseignement', 'en': 'Teaching'},
  'music': {'fr': 'Musique', 'en': 'Music'},
  'youth': {'fr': 'Jeunesse', 'en': 'Youth'},
  'special': {'fr': 'Spécial', 'en': 'Special'},
  'no_programs': {
    'fr': 'Aucun programme pour cette sélection',
    'en': 'No programs for this selection'
  },
  'notification_on': {'fr': 'Rappel activé', 'en': 'Reminder set'},
  'set_reminder': {'fr': 'Me rappeler', 'en': 'Remind me'},
  'view_full_schedule': {
    'fr': 'Voir la grille complète de la semaine',
    'en': 'View full weekly schedule'
  },

  // Reels Screen
  'likes': {'fr': 'J\'aime', 'en': 'Likes'},
  'link_copied': {
    'fr': 'Lien copié dans le presse-papier',
    'en': 'Link copied to clipboard'
  },

  // Auth
  'welcome': {'fr': 'Bienvenue', 'en': 'Welcome'},
  'signIn': {'fr': 'Se connecter', 'en': 'Sign In'},
  'signUp': {'fr': 'S\'inscrire', 'en': 'Sign Up'},
  'email': {'fr': 'Email', 'en': 'Email'},
  'password': {'fr': 'Mot de passe', 'en': 'Password'},
  'firstName': {'fr': 'Prénom', 'en': 'First Name'},
  'lastName': {'fr': 'Nom', 'en': 'Last Name'},
  'continueAsGuest': {
    'fr': 'Continuer en tant qu\'invité',
    'en': 'Continue as Guest'
  },

  // Settings
  'account': {'fr': 'Compte', 'en': 'Account'},
  'profile': {'fr': 'Profil', 'en': 'Profile'},
  'darkMode': {'fr': 'Mode sombre', 'en': 'Dark Mode'},
  'language': {'fr': 'Langue', 'en': 'Language'},
  'about': {'fr': 'À propos', 'en': 'About'},
  'support': {'fr': 'Support', 'en': 'Support'},
  'signOut': {'fr': 'Se déconnecter', 'en': 'Sign Out'},
  'shareApp': {'fr': 'Partager l\'app', 'en': 'Share App'},
  'manageAccount': {
    'fr': 'Gérer votre compte et préférences',
    'en': 'Manage your account and preferences'
  },
  'updatePersonalInfo': {
    'fr': 'Mettre à jour vos informations personnelles',
    'en': 'Update your personal information'
  },
  'manageNotificationPrefs': {
    'fr': 'Gérer les préférences de notification',
    'en': 'Manage notification preferences'
  },
  'switchDarkTheme': {
    'fr': 'Passer au thème sombre',
    'en': 'Switch to dark theme'
  },
  'shareWithFriends': {
    'fr': 'Partager avec vos amis',
    'en': 'Share with your friends'
  },
  'rateApp': {'fr': 'Évaluer l\'app', 'en': 'Rate App'},
  'helpImprove': {
    'fr': 'Aidez-nous à améliorer en évaluant l\'app',
    'en': 'Help us improve by rating the app'
  },
  'aboutMoiEglise': {
    'fr': 'À propos de Moi Église TV',
    'en': 'About Moi Église TV'
  },
  'learnMission': {
    'fr': 'En savoir plus sur notre mission',
    'en': 'Learn more about our mission'
  },
  'getHelpContact': {
    'fr': 'Obtenir de l\'aide et nous contacter',
    'en': 'Get help and contact us'
  },
  'editProfile': {'fr': 'Modifier le profil', 'en': 'Edit Profile'},

  // Success Messages
  'accountCreated': {
    'fr': 'Compte créé avec succès!',
    'en': 'Account created successfully!'
  },
  'loggedIn': {'fr': 'Connecté avec succès!', 'en': 'Logged in successfully!'},
  'loggedOut': {
    'fr': 'Déconnecté avec succès!',
    'en': 'Logged out successfully!'
  },
  'linkCopied': {'fr': 'Lien copié!', 'en': 'Link copied!'},

  // Auth Screen strings
  'createAccount': {'fr': 'Créer un compte', 'en': 'Create Account'},
  'joinCommunity': {
    'fr': 'Rejoignez notre communauté de croyants',
    'en': 'Join our community of believers'
  },
  'welcomeBack': {
    'fr': 'Bon retour dans votre voyage spirituel',
    'en': 'Welcome back to your spiritual journey'
  },
  'phone': {'fr': 'Numéro de téléphone', 'en': 'Phone Number'},
  'birthDate': {'fr': 'Date de naissance', 'en': 'Birth Date'},
  'city': {'fr': 'Ville', 'en': 'City'},
  'confirmPassword': {
    'fr': 'Confirmer le mot de passe',
    'en': 'Confirm Password'
  },
  'acceptTerms': {'fr': 'J\'accepte les ', 'en': 'I accept the '},
  'termsOfUse': {'fr': 'Conditions d\'utilisation', 'en': 'Terms of Use'},
  'and': {'fr': ' et la ', 'en': ' and '},
  'privacyPolicy': {
    'fr': 'Politique de confidentialité',
    'en': 'Privacy Policy'
  },
  'receiveUpdates': {
    'fr': 'Recevoir les mises à jour sur les sermons et événements',
    'en': 'Receive updates on sermons and events'
  },
  'forgotPassword': {'fr': 'Mot de passe oublié ?', 'en': 'Forgot Password?'},
  'orContinueWith': {'fr': 'ou continuer avec', 'en': 'or continue with'},
  'alreadyHaveAccount': {
    'fr': 'Vous avez déjà un compte ? ',
    'en': 'Already have an account? '
  },
  'dontHaveAccount': {
    'fr': 'Vous n\'avez pas de compte ? ',
    'en': 'Don\'t have an account? '
  },
  'resetPassword': {
    'fr': 'Réinitialiser le mot de passe',
    'en': 'Reset Password'
  },
  'resetPasswordDesc': {
    'fr':
        'Entrez votre adresse e-mail pour recevoir un lien de réinitialisation.',
    'en': 'Enter your email address to receive a reset link.'
  },
  'send': {'fr': 'Envoyer', 'en': 'Send'},
  'resetLinkSent': {
    'fr': 'Lien de réinitialisation envoyé. Vérifiez votre e-mail.',
    'en': 'Reset link sent. Check your email.'
  },
  'resetLinkError': {
    'fr': 'Erreur lors de l\'envoi du lien. Vérifiez l\'e-mail.',
    'en': 'Error sending link. Check the email.'
  },

// Validation messages
  'firstNameRequired': {'fr': 'Prénom requis', 'en': 'First name required'},
  'lastNameRequired': {'fr': 'Nom requis', 'en': 'Last name required'},
  'emailRequired': {'fr': 'Email requis', 'en': 'Email required'},
  'emailInvalid': {'fr': 'Email invalide', 'en': 'Invalid email'},
  'passwordRequired': {'fr': 'Mot de passe requis', 'en': 'Password required'},
  'passwordMinLength': {
    'fr': 'Au moins 6 caractères',
    'en': 'At least 6 characters'
  },
  'passwordMismatch': {
    'fr': 'Les mots de passe ne correspondent pas',
    'en': 'Passwords do not match'
  },
  'mustAcceptTerms': {
    'fr': 'Vous devez accepter les conditions d\'utilisation',
    'en': 'You must accept the terms of use'
  },
  'pleaseEnterEmail': {
    'fr': 'Veuillez entrer votre e-mail',
    'en': 'Please enter your email'
  },

// Live Screen
  'noStreamAvailable': {
    'fr': 'Aucun flux en direct disponible.',
    'en': 'No live stream available.'
  },
  'streamLoadError': {
    'fr': 'Erreur lors du chargement du flux en direct',
    'en': 'Error loading live stream'
  },
  'streamPlayError': {
    'fr': 'Erreur de lecture du flux',
    'en': 'Stream playback error'
  },

// Notifications Screen
  'allRead': {'fr': 'Toutes lues', 'en': 'All read'},
  'unread': {'fr': 'non lue', 'en': 'unread'},
  'unreadPlural': {'fr': 'non lues', 'en': 'unread'},
  'markAllRead': {'fr': 'Tout marquer lu', 'en': 'Mark all read'},
  'noNotifications': {'fr': 'Aucune notification', 'en': 'No notifications'},
  'notificationSettings': {
    'fr': 'Paramètres de notification',
    'en': 'Notification settings'
  },
  'liveServices': {'fr': 'Services en direct', 'en': 'Live services'},
  'liveServicesDesc': {
    'fr': 'Recevoir des alertes pour les services',
    'en': 'Receive alerts for services'
  },
  'newSermons': {'fr': 'Nouveaux sermons', 'en': 'New sermons'},
  'newSermonsDesc': {
    'fr': 'Notifications pour les nouveaux contenus',
    'en': 'Notifications for new content'
  },
  'eventReminders': {'fr': 'Rappels d\'événements', 'en': 'Event reminders'},
  'eventRemindersDesc': {
    'fr': 'Rappels pour les événements à venir',
    'en': 'Reminders for upcoming events'
  },
  'prayerMeetings': {'fr': 'Réunions de prière', 'en': 'Prayer meetings'},
  'prayerMeetingsDesc': {
    'fr': 'Alertes pour les réunions de prière',
    'en': 'Alerts for prayer meetings'
  },
  'timeAgo': {'fr': 'Il y a ', 'en': ' ago'},
  'notificationLoadError': {
    'fr': 'Erreur de chargement des notifications',
    'en': 'Error loading notifications'
  },

// Programs Screen
  'programsSchedule': {
    'fr': 'Grille des programmes Moi Église TV',
    'en': 'Moi Église TV program schedule'
  },
  'filterByCategory': {
    'fr': 'Filtrer par catégorie',
    'en': 'Filter by category'
  },
  'noProgramsAvailable': {
    'fr': 'Aucun programme disponible',
    'en': 'No programs available'
  },
  'programsLoadError': {
    'fr': 'Erreur lors du chargement des programmes',
    'en': 'Error loading programs'
  },

// Reels Screen
  'comments': {'fr': 'Commentaires', 'en': 'Comments'},
  'noComments': {'fr': 'Aucun commentaire', 'en': 'No comments'},
  'addComment': {'fr': 'Ajouter un commentaire...', 'en': 'Add a comment...'},
  'commentsLoadError': {
    'fr': 'Erreur lors du chargement des commentaires',
    'en': 'Error loading comments'
  },
  'commentSendError': {
    'fr': 'Erreur lors de l\'envoi du commentaire',
    'en': 'Error sending comment'
  },
  'user': {'fr': 'Utilisateur', 'en': 'User'},

// Settings Screen
  'manageAccountPrefs': {
    'fr': 'Gérer votre compte et préférences',
    'en': 'Manage your account and preferences'
  },
  'application': {'fr': 'Application', 'en': 'Application'},
  'french': {'fr': 'Français', 'en': 'French'},
  'english': {'fr': 'English', 'en': 'English'},
  'version': {
    'fr': 'Version 1.0.0 • Restez connecté avec Dieu et notre communauté',
    'en': 'Version 1.0.0 • Stay connected with God and our community'
  },
  'discoverApp': {
    'fr':
        'Découvrez Moi Église TV - Restez connecté avec Dieu et notre communauté ! https://moieglise.tv',
    'en':
        'Discover Moi Église TV - Stay connected with God and our community! https://moieglise.tv'
  },
  'welcomeToApp': {
    'fr': 'Bienvenue sur Moi Église TV',
    'en': 'Welcome to Moi Église TV'
  },
  // Reels Screen - Action buttons
  'comment': {'fr': 'Commenter', 'en': 'Comment'},
  'like': {'fr': 'J\'aime', 'en': 'Like'},

// Reels Screen - Share message
  'watchReelMessage': {
    'fr': 'Regardez ce reel sur Moi Église TV: ',
    'en': 'Watch this reel on Moi Église TV: '
  }
};
