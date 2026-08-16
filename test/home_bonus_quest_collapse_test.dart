import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:muslim_leveling/services/game_service.dart';
import 'package:muslim_leveling/screens/home_tab.dart';

// ponytail: runnable check — Bonus Quest collapsed shows active-only subset,
// tap chevron expands to full 9 rows. Clock frozen at 13:00 → Dhuha window
// (terbit+15 .. dzuhur) is active, Tahajjud (isya..imsak) is not.
void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  GoogleFonts.config.allowRuntimeFetching = false;

  setUp(() async {
    SharedPreferences.setMockInitialValues({});
    GameService.resetForTest();
    GameService.setTestNow('11:00'); // jendela Dhuha (terbit+15 .. dzuhur)
    await GameService.load();
  });
  tearDown(() => GameService.setTestNow(null));

  testWidgets('collapsed shows active only; chevron expands to all 9',
      (t) async {
    await t.pumpWidget(const MaterialApp(home: Scaffold(body: HomeTab())));
    await t.pump();
    await t.pump();
    await t.scrollUntilVisible(find.textContaining('BONUS QUEST'), 200);

    expect(find.text('Dhuha'), findsOneWidget); // aktif jam 13:00
    expect(find.text('Tahajjud'), findsNothing); // terkunci → tersembunyi

    await t.tap(find.byIcon(Icons.expand_more));
    await t.pumpAndSettle();
    expect(find.text('Tahajjud'), findsOneWidget); // expanded → semua tampil
    expect(find.text("Ba'diyah Isya"), findsOneWidget);
  });
}
