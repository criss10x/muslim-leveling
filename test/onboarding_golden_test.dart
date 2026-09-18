// Golden 6 halaman onboarding (bukti visual + regresi).
//
// Pindah halaman lewat PageView.controller, bukan tap tombol: label tombol
// halaman 5 = "Izinkan Lokasi"/"Allow Location" dan menekannya memicu
// permission asli → tes nyangkut. Controller tidak menyentuh efek samping.
//
// Tiap halaman diasersi lewat judulnya sebelum dipotret — tanpa itu golden
// bisa "lulus" walau yang terpotret halaman yang salah (PageView menyimpan
// posisi saat widget di-pump ulang, mis. waktu ganti locale).
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:muslim_leveling/screens/onboarding_screen.dart';
import 'package:muslim_leveling/theme/app_theme.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'helpers/app_wrap.dart';

const _titles = {
  'id': [
    'Mau pakai bahasa apa?',
    'Siapa nama pejuangmu?',
    'Kamu Ikhwan atau Akhwat?',
    'Cara Main',
    'Butuh Lokasimu',
    'Pengingat Adzan',
  ],
  'en': [
    'Which language do you want?',
    "What's your warrior name?",
    'Are you Ikhwan or Akhwat?',
    'How to Play',
    'We Need Your Location',
    'Adhan Reminders',
  ],
};

void main() {
  testWidgets('golden 6 halaman onboarding (id + en)', (tester) async {
    GoogleFonts.config.allowRuntimeFetching = false;
    tester.view.physicalSize = const Size(1080, 2280);
    tester.view.devicePixelRatio = 3.0;
    addTearDown(tester.view.reset);

    for (final code in ['id', 'en']) {
      SharedPreferences.setMockInitialValues({});
      await tester.pumpWidget(
        appWrap(
          const OnboardingScreen(),
          theme: AppTheme.dark(),
          locale: Locale(code),
        ),
      );
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 600));

      final ctrl = tester.widget<PageView>(find.byType(PageView)).controller!;
      for (var page = 0; page < 6; page++) {
        ctrl.jumpToPage(page);
        await tester.pumpAndSettle();

        expect(
          find.text(_titles[code]![page]),
          findsOneWidget,
          reason: '$code halaman ${page + 1}',
        );
        await expectLater(
          find.byType(OnboardingScreen),
          matchesGoldenFile('goldens/onb_${code}_${page + 1}.png'),
        );
      }
    }
  });
}
