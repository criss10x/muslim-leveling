import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:muslim_leveling/screens/home_tab.dart';

/// ponytail: penjaga struktur tab Home — 5 pintasan harus ada di bawah ring
/// "RITUAL HARI INI", dan section lama yang dipindah tidak boleh muncul lagi
/// (kalau muncul = pemindahan belum bersih / ada sisa render ganda).
void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  GoogleFonts.config.allowRuntimeFetching = false;

  Future<void> pumpHome(WidgetTester tester) async {
    SharedPreferences.setMockInitialValues({});
    await tester.pumpWidget(
      const MaterialApp(home: Scaffold(body: HomeTab())),
    );
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 100));
  }

  testWidgets('5 pintasan AKSES CEPAT ada di Home', (tester) async {
    await pumpHome(tester);
    await tester.scrollUntilVisible(find.text('AKSES CEPAT'), 200);

    expect(find.text('AKSES CEPAT'), findsOneWidget);
    for (final label in ['Hadis', 'Doa', 'Kiblat', 'Dzikir', 'Highlight']) {
      expect(find.text(label), findsOneWidget, reason: 'tombol $label hilang');
    }
  });

  testWidgets('section lama yg dipindah tidak dirender lagi di Home',
      (tester) async {
    await pumpHome(tester);
    await tester.scrollUntilVisible(find.text('AKSES CEPAT'), 200);

    // Dipindah ke tombol / halaman baru → tidak boleh jadi section penuh.
    expect(find.text('DAILY ZIKIR'), findsNothing);
    expect(find.text('BUKA TASBIH DIGITAL'), findsNothing);
    expect(find.text('DAILY HIGHLIGHT'), findsNothing);
  });
}
