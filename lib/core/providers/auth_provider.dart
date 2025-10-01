import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_facebook_auth/flutter_facebook_auth.dart';

class AuthProvider extends ChangeNotifier {
  // Facebook login
  Future<bool> signInWithFacebook() async {
    try {
      setLoading(true);
      clearError();
      // Import FacebookAuth from flutter_facebook_auth
      final LoginResult result = await FacebookAuth.instance.login();
      if (result.status == LoginStatus.success) {
        final OAuthCredential facebookAuthCredential =
            FacebookAuthProvider.credential(result.accessToken!.token);
        final userCredential =
            await _auth.signInWithCredential(facebookAuthCredential);
        if (userCredential.user != null) {
          // Check if user profile exists, create if not
          final userDoc = await _firestore
              .collection('users')
              .doc(userCredential.user!.uid)
              .get();
          if (!userDoc.exists) {
            await _createUserProfile(
              userCredential.user!,
              firstName:
                  userCredential.user!.displayName?.split(' ').first ?? '',
              lastName: userCredential.user!.displayName
                      ?.split(' ')
                      .skip(1)
                      .join(' ') ??
                  '',
            );
          } else {
            await _updateUserLastLogin(userCredential.user!.uid);
          }
          return true;
        }
      } else {
        setError('Connexion Facebook annulée ou échouée');
        return false;
      }
      return false;
    } catch (e) {
      setError('Erreur lors de la connexion avec Facebook');
      return false;
    } finally {
      setLoading(false);
    }
  }

  /// Sends a password reset email to the given email address.
  Future<void> sendPasswordResetEmail(String email) async {
    try {
      setLoading(true);
      clearError();
      await _auth.sendPasswordResetEmail(email: email);
    } on FirebaseAuthException catch (e) {
      setError(_getErrorMessage(e.code));
      rethrow;
    } catch (e) {
      setError('Une erreur inattendue s\'est produite');
      rethrow;
    } finally {
      setLoading(false);
    }
  }

  final FirebaseAuth _auth = FirebaseAuth.instance;
  final GoogleSignIn _googleSignIn = GoogleSignIn();
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  User? _user;
  bool _isLoading = false;
  String? _errorMessage;
  bool _isGuest = false;

  User? get user => _user;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  bool get isAuthenticated => _user != null || _isGuest;
  bool get isGuest => _isGuest;

  AuthProvider() {
    _auth.authStateChanges().listen((User? user) {
      _user = user;
      _isGuest = false; // Reset guest mode when auth state changes
      notifyListeners();
    });
  }

