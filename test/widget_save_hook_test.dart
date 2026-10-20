import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:muslim_leveling/services/game_service.dart';
import 'package:muslim_leveling/services/widget_snapshot.dart';

/// Membuktikan penyambungan nyata: setiap penyimpanan game menghasilkan
/// snapshot widget. Tanpa tes ini, `refreshWidget()` bisa ada tapi tidak pernah
/// dipanggil dan semua tes lain tetap hijau.
void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() {
    SharedPreferences.setMockInitialValues({});
    GameService.resetForTest();
  });

  test('menyimpan game menulis snapshot widget', () async {
    await GameService.load();
    final p = await SharedPreferences.getInstance();
    // Snapshot awal belum tentu ada; picu lewat aksi nyata yang menyimpan.
    await GameService.addXp(10);
    await pumpEventQueue();

    final raw = p.getString(WidgetSnapshot.prefKey);
    expect(raw, isNotNull, reason: 'save() harus menulis snapshot widget');
    // Bentuk snapshot v2: hari ini berisi lima sholat wajib, bukan quest.
    expect(raw, contains('"days"'));
    expect(raw, contains('"subuh"'));
    expect(raw, contains('"total":5'));
    expect(raw, isNot(contains('"quests"')));
  });

  test('snapshot memuat tanggal hari ini, bukan tanggal tetap', () async {
    await GameService.load();
    await GameService.addXp(5);
    await pumpEventQueue();

    final raw = (await SharedPreferences.getInstance())
        .getString(WidgetSnapshot.prefKey)!;
    final today = WidgetSnapshot.dateKey(DateTime.now());
    expect(raw, contains(today));
  });

  test('XP yang diberikan benar-benar masuk (aksi nyata, bukan mock)', () async {
    await GameService.load();
    final before = GameService.current.xp;
    await GameService.addXp(25);
    expect(GameService.current.xp, before + 25);
  });
}
