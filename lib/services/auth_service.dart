import 'dart:async';

import 'package:firebase_auth/firebase_auth.dart' as fb;
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
  static const _webClientId = String.fromEnvironment(
    'GOOGLE_WEB_CLIENT_ID',
    defaultValue:
        '691907686915-mpcmcu4oh3e3kv2ld0qs5ur3kl7oro3h.apps.googleusercontent.com',
  );

  static final _google = GoogleSignIn(
    serverClientId: _webClientId,
    scopes: const ['email', 'profile'],
  );

  static String? _userId;
  static String? get userId => _userId;
  static bool get isSignedIn => _userId != null;

  static StreamSubscription<fb.User?>? _authSub;

  static Future<bool> init() async {
    try {
      _authSub?.cancel();
      _authSub = fb.FirebaseAuth.instance.authStateChanges().listen((user) {
        if (user != null) {
          _userId = user.uid;
          CloudSync.initWithUser(user.uid);
        } else {
          _userId = null;
          CloudSync.clearUser();
        }
      });

      final user = fb.FirebaseAuth.instance.currentUser;
      if (user != null) {
        _userId = user.uid;
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

  static Future<String?> signInWithGoogle({bool preferNative = true}) async {
    _lastError = null;
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

      final accessToken = googleAuth.accessToken;
      if (accessToken == null || accessToken.isEmpty) {
        _lastError = 'Google tidak kirim access token.';
        return null;
      }

      final credential = fb.GoogleAuthProvider.credential(
        idToken: idToken,
        accessToken: accessToken,
      );
      final res = await fb.FirebaseAuth.instance.signInWithCredential(credential);
      final uid = res.user?.uid;
      if (uid == null) {
        _lastError = 'Firebase Auth gagal — user kosong.';
        return null;
      }

      _userId = uid;
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_prefGoogleUser, googleUser.email);
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
