import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:muslim_leveling/screens/onboarding_screen.dart';
import 'package:muslim_leveling/services/game_service.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'helpers/app_wrap.dart';

/// Gender disimpan di prefs (bukan GameState) — aturan sembunyi fitur haid
/// di Profil hanya membaca 'male', jadi tiga nilai ini harus tersimpan persis:
/// 'male' (sembunyi), 'female' (tampil), '' (Lewati → tetap tampil).
void main() {
  const genderPage = 2; // 0-indexed: bahasa, nama, gender, ...

  Future<void> gotoGender(WidgetTester tester) async {
    await tester.pumpWidget(appWrap(const OnboardingScreen()));
    for (var i = 0; i < genderPage; i++) {
      await tester.fling(find.byType(PageView), const Offset(-400, 0), 800);
      await tester.pumpAndSettle();
    }
  }

  Future<void> finish(WidgetTester tester) async {
    // 2 halaman sisa setelah gender: lokasi, notif → tombol "Lewati, nanti
    // saja" di halaman notif menutup onboarding tanpa menyentuh permission.
    for (var i = 0; i < 3; i++) {
      await tester.fling(find.byType(PageView), const Offset(-400, 0), 800);
      await tester.pumpAndSettle();
    }
    await tester.tap(find.text('LEWATI, NANTI SAJA'));
    // Bukan pumpAndSettle: DashboardShell punya animasi fireflies yang tidak
    // pernah berhenti, jadi pumpAndSettle selalu timeout di sini.
    for (var i = 0; i < 5; i++) {
      await tester.pump(const Duration(milliseconds: 100));
    }
  }

  for (final (label, expected) in [
    ('IKHWAN', 'male'),
    ('AKHWAT', 'female'),
  ]) {
    testWidgets('pilih $label → prefs gender == $expected', (tester) async {
      SharedPreferences.setMockInitialValues({});
      await gotoGender(tester);
      await tester.tap(find.text(label));
      await tester.pump();
      await finish(tester);

      final prefs = await SharedPreferences.getInstance();
      expect(prefs.getString('gender'), expected);
    });
  }

  testWidgets('Tidak perlu → gender kosong dan langsung maju ke halaman 4',
      (tester) async {
    SharedPreferences.setMockInitialValues({});
    await gotoGender(tester);
    await tester.tap(find.text('TIDAK PERLU'));
    await tester.pumpAndSettle();

    // Tidak lagi no-op: tombol ini maju, sama seperti tombol lain di posisi
    // itu. Kalau user tidak menekan apa-apa, ia tidak tahu app-nya hidup.
    expect(find.text('Cara Main'), findsOneWidget);

    await finish(tester);
    final prefs = await SharedPreferences.getInstance();
    expect(prefs.getString('gender'), '');
    // '' berarti baris Periode Haid TETAP tampil di Profil — akhwat yang
    // melewati pertanyaan tidak boleh kehilangan fiturnya.
    expect(prefs.getString('gender'), isNot('male'));
  });

  testWidgets('demo XP di onboarding tidak menulis ke game state',
      (tester) async {
    SharedPreferences.setMockInitialValues({});
    await GameService.load();
    final beforeXp = GameService.current.xp;
    final beforeShields = GameService.freezeShields;

    await tester.pumpWidget(appWrap(const OnboardingScreen()));
    for (var i = 0; i < 3; i++) {
      await tester.fling(find.byType(PageView), const Offset(-400, 0), 800);
      await tester.pumpAndSettle();
    }
    // Halaman 4 = kartu demo.
    for (var i = 0; i < 5; i++) {
      await tester.tap(find.byKey(kOnbXpDemoCardKey));
      await tester.pump(const Duration(milliseconds: 50));
    }

    // Kartu harus BENAR-BENAR bereaksi (kalau onTap kosong, tes anti-cheat di
    // bawah lolos palsu). Toast '+50 XP' muncul sebagai widget kedua.
    expect(find.text('+50 XP'), findsWidgets);
    expect(find.text('+50 XP').evaluate().length, greaterThan(1),
        reason: 'toast demo tidak muncul — handler mati?');

    expect(GameService.current.xp, beforeXp, reason: 'onboarding = anti-cheat');
    expect(GameService.freezeShields, beforeShields);

    // Toast XP punya ticker sendiri (overlay root). Kalau tes selesai sebelum
    // animasinya habis, OverlayState di-dispose dengan ticker aktif → tes merah
    // walau logikanya benar. 1600ms tampil + 200ms reverse.
    await tester.pump(const Duration(milliseconds: 2000));
    await tester.pump(const Duration(milliseconds: 400));
  });
}
