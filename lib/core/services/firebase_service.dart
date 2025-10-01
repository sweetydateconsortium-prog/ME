import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/foundation.dart';

import '../models/user_model.dart';
import '../models/program_model.dart';

class FirebaseService {
  /// Sends a password reset email to the given email address.
  Future<void> sendPasswordResetEmail(String email) async {
    try {
      await _auth.sendPasswordResetEmail(email: email);
    } catch (e) {
      debugPrint('Error sending password reset email: $e');
      rethrow;
    }
  }
  static final FirebaseService _instance = FirebaseService._internal();
  factory FirebaseService() => _instance;
  FirebaseService._internal();

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseStorage _storage = FirebaseStorage.instance;

  // Collections
  CollectionReference get _usersCollection => _firestore.collection('users');
  CollectionReference get _programsCollection => _firestore.collection('programs');
  CollectionReference get _reelsCollection => _firestore.collection('reels');
  CollectionReference get _notificationsCollection => _firestore.collection('notifications');
  CollectionReference get _liveStreamsCollection => _firestore.collection('liveStreams');

  // User Operations
  Future<UserModel?> getUserProfile(String userId) async {
    try {
      final doc = await _usersCollection.doc(userId).get();
      if (doc.exists) {
        return UserModel.fromJson({
          'id': doc.id,
          ...doc.data() as Map<String, dynamic>,
        });
      }
      return null;
    } catch (e) {
      debugPrint('Error getting user profile: $e');
      return null;
    }
  }

  Future<bool> createUserProfile(UserModel user) async {
    try {
      await _usersCollection.doc(user.id).set(user.toJson());
      return true;
    } catch (e) {
      debugPrint('Error creating user profile: $e');
      return false;
    }
  }

  Future<bool> updateUserProfile(UserModel user) async {
    try {
      await _usersCollection.doc(user.id).update(user.toJson());
      return true;
    } catch (e) {
      debugPrint('Error updating user profile: $e');
      return false;
    }
  }

  // Program Operations
  Future<List<ProgramModel>> getPrograms({
    String? category,
    DateTime? startDate,
    DateTime? endDate,
    int limit = 50,
  }) async {
    try {
      Query query = _programsCollection.orderBy('startTime');

      if (category != null && category != 'all') {
        query = query.where('category', isEqualTo: category);
      }

      if (startDate != null) {
        query = query.where('startTime', isGreaterThanOrEqualTo: startDate);
      }

      if (endDate != null) {
        query = query.where('startTime', isLessThanOrEqualTo: endDate);
      }

      final snapshot = await query.limit(limit).get();
      
      return snapshot.docs.map((doc) {
        return ProgramModel.fromJson({
          'id': doc.id,
          ...doc.data() as Map<String, dynamic>,
        });
      }).toList();
    } catch (e) {
      debugPrint('Error getting programs: $e');
      return [];
    }
  }

  Future<List<ProgramModel>> getTodayPrograms() async {
    final now = DateTime.now();
    final startOfDay = DateTime(now.year, now.month, now.day);
    final endOfDay = startOfDay.add(const Duration(days: 1));
    
    return getPrograms(
      startDate: startOfDay,
      endDate: endOfDay,
    );
  }

  Future<ProgramModel?> getCurrentLiveProgram() async {
    try {
      final now = DateTime.now();
      final snapshot = await _programsCollection
          .where('isLive', isEqualTo: true)
          .where('startTime', isLessThanOrEqualTo: now)
          .where('endTime', isGreaterThan: now)
          .limit(1)
          .get();

      if (snapshot.docs.isNotEmpty) {
        return ProgramModel.fromJson({
          'id': snapshot.docs.first.id,
          ...snapshot.docs.first.data() as Map<String, dynamic>,
        });
      }
      return null;
    } catch (e) {
      debugPrint('Error getting current live program: $e');
      return null;
    }
  }

  // Reels Operations
  Future<List<Map<String, dynamic>>> getReels({int limit = 20}) async {
    try {
      final snapshot = await _reelsCollection
          .orderBy('createdAt', descending: true)
          .limit(limit)
          .get();

      return snapshot.docs.map((doc) {
        return {
          'id': doc.id,
          ...doc.data() as Map<String, dynamic>,
        };
      }).toList();
    } catch (e) {
      debugPrint('Error getting reels: $e');
      return [];
    }
  }

