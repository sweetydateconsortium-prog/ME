import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:timezone/timezone.dart' as tz;

class NotificationService {
  static final NotificationService _instance = NotificationService._internal();
  factory NotificationService() => _instance;
  NotificationService._internal();

  final FirebaseMessaging _firebaseMessaging = FirebaseMessaging.instance;
  final FlutterLocalNotificationsPlugin _localNotifications =
      FlutterLocalNotificationsPlugin();

  String? _fcmToken;
  bool _isInitialized = false;

  String? get fcmToken => _fcmToken;
  bool get isInitialized => _isInitialized;

  // Initialize notification service
  Future<void> initialize() async {
    if (_isInitialized) return;

    try {
      // Request permissions
      await requestPermissions();

      // Initialize local notifications
      await _initializeLocalNotifications();

      // Initialize Firebase messaging
      await _initializeFirebaseMessaging();

      // Setup message handlers
      _setupMessageHandlers();

      _isInitialized = true;
    } catch (e) {
      debugPrint('Error initializing notification service: $e');
    }
  }

  // Request notification permissions
  Future<bool> requestPermissions() async {
    try {
      // Request system notification permissions
      final status = await Permission.notification.request();

      // Request Firebase messaging permissions
      final settings = await _firebaseMessaging.requestPermission(
        alert: true,
        badge: true,
        sound: true,
        provisional: false,
        announcement: false,
        carPlay: false,
        criticalAlert: false,
      );

      return status.isGranted &&
          settings.authorizationStatus == AuthorizationStatus.authorized;
    } catch (e) {
      debugPrint('Error requesting notification permissions: $e');
      return false;
    }
  }

  // Initialize local notifications
  Future<void> _initializeLocalNotifications() async {
    const androidSettings =
        AndroidInitializationSettings('@mipmap/ic_launcher');
    const iosSettings = DarwinInitializationSettings(
      requestAlertPermission: true,
      requestBadgePermission: true,
      requestSoundPermission: true,
    );

    const initSettings = InitializationSettings(
      android: androidSettings,
      iOS: iosSettings,
    );

    await _localNotifications.initialize(
      initSettings,
      onDidReceiveNotificationResponse: _onNotificationTapped,
    );
  }

  // Initialize Firebase messaging
  Future<void> _initializeFirebaseMessaging() async {
    // Get FCM token
    _fcmToken = await _firebaseMessaging.getToken();
    debugPrint('FCM Token: $_fcmToken');

    // Subscribe to topic for all app users
    await _firebaseMessaging.subscribeToTopic('all_users');

    // Listen to token refresh
    _firebaseMessaging.onTokenRefresh.listen((newToken) {
      _fcmToken = newToken;
      debugPrint('FCM Token refreshed: $newToken');
      // ...existing code...
    });
  }

  // Setup message handlers
  void _setupMessageHandlers() {
    // Handle foreground messages
    FirebaseMessaging.onMessage.listen(_handleForegroundMessage);

    // Handle background message taps
    FirebaseMessaging.onMessageOpenedApp.listen(_handleBackgroundMessageTap);

    // Handle app launch from terminated state
    _handleAppLaunchFromNotification();
  }

  // Handle foreground messages
  Future<void> _handleForegroundMessage(RemoteMessage message) async {
    debugPrint('Received foreground message: ${message.messageId}');

    // Show local notification
    await _showLocalNotification(
      title: message.notification?.title ?? '',
      body: message.notification?.body ?? '',
      data: message.data,
    );
  }

  // Handle background message taps
  void _handleBackgroundMessageTap(RemoteMessage message) {
    debugPrint('Background message tapped: ${message.messageId}');
    _handleNotificationAction(message.data);
  }

  // Handle app launch from notification
  Future<void> _handleAppLaunchFromNotification() async {
    final initialMessage = await _firebaseMessaging.getInitialMessage();
    if (initialMessage != null) {
      debugPrint('App launched from notification: ${initialMessage.messageId}');
      _handleNotificationAction(initialMessage.data);
    }
  }

  // Show local notification
  Future<void> _showLocalNotification({
    required String title,
    required String body,
    Map<String, dynamic>? data,
  }) async {
    const androidDetails = AndroidNotificationDetails(
      'moi_eglise_channel',
      'Moi Église TV',
      channelDescription: 'Notifications pour Moi Église TV',
      importance: Importance.high,
      priority: Priority.high,
      icon: '@mipmap/ic_launcher',
    );

    const iosDetails = DarwinNotificationDetails(
      presentAlert: true,
      presentBadge: true,
      presentSound: true,
    );

    const details = NotificationDetails(
      android: androidDetails,
      iOS: iosDetails,
    );

    await _localNotifications.show(
      DateTime.now().millisecondsSinceEpoch.remainder(100000),
      title,
      body,
      details,
      payload: data?.toString(),
    );
  }

