import 'package:flutter_test/flutter_test.dart';
import 'package:muslim_leveling/services/game_service.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Save lama dari versi sebelumnya masih memuat 'qadhaLog' dan
/// 'tawbahDismissedAt'. Uji bahwa GameState.fromMap mengabaikannya dengan
/// tenang (tidak crash) dan data lain tetap terbaca.
void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  test('save lama dengan qadhaLog/tawbahDismissedAt tetap terbaca', () {
    final legacy = <String, dynamic>{
      'xp': 1234,
      'level': 9,
      'lastCheckedDate': '2026-09-30',
      'haidMode': true,
      'freezeShields': 2,
      'comebackCount': 3,
      // dua field yang sistemnya sudah dihapus
      'qadhaLog': [
        {'date': '2026-09-28', 'prayer': 'subuh'},
        {'date': '2026-09-28', 'prayer': 'maghrib'},
      ],
      'tawbahDismissedAt': '2026-09-29',
      'lifeTotals': {'qadha_done': 4},
      'freezeSavedDates': ['2026-09-27'],
    };

    final state = GameState.fromMap(legacy);

    expect(state.xp, 1234);
    expect(state.haidMode, isTrue);
    expect(state.freezeShields, 2);
    expect(state.comebackCount, 3);
    expect(state.freezeSavedDates, contains('2026-09-27'));
    // qadha_done tetap dibaca sebagai lifeTotal biasa (tidak dihapus datanya)
    expect(state.lifeTotals['qadha_done'], 4);

    // round-trip: toMap tidak lagi menulis kedua field itu
    final out = state.toMap();
    expect(out.containsKey('qadhaLog'), isFalse,
        reason: 'qadhaLog tidak ditulis lagi');
    expect(out.containsKey('tawbahDismissedAt'), isFalse,
        reason: 'tawbahDismissedAt tidak ditulis lagi');
  });

  test('runDailyCheck tetap jalan tanpa sistem qadha', () async {
    GameService.resetForTest();
    SharedPreferences.setMockInitialValues({});
    GameService.setStateForTest(GameState(
      lastCheckedDate: GameService.dailyDateKey(
        DateTime.now().subtract(const Duration(days: 2)),
      ),
      heroStreak: StreakState(current: 5, best: 5),
      freezeShields: 1,
    ));

    final after = await GameService.runDailyCheck();

    // shield tetap bekerja; tidak ada yang pecah karena blok qadha hilang
    expect(after.freezeShields, 0);
    expect(after.freezeSavedDates, isNotEmpty);
  });
}
