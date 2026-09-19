// Regresi: progres onboarding bisa dilanjutkan.
//
// Dulu semua jawaban baru ditulis di halaman terakhir, jadi app yang dibunuh
// OS — atau sekadar di-background lalu ditutup user di halaman 4 — kembali ke
// halaman 1 dan membuang 4 halaman yang sudah dilewati.
//
// Tiap tes di sini sudah diuji-negatif: perbaikannya dimatikan sementara dan
// tesnya GAGAL dengan pesan yang tepat.
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:muslim_leveling/screens/onboarding_screen.dart';
import 'package:muslim_leveling/screens/splash_screen.dart';
import 'package:muslim_leveling/theme/app_icons.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'helpers/app_wrap.dart';

const _pageKey = 'onboarding_page';

/// Pump tanpa pumpAndSettle: DashboardShell punya animasi yang tidak pernah
/// berhenti, jadi pumpAndSettle selalu timeout setelah onboarding selesai.
Future<void> _settle(WidgetTester t, int ms) async {
  for (var i = 0; i < ms ~/ 50; i++) {
    await t.pump(const Duration(milliseconds: 50));
  }
}

/// Splash menunggu 900 ms sebelum memutuskan ke mana pergi.
Future<void> _bootSplash(WidgetTester t) async {
  await t.pumpWidget(appWrap(const SplashScreen()));
  await _settle(t, 1400);
}

void main() {
  setUpAll(() => GoogleFonts.config.allowRuntimeFetching = false);

  testWidgets('buka lagi di halaman 4 → lanjut di halaman 4, bukan halaman 1',
      (tester) async {
    // onbarding_done TIDAK diset: user belum menyelesaikan apa pun.
    SharedPreferences.setMockInitialValues({_pageKey: 3, 'gender': 'male'});
    await _bootSplash(tester);

    expect(find.byType(OnboardingScreen), findsOneWidget,
        reason: 'user yang belum selesai dilempar ke Dashboard');
    expect(find.text('Cara Main'), findsOneWidget,
        reason: 'kembali ke halaman 1 — 3 halaman yang sudah dilewati dibuang');
    // Progres di header ikut halaman yang dipulihkan, bukan halaman 1.
    expect(find.text('4/6'), findsOneWidget);
  });

  testWidgets('gender yang sudah dipilih ikut dipulihkan', (tester) async {
    SharedPreferences.setMockInitialValues({_pageKey: 2, 'gender': 'female'});
    await tester.pumpWidget(appWrap(const OnboardingScreen()));
    await _settle(tester, 900);

    // Halaman 3 (gender) tidak punya ikon lain, jadi centang ini hanya bisa
    // datang dari kartu yang ter-select.
    expect(find.text('Kamu Ikhwan atau Akhwat?'), findsOneWidget);
    expect(find.byIcon(AppIcons.checkCircle), findsWidgets,
        reason: 'pilihan gender tidak dipulihkan');
  });

  testWidgets('kota yang sudah dipilih ikut dipulihkan', (tester) async {
    SharedPreferences.setMockInitialValues({
      _pageKey: 4,
      'city_id': 'Bali/Kota Denpasar',
      'city_name': 'Kota Denpasar',
    });
    await tester.pumpWidget(appWrap(const OnboardingScreen()));
    await _settle(tester, 900);

    // Kota tersimpan sejak user memilihnya, tapi UI-nya dulu lupa: halaman 5
    // muncul dengan "Izinkan Lokasi" dan menyuruh mengulang langkah selesai.
    expect(find.text('Kota Denpasar'), findsOneWidget,
        reason: 'kota tidak dipulihkan — user disuruh mengulang langkah lokasi');
    expect(find.text('Izinkan Lokasi'), findsNothing,
        reason: 'tombol lokasi muncul padahal kotanya sudah tersimpan');
    expect(find.text('Lanjut'), findsOneWidget,
        reason: 'tanpa Lanjut, halaman lokasi buntu lagi setelah dilanjutkan');
  });

  testWidgets('pindah halaman menyimpan progres', (tester) async {
    SharedPreferences.setMockInitialValues({});
    await tester.pumpWidget(appWrap(const OnboardingScreen()));
    await _settle(tester, 900);

    tester.widget<PageView>(find.byType(PageView)).controller!.jumpToPage(4);
    await _settle(tester, 700);

    final prefs = await SharedPreferences.getInstance();
    expect(prefs.getInt(_pageKey), 4,
        reason: 'progres tidak ditulis saat halaman berubah');
  });

  testWidgets('selesai onboarding → penanda halaman dihapus', (tester) async {
    SharedPreferences.setMockInitialValues({_pageKey: 4, 'nickname': 'Kris'});
    await tester.pumpWidget(appWrap(const OnboardingScreen()));
    await _settle(tester, 900);

    tester.widget<PageView>(find.byType(PageView)).controller!.jumpToPage(5);
    await _settle(tester, 700);
    await tester.tap(find.text('LEWATI, NANTI SAJA'));
    await _settle(tester, 600);

    final prefs = await SharedPreferences.getInstance();
    expect(prefs.getInt(_pageKey), isNull,
        reason: 'penanda dibiarkan → onboarding diulang setelah selesai');
    // Gender tetap ada: Profil membacanya untuk menyembunyikan menu haid.
    expect(prefs.containsKey('gender'), isTrue);
  });
}
