import 'dart:convert';

import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../l10n/app_localizations.dart';
import 'game_service.dart';

/// Snapshot siap-tampil untuk home screen widget Android.
///
/// Kotlin TIDAK mem-parsing `game_state_v1`: ia membaca JSON ini apa adanya.
/// Alasannya: teks hidup di ARB (4 bahasa) dan tidak bisa diterjemahkan dari
/// sisi native. Semua keputusan yang butuh konteks Flutter selesai di sini,
/// jadi provider Kotlin nol logika permainan dan tidak bisa menyimpang dari app.
///
/// Isi widget adalah **sholat wajib**, bukan quest game. Widget menempel di home
/// screen sepanjang hari, jadi yang ia jawab adalah pertanyaan yang sebenarnya
/// dibawa user ke layar itu: sholat apa sekarang, sudah dikerjakan belum, dan
/// yang berikutnya jam berapa. Quest game tetap hidup di dalam app.
class WidgetSnapshot {
  /// Kunci prefs. Provider Kotlin membacanya lewat
  /// `WidgetPrefs.flutterKey(prefKey)` (prefix `flutter.` ditambahkan
  /// SharedPreferences versi Dart).
  static const prefKey = 'widget_snapshot_v1';
  static const channelName = 'ml/widget';

  static const _channel = MethodChannel(channelName);

  /// Lima sholat wajib, urut waktu. Satu sumber dengan `GameService.wajibList`
  /// supaya widget dan layar Home tidak bisa berbeda pendapat soal jumlahnya.
  static const wajibKeys = GameService.wajibList;

  /// Satu baris sholat untuk widget: identitas, jam, dan status.
  ///
  /// `done` datang dari `prayerLog` hari ini — sumber yang sama dengan baris
  /// wajib di Home. Widget tidak pernah menghitung sendiri.
  static List<Map<String, dynamic>> prayersOf(
    Timings t,
    AppL10n l10n,
    Set<String> done,
  ) => [
    {
      'key': 'subuh',
      'label': l10n.prayerSubuh,
      'time': t.subuh,
      'done': done.contains('subuh'),
    },
    {
      'key': 'dzuhur',
      'label': l10n.prayerDzuhur,
      'time': t.dzuhur,
      'done': done.contains('dzuhur'),
    },
    {
      'key': 'ashar',
      'label': l10n.prayerAshar,
      'time': t.ashar,
      'done': done.contains('ashar'),
    },
    {
      'key': 'maghrib',
      'label': l10n.prayerMaghrib,
      'time': t.maghrib,
      'done': done.contains('maghrib'),
    },
    {
      'key': 'isya',
      'label': l10n.prayerIsya,
      'time': t.isya,
      'done': done.contains('isya'),
    },
  ];

  /// Sholat wajib yang sudah dikerjakan hari ini, dari `prayerLog`.
  static Set<String> doneToday(List<PrayerLog> log, DateTime now) {
    final today = dateKey(now);
    return log
        .where((l) => l.date == today && wajibKeys.contains(l.prayer))
        .map((l) => l.prayer)
        .toSet();
  }

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
    required AppL10n l10n,
    required DateTime now,
    required List<PrayerLog> prayerLog,
    Map<String, List<Map<String, dynamic>>>? week,
  }) {
    final today = dateKey(now);
    final done = doneToday(prayerLog, now);
    final todayPrayers = prayersOf(timings, l10n, done);
    return {
      'v': 2,
      'today': today,
      'days': week ?? {today: todayPrayers},
      'doneCount': done.length,
      'total': wajibKeys.length,
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
