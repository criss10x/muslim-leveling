import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:muslim_leveling/screens/dashboard_shell.dart';
import 'package:muslim_leveling/screens/home_tab.dart';
import 'package:muslim_leveling/services/game_service.dart';
import 'package:muslim_leveling/services/achievement_service.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  setUp(() {
    SharedPreferences.setMockInitialValues({});
    GameService.resetForTest();
    AchievementService.resetForTest();
  });

  testWidgets('DashboardShell IndexedStack mengisi penuh (bukan collapse 0x0)',
      (tester) async {
    await tester.pumpWidget(const MaterialApp(home: DashboardShell()));
    await tester.pump();

    final stack = tester.widget<IndexedStack>(find.byType(IndexedStack));
    final ctx = tester.element(find.byType(IndexedStack));
    final size = ctx.size!;
    // Bukan 0x0 — shell render konten HomeTab, bukan layar hitam kosong.
    expect(size.width, greaterThan(0));
    expect(size.height, greaterThan(0));
    expect(stack.index, 0);
    expect(find.byType(HomeTab), findsOneWidget);
  });
}