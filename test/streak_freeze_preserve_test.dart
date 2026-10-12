import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:muslim_leveling/services/game_service.dart';

/// Hari yang diselamatkan freeze shield TIDAK boleh memutus rantai streak.
///
/// Bug yang dijaga di sini (terukur, bukan dugaan): hari yang dilindungi
/// shield melewati `_updStreak`, jadi `lastDate` tidak ikut maju. Log
/// berikutnya lalu melihat "kemarin" != lastDate dan mereset streak ke 1.
/// Gejala di layar: sudah sholat kemarin, tapi angka di tab Profil tetap 1.
String _key(DateTime d) =>
    '${d.year}-${d.month.toString().padLeft(2, '0')}-${d.day.toString().padLeft(2, '0')}';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() {
    SharedPreferences.setMockInitialValues({});
    GameService.resetForTest();
    GameService.setTestSkipTimeWindow(true);
  });
  tearDown(() => GameService.setTestSkipTimeWindow(false));

  Future<void> seed({
    required String lastPrayerDate,
    required int current,
    required int shields,
    bool freezeAvailable = true,
  }) async {
    await GameService.load();
    GameService.setStateForTest(GameState(
      prayerLog: [
        PrayerLog(
            date: lastPrayerDate, prayer: 'subuh', time: '04:45', type: 'wajib'),
      ],
      perPrayerStreaks: {
        'subuh': StreakState(
          current: current,
          best: current,
          lastDate: lastPrayerDate,
          freezeAvailable: freezeAvailable,
        ),
      },
      lastCheckedDate: lastPrayerDate,
      freezeShields: shields,
    ));
  }

  test('streak 3 hari + kemarin diselamatkan shield + sholat hari ini = 4',
      () async {
    final today = GameService.todayStr();
    final d2 = _key(DateTime.parse(today).subtract(const Duration(days: 2)));

    await seed(lastPrayerDate: d2, current: 3, shields: 1);
    await GameService.runDailyCheck();

    // Shield memang terpakai untuk hari kemarin.
    expect(GameService.current.freezeShields, 0);
    expect(GameService.current.freezeSavedDates, contains(GameService.yesterdayStr()));

    final res = GameService.logPrayer(GameService.current, 'subuh', 'wajib');
    expect(res, isNotNull);
    expect(res!.$1.perPrayerStreaks['subuh']!.current, 4,
        reason: 'hari yang diselamatkan shield tidak boleh memutus rantai');
    expect(res.$1.perPrayerStreaks['subuh']!.lastDate, today);
  });

  test('hari diselamatkan shield juga tidak memutus streak hero & tilawah',
      () async {
    final today = GameService.todayStr();
    final d2 = _key(DateTime.parse(today).subtract(const Duration(days: 2)));

    await GameService.load();
    GameService.setStateForTest(GameState(
      prayerLog: [
        PrayerLog(
            date: d2, prayer: 'subuh', time: '04:45', type: 'wajib'),
      ],
      heroStreak: StreakState(
          current: 5, best: 5, lastDate: d2, freezeAvailable: true),
      tilawahStreak: StreakState(
          current: 4, best: 4, lastDate: d2, freezeAvailable: true),
      perPrayerStreaks: const {},
      lastCheckedDate: d2,
      freezeShields: 1,
    ));

    await GameService.runDailyCheck();
    final healed = GameService.backfillPrayerStreaks(GameService.current);

    // current tidak boleh jatuh karena hari yang dilindungi.
    expect(healed.heroStreak.current, greaterThanOrEqualTo(5),
        reason: 'hero streak tidak boleh putus karena hari yang diselamatkan');
    expect(healed.tilawahStreak.current, greaterThanOrEqualTo(4),
        reason: 'streak tilawah tidak boleh putus karena hari yang diselamatkan');
  });

  test('lastDate basi (bukan kemarin) memang reset ke 1: rantai tidak palsu',
      () async {
    final today = GameService.todayStr();
    // lastDate 3 hari lalu, jadi sholat hari ini bukan lanjutan rantai.
    final d3 = _key(DateTime.parse(today).subtract(const Duration(days: 3)));
    await GameService.load();
    GameService.setStateForTest(GameState(
      prayerLog: [
        PrayerLog(date: d3, prayer: 'subuh', time: '04:45', type: 'wajib'),
      ],
      perPrayerStreaks: {
        'subuh':
            StreakState(current: 3, best: 3, lastDate: d3, freezeAvailable: false),
      },
      lastCheckedDate: GameService.yesterdayStr(),
      freezeShields: 0,
    ));

    final res = GameService.logPrayer(GameService.current, 'subuh', 'wajib');
    expect(res!.$1.perPrayerStreaks['subuh']!.current, 1,
        reason: 'rantai yang benar-benar putus tetap mulai dari 1');
  });

  test('streak yang sudah 0 tidak dibangkitkan shield', () async {
    final today = GameService.todayStr();
    final d2 = _key(DateTime.parse(today).subtract(const Duration(days: 2)));

    await seed(lastPrayerDate: d2, current: 0, shields: 1);
    await GameService.runDailyCheck();

    final res = GameService.logPrayer(GameService.current, 'subuh', 'wajib');
    expect(res!.$1.perPrayerStreaks['subuh']!.current, 1,
        reason: 'shield tidak menghidupkan streak yang sudah mati');
  });
}
