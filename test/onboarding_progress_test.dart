// Regresi C: progres terlihat, back mundur satu langkah, mascot ikon,
// counter nama jujur, city picker ikut bahasa aktif.
//
// Tiap tes di sini sudah diuji-negatif: perbaikannya dimatikan sementara dan
// tesnya GAGAL dengan pesan yang tepat. Tanpa langkah itu, tes seperti ini cuma
// hiasan hijau.
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:muslim_leveling/screens/onboarding_screen.dart';
import 'package:muslim_leveling/widgets/city_picker.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'helpers/app_wrap.dart';

Future<void> _settle(WidgetTester t, int ms) async {
  for (var i = 0; i < ms ~/ 50; i++) {
    await t.pump(const Duration(milliseconds: 50));
  }
}

void main() {
  setUpAll(() => GoogleFonts.config.allowRuntimeFetching = false);

  testWidgets('progres onboarding terlihat mata di keenam halaman',
      (tester) async {
    SharedPreferences.setMockInitialValues({});
    await tester.pumpWidget(appWrap(const OnboardingScreen()));
    await _settle(tester, 900);

    final pv = tester.widget<PageView>(find.byType(PageView));
    for (var p = 0; p < 6; p++) {
      pv.controller!.jumpToPage(p);
      await _settle(tester, 700);
      // 'n/6' harus ada sebagai teks di layar, bukan hanya di dalam Semantics:
      // dulu progres hanya untuk TalkBack, mata tidak dapat apa-apa.
      expect(find.text('${p + 1}/6'), findsOneWidget,
          reason: 'halaman ${p + 1} tidak menampilkan progres visual');
    }
  });

  testWidgets('Android back mundur satu halaman, bukan keluar app',
      (tester) async {
    SharedPreferences.setMockInitialValues({});
    await tester.pumpWidget(appWrap(const OnboardingScreen()));
    await _settle(tester, 900);
    tester.widget<PageView>(find.byType(PageView)).controller!.jumpToPage(3);
    await _settle(tester, 700);

    await tester.binding.handlePopRoute();
    await _settle(tester, 700);

    final page =
        tester.widget<PageView>(find.byType(PageView)).controller!.page;
    // Onboarding adalah root route (splash pakai pushReplacement), jadi back
    // bawaan keluar app dan membuang semua jawaban tanpa peringatan.
    expect(page!.round(), 2, reason: 'back tidak mundur satu halaman');
  });

  testWidgets('mascot memakai ikon Phosphor, bukan emoji fontSize mati',
      (tester) async {
    SharedPreferences.setMockInitialValues({});
    await tester.pumpWidget(appWrap(const OnboardingScreen()));
    await _settle(tester, 900);

    final pv = tester.widget<PageView>(find.byType(PageView));
    for (final p in [0, 1, 4, 5]) {
      pv.controller!.jumpToPage(p);
      await _settle(tester, 600);
      final bigIcon = find.descendant(
        of: find.byType(PageView),
        matching: find.byWidgetPredicate(
            (w) => w is Icon && (w.size ?? 0) >= 60),
      );
      final bigText = find.byWidgetPredicate(
          (w) => w is Text && (w.style?.fontSize ?? 0) >= 60);
      expect(bigIcon, findsWidgets, reason: 'halaman ${p + 1} tanpa mascot');
      expect(bigText, findsNothing,
          reason: 'halaman ${p + 1} masih memakai emoji ukuran tetap');
    }
  });

  testWidgets('counter nama menunjukkan batas, bukan memotong diam-diam',
      (tester) async {
    SharedPreferences.setMockInitialValues({});
    await tester.pumpWidget(appWrap(const OnboardingScreen()));
    await _settle(tester, 900);
    tester.widget<PageView>(find.byType(PageView)).controller!.jumpToPage(1);
    await _settle(tester, 700);

    await tester.enterText(find.byType(TextField), 'a' * 20);
    await tester.pump();
    expect(find.text('20/20'), findsOneWidget);

    await tester.enterText(find.byType(TextField), 'a' * 25);
    await tester.pump();
    expect(find.text('20/20'), findsOneWidget,
        reason: 'karakter ke-21 ditolak tanpa jejak di layar');
  });

  testWidgets('city picker ikut bahasa aktif', (tester) async {
    late Future<({String id, String name, bool abroad})?> sel;
    await tester.pumpWidget(appWrap(
      Builder(
        builder: (c) => TextButton(
          onPressed: () => sel = CityPicker.show(c),
          child: const Text('Buka'),
        ),
      ),
      locale: const Locale('en'),
    ));
    await tester.tap(find.text('Buka'));
    await tester.pumpAndSettle();
    // Langkah wilayah juga harus ikut bahasa aktif, bukan hanya layar provinsi.
    expect(find.text('Select Region'), findsOneWidget);
    expect(find.text('Abroad'), findsOneWidget);
    await tester.tap(find.text('Indonesia'));
    await tester.pumpAndSettle();

    // Dialog ini dulu hardcode Indonesia walau app berbahasa Inggris.
    expect(find.text('Pick a Province'), findsOneWidget);
    expect(find.text('Pilih Provinsi'), findsNothing);
    expect(find.text('Close'), findsOneWidget);
    sel.ignore();
  });
}
