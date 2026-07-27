import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:muslim_leveling/widgets/cosmetic_locker.dart';
import 'package:muslim_leveling/services/cosmetic_catalog.dart';
import 'package:muslim_leveling/services/game_service.dart';
import 'package:muslim_leveling/services/entitlement_service.dart';
import 'package:muslim_leveling/theme/app_theme.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  setUp(() => SharedPreferences.setMockInitialValues({}));
  tearDown(() => isLightTheme = false);

  testWidgets('empty free slot explains how to unlock cosmetics', (
    tester,
  ) async {
    await GameService.load();
    await EntitlementService.load();
    await tester.pumpWidget(
      const MaterialApp(home: Scaffold(body: CosmeticLocker())),
    );
    await tester.pumpAndSettle();

    expect(
      find.text('Selesaikan quest harian untuk membuka skin dari Daily Chest.'),
      findsOneWidget,
    );
  });

  testWidgets('tapping an owned free cosmetic equips it', (tester) async {
    await GameService.load();
    await EntitlementService.load();
    await GameService.debugSeedOwned(['title_crescent']);

    await tester.pumpWidget(
      const MaterialApp(home: Scaffold(body: CosmeticLocker())),
    );
    await tester.pumpAndSettle();

    // Switch to the Title tab, then tap the owned title.
    await tester.tap(find.text('Title'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Bulan Sabit Menyala'));
    await tester.pumpAndSettle();

    expect(GameService.current.equipped['title'], 'title_crescent');
  });

  testWidgets('tapping an equipped free cosmetic unequips it', (tester) async {
    await GameService.load();
    await EntitlementService.load();
    await GameService.debugSeedOwned(['title_crescent']);
    await GameService.equipCosmetic(
      CosmeticSlot.title,
      'title_crescent',
      isPro: false,
    );

    await tester.pumpWidget(
      const MaterialApp(home: Scaffold(body: CosmeticLocker())),
    );
    await tester.pumpAndSettle();
    await tester.tap(find.text('Title'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Bulan Sabit Menyala'));
    await tester.pumpAndSettle();

    expect(GameService.current.equipped.containsKey('title'), isFalse);
  });

  testWidgets('locker labels use explicit light-theme ink', (tester) async {
    isLightTheme = true;
    await GameService.load();
    await EntitlementService.load();
    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.light(),
        home: const Scaffold(body: CosmeticLocker()),
      ),
    );
    await tester.pumpAndSettle();

    expect(
      tester.widget<Text>(find.text('Bingkai')).style?.color,
      AppColors.primary,
    );
    for (final label in ['Aura', 'Title', 'KOLEKSI']) {
      expect(
        tester.widget<Text>(find.text(label)).style?.color,
        AppColors.onSurface,
      );
    }
  });
}
