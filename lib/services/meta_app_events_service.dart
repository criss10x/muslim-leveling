import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:facebook_app_events/facebook_app_events.dart';

/// Meta App Events — pengukuran iklan (Events Manager / App Ads Helper).
///
/// Wrapper tipis: semua pemanggil log lewat sini supaya (1) satu titik
/// on/off — SDK gagal init tidak boleh bikin crash game logic, (2) penanda
/// event konsisten, (3) mudah dimatikan kalau nanti butuh consent gate.
///
/// Lapisan pertahanan: fire-and-forget + catchError di dalam — kredensial
/// kosong / MissingPluginException / jaring mati ditelan; pelaporan iklan
/// tidak boleh pernah mengganggu game logic.
///
/// Yang TIDAK dipasang (jujur — belum ada di app):
/// - `logSubscribe` / `logStartTrial`: app belum punya billing (pubspec tanpa
///   `in_app_purchase`, EntitlementService masih "semua gratis"). Log event
///   yang tidak bisa terpicu berarti data bohong di Events Manager.
///
/// Konfigurasi kredensial: android/facebook.properties (lokal, gitignored)
/// atau GitHub Secrets FACEBOOK_APP_ID / FACEBOOK_CLIENT_TOKEN (CI) → gradle
/// resValue → AndroidManifest meta-data → SDK init otomatis oleh plugin.
/// App ID Meta dashboard: 1101188639281497.
class MetaAppEvents {
  static final FacebookAppEvents _sdk = FacebookAppEvents();

  /// Fire-and-forget: kirim log TANPA di-await pemanggil. Alasan:
  /// (1) testWidgets jalan di fake-async zone — future MethodChannel tanpa
  /// handler native tidak pernah resolve dan `await` menggantung test sampai
  /// framework membunuhnya (10 menit); unawaited memutus rantai itu.
  /// (2) Di produksi, log event hanya enqueue — tidak ada alasan game logic
  /// menunggu SDK. Kegagalan jaring/credential ditelan di sini.
  static void _send(Future<void> fut, String label) {
    unawaited(fut.catchError((Object e) {
      debugPrint('MetaAppEvents $label gagal: $e');
    }));
  }

  /// Panggil sekali di main() — no-op di sisi native karena SDK Android
  /// mengirim App Install/App Launch OTOMATIS saat kredensial tersedia
  /// (AutoLogAppEventsEnabled default true). Eksplisit hanya dipanggil bila
  /// auto-log dimatikan untuk consent gate (belum dibutuhkan).
  static Future<void> init() async {
    if (kIsWeb) return;
    // Sengaja tidak memanggil _sdk.activateApp(): plugin mendokumentasikan
    // bahwa pemanggilan itu hanya untuk setup manual/delayed-consent, dan
    // AutoLogAppEventsEnabled kita tetap true — memanggilnya lagi berisiko
    // event launch dobel di Events Manager.
  }

  /// Standard event: pengguna naik level (LEVEL).
  static void achievedLevel(int level) {
    if (kIsWeb || level <= 0) return;
    _send(
      _sdk.logAchievedLevel(level: '$level'),
      'achievedLevel($level)',
    );
  }

  /// Standard event: medali baru terbuka (UNLOCKED_ACHIEVEMENT).
  /// [description] = id medali internal (bukan copy UI — stabil antar locale).
  static void unlockedAchievement(String description) {
    if (kIsWeb || description.isEmpty) return;
    _send(
      _sdk.logUnlockedAchievement(description: description),
      'unlockedAchievement($description)',
    );
  }
}

