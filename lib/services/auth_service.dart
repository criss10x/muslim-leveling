import 'dart:async';

import 'package:firebase_auth/firebase_auth.dart' as fb;
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:sentry_flutter/sentry_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../firebase_options.dart';
import 'cloud_sync.dart';
import '../l10n/app_localizations.dart';

/// Auth: Google Sign-In → Firebase Auth → CloudSync.
class AuthService {
  static const _prefEmail = 'google_user_email';
  static String? _lastError;
  static String? get lastError => _lastError;

  static const _webClientId =
      '691907686915-ljhu8cc4uvjuggd093fv5bl7dvk6joil.apps.googleusercontent.com';

  static final _google = GoogleSignIn(
    serverClientId: _webClientId,
    scopes: const ['email', 'profile'],
  );

  static String? _userId;
  static String? get userId => _userId;
  static bool get isSignedIn => _userId != null;

  static StreamSubscription<fb.User?>? _authSub;
  static Future<bool>? _firebaseInit;

  static Future<bool> ensureFirebaseReady() =>
      _firebaseInit ??= _initFirebase();

  static Future<bool> _initFirebase() async {
    try {
      if (Firebase.apps.isEmpty) {
        await Firebase.initializeApp(
          options: DefaultFirebaseOptions.currentPlatform,
        );
      }
      return true;
    } catch (e) {
      _lastError = 'Firebase belum siap. ($e)';
      debugPrint('[Auth] Firebase init gagal: $e');
      Sentry.captureException(e,
          withScope: (s) => s.setTag('error_type', 'firebase_init'));
      return false;
    }
  }

  static Future<bool> init() async {
    if (!await ensureFirebaseReady()) return false;
    try {
      _authSub?.cancel();
      _authSub =
          fb.FirebaseAuth.instance.authStateChanges().listen((user) {
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
          final p = await SharedPreferences.getInstance();
          await p.setString(_prefEmail, email);
        }
        return true;
      }
    } catch (e) {
      Sentry.captureException(e,
          withScope: (s) => s.setTag('init_step', 'auth_init'));
    }
    return false;
  }

  static Future<String?> signInWithGoogle(AppL10n l10n) async {
    _lastError = null;
    if (!await ensureFirebaseReady()) return null;
    return _signInNative(l10n);
  }

  static Future<String?> _signInNative(AppL10n l10n) async {
    try {
      // ponytail: tidak signOut() dulu — GoogleSignIn pakai cached account
      // (akun sebelumnya), supaya tidak re-prompt OAuth tiap login.
      final googleUser = await _google.signIn();
      if (googleUser == null) {
        _lastError = l10n.profilLoginCancelled;
        return null;
      }

      final auth = await googleUser.authentication;
      final idToken = auth.idToken;
      if (idToken == null || idToken.isEmpty) {
        _lastError =
            l10n.authNoIdToken;
        Sentry.captureMessage(_lastError!,
            level: SentryLevel.error,
            withScope: (scope) =>
                scope.setTag('error_type', 'google_sign_in_no_idtoken'));
        return null;
      }

      final credential = fb.GoogleAuthProvider.credential(
        idToken: idToken,
        accessToken: auth.accessToken,
      );
      final res =
          await fb.FirebaseAuth.instance.signInWithCredential(credential);
      final uid = res.user?.uid;
      if (uid == null) {
        _lastError = l10n.authEmptyUser;
        Sentry.captureMessage(_lastError!,
            level: SentryLevel.error,
            withScope: (scope) =>
                scope.setTag('error_type', 'google_sign_in_empty_uid'));
        return null;
      }

      _userId = uid;
      CloudSync.recordAuthenticatedUser(uid);
      return uid;
    } catch (e) {
      _lastError = _mapError(e, l10n);
      debugPrint('[Auth] sign-in gagal: $e');
      Sentry.captureException(
        e,
        stackTrace: StackTrace.current,
        withScope: (scope) {
          scope.level = SentryLevel.error;
          scope.setTag('error_type', 'google_sign_in');
          scope.setContexts(
              'auth_error', {'mapped_error': _lastError});
        },
      );
      return null;
    }
  }

  static Future<void> signOut() async {
    _userId = null;
    CloudSync.clearUser();
    try {
      await _google.signOut();
    } catch (_) {}
    try {
      await fb.FirebaseAuth.instance.signOut();
    } catch (_) {}
    final p = await SharedPreferences.getInstance();
    await p.remove(_prefEmail);
  }

  static Future<void> saveEmail() async {
    try {
      final email = fb.FirebaseAuth.instance.currentUser?.email;
      if (email == null || email.isEmpty) return;
      final p = await SharedPreferences.getInstance();
      await p.setString(_prefEmail, email);
    } catch (_) {}
  }

  static Future<String?> get savedEmail async {
    final p = await SharedPreferences.getInstance();
    return p.getString(_prefEmail);
  }

  static String _mapError(Object e, AppL10n l10n) {
    final s = e.toString();
    if (s.contains('ApiException: 10') || s.contains('DEVELOPER_ERROR')) {
      return l10n.authDevError10;
    }
    if (s.contains('ApiException: 12500') || s.contains('12501')) {
      return l10n.authMisconfigured;
    }
    if (s.contains('ApiException: 7') || s.contains('NETWORK_ERROR')) {
      return l10n.authNetworkError;
    }
    if (s.contains('invalid-credential')) {
      return l10n.authCredInvalid;
    }
    if (s.contains('operation-not-allowed')) {
      return l10n.authNotEnabled;
    }
    if (s.contains('account-exists-with-different-credential')) {
      return l10n.authEmailInUse;
    }
    return 'Error: $e';
  }
}
