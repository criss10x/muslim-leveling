import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:muslim_leveling/screens/quran_tab.dart';

import 'helpers/app_wrap.dart';

/// Jendela bantuan harus aman dari sistem navigasi Android.
///
/// Keluhan user: "aku memakai android nav button bottom, jadi tulisan paling
/// bawahnya tertutup". Isi sheet dibungkus SafeArea supaya dinaikkan di atas nav
/// bar.
///
/// Yang diuji adalah ISINYA, bukan permukaan sheet: permukaan sheet memang wajar
/// menjulur sampai dasar layar (nav bar digambar di atasnya, dan permukaan itu
/// sendiri tidak mengganggu), sedangkan teks terakhir tidak boleh berada di
/// bawah nav bar.
void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  const navBar = 48.0; // nav bar 3-tombol Android, nilai lazim

  /// Semua baris isi jendela yang terlihat (chip contoh + keterangannya).
  const rows = ['Al-Baqarah 286', '2:286', 'kesabaran', 'sapi'];

  /// Siapkan layar 360x640 dengan tinggi nav bar tertentu, lalu buka jendelanya.
  ///
  /// SafeArea membaca `MediaQuery.padding`, jadi `view.padding` yang harus
  /// disetel — bukan hanya `viewPadding`. Menyetel viewPadding saja membuat
  /// padding tetap nol dan jendela tampak "aman" padahal tidak; itu pernah
  /// membuat probe pertama salah lapor.
  Future<void> openHelp(WidgetTester tester, double barHeight,
      {Locale? locale, String title = 'Cara mencari'}) async {
    tester.view.physicalSize = const Size(360, 640);
    tester.view.devicePixelRatio = 1.0;
    tester.view.viewPadding = FakeViewPadding(bottom: barHeight);
    tester.view.padding = FakeViewPadding(bottom: barHeight);
    addTearDown(tester.view.reset);

    await tester.pumpWidget(
      appWrap(const Scaffold(body: QuranTab()),
          locale: locale ?? const Locale('id')),
    );
    await tester.pumpAndSettle();
    await tester.tap(find.byIcon(Icons.help_outline));
    await tester.pumpAndSettle();
    expect(find.text(title), findsOneWidget);
  }

  testWidgets('dengan nav bar: seluruh baris jendela di atas nav bar',
      (tester) async {
    await openHelp(tester, navBar);
    final screenH = tester.getSize(find.byType(MaterialApp)).height;
    final limit = screenH - navBar; // 592

    for (final label in rows) {
      final r = tester.getRect(find.text(label));
      expect(
        r.bottom,
        lessThanOrEqualTo(limit + 0.5),
        reason: 'baris "$label" tertutup nav bar: '
            'bawah ${r.bottom.toStringAsFixed(1)} > ${limit.toStringAsFixed(1)}',
      );
    }

    // Keterangan baris terakhir adalah teks paling bawah di jendela.
    final last = tester.getRect(find.text('nama atau arti surat'));
    expect(last.bottom, lessThanOrEqualTo(limit + 0.5),
        reason: 'keterangan terakhir tertutup nav bar');
  });

  testWidgets('tanpa nav bar: tidak ada celah hantu sebesar nav bar',
      (tester) async {
    await openHelp(tester, 0);
    final screenH = tester.getSize(find.byType(MaterialApp)).height;

    final last = tester.getRect(find.text('nama atau arti surat'));
    // Tanpa nav bar, isi jendela duduk seperti semula (~68px dari dasar).
    // Kalau padding nav bar tetap dipakai meski nilainya nol, di sini akan
    // muncul celah ~48px yang tidak dibutuhkan.
    expect(last.bottom, greaterThan(screenH - 48),
        reason: 'celah hantu: baris terakhir terlalu jauh dari dasar '
            '(${last.bottom.toStringAsFixed(1)} vs dasar $screenH)');
  });

  testWidgets('empat cara tetap tampil lengkap di keempat bahasa',
      (tester) async {
    // Judul ikut bahasa; "Cara mencari" hanya benar di id/ms.
    const titles = {
      'id': 'Cara mencari',
      'en': 'How to search',
      'tr': 'Nasıl aranır',
      'ms': 'Cara cari',
    };
    for (final loc in const [
      Locale('id'),
      Locale('en'),
      Locale('tr'),
      Locale('ms'),
    ]) {
      await openHelp(tester, navBar,
          locale: loc, title: titles[loc.languageCode]!);
      final screenH = tester.getSize(find.byType(MaterialApp)).height;
      final limit = screenH - navBar;
      for (final label in rows) {
        final r = tester.getRect(find.text(label));
        expect(r.bottom, lessThanOrEqualTo(limit + 0.5),
            reason: '${loc.languageCode}: "$label" tertutup nav bar');
      }
      // Tutup jendelanya sebelum locale berikutnya.
      await tester.tapAt(const Offset(180, 100));
      await tester.pumpAndSettle();
    }
  });
}
