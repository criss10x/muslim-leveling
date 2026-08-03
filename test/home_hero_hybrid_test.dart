import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:muslim_leveling/screens/home_tab.dart';
import 'package:muslim_leveling/theme/app_theme.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  setUp(() {
    GoogleFonts.config.allowRuntimeFetching = false;
    SharedPreferences.setMockInitialValues({
      'game_state_v1': '{"xp":0,"level":1}',
    });
  });

  Future<void> pumpHero(WidgetTester tester, {required bool light}) async {
    isLightTheme = light;
    await tester.pumpWidget(
      MaterialApp(
        theme: light ? AppTheme.light() : AppTheme.dark(),
        home: const Scaffold(body: HomeTab()),
      ),
    );
    await tester.pump(const Duration(milliseconds: 300));
  }

  testWidgets(
    'Home hero renders Islamic pattern and rank medallion in light mode',
    (tester) async {
      await pumpHero(tester, light: true);

      final card = tester.widget<Container>(
        find.byKey(const Key('home-hero-card')),
      );
      final decoration = card.decoration! as BoxDecoration;
      expect(decoration.boxShadow, isNull);
      expect(find.byKey(const Key('home-hero-pattern')), findsOneWidget);
      expect(find.byKey(const Key('home-rank-medallion')), findsOneWidget);
      expect(find.text('CURRENT RANK'), findsOneWidget);
      expect(tester.takeException(), isNull);
    },
  );

  testWidgets('Home hero adds one restrained rank glow in dark mode', (
    tester,
  ) async {
    await pumpHero(tester, light: false);

    final card = tester.widget<Container>(
      find.byKey(const Key('home-hero-card')),
    );
    final decoration = card.decoration! as BoxDecoration;
    expect(decoration.boxShadow, hasLength(1));
    expect(find.byKey(const Key('home-hero-pattern')), findsOneWidget);
    expect(find.byKey(const Key('home-rank-medallion')), findsOneWidget);
    expect(find.byKey(const Key('home-xp-progress-fill')), findsOneWidget);
    expect(tester.takeException(), isNull);
  });
}
