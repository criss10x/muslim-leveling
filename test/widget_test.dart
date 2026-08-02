// Basic smoke test — splash screen renders without throwing.
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:muslim_leveling/main.dart';
import 'package:muslim_leveling/screens/splash_screen.dart';
import 'package:muslim_leveling/theme/app_theme.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  testWidgets('App boots and shows splash', (tester) async {
    await tester.pumpWidget(const MuslimLevelingApp());
    expect(find.byType(MaterialApp), findsOneWidget);
  });

  testWidgets('SplashScreen tints its logo mark with the theme primary', (
    tester,
  ) async {
    await tester.pumpWidget(const MaterialApp(home: SplashScreen()));

    final tintedMark = find.byWidgetPredicate(
      (widget) =>
          widget is ColorFiltered &&
          widget.colorFilter ==
              ColorFilter.mode(AppColors.primary, BlendMode.srcIn),
    );
    expect(tintedMark, findsOneWidget);
    expect(
      find.descendant(of: tintedMark, matching: find.byType(Image)),
      findsOneWidget,
    );
  });

  testWidgets('Splash finishes progress within its 900 ms entry', (
    tester,
  ) async {
    SharedPreferences.setMockInitialValues({});
    await tester.pumpWidget(const MaterialApp(home: SplashScreen()));
    await tester.pump(const Duration(milliseconds: 900));

    final fill = tester.widget<FractionallySizedBox>(
      find.byKey(const Key('splash-progress-fill')),
    );
    expect(fill.widthFactor, 1);
    expect(find.byKey(const Key('splash-logo-card')), findsOneWidget);
  });
}