  void setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }

  void setError(String? error) {
    _errorMessage = error;
    notifyListeners();
  }

  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }

  // Sign in with email and password
  Future<bool> signInWithEmail(String email, String password) async {
    try {
      setLoading(true);
      clearError();

      final credential = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      if (credential.user != null) {
        await _updateUserLastLogin(credential.user!.uid);
        return true;
      }
      return false;
    } on FirebaseAuthException catch (e) {
      setError(_getErrorMessage(e.code));
      return false;
    } catch (e) {
      setError('Une erreur inattendue s\'est produite');
      return false;
    } finally {
      setLoading(false);
    }
  }

  // Sign up with email and password
  Future<bool> signUpWithEmail(
    String email,
    String password, {
    required String firstName,
    required String lastName,
    String? phone,
    String? city,
    DateTime? birthDate,
  }) async {
    try {
      setLoading(true);
      clearError();

      final credential = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      if (credential.user != null) {
        // Create user profile in Firestore
        await _createUserProfile(
          credential.user!,
          firstName: firstName,
          lastName: lastName,
          phone: phone,
          city: city,
          birthDate: birthDate,
        );

        // Update display name
        await credential.user!.updateDisplayName('$firstName $lastName');

        return true;
      }
      return false;
    } on FirebaseAuthException catch (e) {
      setError(_getErrorMessage(e.code));
      return false;
    } catch (e) {
      setError('Une erreur inattendue s\'est produite');
      return false;
    } finally {
      setLoading(false);
    }
  }

  // Sign in with Google
  Future<bool> signInWithGoogle() async {
    try {
      setLoading(true);
      clearError();

      final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();
      if (googleUser == null) return false;

      final GoogleSignInAuthentication googleAuth =
          await googleUser.authentication;

      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      final userCredential = await _auth.signInWithCredential(credential);

      if (userCredential.user != null) {
        // Check if user profile exists, create if not
        final userDoc = await _firestore
            .collection('users')
            .doc(userCredential.user!.uid)
            .get();

        if (!userDoc.exists) {
          await _createUserProfile(
            userCredential.user!,
            firstName: userCredential.user!.displayName?.split(' ').first ?? '',
            lastName: userCredential.user!.displayName
                    ?.split(' ')
                    .skip(1)
                    .join(' ') ??
                '',
          );
        } else {
          await _updateUserLastLogin(userCredential.user!.uid);
        }

        return true;
      }
      return false;
    } catch (e) {
      setError('Erreur lors de la connexion avec Google');
      return false;
    } finally {
      setLoading(false);
    }
  }

  // Continue as guest
  Future<void> continueAsGuest() async {
    _isGuest = true;
    _user = null;
    notifyListeners();
  }

  // Sign out
  Future<void> signOut() async {
    try {
      setLoading(true);
      await _auth.signOut();
      await _googleSignIn.signOut();
      _isGuest = false;
    } catch (e) {
      setError('Erreur lors de la déconnexion');
    } finally {
      setLoading(false);
    }
  }

  // Create user profile in Firestore
  Future<void> _createUserProfile(
    User user, {
    required String firstName,
    required String lastName,
    String? phone,
    String? city,
    DateTime? birthDate,
  }) async {
    final userData = {
      'firstName': firstName,
      'lastName': lastName,
      'email': user.email,
      'phone': phone,
      'photoURL': user.photoURL,
      'city': city,
      'birthDate': birthDate?.toIso8601String(),
      'joinDate': DateTime.now().toIso8601String(),
      'preferences': {
        'language': 'fr',
        'darkMode': false,
        'notifications': {
          'liveServices': true,
          'newSermons': true,
          'events': true,
          'prayerMeetings': true,
          'testimonies': false,
        },
      },
      'stats': {
        'watchedPrograms': [],
        'likedReels': [],
        'totalWatchTime': 0,
        'streakDays': 0,
      },
      'createdAt': DateTime.now().toIso8601String(),
      'updatedAt': DateTime.now().toIso8601String(),
      'isActive': true,
    };

    await _firestore.collection('users').doc(user.uid).set(userData);
  }

  // Update user last login
  Future<void> _updateUserLastLogin(String uid) async {
    await _firestore.collection('users').doc(uid).update({
      'lastLoginAt': DateTime.now().toIso8601String(),
      'updatedAt': DateTime.now().toIso8601String(),
    });
  }

  // Get error message for Firebase Auth exceptions
  String _getErrorMessage(String errorCode) {
    switch (errorCode) {
      case 'user-not-found':
        return 'Aucun utilisateur trouvé avec cet email';
      case 'wrong-password':
        return 'Mot de passe incorrect';
      case 'email-already-in-use':
        return 'Cet email est déjà utilisé';
      case 'weak-password':
        return 'Le mot de passe est trop faible';
      case 'invalid-email':
        return 'Email invalide';
      case 'user-disabled':
        return 'Ce compte a été désactivé';
      case 'too-many-requests':
        return 'Trop de tentatives. Réessayez plus tard';
      case 'operation-not-allowed':
        return 'Opération non autorisée';
      default:
        return 'Une erreur s\'est produite';
    }
  }

  // Reset password
  Future<bool> resetPassword(String email) async {
    try {
      setLoading(true);
      clearError();

      await _auth.sendPasswordResetEmail(email: email);
      return true;
    } on FirebaseAuthException catch (e) {
      setError(_getErrorMessage(e.code));
      return false;
    } catch (e) {
      setError('Erreur lors de l\'envoi de l\'email');
      return false;
    } finally {
      setLoading(false);
    }
  }

  // Update user profile
  Future<bool> updateProfile({
    String? firstName,
    String? lastName,
    String? phone,
    String? city,
    DateTime? birthDate,
  }) async {
    if (_user == null) return false;

    try {
      setLoading(true);
      clearError();

      final updateData = <String, dynamic>{
        'updatedAt': DateTime.now().toIso8601String(),
      };

      if (firstName != null) updateData['firstName'] = firstName;
      if (lastName != null) updateData['lastName'] = lastName;
      if (phone != null) updateData['phone'] = phone;
      if (city != null) updateData['city'] = city;
      if (birthDate != null)
        updateData['birthDate'] = birthDate.toIso8601String();

      await _firestore.collection('users').doc(_user!.uid).update(updateData);

      // Update display name if name changed
      if (firstName != null || lastName != null) {
        final userDoc =
            await _firestore.collection('users').doc(_user!.uid).get();
        final userData = userDoc.data();
        final displayName =
            '${userData?['firstName'] ?? firstName ?? ''} ${userData?['lastName'] ?? lastName ?? ''}';
        await _user!.updateDisplayName(displayName.trim());
      }

      return true;
    } catch (e) {
      setError('Erreur lors de la mise à jour du profil');
      return false;
    } finally {
      setLoading(false);
    }
  }
}
