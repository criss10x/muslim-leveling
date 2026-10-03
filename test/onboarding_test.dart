import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:muslim_leveling/screens/onboarding_screen.dart';
import 'package:muslim_leveling/theme/app_icons.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'helpers/app_wrap.dart';

void main() {
  testWidgets('onboarding: 6 halaman, urutan bahasa→nama→gender→cara main', (
    tester,
  ) async {
    SharedPreferences.setMockInitialValues({});
    await tester.pumpWidget(appWrap(OnboardingScreen()));

    Future<void> swipe() async {
      await tester.fling(find.byType(PageView), const Offset(-400, 0), 800);
      await tester.pumpAndSettle();
    }

    // Halaman 1: bahasa — default ikut HP, jadi tidak ada yang ter-select
    // dari dua bahasa (override null).
    expect(find.text('Mau pakai bahasa apa?'), findsOneWidget);
    expect(find.text('Lanjut'), findsOneWidget);

    // Halaman 2: nama
    await swipe();
    expect(find.text('Siapa nama pejuangmu?'), findsOneWidget);

    // Halaman 3: Ikhwan/Akhwat pakai istilah Arab — artinya harus ada di
    // layar ini juga, bukan cuma di kepala user yang sudah tahu.
    await swipe();
    expect(find.text('Kamu Ikhwan atau Akhwat?'), findsOneWidget);
    expect(find.text('IKHWAN'), findsOneWidget);
    expect(find.text('AKHWAT'), findsOneWidget);
    expect(
      find.text('Ikhwan artinya laki-laki, akhwat artinya perempuan.'),
      findsOneWidget,
    );

    // Halaman 4: cara main
    await swipe();
    expect(find.text('Cara Main'), findsOneWidget);
    expect(find.text('Quest Harian'), findsOneWidget);

    // Halaman 5: lokasi (swipe, hindari Geolocator di test)
    await swipe();
    expect(find.text('Butuh Lokasimu'), findsOneWidget);
    expect(find.text('Izinkan Lokasi'), findsOneWidget);
    expect(find.text('PILIH KOTA MANUAL'), findsOneWidget);

    // Halaman 6: notifikasi per sholat (sebelum izin notif — user mengatur
    // mode suaranya dulu, sama seperti picker di tab Jadwal)
    await swipe();
    expect(find.text('Notifikasi Adzan'), findsOneWidget);
    expect(find.text('Lanjut'), findsOneWidget);
    // 5 sholat wajib, dan HANYA itu: imsak/terbit penanda waktu yang selalu
    // senyap, jadi barisnya tidak pernah bisa diubah di sini.
    for (final prayer in ['Subuh', 'Dzuhur', 'Ashar', 'Maghrib', 'Isya']) {
      expect(find.text(prayer), findsOneWidget,
          reason: 'baris notifikasi $prayer harus ada');
    }
    expect(find.text('Imsak'), findsNothing);
    expect(find.text('Terbit'), findsNothing);
    // Default global = adzan, jadi ikon tiap baris harus ikon adzan.
    // Dicek lewat key barisnya: maskot di atas halaman memakai ikon volume
    // yang sama, jadi find.byIcon() mentah menghitung satu terlalu banyak.
    for (final id in ['subuh', 'dzuhur', 'ashar', 'maghrib', 'isya']) {
      expect(
        find.descendant(
          of: find.byKey(Key('onb-sound-$id')),
          matching: find.byIcon(AppIcons.volumeUpRounded),
        ),
        findsOneWidget,
        reason: 'baris $id harus mengikuti mode global (adzan)',
      );
    }

    // Halaman 7: notifikasi
    await swipe();
    expect(find.text('Pengingat Adzan'), findsOneWidget);
    expect(find.text('Izinkan Notifikasi'), findsOneWidget);
  });
}
