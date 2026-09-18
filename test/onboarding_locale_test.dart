import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:muslim_leveling/screens/onboarding_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'helpers/app_wrap.dart';

/// Onboarding dipaksa berbahasa English: membuktikan l10n benar-benar
/// terpasang, bukan cuma pindah string ke ARB yang tak pernah dipakai.
/// Bonus: mendeteksi string Indonesia yang lupa diterjemahkan di app_en.arb
/// (regresi salin-tempel paling sering terjadi saat onboarding dirombak).
void main() {
  testWidgets('onboarding locale en: judul halaman jadi English', (
    tester,
  ) async {
    SharedPreferences.setMockInitialValues({});
    await tester.pumpWidget(
      appWrap(const OnboardingScreen(), locale: const Locale('en')),
    );

    expect(find.text('Welcome, Muslim Warrior!'), findsOneWidget);
    expect(find.text('Skip'), findsOneWidget);

    await tester.fling(find.byType(PageView), const Offset(-400, 0), 800);
    await tester.pumpAndSettle();
    expect(find.text('We Need Your Location'), findsOneWidget);
    expect(find.text('Allow Location'), findsOneWidget);
  });
}
