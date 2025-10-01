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
    final languageProvider =
        Provider.of<LanguageProvider>(context, listen: false);

    await showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              title: Text(languageProvider.translate('resetPassword')),
              content: Form(
                key: formKey,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(languageProvider.translate('resetPasswordDesc')),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: emailController,
                      keyboardType: TextInputType.emailAddress,
                      decoration: InputDecoration(
                        labelText: languageProvider.translate('email'),
                        prefixIcon: const Icon(Icons.email_outlined),
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return languageProvider.translate('pleaseEnterEmail');
                        }
                        if (!RegExp(r'^.+@.+\..+$').hasMatch(value)) {
                          return languageProvider.translate('emailInvalid');
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
                  child: Text(languageProvider.translate('cancel')),
                ),
                ElevatedButton(
                  onPressed: isLoading
                      ? null
                      : () async {
                          if (!(formKey.currentState?.validate() ?? false))
                            return;
                          setState(() => isLoading = true);
                          try {
                            await context
                                .read<AuthProvider>()
                                .sendPasswordResetEmail(
                                    emailController.text.trim());
                            setState(() => isLoading = false);
                            Navigator.of(context).pop();
                            ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                                content: Text(languageProvider
                                    .translate('resetLinkSent'))));
                          } catch (e) {
                            setState(() {
                              isLoading = false;
                              errorMessage =
                                  languageProvider.translate('resetLinkError');
                            });
                          }
                        },
                  child: Text(languageProvider.translate('send')),
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
                                  ? languageProvider.translate('createAccount')
                                  : languageProvider.translate('signIn'),
                              style: Theme.of(context).textTheme.headlineSmall,
                              textAlign: TextAlign.center,
                            ),

                            const SizedBox(height: 8),

                            Text(
                              _isSignUp
                                  ? languageProvider.translate('joinCommunity')
                                  : languageProvider.translate('welcomeBack'),
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
                                                return languageProvider
                                                    .translate(
                                                        'firstNameRequired');
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
                                                return languageProvider
                                                    .translate(
                                                        'lastNameRequired');
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
                                      label:
                                          languageProvider.translate('phone'),
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
                                                        : languageProvider
                                                            .translate(
                                                                'birthDate'),
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
                                            label: languageProvider
                                                .translate('city'),
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
                                        return languageProvider
                                            .translate('emailRequired');
                                      }
                                      if (!RegExp(
                                              r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$')
                                          .hasMatch(value!)) {
                                        return languageProvider
                                            .translate('emailInvalid');
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
                                        return languageProvider
                                            .translate('passwordRequired');
                                      }
                                      if (value!.length < 6) {
                                        return languageProvider
                                            .translate('passwordMinLength');
                                      }
                                      return null;
                                    },
                                  ),

                                  if (_isSignUp) ...[
                                    const SizedBox(height: 16),

                                    // Confirm password
                                    CustomTextField(
                                      controller: _confirmPasswordController,
                                      label: languageProvider
                                          .translate('confirmPassword'),
                                      prefixIcon: Icons.lock_outline,
                                      obscureText: !_showPassword,
                                      validator: (value) {
                                        if (value != _passwordController.text) {
                                          return languageProvider
                                              .translate('passwordMismatch');
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
                                                    TextSpan(
                                                      text: languageProvider
                                                          .translate(
                                                              'acceptTerms'),
                                                    ),
                                                    TextSpan(
                                                      text: languageProvider
                                                          .translate(
                                                              'termsOfUse'),
                                                      style: TextStyle(
                                                        color: Theme.of(context)
                                                            .primaryColor,
                                                        decoration:
                                                            TextDecoration
                                                                .underline,
                                                      ),
                                                    ),
                                                    TextSpan(
                                                        text: languageProvider
                                                            .translate('and')),
                                                    TextSpan(
                                                      text: languageProvider
                                                          .translate(
                                                              'privacyPolicy'),
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
                                                languageProvider.translate(
                                                    'receiveUpdates'),
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
                                  ? languageProvider.translate('createAccount')
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
                                child: Text(languageProvider
                                    .translate('forgotPassword')),
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
                                    languageProvider
                                        .translate('orContinueWith'),
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
                                      ? languageProvider
                                          .translate('alreadyHaveAccount')
                                      : languageProvider
                                          .translate('dontHaveAccount'),
                                  style: Theme.of(context).textTheme.bodyMedium,
                                ),
                                TextButton(
                                  onPressed: () {
                                    setState(() {
                                      _isSignUp = !_isSignUp;
                                    });
                                  },
                                  child: Text(
                                    _isSignUp
                                        ? languageProvider.translate('signIn')
                                        : languageProvider.translate('signUp'),
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
    final languageProvider = LanguageProvider();
    if (!_formKey.currentState!.validate()) return;

    if (_isSignUp && !_acceptTerms) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(languageProvider.translate('mustAcceptTerms'))),
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
        if (!success) {}
        break;
    }

    if (success) {
      widget.onAuthSuccess();
    }
  }
}
