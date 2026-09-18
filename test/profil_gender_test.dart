import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:muslim_leveling/screens/profil_tab.dart';
import 'package:muslim_leveling/theme/app_theme.dart';
import 'package:muslim_leveling/widgets/gender_picker.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'helpers/app_wrap.dart';

/// Gate "Periode Haid" di Profil. Aturannya satu:
/// baris hilang ⟺ gender == 'male'. '' (Lewati di onboarding) tetap tampil.
void main() {
  test('hanya Ikhwan yang menyembunyikan baris Periode Haid', () {
    expect(genderHidesCycle('male'), isTrue);
    expect(genderHidesCycle('female'), isFalse);
    expect(genderHidesCycle(''), isFalse, reason: 'Lewati ≠ Ikhwan');
  });

  // ListView Profil membangun anaknya malas: kartu setting belum ada di tree
  // sampai di-scroll. scrollUntilVisible berhenti begitu widget ditemukan —
  // belum tentu di dalam viewport 800x600 — jadi tap masih bisa meleset;
  // ensureVisible menutup jarak itu.
  Future<void> scrollTo(WidgetTester tester, Finder f) async {
    await tester.scrollUntilVisible(
      f,
      200,
      scrollable: find.byType(Scrollable).first,
    );
    await tester.ensureVisible(f);
    await tester.pumpAndSettle();
  }

  Future<void> openProfil(WidgetTester tester, String gender) async {
    GoogleFonts.config.allowRuntimeFetching = false;
    SharedPreferences.setMockInitialValues({
      'nickname': 'Pejuang',
      'onboarding_done': true,
      'avatar_path': '',
      kGenderPrefKey: gender,
    });
    await tester.pumpWidget(
      appWrap(const Scaffold(body: ProfilTab()), theme: AppTheme.dark()),
    );
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 300));
    // 'Jenis Kelamin' selalu ada di kartu setting → aman jadi jangkar scroll.
    // Sekali kartunya terbangun, seluruh barisnya ada di element tree.
    await scrollTo(tester, find.text('Jenis Kelamin'));
  }

  for (final (gender, visible, why) in [
    ('male', false, 'Ikhwan → menu haid disembunyikan'),
    ('female', true, 'Akhwat → menu haid tampil'),
    ('', true, "Lewati ('') → menu haid tetap tampil"),
  ]) {
    testWidgets('gender "$gender": baris haid '
        '${visible ? 'tampil' : 'hilang'} — $why', (tester) async {
      await openProfil(tester, gender);
      expect(find.text('Periode Haid'), visible ? findsOneWidget : findsNothing);
      expect(find.text('Jenis Kelamin'), findsOneWidget);
    });
  }

  testWidgets('ganti gender ke Ikhwan menyembunyikan baris haid', (
    tester,
  ) async {
    await openProfil(tester, 'female');

    await tester.tap(find.text('Jenis Kelamin'));
    await tester.pumpAndSettle();

    expect(find.text('Ikhwan'), findsOneWidget, reason: 'sheet terbuka');
    await tester.tap(find.text('Ikhwan'));
    await tester.pumpAndSettle();

    final p = await SharedPreferences.getInstance();
    expect(p.getString(kGenderPrefKey), 'male');
    expect(find.text('Periode Haid'), findsNothing);
  });
}
