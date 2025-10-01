import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../core/providers/language_provider.dart';
import '../../../core/theme/app_colors.dart';

class AuthHeader extends StatelessWidget {
  const AuthHeader({super.key});

  @override
  Widget build(BuildContext context) {
    final languageProvider = context.read<LanguageProvider>();

    return Column(
      children: [
        // Logo
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.2),
            borderRadius: BorderRadius.circular(16),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              // "me" part with script font
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFF3366CC), Color(0xFF6699FF)],
                  ),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Text(
                  'me',
                  style: TextStyle(
                    fontFamily: 'Dancing Script',
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    fontStyle: FontStyle.italic,
                    color: Colors.white,
                  ),
                ),
              ),

              const SizedBox(width: 8),

              // "Tv" part with sans-serif font
              Transform.rotate(
                angle: 0.2, // ~12 degrees
                child: Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
                  decoration: BoxDecoration(
                    color: AppColors.accent,
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: const Text(
                    'Tv',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),

        const SizedBox(height: 16),

        // App Title
        Text(
          languageProvider.translate('welcomeToApp'),
          style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
          textAlign: TextAlign.center,
        ),

        const SizedBox(height: 8),

        // Slogan
        Text(
          languageProvider.translate('slogan'),
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: Colors.white.withOpacity(0.9),
              ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }
}
