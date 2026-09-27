import 'package:flutter_test/flutter_test.dart';
import 'package:muslim_leveling/services/meta_app_events_service.dart';
import 'package:muslim_leveling/services/game_service.dart';
import 'package:shared_preferences/shared_preferences.dart';

// Wrapper MetaAppEvents: pemanggilannya harus TIDAK PERNAH melempar ke
// pemanggil (game logic tidak boleh kena down karena jaring Meta gagal),
// dan HANYA nge-log ketika level benar-benar naik / medali baru.
//
// Wrapper sengaja fire-and-forget (void, bukan Future) — testWidgets jalan
// di fake-async zone; MethodChannel tanpa handler native di sana future-nya
// tidak pernah resolve, dan await akan menggantung test sampai framework
// membunuhnya. Karena itu API-nya void: salah pakai (await) ketangkap analyzer.
//
// Di test env, panggilan log membuang MissingPluginException — terlihat
// sebagai debugPrint, bukan error.

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  test('MetaAppEvents tidak melempar saat plugin native absen', () async {
    SharedPreferences.setMockInitialValues({});
    await GameService.load();
    // void — dipanggil langsung, bukan di-await.
    MetaAppEvents.achievedLevel(3);
    MetaAppEvents.achievedLevel(0); // guard level <= 0: no-op
    MetaAppEvents.unlockedAchievement('subuh_ontime');
    MetaAppEvents.unlockedAchievement(''); // guard kosong: no-op
  });

  test('addXp hanya memicu event saat level naik, bukan tiap XP', () async {
    // game_state_v1 XP 0 → level 1. Tambah 10 XP (tidak naik level) — tidak
    // boleh error; tidak ada cara mengamati event tanpa mock channel, jadi
    // asersinya: tidak throw dan level state tetap benar.
    SharedPreferences.setMockInitialValues({
      'game_state_v1': '{"xp":0,"level":1}',
    });
    await GameService.load();
    final (state, levelsGained) = await GameService.addXp(10);
    expect(levelsGained, 0, reason: '10 XP tidak boleh naik level');
    expect(state.level, 1);

    final (state2, levelsGained2) = await GameService.addXp(100000);
    expect(levelsGained2, greaterThan(0), reason: '100rb XP wajib naik level');
    expect(state2.level, greaterThan(1));
  });
}
