import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:muslim_leveling/screens/profil_tab.dart';
import 'package:muslim_leveling/theme/app_theme.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  testWidgets('hero edit action is accessible', (tester) async {
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

    final edit = find.byTooltip('Edit profil');
    expect(edit, findsOneWidget);
    expect(tester.getSize(edit).width, greaterThanOrEqualTo(44));
    expect(tester.getSize(edit).height, greaterThanOrEqualTo(44));
  });
}
