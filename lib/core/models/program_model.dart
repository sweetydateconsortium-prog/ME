class ProgramModel {
  final String id;
  final String title;
  final String description;
  final String category;
  final DateTime startTime;
  final DateTime endTime;
  final String? thumbnailUrl;
  final String? videoUrl;
  final String? liveStreamUrl;
  final bool isLive;
  final bool isRecurring;
  final List<String> tags;
  final ProgramHost host;
  final ProgramMetadata metadata;

  ProgramModel({
    required this.id,
    required this.title,
    required this.description,
    required this.category,
    required this.startTime,
    required this.endTime,
    this.thumbnailUrl,
    this.videoUrl,
    this.liveStreamUrl,
    this.isLive = false,
    this.isRecurring = false,
    this.tags = const [],
    required this.host,
    required this.metadata,
  });

  factory ProgramModel.fromJson(Map<String, dynamic> json) {
    return ProgramModel(
      id: json['id'] ?? '',
      title: json['title'] ?? '',
      description: json['description'] ?? '',
      category: json['category'] ?? '',
      startTime: DateTime.parse(json['startTime']),
      endTime: DateTime.parse(json['endTime']),
      thumbnailUrl: json['thumbnailUrl'],
      videoUrl: json['videoUrl'],
      liveStreamUrl: json['liveStreamUrl'],
      isLive: json['isLive'] ?? false,
      isRecurring: json['isRecurring'] ?? false,
      tags: List<String>.from(json['tags'] ?? []),
      host: ProgramHost.fromJson(json['host'] ?? {}),
      metadata: ProgramMetadata.fromJson(json['metadata'] ?? {}),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'category': category,
      'startTime': startTime.toIso8601String(),
      'endTime': endTime.toIso8601String(),
      'thumbnailUrl': thumbnailUrl,
      'videoUrl': videoUrl,
      'liveStreamUrl': liveStreamUrl,
      'isLive': isLive,
      'isRecurring': isRecurring,
      'tags': tags,
      'host': host.toJson(),
      'metadata': metadata.toJson(),
    };
  }

  Duration get duration => endTime.difference(startTime);
  String get formattedTime => '${_formatTime(startTime)} - ${_formatTime(endTime)}';
  bool get isCurrentlyLive {
    final now = DateTime.now();
    return isLive && now.isAfter(startTime) && now.isBefore(endTime);
  }

  String _formatTime(DateTime time) {
    return '${time.hour.toString().padLeft(2, '0')}:${time.minute.toString().padLeft(2, '0')}';
  }
}

class ProgramHost {
  final String id;
  final String name;
  final String? title;
  final String? avatarUrl;
  final String? bio;

  ProgramHost({
    required this.id,
    required this.name,
    this.title,
    this.avatarUrl,
    this.bio,
  });

  factory ProgramHost.fromJson(Map<String, dynamic> json) {
    return ProgramHost(
      id: json['id'] ?? '',
      name: json['name'] ?? '',
      title: json['title'],
      avatarUrl: json['avatarUrl'],
      bio: json['bio'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'title': title,
      'avatarUrl': avatarUrl,
      'bio': bio,
    };
  }
}

class ProgramMetadata {
  final int viewCount;
  final int likeCount;
  final double rating;
  final List<String> reminders;
  final DateTime createdAt;
  final DateTime updatedAt;

  ProgramMetadata({
    this.viewCount = 0,
    this.likeCount = 0,
    this.rating = 0.0,
    this.reminders = const [],
    required this.createdAt,
    required this.updatedAt,
  });

  factory ProgramMetadata.fromJson(Map<String, dynamic> json) {
    return ProgramMetadata(
      viewCount: json['viewCount'] ?? 0,
      likeCount: json['likeCount'] ?? 0,
      rating: (json['rating'] ?? 0.0).toDouble(),
      reminders: List<String>.from(json['reminders'] ?? []),
      createdAt: DateTime.parse(json['createdAt']),
      updatedAt: DateTime.parse(json['updatedAt']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'viewCount': viewCount,
      'likeCount': likeCount,
      'rating': rating,
      'reminders': reminders,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }
}

enum ProgramCategory {
  culte,
  enseignement,
  musique,
  jeunesse,
  special,
  emissions;

  String get displayName {
    switch (this) {
      case ProgramCategory.culte:
        return 'Culte';
      case ProgramCategory.enseignement:
        return 'Enseignement';
      case ProgramCategory.musique:
        return 'Musique';
      case ProgramCategory.jeunesse:
        return 'Jeunesse';
      case ProgramCategory.special:
        return 'Spécial';
      case ProgramCategory.emissions:
        return 'Émissions';
    }
  }

  static ProgramCategory fromString(String category) {
    return ProgramCategory.values.firstWhere(
      (e) => e.name.toLowerCase() == category.toLowerCase(),
      orElse: () => ProgramCategory.emissions,
    );
  }
}