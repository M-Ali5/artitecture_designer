import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';

class AuthController extends ChangeNotifier {
  AuthController({FirebaseAuth? auth}) : _auth = auth ?? FirebaseAuth.instance {
    _auth.authStateChanges().listen((_) {
      notifyListeners();
    });
  }

  final FirebaseAuth _auth;
  bool isBusy = false;
  String? error;

  User? get currentUser => _auth.currentUser;
  bool get isLoggedIn => currentUser != null;

  Future<void> signIn({
    required String email,
    required String password,
  }) async {
    await _runSafely(() async {
      await _auth.signInWithEmailAndPassword(email: email, password: password);
    });
  }

  Future<void> signUp({
    required String email,
    required String password,
    required String displayName,
  }) async {
    await _runSafely(() async {
      final result = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
      await result.user?.updateDisplayName(displayName.trim());
    });
  }

  Future<void> sendPasswordReset(String email) async {
    await _runSafely(() async {
      await _auth.sendPasswordResetEmail(email: email.trim());
    });
  }

  Future<void> signOut() async {
    await _auth.signOut();
  }

  Future<void> _runSafely(Future<void> Function() action) async {
    isBusy = true;
    error = null;
    notifyListeners();
    try {
      await action();
    } on FirebaseAuthException catch (e) {
      error = _friendlyAuthError(e);
    } catch (_) {
      error = 'Unexpected authentication error.';
    } finally {
      isBusy = false;
      notifyListeners();
    }
  }

  String _friendlyAuthError(FirebaseAuthException e) {
    switch (e.code) {
      case 'invalid-email':
        return 'Email address invalid hai. Please sahi email enter karein.';
      case 'invalid-credential':
        return 'Email ya password galat hai. Please dubara try karein.';
      case 'user-not-found':
        return 'Is email par account nahi mila.';
      case 'wrong-password':
        return 'Password incorrect hai.';
      case 'email-already-in-use':
        return 'Is email par pehle se account bana hua hai.';
      case 'weak-password':
        return 'Password weak hai. Kam az kam 6 characters use karein.';
      case 'too-many-requests':
        return 'Zyada attempts ho gaye. Thori der baad dubara try karein.';
      case 'network-request-failed':
        return 'Internet issue hai. Network check karke dubara try karein.';
      case 'operation-not-allowed':
        return 'Email/password sign-in Firebase Console mein enabled nahi hai.';
      case 'internal-error':
        return 'Internal auth error aya hai. Firebase config (google-services files / API keys) aur network check karein.';
      default:
        final fallback = e.message?.trim();
        if (fallback != null && fallback.isNotEmpty) {
          return '$fallback (code: ${e.code})';
        }
        return 'Authentication failed (code: ${e.code}).';
    }
  }
}
