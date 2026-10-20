import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:muslim_leveling/l10n/app_localizations.dart';
import 'package:muslim_leveling/services/game_service.dart';
import 'package:muslim_leveling/services/widget_snapshot.dart';

PrayerLog _log(String prayer, {String date = '2026-10-19'}) =>
    PrayerLog(date: date, prayer: prayer, time: '05:00', type: 'wajib');

void main() {
  final l10n = lookupAppL10n(const Locale('id'));
  final now = DateTime(2026, 10, 19, 9, 30);

  test('payload memuat 5 sholat wajib hari ini, tanpa quest', () {
    final s = WidgetSnapshot.build(
      timings: Timings(),
      l10n: l10n,
      now: now,
      prayerLog: const [],
    );
    expect(s['today'], '2026-10-19');
    expect(s['total'], 5);
    expect(s['doneCount'], 0);
    final days = s['days'] as Map;
    expect((days['2026-10-19'] as List).length, 5);
    // Widget menampilkan sholat wajib, bukan quest game.
    expect(s.containsKey('quests'), isFalse);
  });

  test('urutan sholat wajib tetap urut waktu', () {
    final list = (WidgetSnapshot.build(
      timings: Timings(),
      l10n: l10n,
      now: now,
      prayerLog: const [],
    )['days'] as Map)['2026-10-19'] as List;
    expect(list.map((e) => e['key']), [
      'subuh',
      'dzuhur',
      'ashar',
      'maghrib',
      'isya',
    ]);
  });

  test('status done diambil dari prayerLog hari ini', () {
    final s = WidgetSnapshot.build(
      timings: Timings(),
      l10n: l10n,
      now: now,
      prayerLog: [_log('subuh'), _log('dzuhur')],
    );
    final list = (s['days'] as Map)['2026-10-19'] as List;
    final done = {
      for (final e in list)
        if (e['done'] == true) e['key'],
    };
    expect(done, {'subuh', 'dzuhur'});
    expect(s['doneCount'], 2);
  });

  test('log hari lain tidak dihitung done hari ini', () {
    final s = WidgetSnapshot.build(
      timings: Timings(),
      l10n: l10n,
      now: now,
      prayerLog: [_log('subuh', date: '2026-10-18')],
    );
    expect(s['doneCount'], 0);
  });

  test('sholat sunnah di prayerLog tidak menambah doneCount', () {
    // Sunah punya log sendiri; kalau ikut dihitung, bilah jade akan bohong.
    final s = WidgetSnapshot.build(
      timings: Timings(),
      l10n: l10n,
      now: now,
      prayerLog: [_log('subuh'), _log('dhuha'), _log('tahajjud')],
    );
    expect(s['doneCount'], 1);
  });

  test('tanggal satu digit diberi nol di depan', () {
    final s = WidgetSnapshot.build(
      timings: Timings(),
      l10n: l10n,
      now: DateTime(2026, 1, 5, 4, 0),
      prayerLog: const [],
    );
    expect(s['today'], '2026-01-05');
  });

  test('label sholat ikut bahasa aktif', () {
    final id = WidgetSnapshot.prayersOf(Timings(), l10n, const {});
    final en = WidgetSnapshot.prayersOf(
      Timings(),
      lookupAppL10n(const Locale('en')),
      const {},
    );
    expect(id.first['label'], l10n.prayerSubuh);
    expect(en.first['label'], lookupAppL10n(const Locale('en')).prayerSubuh);
    expect(id.first['label'], isNot(en.first['label']));
  });

  test('Dhuha tidak ikut di daftar sholat widget', () {
    final list = WidgetSnapshot.prayersOf(Timings(), l10n, const {});
    expect(list.map((e) => e['key']), isNot(contains('dhuha')));
  });

  test('jumlah wajib di widget sama dengan yang dilacak app', () {
    // Widget dan layar Home tidak boleh berbeda pendapat soal berapa sholat
    // wajib yang harus selesai hari ini.
    expect(WidgetSnapshot.wajibKeys, GameService.wajibList);
    expect(WidgetSnapshot.wajibKeys.length, 5);
  });
}
