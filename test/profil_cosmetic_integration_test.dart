import 'dart:ui' show SemanticsAction;

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:muslim_leveling/screens/profil_tab.dart';
import 'package:muslim_leveling/widgets/cosmetic_locker.dart';
import 'package:muslim_leveling/services/game_service.dart';
import 'package:muslim_leveling/services/entitlement_service.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  setUp(() => SharedPreferences.setMockInitialValues({}));

  testWidgets('Profil keeps skin locker compact and opens it on demand', (
    tester,
  ) async {
    final semantics = tester.ensureSemantics();
    tester.view.physicalSize = const Size(412, 2000);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await GameService.load();
    await EntitlementService.load();
    await tester.pumpWidget(
      const MaterialApp(home: Scaffold(body: ProfilTab())),
    );
    await tester.pumpAndSettle();

    final locker = find.bySemanticsLabel(
      'Buka loker skin',
      skipOffstage: false,
    );
    final hero = find.bySemanticsLabel(
      RegExp('Profile hero'),
      skipOffstage: false,
    );
    final stats = find.text('STATISTIK', skipOffstage: false);
    expect(locker, findsOneWidget);
    expect(
      tester
          .getSemantics(locker)
          .getSemanticsData()
          .hasAction(SemanticsAction.tap),
      isTrue,
    );
    expect(tester.getSize(locker).height, greaterThanOrEqualTo(44));
    expect(
      tester.getTopLeft(stats).dy,
      greaterThan(tester.getBottomRight(hero).dy),
    );
    expect(
      tester.getTopLeft(locker).dy,
      greaterThan(tester.getBottomRight(stats).dy),
    );
    expect(find.byType(CosmeticLocker), findsNothing);

    await tester.tap(locker);
    await tester.pumpAndSettle();
    expect(find.byType(CosmeticLocker), findsOneWidget);
    semantics.dispose();
  });

  testWidgets('Profil keeps statistics compact on a phone', (tester) async {
    tester.view.physicalSize = const Size(412, 915);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await GameService.load();
    await EntitlementService.load();
    await tester.pumpWidget(
      const MaterialApp(home: Scaffold(body: ProfilTab())),
    );
    await tester.pumpAndSettle();

    final grids = find.byType(GridView);
    expect(grids, findsOneWidget);
    expect(tester.getSize(grids).height, lessThan(240));
  });
}
