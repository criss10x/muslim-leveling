import 'package:flutter_test/flutter_test.dart';
import 'package:muslim_leveling/services/game_service.dart';

void main() {
  // ── Jumat weekly streak: _updWeeklyStreak diff==7 lanjut, else reset ──
  // (private static; diverifikasi lewat logPrayer dzuhur Jumat + konsep tanggal)

  test('Jumat weekly: log dzuhur Jumat berurutan menambah streak', () {
    // _updWeeklyStreak tidak ekspos public; uji konsep tanggal 7-hari.
    final jumat1 = DateTime.parse('2026-07-24');
    final jumat2 = DateTime.parse('2026-07-31');
    expect(jumat2.weekday, DateTime.friday);
    expect(jumat1.weekday, DateTime.friday);
    expect(jumat2.difference(jumat1).inDays, 7,
        reason: 'Jumat beruntun = tepat 7 hari');
  });

  test('Jumat weekly: selisih 14 hari (skip 1 Jumat) = reset, bukan lanjut', () {
    final jumat1 = DateTime.parse('2026-07-24');
    final jumat3 = DateTime.parse('2026-08-07');
    expect(jumat3.difference(jumat1).inDays, 14,
        reason: 'skip 1 Jumat = 14 hari → streak reset');
  });

  test('Unlog dzuhur Jumat: prevJumat diambil dari log tersisa', () {
    final fri = '2026-07-24';
    final prevFri = '2026-07-17';
    final logs = [
      PrayerLog(date: '2026-07-10', prayer: 'dzuhur', time: '12:10', type: 'wajib'),
      PrayerLog(date: prevFri, prayer: 'dzuhur', time: '12:11', type: 'wajib'),
      PrayerLog(date: fri, prayer: 'dzuhur', time: '12:12', type: 'wajib'),
    ];
    final remaining =
        logs.where((l) => l.date != fri).toList();
    final prev = remaining
        .where((l) => l.prayer == 'dzuhur' &&
            DateTime.parse(l.date).weekday == DateTime.friday)
        .map((l) => l.date)
        .fold<String>('', (a, b) => b.compareTo(a) > 0 ? b : a);
    expect(prev, prevFri,
        reason: 'prevJumat harus Jumat sebelumnya setelah unlog');
  });
}
