import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:share_plus/share_plus.dart';

import '../../core/providers/language_provider.dart';
import '../../core/providers/theme_provider.dart';
import '../../core/providers/auth_provider.dart';
import '../../core/theme/app_colors.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer3<LanguageProvider, ThemeProvider, AuthProvider>(
      builder: (context, languageProvider, themeProvider, authProvider, child) {
        return Scaffold(
          backgroundColor: themeProvider.isDarkMode
              ? AppColors.backgroundDark
              : AppColors.background,
          body: Column(
            children: [
              // Header
              SafeArea(
                child: Container(
                  padding: const EdgeInsets.all(16),
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          gradient: const LinearGradient(
                            colors: [Colors.grey, Colors.blueGrey],
                          ),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: const Icon(
                          Icons.settings,
                          color: Colors.white,
                          size: 24,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              languageProvider.translate('settings'),
                              style: TextStyle(
                                color: themeProvider.isDarkMode
                                    ? Colors.white
                                    : Colors.black,
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            Text(
                              languageProvider.translate('manageAccountPrefs'),
                              style: TextStyle(
                                color: themeProvider.isDarkMode
                                    ? AppColors.textSecondaryDark
                                    : AppColors.textSecondary,
                                fontSize: 14,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Column(
                    children: [
                      // Profile Card
                      if (!authProvider.isGuest)
                        _buildProfileCard(themeProvider.isDarkMode),

                      const SizedBox(height: 16),

                      // Account Section
                      _buildSection(
                        languageProvider.translate('account'),
                        [
                          if (!authProvider.isGuest)
                            _buildSettingItem(
                              Icons.person_outline,
                              languageProvider.translate('profile'),
                              languageProvider.translate('updatePersonalInfo'),
                              () {},
                              themeProvider.isDarkMode,
                            ),
                          _buildSettingItem(
                            Icons.notifications_outlined,
                            languageProvider.translate('notifications'),
                            languageProvider
                                .translate('manageNotificationPrefs'),
                            () {},
                            themeProvider.isDarkMode,
                          ),
                          _buildSettingItem(
                            Icons.dark_mode_outlined,
                            languageProvider.translate('darkMode'),
                            languageProvider.translate('switchDarkTheme'),
                            null,
                            themeProvider.isDarkMode,
                            trailing: Switch(
                              value: themeProvider.isDarkMode,
                              onChanged: (value) {
                                themeProvider.toggleTheme();
                              },
                              activeColor: AppColors.primary,
                            ),
                          ),
                        ],
                        themeProvider.isDarkMode,
                      ),

                      const SizedBox(height: 16),

                      // App Section
                      _buildSection(
                        'Application',
                        [
                          _buildSettingItem(
                            Icons.language_outlined,
                            languageProvider.translate('language'),
                            languageProvider.translate(languageProvider.isFrench
                                ? 'french'
                                : 'english'),
                            null,
                            themeProvider.isDarkMode,
                            trailing: DropdownButton<String>(
                              value: languageProvider.languageCode,
                              items: const [
                                DropdownMenuItem(
                                    value: 'fr', child: Text('🇫🇷 FR')),
                                DropdownMenuItem(
                                    value: 'en', child: Text('🇺🇸 EN')),
                              ],
                              onChanged: (value) {
                                if (value != null) {
                                  languageProvider.setLanguage(value);
                                }
                              },
                              underline: const SizedBox(),
                            ),
                          ),
                          _buildSettingItem(
                            Icons.share_outlined,
                            languageProvider.translate('shareApp'),
                            languageProvider.translate('shareWithFriends'),
                            () => _shareApp(),
                            themeProvider.isDarkMode,
                          ),
                          _buildSettingItem(
                            Icons.star_outline,
                            languageProvider.translate('rateApp'),
                            languageProvider.translate('helpImprove'),
                            () {},
                            themeProvider.isDarkMode,
                          ),
                        ],
                        themeProvider.isDarkMode,
                      ),

                      const SizedBox(height: 16),

                      // About Section
                      _buildSection(
                        languageProvider.translate('about'),
                        [
                          _buildSettingItem(
                            Icons.info_outline,
                            languageProvider.translate('aboutMoiEglise'),
                            languageProvider.translate('learnMission'),
                            () {},
                            themeProvider.isDarkMode,
                          ),
                          _buildSettingItem(
                            Icons.help_outline,
                            languageProvider.translate('support'),
                            languageProvider.translate('getHelpContact'),
                            () {},
                            themeProvider.isDarkMode,
                          ),
                        ],
                        themeProvider.isDarkMode,
                      ),

                      const SizedBox(height: 24),

                      // About App Card
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          gradient: themeProvider.isDarkMode
                              ? const LinearGradient(
                                  colors: [
                                    AppColors.primaryDark,
                                    AppColors.accentDark
                                  ],
                                )
                              : AppColors.primaryGradient,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Column(
                          children: [
                            const Text(
                              'Moi Église TV',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              languageProvider.translate('slogan'),
                              style: TextStyle(
                                color: Colors.white.withOpacity(0.9),
                                fontSize: 12,
                              ),
                              textAlign: TextAlign.center,
                            ),
                            const SizedBox(height: 8),
                            Text(
                              languageProvider.translate('version'),
                              style: TextStyle(
                                color: Colors.white.withOpacity(0.8),
                                fontSize: 10,
                              ),
                              textAlign: TextAlign.center,
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(height: 24),

                      // Logout Button
                      if (!authProvider.isGuest)
                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton.icon(
                            onPressed: () async {
                              await authProvider.signOut();
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppColors.error,
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(vertical: 12),
                            ),
                            icon: const Icon(Icons.logout),
                            label: Text(languageProvider.translate('signOut')),
                          ),
                        ),

                      const SizedBox(height: 24),
                    ],
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildProfileCard(bool isDark) {
    var languageProvider = LanguageProvider();
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark ? AppColors.surfaceDark : Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          Stack(
            children: [
              CircleAvatar(
                radius: 32,
                backgroundColor: AppColors.primary.withOpacity(0.1),
                child: Text(
                  'JD',
                  style: TextStyle(
                    color: AppColors.primary,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              Positioned(
                bottom: 0,
                right: 0,
                child: Container(
                  padding: const EdgeInsets.all(4),
                  decoration: const BoxDecoration(
                    color: AppColors.primary,
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.camera_alt,
                    color: Colors.white,
                    size: 12,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Jean Dupont',
                  style: TextStyle(
                    color: isDark ? Colors.white : Colors.black,
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  'jean.dupont@email.com',
                  style: TextStyle(
                    color: isDark
                        ? AppColors.textSecondaryDark
                        : AppColors.textSecondary,
                    fontSize: 14,
                  ),
                ),
                const SizedBox(height: 4),
                TextButton(
                  onPressed: () {},
                  style: TextButton.styleFrom(
                    padding: EdgeInsets.zero,
                    minimumSize: Size.zero,
                    tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  ),
                  child: Text(
                    languageProvider.translate('editProfile'),
                    style: TextStyle(
                      color: AppColors.primary,
                      fontSize: 12,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSection(String title, List<Widget> items, bool isDark) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 4, bottom: 8),
          child: Text(
            title,
            style: TextStyle(
              color: isDark
                  ? AppColors.textSecondaryDark
                  : AppColors.textSecondary,
              fontSize: 12,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
        Container(
          decoration: BoxDecoration(
            color: isDark ? AppColors.surfaceDark : Colors.white,
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.05),
                blurRadius: 4,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Column(
            children: items.asMap().entries.map((entry) {
              final index = entry.key;
              final item = entry.value;

              return Column(
                children: [
                  item,
                  if (index < items.length - 1)
                    Divider(
                      height: 1,
                      color: isDark ? AppColors.borderDark : AppColors.border,
                    ),
                ],
              );
            }).toList(),
          ),
        ),
      ],
    );
  }

  Widget _buildSettingItem(
    IconData icon,
    String title,
    String subtitle,
    VoidCallback? onTap,
    bool isDark, {
    Widget? trailing,
  }) {
    return ListTile(
      leading: Icon(
        icon,
        color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondary,
      ),
      title: Text(
        title,
        style: TextStyle(
          color: isDark ? Colors.white : Colors.black,
          fontWeight: FontWeight.w500,
        ),
      ),
      subtitle: Text(
        subtitle,
        style: TextStyle(
          color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondary,
          fontSize: 12,
        ),
      ),
      trailing: trailing ??
          (onTap != null
              ? Icon(
                  Icons.chevron_right,
                  color: isDark
                      ? AppColors.textSecondaryDark
                      : AppColors.textSecondary,
                )
              : null),
      onTap: onTap,
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
    );
  }

  void _shareApp() {
    var languageProvider = LanguageProvider();
    Share.share(
      languageProvider.translate('discoverApp'),
      subject: 'Moi Église TV',
    );
  }
}
