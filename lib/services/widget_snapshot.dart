import 'dart:convert';

import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../l10n/app_localizations.dart';
import 'game_service.dart';

/// Snapshot siap-tampil untuk home screen widget Android.
///
/// Kotlin TIDAK mem-parsing `game_state_v1`: ia membaca JSON ini apa adanya.
/// Alasannya: teks quest hidup di ARB (4 bahasa) dan tidak bisa diterjemahkan
/// dari sisi native. Semua keputusan yang butuh konteks Flutter selesai di sini,
/// jadi provider Kotlin nol logika permainan dan tidak bisa menyimpang dari app.
class WidgetSnapshot {
  /// Kunci prefs. Provider Kotlin membacanya sebagai
  /// `flutter.widget_snapshot_v1` (SharedPreferences Flutter menambahkan
  /// prefix `flutter.` pada nama kunci).
  static const prefKey = 'widget_snapshot_v1';
  static const channelName = 'ml/widget';

  static const _channel = MethodChannel(channelName);

  /// Urutan tampil quest: yang bisa di-claim dulu, lalu yang paling dekat
  /// selesai. `claimed` tidak pernah masuk, karena sudah tidak ada yang bisa
  /// dikerjakan. Maksimal 2 (sekarang + berikutnya).
  static List<Map<String, dynamic>> pickQuests(
    List<Quest> quests,
    AppL10n l10n, {
    int limit = 2,
  }) {
    final alive = quests.where((q) => !q.claimed).toList()
      ..sort((a, b) {
        if (a.completed != b.completed) return a.completed ? -1 : 1;
        if (a.completed && b.completed) return b.xpReward.compareTo(a.xpReward);
        final ar = a.target == 0 ? 0.0 : a.progress / a.target;
        final br = b.target == 0 ? 0.0 : b.progress / b.target;
        return br.compareTo(ar);
      });
    return alive
        .take(limit)
        .map(
          (q) => {
            'id': q.id,
            'desc': q.localizedDesc(l10n),
            'progress': q.progress,
            'target': q.target,
            'xp': q.xpReward,
            'completed': q.completed,
            'claimed': q.claimed,
          },
        )
        .toList();
  }

  /// Lima sholat wajib.
  ///
  /// Dhuha sengaja tidak ada: menambah cabang waktu yang tidak sepadan untuk
  /// widget 4x2, dan ia bukan sholat wajib.
  static List<Map<String, String>> prayersOf(Timings t, AppL10n l10n) => [
    {'key': 'subuh', 'label': l10n.prayerSubuh, 'time': t.subuh},
    {'key': 'dzuhur', 'label': l10n.prayerDzuhur, 'time': t.dzuhur},
    {'key': 'ashar', 'label': l10n.prayerAshar, 'time': t.ashar},
    {'key': 'maghrib', 'label': l10n.prayerMaghrib, 'time': t.maghrib},
    {'key': 'isya', 'label': l10n.prayerIsya, 'time': t.isya},
  ];

  /// Kunci tanggal `yyyy-MM-dd`, bentuknya sama dengan
  /// `PrayerService.dateKey` dan `GameService.dailyDateKey`.
  static String dateKey(DateTime d) =>
      '${d.year}-${d.month.toString().padLeft(2, '0')}-'
      '${d.day.toString().padLeft(2, '0')}';

  /// Payload lengkap.
  ///
  /// [week] berisi jadwal 7 hari ke depan sebagai peta tanggal → daftar sholat.
  /// Kalau null (belum pernah fetch), `days` hanya berisi hari ini, sehingga
  /// widget tetap benar hari ini dan meminta buka app besok. Itu sengaja:
  /// menampilkan jadwal kemarin sebagai "berikutnya" lebih buruk daripada kosong.
  static Map<String, dynamic> build({
    required Timings timings,
    required List<Quest> quests,
    required AppL10n l10n,
    required DateTime now,
    Map<String, List<Map<String, String>>>? week,
  }) {
    final today = dateKey(now);
    final todayPrayers = prayersOf(timings, l10n);
    return {
      'v': 1,
      'today': today,
      'prayers': todayPrayers,
      'days': week ?? {today: todayPrayers},
      'quests': pickQuests(quests, l10n),
    };
  }

  /// Tulis snapshot lalu minta widget menggambar ulang.
  ///
  /// Tidak pernah melempar: widget fitur tambahan, kegagalannya tidak boleh
  /// membatalkan penyimpanan game.
  static Future<void> pushRaw(Map<String, dynamic> payload) async {
    try {
      final p = await SharedPreferences.getInstance();
      await p.setString(prefKey, jsonEncode(payload));
    } catch (_) {
      return;
    }
    try {
      await _channel.invokeMethod('refresh');
    } catch (_) {
      // Platform tanpa widget (iOS, unit test, channel belum terdaftar).
    }
  }
}
