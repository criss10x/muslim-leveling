import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:muslim_leveling/services/game_service.dart';
import 'package:muslim_leveling/services/achievement_service.dart';

// ponytail: runnable check — ladder akumulasi (eks badge system) jalan lewat
// AchievementService: threshold benar, unlock baru masuk antrean announcer.
List<PrayerLog> _wajibLogs(int days, {int bonusXp = 0}) {
  const wajib = ['subuh', 'dzuhur', 'ashar', 'maghrib', 'isya'];
  return [
    for (var d = 0; d < days; d++)
      for (final p in wajib)
        PrayerLog(
          date: '2026-01-${(d + 1).toString().padLeft(2, '0')}',
          prayer: p,
          time: '12:00',
          type: 'wajib',
          bonusXp: bonusXp,
        ),
  ];
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  setUp(() {
    SharedPreferences.setMockInitialValues({});
    GameService.resetForTest();
    AchievementService.resetForTest();
  });

  Future<void> refresh() async {
    await AchievementService.load();
    await AchievementService.refresh(silent: true);
  }

  test('wajib ladder: 25 wajib → rookie+grinder, warrior (50x) belum', () async {
    // 5 hari x 5 wajib = 25.
    GameService.setStateForTest(GameState(prayerLog: _wajibLogs(5)));
    await refresh();
    expect(AchievementService.isUnlocked('wajib_rookie'), isTrue);
    expect(AchievementService.isUnlocked('wajib_grinder'), isTrue);
    expect(AchievementService.isUnlocked('wajib_warrior'), isFalse);
  });

  test('jamaah ladder: 5x bonus berjamaah → jamaah_rookie', () async {
    GameService.setStateForTest(GameState(
      prayerLog: _wajibLogs(1, bonusXp: GameService.jamaahBonusXp),
    ));
    await refresh();
    expect(AchievementService.isUnlocked('jamaah_rookie'), isTrue);
    expect(AchievementService.isUnlocked('jamaah_grinder'), isFalse);
  });

  test('hadis ladder: 5 hadis → hadis_rookie (via noteHadisRead)', () async {
    await GameService.load();
    await AchievementService.load();
    for (var id = 1; id <= 5; id++) {
      await GameService.noteHadisRead(id);
    }
    await AchievementService.refresh(silent: true);
    expect(AchievementService.isUnlocked('hadis_rookie'), isTrue);
    expect(AchievementService.isUnlocked('hadis_grinder'), isFalse);
  });

  test('unlock baru masuk antrean announcer global', () async {
    GameService.setStateForTest(GameState(prayerLog: _wajibLogs(5)));
    await AchievementService.load();
    expect(AchievementService.pendingAnnouncer.value, isEmpty);
    await AchievementService.refresh(); // non-silent → antrean terisi
    expect(AchievementService.pendingAnnouncer.value, isNotEmpty);
  });
}
