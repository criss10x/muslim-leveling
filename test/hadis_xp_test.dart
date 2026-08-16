import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:muslim_leveling/services/game_service.dart';

// ponytail: runnable check — XP hadis: +1 per id baru (cap 10/hari), dwell
// ditegakkan di UI; 5 hadis → auto-claim side quest (+15 XP).
void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  setUp(() {
    SharedPreferences.setMockInitialValues({});
    GameService.resetForTest();
  });

  test('hadis baru +1 XP; id sama tidak dobel; cap 10/hari', () async {
    await GameService.load();
    final xp0 = GameService.current.xp;
    for (var id = 1; id <= 10; id++) {
      await GameService.noteHadisRead(id);
    }
    // 10 XP baca + 15 side quest (tercapai di id ke-5).
    expect(GameService.current.xp, xp0 + 10 + 15);
    expect(GameService.hadisReadToday, 10);
    // id ke-11 → terhitung terbaca tapi XP cap.
    await GameService.noteHadisRead(11);
    expect(GameService.current.xp, xp0 + 10 + 15);
    expect(GameService.hadisReadToday, 11);
    // id lama → diabaikan.
    await GameService.noteHadisRead(1);
    expect(GameService.hadisReadToday, 11);
  });

  test('5 hadis → side quest hadis5 ter-log sekali saja', () async {
    await GameService.load();
    for (var id = 1; id <= 4; id++) {
      await GameService.noteHadisRead(id);
    }
    expect(GameService.isPrayerCheckedToday('hadis5'), isFalse);
    await GameService.noteHadisRead(5);
    expect(GameService.isPrayerCheckedToday('hadis5'), isTrue);
  });
}
