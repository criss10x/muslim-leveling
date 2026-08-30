import 'package:flutter_test/flutter_test.dart';
import 'package:muslim_leveling/services/game_service.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() {
    GameService.resetForTest();
    SharedPreferences.setMockInitialValues({});
  });

  // ── P0 fix: setHaidMode(false) harus majukan lastCheckedDate ke today,
  //    supaya hari-hari haid (tanpa log) tidak dievaluasi sebagai missed.
  test('setHaidMode(false) mengatur lastCheckedDate ke hari ini (P0 fix)', () async {
    GameService.setStateForTest(GameState(
      haidMode: true,
      lastCheckedDate: '2026-08-01',
      perPrayerStreaks: {
        'subuh': StreakState(current: 10, best: 15, lastDate: '2026-08-01'),
      },
    ));

    await GameService.setHaidMode(false);

    expect(GameService.haidMode, isFalse);
    expect(
      GameService.current.lastCheckedDate,
      GameService.todayStr(),
      reason: 'P0: hari-hari haid tidak boleh dievaluasi sebagai missed',
    );
  });

  test('setHaidMode(false) tidak menyentuh lastCheckedDate jika bukan haid', () async {
    GameService.setStateForTest(GameState(
      haidMode: false,
      lastCheckedDate: '2026-08-01',
    ));

    await GameService.setHaidMode(false);

    expect(
      GameService.current.lastCheckedDate,
      '2026-08-01',
      reason: 'toggle off saat bukan haid = no-op pada lastCheckedDate',
    );
  });

  // ── P2 fix: restorePrayerStreakAfterUnlog tidak decrement jika lastDate==today
  test('restore setelah unlog: lastDate==today tidak decrement (P2 fix)', () {
    final today = GameService.todayStr();
    final prev = StreakState(current: 12, best: 15, lastDate: today);

    final restored = GameService.restorePrayerStreakAfterUnlog(
      const [], // log hari ini sudah dihapus
      'subuh',
      previous: prev,
    );

    expect(
      restored.current,
      12,
      reason: 'P2: unlog hari ini tidak mencabut streak yang sudah di-update',
    );
    expect(restored.lastDate, today);
  });

  test('restore setelah unlog: lastDate != today tetap decrement + lastDate mundur', () {
    final logs = [
      PrayerLog(date: '2026-07-31', prayer: 'subuh', time: '04:45', type: 'wajib'),
    ];
    final prev = StreakState(current: 12, best: 15, lastDate: '2026-08-01');

    final restored = GameService.restorePrayerStreakAfterUnlog(
      logs,
      'subuh',
      previous: prev,
    );

    expect(restored.current, 11);
    expect(restored.lastDate, '2026-07-31');
  });

  // ── Freeze shield: konsumsi otomatis saat missed day (1 shield = 1 hari aman)
  test('freeze shield dikonsumsi otomatis saat missed day, streak aman', () async {
    // State: streak subuh aktif (current 5), 1 shield, lastChecked 2 hari lalu,
    // kemarin tidak ada log subuh → missed 1 hari (dievaluasi hari ini).
    // lastChecked = 2 hari lalu → evalDate = kemarin (1 missed day)
    final twoDaysAgoDate =
        DateTime.now().subtract(const Duration(days: 2));
    final lastChecked = '${twoDaysAgoDate.year.toString().padLeft(4, '0')}-'
        '${twoDaysAgoDate.month.toString().padLeft(2, '0')}-'
        '${twoDaysAgoDate.day.toString().padLeft(2, '0')}';
    final yesterday = GameService.yesterdayStr();
    GameService.setStateForTest(GameState(
      freezeShields: 1,
      lastCheckedDate: lastChecked,
      perPrayerStreaks: {
        'subuh': StreakState(current: 5, best: 8, lastDate: yesterday),
      },
      prayerLog: [
        // kemarin tidak ada log subuh → missed
      ],
    ));

    await GameService.runDailyCheck();

    final s = GameService.current.perPrayerStreaks['subuh']!;
    expect(GameService.current.freezeShields, 0,
        reason: '1 shield dikonsumsi untuk 1 hari missed');
    expect(s.current, 5,
        reason: 'streak tidak kena penalty karena shield');
    expect(s.freezeAvailable, isTrue,
        reason: 'freeze mingguan tidak ikut terkonsumsi');
  });
}
