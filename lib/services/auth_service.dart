import 'dart:async';

import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'supabase_sync.dart';

/// Auth layer: Google → Supabase Auth (untuk backup progress online).
///
/// Alur:
/// 1) Native Google Sign-In (cepat, butuh Android OAuth + SHA-1 cocok keystore).
/// 2) Kalau native gagal (SHA-1 belum terdaftar / idToken kosong / ApiException
///    10/12500), fallback ke Supabase OAuth browser flow — ini **tidak** butuh
///    Android SHA-1, cukup Web OAuth client + Google provider di Supabase.
///
/// Android native notes:
/// - JANGAN set [GoogleSignIn.clientId] ke Web client.
/// - [GoogleSignIn.serverClientId] = Web client (client_type: 3) → idToken.
/// - Android client di-resolve dari package name + SHA-1 di Google Cloud.
class AuthService {
  static const _prefGoogleUser = 'google_user_email';
  static String? _lastError;
  static String? get lastError => _lastError;

  /// Web OAuth client (client_type: 3). Override via --dart-define.
  static const _webClientId = String.fromEnvironment(
    'GOOGLE_WEB_CLIENT_ID',
    defaultValue:
        '691907686915-mpcmcu4oh3e3kv2ld0qs5ur3kl7oro3h.apps.googleusercontent.com',
  );

  /// Deep link scheme for browser OAuth return.
  static const redirectScheme = 'id.muslimleveling.muslim_leveling';
  static const redirectUrl = '$redirectScheme://login-callback';

  static final _google = GoogleSignIn(
    serverClientId: _webClientId,
    scopes: const ['email', 'profile'],
  );

  static String? _userId;
  static String? get userId => _userId;
  static bool get isSignedIn => _userId != null;
  static StreamSubscription<AuthState>? _authSub;

  static Future<bool> init() async {
    try {
      // Keep _userId + SupabaseSync in sync with session changes (refresh, expire, multi-tab).
      _authSub?.cancel();
      _authSub = Supabase.instance.client.auth.onAuthStateChange.listen((data) {
        final session = data.session;
        if (session != null) {
          _userId = session.user.id;
          SupabaseSync.initWithUser(session.user.id);
        } else {
          _userId = null;
          SupabaseSync.clearUser();
        }
      });

      final session = Supabase.instance.client.auth.currentSession;
      if (session != null) {
        _userId = session.user.id;
        // Restore email label if we have a session but prefs empty.
        final email = session.user.email;
        if (email != null && email.isNotEmpty) {
          final prefs = await SharedPreferences.getInstance();
          await prefs.setString(_prefGoogleUser, email);
        }
        return true;
      }
    } catch (_) {}
    return false;
  }

  /// Return Supabase auth.uid, atau null kalau batal/gagal.
  /// [preferNative] true → native Google Sign-In popup (pilih akun, bukan browser).
  ///
  /// ## Persyaratan Native Popup
  /// Di Google Cloud Console → APIs & Services → Credentials, pastikan ada
  /// **Android OAuth client** dengan:
  /// - Package name: `id.muslimleveling.muslim_leveling`
  /// - SHA-1: `DF:2C:7E:72:5A:29:A7:1B:6F:66:FA:A6:FA:04:78:77:5B:46:F7:23`
  ///
  /// Kalau belum ada, native akan gagal (ApiException 10) dan fallback ke login browser.
  /// Web Client ID (serverClientId): ${_webClientId}
  static Future<String?> signInWithGoogle({bool preferNative = true}) async {
    _lastError = null;

    if (preferNative) {
      final native = await _signInNative();
      if (native != null) return native;
      // Keep lastError as diagnostic, but try browser before giving up.
      debugPrint('[AuthService] native gagal → fallback OAuth browser: $_lastError');
    }

    return _signInBrowserOAuth();
  }