  // Handle notification action
  void _handleNotificationAction(Map<String, dynamic> data) {
    final type = data['type'];
    final action = data['action'];

    debugPrint('Handling notification action: $type, $action');

    switch (type) {
      case 'live_service':
        // Navigate to live screen
        break;
      case 'new_sermon':
        // Navigate to programs screen
        break;
      case 'reminder':
        // Navigate to specific program
        break;
      default:
        // Navigate to home
        break;
    }
  }

  // Handle local notification tap
  void _onNotificationTapped(NotificationResponse response) {
    debugPrint('Local notification tapped: ${response.payload}');
    // Handle local notification tap
  }

  // Schedule program reminder
  Future<void> scheduleReminder({
    required String programId,
    required String title,
    required String body,
    required DateTime scheduledTime,
  }) async {
    try {
      const androidDetails = AndroidNotificationDetails(
        'reminders_channel',
        'Rappels de Programmes',
        channelDescription: 'Rappels pour les programmes à venir',
        importance: Importance.high,
        priority: Priority.high,
      );

      const iosDetails = DarwinNotificationDetails();
      const details =
          NotificationDetails(android: androidDetails, iOS: iosDetails);
      // Ensure you have imported: import 'package:timezone/timezone.dart' as tz;
      final tzScheduledTime = tz.TZDateTime.from(scheduledTime, tz.local);

      await _localNotifications.zonedSchedule(
        programId.hashCode,
        title,
        body,
        tzScheduledTime,
        details,
        androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
        uiLocalNotificationDateInterpretation:
            UILocalNotificationDateInterpretation.absoluteTime,
      );
    } catch (e) {
      debugPrint('Error scheduling reminder: $e');
    }
  }

  // Cancel reminder
  Future<void> cancelReminder(String programId) async {
    try {
      await _localNotifications.cancel(programId.hashCode);
    } catch (e) {
      debugPrint('Error canceling reminder: $e');
    }
  }

  // Subscribe to topic
  Future<void> subscribeToTopic(String topic) async {
    try {
      await _firebaseMessaging.subscribeToTopic(topic);
      debugPrint('Subscribed to topic: $topic');
    } catch (e) {
      debugPrint('Error subscribing to topic: $e');
    }
  }

  // Unsubscribe from topic
  Future<void> unsubscribeFromTopic(String topic) async {
    try {
      await _firebaseMessaging.unsubscribeFromTopic(topic);
      debugPrint('Unsubscribed from topic: $topic');
    } catch (e) {
      debugPrint('Error unsubscribing from topic: $e');
    }
  }

  // Send token to backend
  Future<void> sendTokenToBackend(String userId) async {
    if (_fcmToken != null) {
      try {
        // Send token to your backend
        final backendUrl =
            const String.fromEnvironment('BACKEND_API_URL', defaultValue: '');
        if (backendUrl.isEmpty) {
          debugPrint(
              'No BACKEND_API_URL set in environment. Skipping FCM token send.');
          return;
        }
        final url = Uri.parse('$backendUrl/api/user/fcm-token');
        final response = await http.post(
          url,
          headers: {'Content-Type': 'application/json'},
          body: '{"userId": "$userId", "token": "$_fcmToken"}',
        );
        if (response.statusCode == 200) {
          debugPrint('FCM token sent to backend successfully.');
        } else {
          debugPrint(
              'Failed to send FCM token to backend: \\${response.statusCode}');
        }
      } catch (e) {
        debugPrint('Error sending token to backend: $e');
      }
    }
  }

  // Update notification preferences
  Future<void> updateNotificationPreferences({
    required bool liveServices,
    required bool newSermons,
    required bool events,
    required bool prayerMeetings,
    required bool testimonies,
  }) async {
    try {
      // Subscribe/unsubscribe from topics based on preferences
      if (liveServices) {
        await subscribeToTopic('live_services');
      } else {
        await unsubscribeFromTopic('live_services');
      }

      if (newSermons) {
        await subscribeToTopic('new_sermons');
      } else {
        await unsubscribeFromTopic('new_sermons');
      }

      if (events) {
        await subscribeToTopic('events');
      } else {
        await unsubscribeFromTopic('events');
      }

      if (prayerMeetings) {
        await subscribeToTopic('prayer_meetings');
      } else {
        await unsubscribeFromTopic('prayer_meetings');
      }

      if (testimonies) {
        await subscribeToTopic('testimonies');
      } else {
        await unsubscribeFromTopic('testimonies');
      }
    } catch (e) {
      debugPrint('Error updating notification preferences: $e');
    }
  }
}
