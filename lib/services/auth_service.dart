import 'dart:async';

import 'package:firebase_auth/firebase_auth.dart' as fb;
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'cloud_sync.dart';

/// Auth layer: Google Sign-In → Firebase Auth.
class AuthService {
  static const _prefGoogleUser = 'google_user_email';
  static String? _lastError;
  static String? get lastError => _lastError;

  /// Web OAuth client (client_type: 3) for idToken via native GoogleSignIn.
  @visibleForTesting
  static const googleWebClientId = String.fromEnvironment(
    'GOOGLE_WEB_CLIENT_ID',
    defaultValue:
        '691907686915-ljhu8cc4uvjuggd093fv5bl7dvk6joil.apps.googleusercontent.com',
  );

  static final _google = GoogleSignIn(
    serverClientId: googleWebClientId,
    scopes: const ['email', 'profile'],
  );

  static String? _userId;
  static String? get userId => _userId;
  static bool get isSignedIn => _userId != null;

  static StreamSubscription<fb.User?>? _authSub;
  static Future<bool>? _firebaseInit;

  static Future<bool> ensureFirebaseReady() =>
      _firebaseInit ??= _initializeFirebase();

  static Future<bool> _initializeFirebase() async {
    try {
      if (Firebase.apps.isEmpty) await Firebase.initializeApp();
      return true;
    } catch (e) {
      _lastError = 'Firebase belum siap. Coba buka ulang aplikasi. ($e)';
      debugPrint('[AuthService] Firebase initialization gagal: $e');
      return false; // ponytail: one init attempt per process, retry on app restart
    }
  }

  static Future<bool> init() async {
    if (!await ensureFirebaseReady()) return false;
    try {
      _authSub?.cancel();
      _authSub = fb.FirebaseAuth.instance.authStateChanges().listen((user) {
        if (user != null) {
          _userId = user.uid;
          CloudSync.recordAuthenticatedUser(user.uid);
        } else {
          _userId = null;
          CloudSync.clearUser();
        }
      });

      final user = fb.FirebaseAuth.instance.currentUser;
      if (user != null) {
        _userId = user.uid;
        CloudSync.recordAuthenticatedUser(user.uid);
        final email = user.email;
        if (email != null && email.isNotEmpty) {
          final prefs = await SharedPreferences.getInstance();
          await prefs.setString(_prefGoogleUser, email);
        }
        return true;
      }
    } catch (_) {}
    return false;
  }

  static Future<String?> signInWithGoogle() async {
    _lastError = null;
    if (!await ensureFirebaseReady()) return null;
    final native = await _signInNative();
    if (native != null) return native;
    return null; // ponytail: no browser fallback; native always works once SHA-1 registered
  }

  static Future<String?> _signInNative() async {
    try {
      try { await _google.signOut(); } catch (_) {}

      final googleUser = await _google.signIn();
      if (googleUser == null) {
        _lastError = 'Login dibatalkan.';
        return null;
      }

      final googleAuth = await googleUser.authentication;
      final idToken = googleAuth.idToken;
      if (idToken == null || idToken.isEmpty) {
        _lastError = 'Google tidak kirim idToken. Cek SHA-1 di Firebase Console.';
        return null;
      }

      final credential = googleCredentialForTokens(
        idToken: idToken,
        accessToken: googleAuth.accessToken,
      );
      final res = await fb.FirebaseAuth.instance.signInWithCredential(credential);
      final uid = res.user?.uid;
      if (uid == null) {
        _lastError = 'Firebase Auth gagal — user kosong.';
        return null;
      }

      _userId = uid;
      CloudSync.recordAuthenticatedUser(uid);
      return uid;
    } catch (e) {
      _lastError = _mapError(e);
      debugPrint('[AuthService] Google sign-in gagal: $e');
      return null;
    }
  }

  static Future<void> signOut() async {
    try { await _google.signOut(); } catch (_) {}
    try { await fb.FirebaseAuth.instance.signOut(); } catch (_) {}
    _userId = null;
    CloudSync.clearUser();
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_prefGoogleUser);
  }

  @visibleForTesting
  static fb.AuthCredential googleCredentialForTokens({
    required String idToken,
    String? accessToken,
  }) => fb.GoogleAuthProvider.credential(
    idToken: idToken,
    accessToken: accessToken,
  );

  static Future<String?> get savedEmail async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_prefGoogleUser);
  }

  static String _mapError(Object e) {
    final s = e.toString();
    if (s.contains('ApiException: 10') || s.contains('DEVELOPER_ERROR')) {
      return 'Google DEVELOPER_ERROR (10): SHA-1 APK ini belum terdaftar di '
          'Firebase Console → Project Settings → General → Your apps → SHA certificate.';
    }
    if (s.contains('ApiException: 12500')) {
      return 'Google Sign-In misconfigured (12500). Cek OAuth consent + SHA-1.';
    }
    if (s.contains('ApiException: 7') || s.contains('NETWORK_ERROR')) {
      return 'Jaringan error saat login Google.';
    }
    if (s.contains('sign_in_failed') || s.contains('PlatformException')) {
      return 'Login Google gagal di device. ($s)';
    }
    return 'Error: $e';
  }
}
