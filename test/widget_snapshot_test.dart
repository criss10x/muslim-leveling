import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:muslim_leveling/l10n/app_localizations.dart';
import 'package:muslim_leveling/services/game_service.dart';
import 'package:muslim_leveling/services/widget_snapshot.dart';

Quest _q(
  String id, {
  int progress = 0,
  int target = 1,
  bool completed = false,
  bool claimed = false,
  int xp = 50,
}) => Quest(
  id: id,
  desc: 'fallback $id',
  xpReward: xp,
  target: target,
  progress: progress,
  completed: completed,
  claimed: claimed,
);

void main() {
  final l10n = lookupAppL10n(const Locale('id'));

  test('quest yang bisa di-claim tampil lebih dulu', () {
    final picks = WidgetSnapshot.pickQuests([
      _q('a', progress: 0, target: 3),
      _q('b', progress: 1, target: 1, completed: true),
      _q('c', progress: 2, target: 3),
      _q('d', progress: 0, target: 1),
    ], l10n);
    expect(picks.map((e) => e['id']), ['b', 'c']);
  });

  test('quest claimed tidak pernah muncul', () {
    final picks = WidgetSnapshot.pickQuests([
      _q('a', completed: true, claimed: true),
      _q('b', progress: 1, target: 2),
    ], l10n);
    expect(picks.map((e) => e['id']), ['b']);
  });

  test('semua sudah di-claim menghasilkan daftar kosong', () {
    final picks = WidgetSnapshot.pickQuests([
      _q('a', completed: true, claimed: true),
      _q('b', completed: true, claimed: true),
    ], l10n);
    expect(picks, isEmpty);
  });

  test('dua quest siap claim: XP terbesar dulu', () {
    final picks = WidgetSnapshot.pickQuests([
      _q('kecil', completed: true, xp: 40),
      _q('besar', completed: true, xp: 100),
    ], l10n);
    expect(picks.map((e) => e['id']), ['besar', 'kecil']);
  });

  test('deskripsi memakai bahasa aktif, bukan desc tersimpan', () {
    final en = WidgetSnapshot.pickQuests([
      _q('quest_five_rings', progress: 1, target: 1),
    ], lookupAppL10n(const Locale('en')));
    expect(en.first['desc'], isNot(contains('fallback')));
    final id = WidgetSnapshot.pickQuests([
      _q('quest_five_rings', progress: 1, target: 1),
    ], l10n);
    expect(id.first['desc'], isNot(contains('fallback')));
    expect(en.first['desc'], isNot(id.first['desc']));
  });

  test('payload memuat 5 sholat, hari ini, dan quest', () {
    final s = WidgetSnapshot.build(
      timings: Timings(),
      quests: [_q('a', progress: 1, target: 2)],
      l10n: l10n,
      now: DateTime(2026, 10, 19, 9, 30),
    );
    expect(s['today'], '2026-10-19');
    expect((s['prayers'] as List).length, 5);
    expect((s['days'] as Map)['2026-10-19'], isNotNull);
    expect(s['quests'], isNotEmpty);
  });

  test('tanggal satu digit diberi nol di depan', () {
    final s = WidgetSnapshot.build(
      timings: Timings(),
      quests: const [],
      l10n: l10n,
      now: DateTime(2026, 1, 5, 4, 0),
    );
    expect(s['today'], '2026-01-05');
  });

  test('label sholat ikut bahasa', () {
    final id = WidgetSnapshot.prayersOf(Timings(), l10n);
    final en = WidgetSnapshot.prayersOf(Timings(), lookupAppL10n(const Locale('en')));
    expect(id.first['label'], l10n.prayerSubuh);
    expect(en.first['label'], lookupAppL10n(const Locale('en')).prayerSubuh);
    expect(id.map((e) => e['key']), ['subuh', 'dzuhur', 'ashar', 'maghrib', 'isya']);
  });

  test('Dhuha tidak ikut di daftar sholat widget', () {
    final list = WidgetSnapshot.prayersOf(Timings(), l10n);
    expect(list.map((e) => e['key']), isNot(contains('dhuha')));
  });
}
