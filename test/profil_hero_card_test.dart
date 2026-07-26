import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:muslim_leveling/screens/profil_tab.dart';
import 'package:muslim_leveling/theme/app_theme.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  testWidgets('hero exposes tier identity without reducing edit target',
      (tester) async {
    GoogleFonts.config.allowRuntimeFetching = false;
    SharedPreferences.setMockInitialValues({
      'nickname': 'Pejuang',
      'onboarding_done': true,
      'avatar_path': '',
    });

    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.dark(),
        home: const Scaffold(body: ProfilTab()),
      ),
    );
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 300));

    expect(find.bySemanticsLabel('Profile hero — Warrior'), findsOneWidget);
    final edit = find.byTooltip('Edit profil');
    expect(tester.getSize(edit).shortestSide, greaterThanOrEqualTo(44));
  });
}
