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
  testWidgets('onboarding locale en: teks halaman jadi English', (
    tester,
  ) async {
    SharedPreferences.setMockInitialValues({});
    await tester.pumpWidget(
      appWrap(const OnboardingScreen(), locale: const Locale('en')),
    );

    // Halaman 1: bahasa. Lewati ada tapi nonaktif — halaman ini tidak boleh
    // di-skip (defaultnya "ikut HP" sudah aman, jadi tetap bisa ditinggal).
    expect(find.text('Which language do you want?'), findsOneWidget);
    final skipBtn = tester.widget<TextButton>(
      find.widgetWithText(TextButton, 'Skip'),
    );
    expect(skipBtn.onPressed, isNull, reason: 'halaman bahasa tak bisa di-skip');

    // Halaman 2: nama
    await tester.fling(find.byType(PageView), const Offset(-400, 0), 800);
    await tester.pumpAndSettle();
    expect(find.text("What's your warrior name?"), findsOneWidget);

    // Halaman 3: gender — istilah Arab dipakai apa adanya di kedua bahasa
    await tester.fling(find.byType(PageView), const Offset(-400, 0), 800);
    await tester.pumpAndSettle();
    expect(find.text('Are you Ikhwan or Akhwat?'), findsOneWidget);
    expect(find.text('IKHWAN'), findsOneWidget);
    expect(find.text('AKHWAT'), findsOneWidget);

    // Halaman 4: cara main
    await tester.fling(find.byType(PageView), const Offset(-400, 0), 800);
    await tester.pumpAndSettle();
    expect(find.text('How to Play'), findsOneWidget);

    // Halaman 5: lokasi
    await tester.fling(find.byType(PageView), const Offset(-400, 0), 800);
    await tester.pumpAndSettle();
    expect(find.text('We Need Your Location'), findsOneWidget);
    expect(find.text('Allow Location'), findsOneWidget);

    // Halaman 6: notifikasi
    await tester.fling(find.byType(PageView), const Offset(-400, 0), 800);
    await tester.pumpAndSettle();
    expect(find.text('Adhan Reminders'), findsOneWidget);
    expect(find.text('Allow Notifications'), findsOneWidget);
  });
}