  static Future<String?> _signInNative() async {
    try {
      // Bersihkan sesi Google lama biar picker gak stuck di account mati.
      try {
        await _google.signOut();
      } catch (_) {}

      final googleUser = await _google.signIn();
      if (googleUser == null) {
        _lastError = 'Login dibatalkan.';
        return null;
      }

      final googleAuth = await googleUser.authentication;
      final idToken = googleAuth.idToken;
      if (idToken == null || idToken.isEmpty) {
        _lastError =
            'Google tidak kirim idToken (biasanya SHA-1 release belum terdaftar '
            'di Google Cloud / Firebase). Mencoba login browser…';
        return null;
      }

      final accessToken = googleAuth.accessToken;
      if (accessToken == null || accessToken.isEmpty) {
        _lastError = 'Google tidak kirim access token. Mencoba login browser…';
        return null;
      }

      final res = await Supabase.instance.client.auth.signInWithIdToken(
        provider: OAuthProvider.google,
        idToken: idToken,
        accessToken: accessToken,
      );

      final uid = res.session?.user.id ?? res.user?.id;
      if (uid == null) {
        _lastError = 'Supabase Auth gagal — session kosong.';
        return null;
      }

      _userId = uid;
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_prefGoogleUser, googleUser.email);
      return uid;
    } catch (e) {
      _lastError = _mapError(e);
      debugPrint('[AuthService] native Google sign-in gagal: $e');
      return null;
    }
  }

  /// Browser OAuth via Supabase — bypass Android SHA-1 requirement.
  /// Needs:
  /// - Supabase Auth → Google provider enabled (Web Client ID + Secret)
  /// - Supabase Auth → Redirect URLs include [redirectUrl]
  /// - Android intent-filter for scheme [redirectScheme]
  static Future<String?> _signInBrowserOAuth() async {
    StreamSubscription<AuthState>? callbackSub;
    try {
      final client = Supabase.instance.client;
      // Clear stale session/flow state before starting fresh OAuth.
      try {
        await client.auth.signOut();
      } catch (_) {}

      final signedIn = Completer<Session>();
      // Attach listener before opening Chrome so a fast deep-link callback is
      // never missed between launch and subscription.
      callbackSub = client.auth.onAuthStateChange.listen((data) {
        if (data.event == AuthChangeEvent.signedIn &&
            data.session != null &&
            !signedIn.isCompleted) {
          signedIn.complete(data.session!);
        }
      });

      final launched = await client.auth.signInWithOAuth(
        OAuthProvider.google,
        redirectTo: redirectUrl,
        authScreenLaunchMode: LaunchMode.externalApplication,
      );
      if (!launched) {
        _lastError =
            'Gagal buka browser Google. Cek koneksi / browser default.';
        return null;
      }

      // Wait for deep-link callback to establish a session (max 3 min).
      // Catatan: URL app harus ada di Supabase URL Configuration, sedangkan
      // callback Supabase harus ada di Web OAuth client Google Cloud.
      final Session session;
      try {
        session = client.auth.currentSession ??
            await signedIn.future.timeout(const Duration(minutes: 3));
      } on TimeoutException {
        _lastError =
            'Login browser timeout — tidak kembali ke apps. '
            'Pastikan $redirectUrl ada di Supabase Auth → URL Configuration, '
            'dan callback Supabase ada di Google Cloud Web OAuth client. '
            'Atau coba login lewat perangkat lain / pastikan Chrome default.';
        return null;
      }

      _userId = session.user.id;
      final email = session.user.email;
      if (email != null && email.isNotEmpty) {
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString(_prefGoogleUser, email);
      }
      return _userId;
    } catch (e) {
      _lastError = _mapError(e);
      debugPrint('[AuthService] browser OAuth gagal: $e');
      return null;
    } finally {
      await callbackSub?.cancel();
    }
  }

  static Future<void> signOut() async {
    try {
      await _google.signOut();
    } catch (_) {}
    try {
      await Supabase.instance.client.auth.signOut();
    } catch (_) {}
    _userId = null;
    SupabaseSync.clearUser();
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_prefGoogleUser);
  }

  static Future<String?> get savedEmail async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_prefGoogleUser);
  }

  static String _mapError(Object e) {
    final s = e.toString();
    // Common Google Play Services / Sign-In codes
    if (s.contains('ApiException: 10') || s.contains('DEVELOPER_ERROR')) {
      // Sengaja tidak menyebut SHA-1 tertentu: APK bisa saja di-sign keystore
      // debug (mis. build CI tanpa secret keystore), dan menyebut SHA release
      // di situ menuntun orang mendaftarkan sidik jari yang salah lalu tetap
      // gagal. SHA yang benar hanya bisa dibaca dari APK yang terpasang.
      return 'Google DEVELOPER_ERROR (10): SHA-1 APK ini belum terdaftar di '
          'OAuth Android client. Cek sidik jari APK-nya dengan '
          '"apksigner verify --print-certs", lalu daftarkan yang itu. '
          'Mencoba login browser…';
    }
    if (s.contains('ApiException: 12500')) {
      return 'Google Sign-In misconfigured (12500). Cek OAuth consent + '
          'Android client package/SHA-1.';
    }
    if (s.contains('ApiException: 7') || s.contains('NETWORK_ERROR')) {
      return 'Jaringan error saat login Google. Coba lagi.';
    }
    if (s.contains('sign_in_failed') || s.contains('PlatformException')) {
      return 'Login Google gagal di device. Mencoba jalur browser… ($s)';
    }
    return 'Error: $e';
  }
}
