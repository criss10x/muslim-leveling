import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:muslim_leveling/services/game_service.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  setUp(() {
    SharedPreferences.setMockInitialValues({});
    GameService.resetForTest();
  });

  test('first swipe of a page grants XP once per day; cap 4', () async {
    await GameService.load();
    final xp0 = GameService.current.xp;

    expect(await GameService.claimHighlightSwipeXp(0), isTrue); // Ayat
    expect(await GameService.claimHighlightSwipeXp(1), isTrue); // Hadis
    expect(await GameService.claimHighlightSwipeXp(2), isTrue); // Doa
    expect(await GameService.claimHighlightSwipeXp(3), isTrue); // Kata Ulama
    expect(GameService.current.xp, xp0 + 4);
    expect(GameService.current.highlightSwipeDate, GameService.todayStr());
    expect(GameService.current.highlightSwipeMask, 15);

    // Same day, same pages → rejected, no double XP.
    expect(await GameService.claimHighlightSwipeXp(0), isFalse);
    expect(await GameService.claimHighlightSwipeXp(2), isFalse);
    expect(GameService.current.xp, xp0 + 4);
  });

  test('invalid page numbers are rejected', () async {
    await GameService.load();
    final xp0 = GameService.current.xp;

    expect(await GameService.claimHighlightSwipeXp(-1), isFalse);
    expect(await GameService.claimHighlightSwipeXp(4), isFalse);
    expect(GameService.current.xp, xp0);
    expect(GameService.current.highlightSwipeMask, 0);
  });

  test('mask persists through GameState round-trip', () async {
    await GameService.load();
    await GameService.claimHighlightSwipeXp(0);
    await GameService.claimHighlightSwipeXp(2);

    final restored = GameState.fromMap(GameService.current.toMap());
    expect(restored.highlightSwipeMask & 1, 1);
    expect(restored.highlightSwipeMask & 4, 4);
    expect(restored.highlightSwipeMask & 2, 0);
    expect(restored.highlightSwipeDate, GameService.todayStr());
  });
}
