import 'package:flutter_test/flutter_test.dart';
import 'package:muslim_leveling/services/game_service.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Tests untuk sistem "never miss twice":
/// A1 welcome-back shield, A2 mini chest, A3 no-waste freeze,
/// Qadha auto-create + logQadha, tawbah dismiss.
void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() {
    GameService.resetForTest();
    SharedPreferences.setMockInitialValues({});
  });

  String daysAgo(int n) {
    final d = DateTime.now().subtract(Duration(days: n));
    return d.toIso8601String().substring(0, 10);
  }

  // ── A3: streak 0 tidak buang freezeAvailable ──
  test('A3: missed day dengan current==0 tidak consume freeze', () async {
    GameService.setStateForTest(GameState(
      lastCheckedDate: daysAgo(2),
      heroStreak: StreakState(current: 0, best: 5, lastDate: daysAgo(5)),
      perPrayerStreaks: {
        for (final p in GameService.wajibList)
          p: StreakState(current: 0, best: 3, lastDate: daysAgo(5)),
      },
    ));

    final after = await GameService.runDailyCheck();

    // freezeAvailable tetap true (tidak hangus sia-sia).
    expect(after.heroStreak.freezeAvailable, isTrue,
        reason: 'A3: streak 0 tidak boleh consume freeze');
    for (final p in GameService.wajibList) {
      expect(after.perPrayerStreaks[p]?.freezeAvailable, isTrue,
          reason: 'A3: $p streak 0 tidak boleh consume freeze');
    }
  });

  // ── A3 negatif: streak aktif consume freeze ──
  test('A3: missed day dengan current>0 consume freeze', () async {
    GameService.setStateForTest(GameState(
      lastCheckedDate: daysAgo(2),
      heroStreak: StreakState(current: 5, best: 5, lastDate: daysAgo(2)),
      perPrayerStreaks: {
        for (final p in GameService.wajibList)
          p: StreakState(current: 5, best: 5, lastDate: daysAgo(2)),
      },
      tilawahStreak: StreakState(current: 0, best: 0),
    ));

    final after = await GameService.runDailyCheck();

    expect(after.heroStreak.freezeAvailable, isFalse,
        reason: 'streak aktif harus consume freeze');
  });

  // ── A1: welcome-back shield setelah gap 3+ hari ──
  test('A1: gap 4 hari memberi 1 welcome-back shield', () async {
    GameService.setStateForTest(GameState(
      lastCheckedDate: daysAgo(5), // gap = 4 hari missed
      freezeShields: 0,
      heroStreak: StreakState(current: 0, best: 0),
    ));

    final after = await GameService.runDailyCheck();

    expect(after.freezeShields, 1,
        reason: 'A1: gap 3+ hari → 1 welcome-back shield gratis');
  });

  test('A1: gap 1 hari TIDAK memberi shield', () async {
    GameService.setStateForTest(GameState(
      lastCheckedDate: daysAgo(2), // gap = 1 hari missed
      freezeShields: 0,
      heroStreak: StreakState(current: 0, best: 0),
    ));

    final after = await GameService.runDailyCheck();

    expect(after.freezeShields, 0,
        reason: 'gap <3 hari → tidak ada welcome shield');
  });

  test('A1: shield cap 3 — kelebihan jadi XP', () async {
    final xpBefore = 100;
    GameService.setStateForTest(GameState(
      xp: xpBefore,
      lastCheckedDate: daysAgo(5),
      freezeShields: 3, // sudah penuh
      heroStreak: StreakState(current: 0, best: 0),
    ));

    final after = await GameService.runDailyCheck();

    expect(after.freezeShields, 3, reason: 'cap 3 tidak boleh lewat');
    expect(after.xp, xpBefore + 30, reason: 'kelebihan → +30 XP');
  });

  // ── A2: mini chest 3/5 ──
  test('A2: 3/5 wajib bisa buka mini chest (+15 XP)', () async {
    final today = GameService.todayStr();
    GameService.setStateForTest(GameState(
      prayerLog: [
        PrayerLog(date: today, prayer: 'subuh', time: '04:45', type: 'wajib'),
        PrayerLog(date: today, prayer: 'dzuhur', time: '12:05', type: 'wajib'),
        PrayerLog(date: today, prayer: 'ashar', time: '15:20', type: 'wajib'),
      ],
      xp: 0,
    ));

    expect(GameService.isDailyChestAvailable, isTrue);
    expect(GameService.isDailyChestFull, isFalse);

    final reveal = await GameService.claimDailyChest();
    expect(reveal, isNotNull);
    expect(reveal!.xpReward, 15, reason: 'mini chest = +15 XP');
    expect(reveal.isShield, isFalse);
    expect(GameService.isDailyChestOpened, isTrue);
  });

  test('A2: 2/5 wajib TIDAK bisa buka chest', () async {
    final today = GameService.todayStr();
    GameService.setStateForTest(GameState(
      prayerLog: [
        PrayerLog(date: today, prayer: 'subuh', time: '04:45', type: 'wajib'),
        PrayerLog(date: today, prayer: 'dzuhur', time: '12:05', type: 'wajib'),
      ],
    ));

    expect(GameService.isDailyChestAvailable, isFalse);
  });

  // ── Qadha: auto-create saat missed + logQadha lunasi ──
  test('Qadha: missed wajib masuk daftar utang', () async {
    GameService.setStateForTest(GameState(
      lastCheckedDate: daysAgo(2), // 1 hari missed (kemarin)
      prayerLog: [], // tidak ada log kemarin
      heroStreak: StreakState(current: 0, best: 0),
    ));

    final after = await GameService.runDailyCheck();

    expect(after.qadhaLog.length, 5,
        reason: '1 hari missed × 5 wajib = 5 utang qadha');
    expect(GameService.qadhaCount, 5);
  });

  test('Qadha: logQadhaAsync lunasi + beri XP', () async {
    GameService.setStateForTest(GameState(
      xp: 0,
      qadhaLog: [
        QadhaLog(date: daysAgo(1), prayer: 'subuh'),
        QadhaLog(date: daysAgo(1), prayer: 'maghrib'),
      ],
    ));

    final res = await GameService.logQadhaAsync('subuh');
    expect(res, isNotNull);
    expect(res!.$2, 30, reason: 'qadha subuh = +30 XP');
    expect(GameService.current.qadhaLog.length, 1);
    expect(GameService.current.lifeTotals['qadha_done'], 1);
  });

  test('Qadha: logQadhaAsync null jika tidak ada utang', () async {
    GameService.setStateForTest(GameState(qadhaLog: []));
    expect(await GameService.logQadhaAsync('subuh'), isNull);
  });

  test('Qadha: duplikat tidak dibuat (idempotent)', () async {
    final missed = daysAgo(2); // 1 hari missed (kemarin)
    GameService.setStateForTest(GameState(
      lastCheckedDate: missed,
      prayerLog: [],
      qadhaLog: [QadhaLog(date: daysAgo(1), prayer: 'subuh')],
      heroStreak: StreakState(current: 0, best: 0),
    ));

    final after = await GameService.runDailyCheck();
    // subuh kemarin sudah ada → tetap 1, bukan 2. Total = 4 lama? tidak,
    // qadha lama (subuh kemarin) + 4 baru (dzuhur/ashar/maghrib/isya kemarin).
    final subuhCount =
        after.qadhaLog.where((q) => q.prayer == 'subuh').length;
    expect(subuhCount, 1, reason: 'tidak ada duplikat utang');
  });

  // ── freezeSavedDates: shield dipakai tercatat ──
  test('Shield dipakai → tanggal tercatat di freezeSavedDates', () async {
    GameService.setStateForTest(GameState(
      lastCheckedDate: daysAgo(2),
      freezeShields: 1,
      heroStreak: StreakState(current: 5, best: 5, lastDate: daysAgo(2)),
      perPrayerStreaks: {
        for (final p in GameService.wajibList)
          p: StreakState(current: 5, best: 5, lastDate: daysAgo(2)),
      },
    ));

    final after = await GameService.runDailyCheck();

    expect(after.freezeShields, 0, reason: '1 shield terpakai');
    expect(after.freezeSavedDates, contains(daysAgo(1)),
        reason: 'tanggal proteksi tercatat');
    expect(after.heroStreak.current, 5, reason: 'streak selamat');
  });

  // ── Tawbah dismiss ──
  test('dismissTawbah set flag hari ini', () async {
    GameService.setStateForTest(GameState());
    await GameService.dismissTawbah();
    expect(GameService.current.tawbahDismissedAt, GameService.todayStr());
  });

  // ── Full chest: shield drop 15% (roll debug) ──
  test('Full chest roll<15 = shield', () async {
    final today = GameService.todayStr();
    GameService.setStateForTest(GameState(
      prayerLog: [
        for (final p in GameService.wajibList)
          PrayerLog(date: today, prayer: p, time: '12:00', type: 'wajib'),
      ],
      freezeShields: 0,
    ));
    GameService.debugChestRoll = 10;

    final reveal = await GameService.claimDailyChest();
    GameService.debugChestRoll = null;

    expect(reveal, isNotNull);
    expect(reveal!.isShield, isTrue, reason: 'roll 10 < 15 = shield');
    expect(GameService.current.freezeShields, 1);
  });
}
