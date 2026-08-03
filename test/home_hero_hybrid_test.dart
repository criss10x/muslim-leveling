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
      final backgroundFinder = find.descendant(
        of: find.byKey(const Key('home-hero-card')),
        matching: find.byWidgetPredicate((widget) {
          if (widget is! DecoratedBox || widget.decoration is! BoxDecoration) {
            return false;
          }
          final decoration = widget.decoration as BoxDecoration;
          return decoration.gradient is RadialGradient &&
              decoration.border != null;
        }),
      );
      final background = tester.widget<DecoratedBox>(backgroundFinder);
      final backgroundDecoration = background.decoration as BoxDecoration;
      final pattern = tester.widget<CustomPaint>(
        find.byKey(const Key('home-hero-pattern')),
      );
      expect(decoration.boxShadow, isNull);
      expect(
        backgroundDecoration.borderRadius,
        BorderRadius.circular(AppRadius.xl),
      );
      expect(
        find.byWidgetPredicate(
          (widget) =>
              widget is IgnorePointer && identical(widget.child, background),
        ),
        findsOneWidget,
      );
      expect(find.byKey(const Key('home-hero-pattern')), findsOneWidget);
      final medallionFinder = find.byKey(const Key('home-rank-medallion'));
      final medallion = tester.widget<Container>(medallionFinder);
      expect(medallionFinder, findsOneWidget);
      expect(
        find.byWidgetPredicate(
          (widget) =>
              widget is IgnorePointer && identical(widget.child, medallion),
        ),
        findsOneWidget,
      );
      expect((pattern.painter as dynamic).opacity, 0.05);
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
    final pattern = tester.widget<CustomPaint>(
      find.byKey(const Key('home-hero-pattern')),
    );
    expect(decoration.boxShadow, hasLength(1));
    expect(find.byKey(const Key('home-hero-pattern')), findsOneWidget);
    expect(find.byKey(const Key('home-rank-medallion')), findsOneWidget);
    expect(find.byKey(const Key('home-xp-progress-fill')), findsOneWidget);
    expect((pattern.painter as dynamic).opacity, 0.09);
    expect(tester.takeException(), isNull);
  });
}
