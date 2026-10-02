import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:muslim_leveling/services/game_service.dart';
import 'package:muslim_leveling/screens/home_tab.dart';
import 'package:muslim_leveling/theme/app_icons.dart';
import 'helpers/app_wrap.dart';

// ponytail: runnable check untuk catch-up sunnah (2026-10-02):
//   (a) sunnah telat (lewat jendela waktu) tak tampil di COLLAPSED (hidden),
//       tapi muncul saat EXPANDED dengan baris yang bisa dipencet
//       (catch-up, XP 10 bukan 15).
//   (b) claim telat masuk prayerLog dgn catchUp=true dan XP 10.
//   (c) unlog catch-up balikin XP yang persis (10) — symmetric.
void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  GoogleFonts.config.allowRuntimeFetching = false;

  setUp(() async {
    SharedPreferences.setMockInitialValues({});
    GameService.resetForTest();
    // Di luar jendela Dhuha (terbit+15 → dzuhur), dan bukan Tahajjud.
    GameService.setTestNow('13:00');
    await GameService.load();
  });
  tearDown(() => GameService.setTestNow(null));

  test('catch-up: dhuha telat bisa diclaim dgn XP lebih kecil (10)', () async {
    // Jam 13:00 — Dhuha lewat window (terbit 05:35+15=05:50 → dzuhur 12:10).
    final res = await GameService.logPrayerAsync('dhuha', 'sunnah',
        catchUp: true);
    expect(res, isNotNull, reason: 'catch-up harus berhasil bila on-time gagal');
    expect(res!.$2, GameService.sunnahCatchUpXp);
    final today = GameService.todayStr();
    final log = GameService.current.prayerLog
        .where((l) => l.date == today && l.prayer == 'dhuha');
    expect(log, isNotEmpty);
    expect(log.first.catchUp, isTrue);
  });

  test('on-time path tanpa catchUp tetap menolak telat', () async {
    final res = await GameService.logPrayerAsync('dhuha', 'sunnah');
    expect(res, isNull, reason: 'tanpa catchUp, telat tetap ditolak');
  });

  test('unlog catch-up kembali 10 XP (symmetric)', () async {
    await GameService.logPrayerAsync('dhuha', 'sunnah', catchUp: true);
    final before = GameService.current.xp;
    await GameService.unlogPrayer('dhuha');
    final after = GameService.current.xp;
    expect(before - after, GameService.sunnahCatchUpXp);
  });

  testWidgets('catch-up baris hidden di collapsed; kelihatan di expanded',
      (t) async {
    await t.pumpWidget(appWrap(Scaffold(body: HomeTab())));
    await t.pump();
    await t.pump();
    await t.scrollUntilVisible(find.textContaining('BONUS QUEST'), 200);

    // Jam 13:00: Dhuha telat → tidak tampil collapsed (hidden).
    expect(find.text('Dhuha'), findsNothing);

    // Expand → Dhuha kelihatan.
    await t.ensureVisible(find.byIcon(AppIcons.expandMore));
    await t.pumpAndSettle();
    await t.tap(find.byIcon(AppIcons.expandMore));
    await t.pumpAndSettle();
    expect(find.text('Dhuha'), findsOneWidget);
  });
}
