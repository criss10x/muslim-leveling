import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:muslim_leveling/services/game_service.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  Future<void> loadEligibleChest() async {
    final today = GameService.todayStr();
    final logs = GameService.wajibList
        .map(
          (prayer) => PrayerLog(
            date: today,
            prayer: prayer,
            time: '12:00',
            type: 'wajib',
          ),
        )
        .toList();
    SharedPreferences.setMockInitialValues({
      'game_state_v1': jsonEncode(GameState(prayerLog: logs).toMap()),
    });
    await GameService.load();
  }

  tearDown(() {
    GameService.debugChestRoll = null;
    GameService.debugChestPickIndex = null;
  });

  test('daily chest grants a new cosmetic on a cosmetic roll', () async {
    await loadEligibleChest();
    GameService.debugChestRoll = 0;
    GameService.debugChestPickIndex = 0;

    final reveal = await GameService.claimDailyChest();

    expect(reveal!.isCosmetic, isTrue);
    expect(reveal.xpReward, 0);
    expect(GameService.current.ownedCosmetics, contains(reveal.cosmeticId));
  });

  test('daily chest grants exactly 30 XP on a standard roll', () async {
    await loadEligibleChest();
    GameService.debugChestRoll = 10;

    final reveal = await GameService.claimDailyChest();

    expect(reveal!.isCosmetic, isFalse);
    expect(reveal.xpReward, 30);
    expect(GameService.current.xp, 30);
  });
}
