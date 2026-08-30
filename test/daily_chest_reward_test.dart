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

  test('daily chest grants a new cosmetic on a cosmetic roll (15-25)', () async {
    await loadEligibleChest();
    GameService.debugChestRoll = 15; // 15-25 = cosmetic
    GameService.debugChestPickIndex = 0;

    final reveal = await GameService.claimDailyChest();

    expect(reveal!.isCosmetic, isTrue);
    expect(reveal.xpReward, 0);
    expect(GameService.current.ownedCosmetics, contains(reveal.cosmeticId));
  });

  test('daily chest grants exactly 30 XP on a standard roll (25+)', () async {
    await loadEligibleChest();
    GameService.debugChestRoll = 25; // 25+ = XP

    final reveal = await GameService.claimDailyChest();

    expect(reveal!.isCosmetic, isFalse);
    expect(reveal.xpReward, 30);
    expect(GameService.current.xp, 30);
  });

  test('daily chest grants a freeze shield on a shield roll (0-15)', () async {
    await loadEligibleChest();
    GameService.debugChestRoll = 0; // 0-15 = freeze shield

    final reveal = await GameService.claimDailyChest();

    expect(reveal!.isShield, isTrue);
    expect(reveal.rewardName, 'Freeze Shield');
    expect(reveal.shieldCount, 1);
    expect(GameService.current.freezeShields, 1);
    expect(GameService.current.xp, 0, reason: 'shield bukan XP');
  });

  test('freeze shield stack (2 claims → 2 shields)', () async {
    // Claim 1
    await loadEligibleChest();
    GameService.debugChestRoll = 0;
    var reveal = await GameService.claimDailyChest();
    expect(reveal!.shieldCount, 1);

    // Claim 2 hari berbeda (simulasi: set ulang state dengan shield 1)
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
      'game_state_v1': jsonEncode(
        GameState(
          prayerLog: logs,
          freezeShields: 1,
          dailyChestOpenedDate: '2020-01-01', // kemarin
        ).toMap(),
      ),
    });
    await GameService.load();
    GameService.debugChestRoll = 0;
    reveal = await GameService.claimDailyChest();

    expect(reveal!.shieldCount, 2);
    expect(GameService.current.freezeShields, 2);
  });
}
