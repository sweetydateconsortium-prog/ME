import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/providers/language_provider.dart';
import '../../core/providers/theme_provider.dart';

import '../../core/theme/app_colors.dart';
import '../../core/services/firebase_service.dart';
import '../../core/providers/auth_provider.dart';

class NotificationsScreen extends StatefulWidget {
  const NotificationsScreen({super.key});

  @override
  State<NotificationsScreen> createState() => _NotificationsScreenState();
}

class _NotificationsScreenState extends State<NotificationsScreen> {
  late Future<List<Map<String, dynamic>>> _notificationsFuture;
  late String? _userId;
  bool _loadingMarkAll = false;

  @override
  void initState() {
    super.initState();
    // Get userId from AuthProvider
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final authProvider = context.read<AuthProvider>();
      setState(() {
        _userId = authProvider.user?.uid;
        if (_userId != null) {
          _notificationsFuture =
              FirebaseService().getUserNotifications(_userId!);
        }
      });
    });
  }

  Future<void> _refreshNotifications() async {
    if (_userId != null) {
      setState(() {
        _notificationsFuture = FirebaseService().getUserNotifications(_userId!);
      });
    }
  }

  Future<void> _markAllAsRead(List<Map<String, dynamic>> notifications) async {
    setState(() => _loadingMarkAll = true);
    for (final n in notifications.where((n) => n['read'] == false)) {
      await FirebaseService().markNotificationAsRead(n['id']);
    }
    setState(() => _loadingMarkAll = false);
    await _refreshNotifications();
  }

  @override
  Widget build(BuildContext context) {
    final languageProvider = context.read<LanguageProvider>();
    final themeProvider = context.watch<ThemeProvider>();

    return Scaffold(
      backgroundColor: themeProvider.isDarkMode
          ? AppColors.backgroundDark
          : AppColors.background,
      body: _userId == null
          ? const Center(child: CircularProgressIndicator())
          : FutureBuilder<List<Map<String, dynamic>>>(
              future: _notificationsFuture,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }
                if (snapshot.hasError) {
                  return Center(
                      child: Text(
                          languageProvider.translate('notificationLoadError')));
                }
                final notifications = snapshot.data ?? [];
                final unreadCount =
                    notifications.where((n) => n['read'] == false).length;
                return Column(
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
                                  colors: [Colors.orange, Colors.deepOrange],
                                ),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: const Icon(
                                Icons.notifications,
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
                                    languageProvider.translate('notifications'),
                                    style: TextStyle(
                                      color: themeProvider.isDarkMode
                                          ? Colors.white
                                          : Colors.black,
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  Text(
                                    unreadCount == 0
                                        ? languageProvider.translate('allRead')
                                        : '$unreadCount ${languageProvider.translate(unreadCount > 1 ? 'unreadPlural' : 'unread')}',
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
                            TextButton(
                              onPressed: unreadCount == 0 || _loadingMarkAll
                                  ? null
                                  : () => _markAllAsRead(notifications),
                              child: _loadingMarkAll
                                  ? SizedBox(
                                      width: 16,
                                      height: 16,
                                      child: CircularProgressIndicator(
                                        strokeWidth: 2,
                                        valueColor:
                                            AlwaysStoppedAnimation<Color>(
                                          themeProvider.isDarkMode
                                              ? Colors.white
                                              : Colors.black,
                                        ),
                                      ),
                                    )
                                  : Text(languageProvider
                                      .translate('markAllRead')),
                            ),
                          ],
                        ),
                      ),
                    ),

                    // Notifications list
                    Expanded(
                      child: RefreshIndicator(
                        onRefresh: _refreshNotifications,
                        child: notifications.isEmpty
                            ? ListView(
                                children: [
                                  Padding(
                                    padding: const EdgeInsets.only(top: 80.0),
                                    child: Center(
                                      child: Text(languageProvider
                                          .translate('noNotifications')),
                                    ),
                                  ),
                                ],
                              )
                            : ListView.builder(
                                padding:
                                    const EdgeInsets.symmetric(horizontal: 16),
                                itemCount: notifications.length,
                                itemBuilder: (context, index) {
                                  final notification = notifications[index];
                                  return GestureDetector(
                                    onTap: notification['read'] == false
                                        ? () async {
                                            await FirebaseService()
                                                .markNotificationAsRead(
                                                    notification['id']);
                                            await _refreshNotifications();
                                          }
                                        : null,
                                    child: _buildNotificationCard(
                                        notification, themeProvider.isDarkMode),
                                  );
                                },
                              ),
                      ),
                    ),

                    // Notification settings
                    Container(
                      margin: const EdgeInsets.all(16),
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: themeProvider.isDarkMode
                            ? AppColors.surfaceDark
                            : AppColors.surface,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: themeProvider.isDarkMode
                              ? AppColors.borderDark
                              : AppColors.border,
                        ),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            languageProvider.translate('notificationSettings'),
                            style: TextStyle(
                              color: themeProvider.isDarkMode
                                  ? Colors.white
                                  : Colors.black,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          const SizedBox(height: 12),
                          _buildNotificationSetting(
                            languageProvider.translate('liveServices'),
                            languageProvider.translate('liveServicesDesc'),
                            true,
                            themeProvider.isDarkMode,
                          ),
                          _buildNotificationSetting(
                            languageProvider.translate('newSermons'),
                            languageProvider.translate('newSermonsDesc'),
                            true,
                            themeProvider.isDarkMode,
                          ),
                          _buildNotificationSetting(
                            languageProvider.translate('eventReminders'),
                            languageProvider.translate('eventRemindersDesc'),
                            true,
                            themeProvider.isDarkMode,
                          ),
                          _buildNotificationSetting(
                            languageProvider.translate('prayerMeetings'),
                            languageProvider.translate('prayerMeetingsDesc'),
                            false,
                            themeProvider.isDarkMode,
                          ),
                        ],
                      ),
                    ),
                  ],
                );
              },
            ),
    );
  }

  Widget _buildNotificationCard(
      Map<String, dynamic> notification, bool isDark) {
    final String type = (notification['type'] ?? '').toString();
    final Color color = _notificationColor(type);
    final IconData icon = _notificationIcon(type);
    var languageProvider = LanguageProvider();
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark ? AppColors.surfaceDark : Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: notification['read'] == false
            ? Border.all(color: AppColors.primary.withOpacity(0.3))
            : null,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Icon
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(
              icon,
              color: color,
              size: 20,
            ),
          ),

          const SizedBox(width: 12),

          // Content
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        notification['title'],
                        style: TextStyle(
                          color: isDark ? Colors.white : Colors.black,
                          fontWeight: notification['read'] == false
                              ? FontWeight.w600
                              : FontWeight.w500,
                          fontSize: 14,
                        ),
                      ),
                    ),
                    if (notification['read'] == false)
                      Container(
                        width: 8,
                        height: 8,
                        decoration: const BoxDecoration(
                          color: AppColors.primary,
                          shape: BoxShape.circle,
                        ),
                      ),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  notification['message'],
                  style: TextStyle(
                    color: isDark
                        ? AppColors.textSecondaryDark
                        : AppColors.textSecondary,
                    fontSize: 12,
                    height: 1.4,
                  ),
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Icon(
                      Icons.access_time,
                      size: 12,
                      color: isDark
                          ? AppColors.textSecondaryDark
                          : AppColors.textSecondary,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      '${languageProvider.translate('timeAgo')}${notification['time']}',
                      style: TextStyle(
                        color: isDark
                            ? AppColors.textSecondaryDark
                            : AppColors.textSecondary,
                        fontSize: 10,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Color _notificationColor(String type) {
    switch (type) {
      case 'live_service':
        return Colors.redAccent;
      case 'new_sermon':
        return Colors.blueAccent;
      case 'event_reminder':
        return Colors.orangeAccent;
      default:
        return AppColors.info;
    }
  }

  IconData _notificationIcon(String type) {
    switch (type) {
      case 'live_service':
        return Icons.live_tv;
      case 'new_sermon':
        return Icons.library_books;
      case 'event_reminder':
        return Icons.event_available;
      default:
        return Icons.notifications;
    }
  }

  Widget _buildNotificationSetting(
    String title,
    String description,
    bool value,
    bool isDark,
  ) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    color: isDark ? Colors.white : Colors.black,
                    fontWeight: FontWeight.w500,
                    fontSize: 14,
                  ),
                ),
                Text(
                  description,
                  style: TextStyle(
                    color: isDark
                        ? AppColors.textSecondaryDark
                        : AppColors.textSecondary,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
          Switch(
            value: value,
            onChanged: (newValue) {
              // Handle switch change
            },
            activeColor: AppColors.primary,
          ),
        ],
      ),
    );
  }
}
