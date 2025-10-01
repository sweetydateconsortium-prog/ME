class UserModel {
  final String id;
  final String firstName;
  final String lastName;
  final String email;
  final String? phone;
  final String? photoURL;
  final String? city;
  final DateTime? birthDate;
  final DateTime joinDate;
  final UserPreferences preferences;
  final UserStats stats;
  final DateTime? lastLoginAt;
  final bool isActive;

  UserModel({
    required this.id,
    required this.firstName,
    required this.lastName,
    required this.email,
    this.phone,
    this.photoURL,
    this.city,
    this.birthDate,
    required this.joinDate,
    required this.preferences,
    required this.stats,
    this.lastLoginAt,
    this.isActive = true,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['id'] ?? '',
      firstName: json['firstName'] ?? '',
      lastName: json['lastName'] ?? '',
      email: json['email'] ?? '',
      phone: json['phone'],
      photoURL: json['photoURL'],
      city: json['city'],
      birthDate: json['birthDate'] != null ? DateTime.parse(json['birthDate']) : null,
      joinDate: DateTime.parse(json['joinDate']),
      preferences: UserPreferences.fromJson(json['preferences'] ?? {}),
      stats: UserStats.fromJson(json['stats'] ?? {}),
      lastLoginAt: json['lastLoginAt'] != null ? DateTime.parse(json['lastLoginAt']) : null,
      isActive: json['isActive'] ?? true,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'firstName': firstName,
      'lastName': lastName,
      'email': email,
      'phone': phone,
      'photoURL': photoURL,
      'city': city,
      'birthDate': birthDate?.toIso8601String(),
      'joinDate': joinDate.toIso8601String(),
      'preferences': preferences.toJson(),
      'stats': stats.toJson(),
      'lastLoginAt': lastLoginAt?.toIso8601String(),
      'isActive': isActive,
    };
  }

  String get displayName => '$firstName $lastName';
  String get initials => '${firstName.isNotEmpty ? firstName[0] : ''}${lastName.isNotEmpty ? lastName[0] : ''}';
}

class UserPreferences {
  final String language;
  final bool darkMode;
  final NotificationPreferences notifications;

  UserPreferences({
    this.language = 'fr',
    this.darkMode = false,
    required this.notifications,
  });

  factory UserPreferences.fromJson(Map<String, dynamic> json) {
    return UserPreferences(
      language: json['language'] ?? 'fr',
      darkMode: json['darkMode'] ?? false,
      notifications: NotificationPreferences.fromJson(json['notifications'] ?? {}),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'language': language,
      'darkMode': darkMode,
      'notifications': notifications.toJson(),
    };
  }
}

class NotificationPreferences {
  final bool liveServices;
  final bool newSermons;
  final bool events;
  final bool prayerMeetings;
  final bool testimonies;

  NotificationPreferences({
    this.liveServices = true,
    this.newSermons = true,
    this.events = true,
    this.prayerMeetings = true,
    this.testimonies = false,
  });

  factory NotificationPreferences.fromJson(Map<String, dynamic> json) {
    return NotificationPreferences(
      liveServices: json['liveServices'] ?? true,
      newSermons: json['newSermons'] ?? true,
      events: json['events'] ?? true,
      prayerMeetings: json['prayerMeetings'] ?? true,
      testimonies: json['testimonies'] ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'liveServices': liveServices,
      'newSermons': newSermons,
      'events': events,
      'prayerMeetings': prayerMeetings,
      'testimonies': testimonies,
    };
  }
}

class UserStats {
  final List<String> watchedPrograms;
  final List<String> likedReels;
  final int totalWatchTime;
  final int streakDays;

  UserStats({
    this.watchedPrograms = const [],
    this.likedReels = const [],
    this.totalWatchTime = 0,
    this.streakDays = 0,
  });

  factory UserStats.fromJson(Map<String, dynamic> json) {
    return UserStats(
      watchedPrograms: List<String>.from(json['watchedPrograms'] ?? []),
      likedReels: List<String>.from(json['likedReels'] ?? []),
      totalWatchTime: json['totalWatchTime'] ?? 0,
      streakDays: json['streakDays'] ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'watchedPrograms': watchedPrograms,
      'likedReels': likedReels,
      'totalWatchTime': totalWatchTime,
      'streakDays': streakDays,
    };
  }
}