import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:muslim_leveling/screens/home_tab.dart';
import 'package:muslim_leveling/services/game_service.dart';
import 'package:muslim_leveling/theme/app_theme.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  testWidgets('Home XP fill animates after XP changes', (tester) async {
    GoogleFonts.config.allowRuntimeFetching = false;
    SharedPreferences.setMockInitialValues({
      'game_state_v1': '{"xp":0,"level":1}',
    });

    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.dark(),
        home: const Scaffold(body: HomeTab()),
      ),
    );
    await tester.pump(const Duration(milliseconds: 300));

    await GameService.addXp(20);
    await tester.pump(const Duration(milliseconds: 250));

    final fill = find.byKey(const Key('home-xp-progress-fill'));
    expect(fill, findsOneWidget);
    expect(
      find.ancestor(
        of: fill,
        matching: find.byWidgetPredicate(
          (widget) => widget is TweenAnimationBuilder<double>,
        ),
      ),
      findsOneWidget,
    );
  });
}
