import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/providers/auth_provider.dart';
import '../../core/providers/language_provider.dart';
import '../../core/theme/app_colors.dart';
import '../../shared/widgets/custom_button.dart';
import '../../shared/widgets/custom_text_field.dart';
import 'widgets/auth_header.dart';
import 'widgets/social_login_buttons.dart';

class AuthScreen extends StatefulWidget {
  final VoidCallback onAuthSuccess;

  const AuthScreen({
    super.key,
    required this.onAuthSuccess,
  });

  @override
  State<AuthScreen> createState() => _AuthScreenState();
}

class _AuthScreenState extends State<AuthScreen> {
  Future<void> _showForgotPasswordDialog(BuildContext context) async {
    final TextEditingController emailController =
        TextEditingController(text: _emailController.text);
    final formKey = GlobalKey<FormState>();
    bool isLoading = false;
    String? errorMessage;

    await showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              title: const Text('Réinitialiser le mot de passe'),
              content: Form(
                key: formKey,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                        'Entrez votre adresse e-mail pour recevoir un lien de réinitialisation.'),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: emailController,
                      keyboardType: TextInputType.emailAddress,
                      decoration: const InputDecoration(
                        labelText: 'E-mail',
                        prefixIcon: Icon(Icons.email_outlined),
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Veuillez entrer votre e-mail';
                        }
                        if (!RegExp(r'^.+@.+\..+$').hasMatch(value)) {
                          return 'E-mail invalide';
                        }
                        return null;
                      },
                    ),
                    if (errorMessage != null) ...[
                      const SizedBox(height: 8),
                      Text(errorMessage!,
                          style: const TextStyle(color: Colors.red)),
                    ]
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed:
                      isLoading ? null : () => Navigator.of(context).pop(),
                  child: const Text('Annuler'),
                ),
                ElevatedButton(
                  onPressed: isLoading
                      ? null
                      : () async {
                          if (!(formKey.currentState?.validate() ?? false)) return;
                          setState(() => isLoading = true);
                          try {
                            await context
                                .read<AuthProvider>()
                                .sendPasswordResetEmail(
                                    emailController.text.trim());
                            setState(() => isLoading = false);
                            Navigator.of(context).pop();
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                  content: Text(
                                      'Lien de réinitialisation envoyé. Vérifiez votre e-mail.')),
                            );
                          } catch (e) {
                            setState(() {
                              isLoading = false;
                              errorMessage = context
                                      .read<AuthProvider>()
                                      .errorMessage ??
                                  'Erreur lors de l\'envoi du lien. Vérifiez l\'e-mail.';
                            });
                          }
                        },
                  child: isLoading
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(strokeWidth: 2))
                      : const Text('Envoyer'),
                ),
              ],
            );
          },
        );
      },
    );
  }

  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  final _firstNameController = TextEditingController();
  final _lastNameController = TextEditingController();
  final _phoneController = TextEditingController();
  final _cityController = TextEditingController();

  bool _isSignUp = false;
  bool _showPassword = false;
  bool _acceptTerms = false;
  bool _receiveUpdates = true;
  DateTime? _birthDate;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    _firstNameController.dispose();
    _lastNameController.dispose();
    _phoneController.dispose();
    _cityController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer2<AuthProvider, LanguageProvider>(
      builder: (context, authProvider, languageProvider, child) {
        return Scaffold(
          body: Container(
            decoration: const BoxDecoration(
              gradient: AppColors.primaryGradient,
            ),
            child: SafeArea(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    const SizedBox(height: 20),

                    // Header with logo
                    const AuthHeader(),

                    const SizedBox(height: 32),

                    // Auth Form Card
                    Card(
                      elevation: 8,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(24),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            // Form Title
                            Text(
                              _isSignUp
                                  ? 'Créer un compte'
                                  : languageProvider.translate('signIn'),
                              style: Theme.of(context).textTheme.headlineSmall,
                              textAlign: TextAlign.center,
                            ),

                            const SizedBox(height: 8),

                            Text(
                              _isSignUp
                                  ? 'Rejoignez notre communauté de croyants'
                                  : 'Bon retour dans votre voyage spirituel',
                              style: Theme.of(context)
                                  .textTheme
                                  .bodyMedium
                                  ?.copyWith(
                                    color: AppColors.textSecondary,
                                  ),
                              textAlign: TextAlign.center,
                            ),

                            const SizedBox(height: 24),

                            // Auth Form
                            Form(
                              key: _formKey,
                              child: Column(
                                children: [
                                  if (_isSignUp) ...[
                                    // Name fields
                                    Row(
                                      children: [
                                        Expanded(
                                          child: CustomTextField(
                                            controller: _firstNameController,
                                            label: languageProvider
                                                .translate('firstName'),
                                            prefixIcon: Icons.person_outline,
                                            validator: (value) {
                                              if (value?.isEmpty ?? true) {
                                                return 'Prénom requis';
                                              }
                                              return null;
                                            },
                                          ),
                                        ),
                                        const SizedBox(width: 12),
                                        Expanded(
                                          child: CustomTextField(
                                            controller: _lastNameController,
                                            label: languageProvider
                                                .translate('lastName'),
                                            validator: (value) {
                                              if (value?.isEmpty ?? true) {
                                                return 'Nom requis';
                                              }
                                              return null;
                                            },
                                          ),
                                        ),
                                      ],
                                    ),

                                    const SizedBox(height: 16),

                                    // Phone field
                                    CustomTextField(
                                      controller: _phoneController,
                                      label: 'Numéro de téléphone',
                                      prefixIcon: Icons.phone_outlined,
                                      keyboardType: TextInputType.phone,
                                    ),

                                    const SizedBox(height: 16),

                                    // Birth date and city
                                    Row(
                                      children: [
                                        Expanded(
                                          child: InkWell(
                                            onTap: () =>
                                                _selectBirthDate(context),
                                            child: Container(
                                              padding:
                                                  const EdgeInsets.symmetric(
                                                horizontal: 16,
                                                vertical: 12,
                                              ),
                                              decoration: BoxDecoration(
                                                border: Border.all(
                                                    color: AppColors.border),
                                                borderRadius:
                                                    BorderRadius.circular(8),
                                                color:
                                                    AppColors.inputBackground,
                                              ),
                                              child: Row(
                                                children: [
                                                  const Icon(
                                                    Icons
                                                        .calendar_today_outlined,
                                                    color:
                                                        AppColors.textSecondary,
                                                    size: 20,
                                                  ),
                                                  const SizedBox(width: 12),
                                                  Text(
                                                    _birthDate != null
                                                        ? '${_birthDate!.day}/${_birthDate!.month}/${_birthDate!.year}'
                                                        : 'Date de naissance',
                                                    style: TextStyle(
                                                      color: _birthDate != null
                                                          ? AppColors
                                                              .textPrimary
                                                          : AppColors
                                                              .textSecondary,
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ),
                                          ),
                                        ),
                                        const SizedBox(width: 12),
                                        Expanded(
                                          child: CustomTextField(
                                            controller: _cityController,
                                            label: 'Ville',
                                            prefixIcon:
                                                Icons.location_on_outlined,
                                          ),
                                        ),
                                      ],
                                    ),

                                    const SizedBox(height: 16),
                                  ],

                                  // Email field
                                  CustomTextField(
                                    controller: _emailController,
                                    label: languageProvider.translate('email'),
                                    prefixIcon: Icons.email_outlined,
                                    keyboardType: TextInputType.emailAddress,
                                    validator: (value) {
                                      if (value?.isEmpty ?? true) {
                                        return 'Email requis';
                                      }
                                      if (!RegExp(
                                              r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$')
                                          .hasMatch(value!)) {
                                        return 'Email invalide';
                                      }
                                      return null;
                                    },
                                  ),

                                  const SizedBox(height: 16),

                                  // Password field
                                  CustomTextField(
                                    controller: _passwordController,
                                    label:
                                        languageProvider.translate('password'),
                                    prefixIcon: Icons.lock_outline,
                                    obscureText: !_showPassword,
                                    suffixIcon: IconButton(
                                      icon: Icon(
                                        _showPassword
                                            ? Icons.visibility_off
                                            : Icons.visibility,
                                      ),
                                      onPressed: () {
                                        setState(() {
                                          _showPassword = !_showPassword;
                                        });
                                      },
                                    ),
                                    validator: (value) {
                                      if (value?.isEmpty ?? true) {
                                        return 'Mot de passe requis';
                                      }
                                      if (value!.length < 6) {
                                        return 'Au moins 6 caractères';
                                      }
                                      return null;
                                    },
                                  ),

                                  if (_isSignUp) ...[
                                    const SizedBox(height: 16),

                                    // Confirm password
                                    CustomTextField(
                                      controller: _confirmPasswordController,
                                      label: 'Confirmer le mot de passe',
                                      prefixIcon: Icons.lock_outline,
                                      obscureText: !_showPassword,
                                      validator: (value) {
                                        if (value != _passwordController.text) {
                                          return 'Les mots de passe ne correspondent pas';
                                        }
                                        return null;
                                      },
                                    ),

                                    const SizedBox(height: 16),

                                    // Terms and conditions
                                    Row(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Checkbox(
                                          value: _acceptTerms,
                                          onChanged: (value) {
                                            setState(() {
                                              _acceptTerms = value ?? false;
                                            });
                                          },
                                        ),
                                        Expanded(
                                          child: GestureDetector(
                                            onTap: () {
                                              setState(() {
                                                _acceptTerms = !_acceptTerms;
                                              });
                                            },
                                            child: Padding(
                                              padding: const EdgeInsets.only(
                                                  top: 12),
                                              child: RichText(
                                                text: TextSpan(
                                                  style: Theme.of(context)
                                                      .textTheme
                                                      .bodySmall,
                                                  children: [
                                                    const TextSpan(
                                                        text:
                                                            'J\'accepte les '),
                                                    TextSpan(
                                                      text:
                                                          'Conditions d\'utilisation',
                                                      style: TextStyle(
                                                        color: Theme.of(context)
                                                            .primaryColor,
                                                        decoration:
                                                            TextDecoration
                                                                .underline,
                                                      ),
                                                    ),
                                                    const TextSpan(
                                                        text: ' et la '),
                                                    TextSpan(
                                                      text:
                                                          'Politique de confidentialité',
                                                      style: TextStyle(
                                                        color: Theme.of(context)
                                                            .primaryColor,
                                                        decoration:
                                                            TextDecoration
                                                                .underline,
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                              ),
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),

                                    // Email updates checkbox
                                    Row(
                                      children: [
                                        Checkbox(
                                          value: _receiveUpdates,
                                          onChanged: (value) {
                                            setState(() {
                                              _receiveUpdates = value ?? false;
                                            });
                                          },
                                        ),
                                        Expanded(
                                          child: GestureDetector(
                                            onTap: () {
                                              setState(() {
                                                _receiveUpdates =
                                                    !_receiveUpdates;
                                              });
                                            },
                                            child: Padding(
                                              padding: const EdgeInsets.only(
                                                  top: 12),
                                              child: Text(
                                                'Recevoir les mises à jour sur les sermons et événements',
                                                style: Theme.of(context)
                                                    .textTheme
                                                    .bodySmall,
                                              ),
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ],
                                ],
                              ),
                            ),

                            const SizedBox(height: 24),

                            // Submit button
                            CustomButton(
                              text: _isSignUp
                                  ? 'Créer un compte'
                                  : languageProvider.translate('signIn'),
                              onPressed:
                                  authProvider.isLoading ? null : _handleSubmit,
                              isLoading: authProvider.isLoading,
                            ),

                            if (!_isSignUp) ...[
                              const SizedBox(height: 16),

                              // Forgot password
                              TextButton(
                                onPressed: () {
                                  _showForgotPasswordDialog(context);
                                },
                                child: const Text('Mot de passe oublié ?'),
                              ),
                            ],

                            const SizedBox(height: 24),

                            // Divider
                            Row(
                              children: [
                                const Expanded(child: Divider()),
                                Padding(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 16),
                                  child: Text(
                                    'ou continuer avec',
                                    style: Theme.of(context)
                                        .textTheme
                                        .bodySmall
                                        ?.copyWith(
                                          color: AppColors.textSecondary,
                                        ),
                                  ),
                                ),
                                const Expanded(child: Divider()),
                              ],
                            ),

                            const SizedBox(height: 24),

                            // Social login buttons
                            SocialLoginButtons(
                              onGooglePressed: () =>
                                  _handleSocialLogin('google'),
                              onFacebookPressed: () =>
                                  _handleSocialLogin('facebook'),
                            ),

                            const SizedBox(height: 24),

                            // Toggle sign in/up
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text(
                                  _isSignUp
                                      ? 'Vous avez déjà un compte ? '
                                      : 'Vous n\'avez pas de compte ? ',
                                  style: Theme.of(context).textTheme.bodyMedium,
                                ),
                                TextButton(
                                  onPressed: () {
                                    setState(() {
                                      _isSignUp = !_isSignUp;
                                    });
                                  },
                                  child: Text(
                                    _isSignUp ? 'Se connecter' : 'S\'inscrire',
                                  ),
                                ),
                              ],
                            ),

                            // Error message
                            if (authProvider.errorMessage != null) ...[
                              const SizedBox(height: 16),
                              Container(
                                padding: const EdgeInsets.all(12),
                                decoration: BoxDecoration(
                                  color: AppColors.error.withOpacity(0.1),
                                  borderRadius: BorderRadius.circular(8),
                                  border: Border.all(
                                    color: AppColors.error.withOpacity(0.3),
                                  ),
                                ),
                                child: Text(
                                  authProvider.errorMessage!,
                                  style: TextStyle(
                                    color: AppColors.error,
                                    fontSize: 14,
                                  ),
                                  textAlign: TextAlign.center,
                                ),
                              ),
                            ],
                          ],
                        ),
                      ),
                    ),

                    const SizedBox(height: 24),

                    // Guest access button
                    TextButton(
                      onPressed: () {
                        context.read<AuthProvider>().continueAsGuest();
                        widget.onAuthSuccess();
                      },
                      style: TextButton.styleFrom(
                        foregroundColor: Colors.white,
                        backgroundColor: Colors.white.withOpacity(0.1),
                      ),
                      child: Text(
                        context
                            .read<LanguageProvider>()
                            .translate('continueAsGuest'),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Future<void> _selectBirthDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _birthDate ?? DateTime(2000),
      firstDate: DateTime(1900),
      lastDate: DateTime.now(),
    );

    if (picked != null && picked != _birthDate) {
      setState(() {
        _birthDate = picked;
      });
    }
  }

  Future<void> _handleSubmit() async {
    if (!_formKey.currentState!.validate()) return;

    if (_isSignUp && !_acceptTerms) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Vous devez accepter les conditions d\'utilisation'),
        ),
      );
      return;
    }

    final authProvider = context.read<AuthProvider>();
    bool success = false;

    if (_isSignUp) {
      success = await authProvider.signUpWithEmail(
        _emailController.text.trim(),
        _passwordController.text,
        firstName: _firstNameController.text.trim(),
        lastName: _lastNameController.text.trim(),
        phone: _phoneController.text.trim().isNotEmpty
            ? _phoneController.text.trim()
            : null,
        city: _cityController.text.trim().isNotEmpty
            ? _cityController.text.trim()
            : null,
        birthDate: _birthDate,
      );
    } else {
      success = await authProvider.signInWithEmail(
        _emailController.text.trim(),
        _passwordController.text,
      );
    }

    if (success) {
      widget.onAuthSuccess();
    }
  }

  Future<void> _handleSocialLogin(String provider) async {
    final authProvider = context.read<AuthProvider>();
    bool success = false;

    switch (provider) {
      case 'google':
        success = await authProvider.signInWithGoogle();
        break;
      case 'facebook':
        success = await authProvider.signInWithFacebook();
        if (!success) {
          final error = authProvider.errorMessage ??
              'Erreur lors de la connexion avec Facebook';
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(error)),
          );
        }
        break;
    }

    if (success) {
      widget.onAuthSuccess();
    }
  }
}
