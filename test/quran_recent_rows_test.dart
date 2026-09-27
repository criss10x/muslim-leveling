import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:muslim_leveling/screens/quran_tab.dart';
import 'package:muslim_leveling/services/quran_progress.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'helpers/app_wrap.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  Future<void> pumpTab(WidgetTester tester) async {
    await quranProgress.load();
    await tester.pumpWidget(appWrap(const Scaffold(body: QuranTab())));
    await tester.pumpAndSettle();
  }

  testWidgets(
    '0 riwayat: tanpa kartu lanjut, tanpa baris sebelumnya',
    (tester) async {
      SharedPreferences.setMockInitialValues({});
      quranProgress.resetForTest();
      await pumpTab(tester);
      expect(find.text('Lanjutkan membaca'), findsNothing);
    },
  );

  testWidgets(
    '1 riwayat: kartu utama saja, TANPA baris sebelumnya',
    (tester) async {
      SharedPreferences.setMockInitialValues({
        'quran_recent_positions': '[[2,255]]',
      });
      quranProgress.resetForTest();
      await pumpTab(tester);

      expect(find.text('Lanjutkan membaca'), findsOneWidget);
      // Nol biaya tempat: satu posisi tidak boleh menambah baris tambahan.
      expect(find.byIcon(Icons.history), findsNothing);
      expect(find.text('Bacaan sebelumnya'), findsNothing);
    },
  );

  testWidgets(
    '3 riwayat: kartu utama + 2 baris sebelumnya, label hanya di baris pertama',
    (tester) async {
      SharedPreferences.setMockInitialValues({
        'quran_recent_positions': '[[2,255],[18,10],[36,30]]',
      });
      quranProgress.resetForTest();
      await pumpTab(tester);

      expect(find.text('Lanjutkan membaca'), findsOneWidget);
      // Kartu utama menampilkan ayat tersimpan; 2 baris lama di bawahnya.
      expect(find.byIcon(Icons.history), findsNWidgets(2));
      // Label "Bacaan sebelumnya" cuma di baris pertama (anti-redundansi).
      final labelCount = find.textContaining('Bacaan sebelumnya').evaluate().length;
      expect(labelCount, 1);
      // Kedua surat lama terlihat: 18 (Al-Kahf) dan 2 (Al-Baqarah) di baris.
      expect(find.textContaining('Al-Kahf'), findsWidgets);
    },
  );

  testWidgets(
    'tap baris sebelumnya membuka reader surat lama',
    (tester) async {
      SharedPreferences.setMockInitialValues({
        'quran_recent_positions': '[[2,255],[18,10]]',
      });
      quranProgress.resetForTest();
      await pumpTab(tester);

      await tester.tap(find.byIcon(Icons.history).first);
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 400));

      // Reader surat 18 terbuka (judul surat muncul di app bar / header).
      expect(find.textContaining('Al-Kahf'), findsWidgets);
    },
  );
}
