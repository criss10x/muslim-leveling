import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:muslim_leveling/services/game_service.dart';

// ponytail: runnable check — side quest auto-claim: dzikir ke-100 & 10 ayat
// baca Quran (+15 XP masing-masing, sekali per hari).
void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  setUp(() {
    SharedPreferences.setMockInitialValues({});
    GameService.resetForTest();
  });

  test('dzikir ke-100 → auto claim +15 XP, sekali saja', () async {
    await GameService.load();
    final xp0 = GameService.current.xp;
    for (var i = 0; i < 99; i++) {
      await GameService.incrementZikir();
    }
    expect(GameService.isPrayerCheckedToday('zikir100'), isFalse);
    await GameService.incrementZikir(); // ke-100
    expect(GameService.isPrayerCheckedToday('zikir100'), isTrue);
    expect(GameService.current.xp, xp0 + 15);
    await GameService.incrementZikir(); // ke-101 → tidak dobel
    expect(GameService.current.xp, xp0 + 15);
  });

  test('10 ayat maju → side quest Baca Quran ter-log (+15 XP)', () async {
    await GameService.load();
    final xp0 = GameService.current.xp;
    for (var i = 1; i <= 10; i++) {
      await GameService.noteQuranPosition(1, i); // Al-Fatihah 1..10
    }
    expect(GameService.tilawahDoneToday, isTrue);
    expect(GameService.current.xp, xp0 + 10 /*ayat*/ + 15 /*side quest*/);
  });

  test('kurang dari 10 ayat → belum ter-log', () async {
    await GameService.load();
    for (var i = 1; i <= 5; i++) {
      await GameService.noteQuranPosition(1, i);
    }
    expect(GameService.tilawahDoneToday, isFalse);
  });
}
