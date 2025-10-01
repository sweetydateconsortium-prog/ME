import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';

class AdminAuthProvider extends ChangeNotifier {
  final FirebaseAuth _auth = FirebaseAuth.instance;

  User? _user;
  bool _isAdmin = false;
  bool _isLoading = true;

  AdminAuthProvider() {
    _auth.userChanges().listen((user) async {
      _user = user;
      _isAdmin = false;
      _isLoading = false;

      if (user != null) {
        try {
          final IdTokenResult token = await user.getIdTokenResult(true);
          final Map<String, dynamic>? claims = token.claims;
          _isAdmin = (claims != null && claims['admin'] == true);
        } catch (_) {
          _isAdmin = false;
        }
      }

      notifyListeners();
    });
  }

  bool get isLoading => _isLoading;
  bool get isAuthenticated => _user != null;
  bool get isAdmin => _isAdmin;
  User? get user => _user;

  Future<void> signInWithEmail(String email, String password) async {
    await _auth.signInWithEmailAndPassword(email: email, password: password);
  }

  Future<void> signOut() async {
    await _auth.signOut();
  }
}

