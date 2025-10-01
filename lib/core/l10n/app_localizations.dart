import 'package:flutter/material.dart';

class AppLocalizations {
  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  static const List<Locale> supportedLocales = [
    Locale('fr'),
    Locale('en'),
  ];

  static AppLocalizations? of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations);
  }

  final Locale locale;

  AppLocalizations(this.locale);

  // Navigation
  String get live => locale.languageCode == 'fr' ? 'Live' : 'Live';
  String get programs =>
      locale.languageCode == 'fr' ? 'Programmes' : 'Programs';
  String get reels => locale.languageCode == 'fr' ? 'Reels' : 'Reels';
  String get settings =>
      locale.languageCode == 'fr' ? 'Paramètres' : 'Settings';

  // Common
  String get loading =>
      locale.languageCode == 'fr' ? 'Chargement...' : 'Loading...';
  String get retry => locale.languageCode == 'fr' ? 'Réessayer' : 'Retry';
  String get cancel => locale.languageCode == 'fr' ? 'Annuler' : 'Cancel';
  String get save => locale.languageCode == 'fr' ? 'Enregistrer' : 'Save';

  // Auth
  String get signIn => locale.languageCode == 'fr' ? 'Se connecter' : 'Sign In';
  String get signUp => locale.languageCode == 'fr' ? 'S\'inscrire' : 'Sign Up';
  String get email => locale.languageCode == 'fr' ? 'Email' : 'Email';
  String get password =>
      locale.languageCode == 'fr' ? 'Mot de passe' : 'Password';
  String get firstName => locale.languageCode == 'fr' ? 'Prénom' : 'First Name';
  String get lastName => locale.languageCode == 'fr' ? 'Nom' : 'Last Name';
  String get continueAsGuest => locale.languageCode == 'fr'
      ? 'Continuer en tant qu\'invité'
      : 'Continue as Guest';

  // App specific
  String get slogan => locale.languageCode == 'fr'
      ? 'La réconciliation des peuples avec Dieu'
      : 'The reconciliation of people with God';

  String get liveTV =>
      locale.languageCode == 'fr' ? 'Moi Église TV Live' : 'Moi Église TV Live';
  String get liveSubtitle =>
      locale.languageCode == 'fr' ? 'Diffusion en direct' : 'Live broadcast';
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  bool isSupported(Locale locale) => ['fr', 'en'].contains(locale.languageCode);

  @override
  Future<AppLocalizations> load(Locale locale) async {
    return AppLocalizations(locale);
  }

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}
