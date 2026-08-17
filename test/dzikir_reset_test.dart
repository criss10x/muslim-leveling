import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:muslim_leveling/services/game_service.dart';

// ponytail: runnable check — resetZikir hanya nolkan counter aktif,
// total dzikir hari ini (count) TETAP akumulasi sampai hari ganti.
void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  setUp(() {
    SharedPreferences.setMockInitialValues({});
    GameService.resetForTest();
  });

  test('reset counter aktif tidak mengurangi total dzikir hari ini', () async {
    await GameService.load();
    // 5 subhanallah + 3 alhamdulillah = total 8.
    for (var i = 0; i < 5; i++) {
      await GameService.incrementZikir(key: 'subhanallah');
    }
    for (var i = 0; i < 3; i++) {
      await GameService.incrementZikir(key: 'alhamdulillah');
    }
    expect(GameService.zikirCountToday, 8);
    expect(GameService.zikirCountsToday['subhanallah'], 5);

    await GameService.resetZikir('subhanallah');

    // Counter subhanallah nol, tapi total hari ini tetap 8 (3 alhamdulillah).
    expect(GameService.zikirCountsToday['subhanallah'], isNull);
    expect(GameService.zikirCountToday, 8);
  });
}