import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:muslim_leveling/screens/hadis_screen.dart';
import 'package:muslim_leveling/services/hadis_api.dart';
import 'helpers/app_wrap.dart';

/// Penjaga: layar Hadis memakai terjemahan sesuai bahasa aplikasi.
///
/// Regresi nyata: sumber lama (proxy myquran) hanya punya terjemahan Indonesia
/// dan MENGABAIKAN `?lang=`/`?language=` (responsnya identik), jadi user
/// Inggris/Turki membaca teks Indonesia. Sekarang locale diteruskan ke service.
void main() {
  tearDown(() => hadisApi.resetForTest());

  testWidgets('locale layar diteruskan ke service (id/en/tr)', (tester) async {
    for (final (locale, expected) in [
      (const Locale('id'), HadisLang.id),
      (const Locale('en'), HadisLang.en),
      (const Locale('tr'), HadisLang.tr),
      // API tidak punya terjemahan Melayu (diuji → 404) → Inggris.
      (const Locale('ms'), HadisLang.en),
    ]) {
      hadisApi.lastRequestedLang = null;
      await tester.pumpWidget(appWrap(const HadisScreen(), locale: locale));
      // Jaringan tidak ada di widget test; yang diuji adalah bahasa yang
      // diminta service, bukan hasil muatannya.
      await tester.pump(const Duration(milliseconds: 100));
      expect(
        hadisApi.lastRequestedLang,
        expected,
        reason: 'locale ${locale.languageCode} harus meminta ${expected.code}',
      );
      expect(tester.takeException(), isNull);
    }
  });

  testWidgets('banner bahasa: tidak muncul saat konten sebahasa layar', (
    tester,
  ) async {
    hadisApi.resetForTest();
    await tester.pumpWidget(
      appWrap(const HadisScreen(), locale: const Locale('id')),
    );
    await tester.pump(const Duration(milliseconds: 100));
    expect(find.text('Teks dalam Bahasa Indonesia'), findsNothing);
    expect(tester.takeException(), isNull);
  });

  testWidgets('locale tr: banner menyebut Turki, bukan Indonesia', (
    tester,
  ) async {
    hadisApi.resetForTest();
    await tester.pumpWidget(
      appWrap(const HadisScreen(), locale: const Locale('tr')),
    );
    await tester.pump(const Duration(milliseconds: 100));
    // Konten tr tidak dipandang sebagai "Indonesia" (bug label lama).
    expect(find.text('Teks dalam Bahasa Indonesia'), findsNothing);
    expect(tester.takeException(), isNull);
  });

  test('isSahih mengenali grade dari semua bahasa sumber', () {
    HadisItem withGrade(String g) =>
        HadisItem(id: 1, ar: 'x', idn: 'x', grade: g, takhrij: '');
    // id / en / tr
    expect(withGrade('Sahih').isSahih, isTrue);
    expect(withGrade('Hadis sahih').isSahih, isTrue);
    expect(withGrade('Authentic').isSahih, isTrue);
    expect(withGrade('Authentic hadith').isSahih, isTrue);
    expect(withGrade('Sahih Hadis').isSahih, isTrue);
    expect(withGrade('Hasan').isSahih, isTrue);
    // Bukan sahih
    expect(withGrade('Daif').isSahih, isFalse);
    expect(withGrade('Weak').isSahih, isFalse);
    expect(withGrade('').isSahih, isFalse);
  });
}
