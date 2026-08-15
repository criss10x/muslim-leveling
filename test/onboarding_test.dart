import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:muslim_leveling/screens/onboarding_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  testWidgets('onboarding: 3 halaman, lokasi & notif via tombol', (tester) async {
    SharedPreferences.setMockInitialValues({});
    await tester.pumpWidget(const MaterialApp(home: OnboardingScreen()));

    // Halaman 1: welcome (copy sesuai spec)
    expect(find.text('Selamat Datang, Muslim Warrior!'), findsOneWidget);
    expect(find.text('Lanjut'), findsOneWidget);

    // Halaman 2: copy baru "Butuh Lokasimu" + tombol lokasi + fallback manual
    await tester.tap(find.text('Lanjut'));
    await tester.pumpAndSettle();
    expect(find.text('Butuh Lokasimu'), findsOneWidget);
    expect(find.text('Izinkan Lokasi'), findsOneWidget);
    expect(find.text('PILIH KOTA MANUAL'), findsOneWidget);

    // Halaman 3: pengingat (swipe, hindari Geolocator di test)
    await tester.fling(find.byType(PageView), const Offset(-400, 0), 800);
    await tester.pumpAndSettle();
    expect(find.text('Pengingat Adzan'), findsOneWidget);
    expect(find.text('Izinkan Notifikasi'), findsOneWidget);
  });
}