  Future<bool> likeReel(String reelId, String userId) async {
    try {
      await _reelsCollection.doc(reelId).update({
        'likes': FieldValue.arrayUnion([userId]),
        'likeCount': FieldValue.increment(1),
      });
      return true;
    } catch (e) {
      debugPrint('Error liking reel: $e');
      return false;
    }
  }

  Future<bool> unlikeReel(String reelId, String userId) async {
    try {
      await _reelsCollection.doc(reelId).update({
        'likes': FieldValue.arrayRemove([userId]),
        'likeCount': FieldValue.increment(-1),
      });
      return true;
    } catch (e) {
      debugPrint('Error unliking reel: $e');
      return false;
    }
  }

  // Live Stream Operations
  Future<String?> getCurrentLiveStreamUrl() async {
    try {
      final snapshot = await _liveStreamsCollection
          .where('isActive', isEqualTo: true)
          .limit(1)
          .get();

      if (snapshot.docs.isNotEmpty) {
        final data = snapshot.docs.first.data() as Map<String, dynamic>;
        return data['streamUrl'];
      }
      return null;
    } catch (e) {
      debugPrint('Error getting live stream URL: $e');
      return null;
    }
  }

  // Notification Operations
  Future<List<Map<String, dynamic>>> getUserNotifications(String userId) async {
    try {
      final snapshot = await _notificationsCollection
          .where('userId', isEqualTo: userId)
          .orderBy('createdAt', descending: true)
          .limit(50)
          .get();

      return snapshot.docs.map((doc) {
        return {
          'id': doc.id,
          ...doc.data() as Map<String, dynamic>,
        };
      }).toList();
    } catch (e) {
      debugPrint('Error getting notifications: $e');
      return [];
    }
  }

  Future<bool> markNotificationAsRead(String notificationId) async {
    try {
      await _notificationsCollection.doc(notificationId).update({
        'read': true,
        'readAt': DateTime.now().toIso8601String(),
      });
      return true;
    } catch (e) {
      debugPrint('Error marking notification as read: $e');
      return false;
    }
  }

  // Storage Operations
  Future<String?> uploadFile(String path, List<int> bytes) async {
    try {
      final ref = _storage.ref().child(path);
      final uploadTask = await ref.putData(Uint8List.fromList(bytes));
      return await uploadTask.ref.getDownloadURL();
    } catch (e) {
      debugPrint('Error uploading file: $e');
      return null;
    }
  }

  // Real-time subscriptions
  Stream<List<ProgramModel>> watchTodayPrograms() {
    final now = DateTime.now();
    final startOfDay = DateTime(now.year, now.month, now.day);
    final endOfDay = startOfDay.add(const Duration(days: 1));
    
    return _programsCollection
        .where('startTime', isGreaterThanOrEqualTo: startOfDay)
        .where('startTime', isLessThan: endOfDay)
        .orderBy('startTime')
        .snapshots()
        .map((snapshot) {
      return snapshot.docs.map((doc) {
        return ProgramModel.fromJson({
          'id': doc.id,
          ...doc.data() as Map<String, dynamic>,
        });
      }).toList();
    });
  }

  Stream<UserModel?> watchUserProfile(String userId) {
    return _usersCollection.doc(userId).snapshots().map((doc) {
      if (doc.exists) {
        return UserModel.fromJson({
          'id': doc.id,
          ...doc.data() as Map<String, dynamic>,
        });
      }
      return null;
    });
  }

  // Analytics
  Future<void> trackEvent(String eventName, Map<String, dynamic> parameters) async {
    try {
      // This would integrate with Firebase Analytics
      debugPrint('Analytics: $eventName - $parameters');
    } catch (e) {
      debugPrint('Error tracking event: $e');
    }
  }

  Future<void> trackVideoWatch(String programId, int watchTimeSeconds) async {
    final userId = _auth.currentUser?.uid;
    if (userId != null) {
      await trackEvent('video_watch', {
        'program_id': programId,
        'watch_time': watchTimeSeconds,
        'user_id': userId,
      });
    }
  }
}