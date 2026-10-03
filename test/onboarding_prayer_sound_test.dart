// Halaman 6 onboarding: mode notif per sholat, sama seperti picker di Jadwal.
//
// Yang bisa diam-diam rusak dan tidak tertangkap golden test:
// Onboarding memakai modal yang sama dengan Jadwal, TAPI tanpa baris
// "Ikuti pengaturan global" — nilai globalnya diatur di tab Profil yang belum
// pernah dilihat user di titik ini. Kalau baris itu bocor masuk, user melihat
// pilihan yang tidak bisa ia pahami artinya.
//
// Penyimpanan pilihannya sendiri sudah dijaga test lain:
// test/bookmark_notif_backup_test.dart menguji setPerPrayerSound /
// getPerPrayerSounds di level service. Di sini tidak diulang, karena
// setPerPrayerSound memanggil NotificationService.init() yang butuh plugin
// notifikasi asli — widget test tidak menyediakannya.
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:muslim_leveling/screens/onboarding_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'helpers/app_wrap.dart';

void main() {
  Future<void> gotoPage6(WidgetTester tester) async {
    SharedPreferences.setMockInitialValues({});
    await tester.pumpWidget(appWrap(const OnboardingScreen()));
    await tester.pump(const Duration(milliseconds: 600));
    final ctrl = tester.widget<PageView>(find.byType(PageView)).controller!;
    ctrl.jumpToPage(5);
    await tester.pumpAndSettle();
  }

  testWidgets('tap baris sholat → 3 opsi, tanpa "Ikuti pengaturan global"',
      (tester) async {
    await gotoPage6(tester);
    expect(find.text('Notifikasi Adzan'), findsOneWidget);

    await tester.tap(find.text('Subuh'));
    await tester.pumpAndSettle();

    // Judul modal menyebut sholat yang di-tap, bukan sholat lain.
    expect(find.text('Notifikasi Subuh'), findsOneWidget);
    expect(find.text('Senyap: tanpa suara'), findsOneWidget);
    expect(find.text('Suara: notifikasi standar HP'), findsOneWidget);
    expect(find.text('Adzan: suara adzan penuh'), findsOneWidget);
    // Nilai global baru diatur di Profil — di sini opsi itu belum bermakna.
    expect(find.text('Ikuti pengaturan global'), findsNothing);
  });

  testWidgets('tiap baris membuka modal sholatnya sendiri', (tester) async {
    await gotoPage6(tester);

    for (final (id, name) in [
      ('subuh', 'Subuh'),
      ('dzuhur', 'Dzuhur'),
      ('ashar', 'Ashar'),
      ('maghrib', 'Maghrib'),
      ('isya', 'Isya'),
    ]) {
      await tester.tap(find.byKey(Key('onb-sound-$id')));
      await tester.pumpAndSettle();
      expect(find.text('Notifikasi $name'), findsOneWidget,
          reason: 'baris $id harus membuka modal $name');
      // Tutup lagi untuk baris berikutnya.
      await tester.tapAt(const Offset(10, 10));
      await tester.pumpAndSettle();
    }
  });
}
