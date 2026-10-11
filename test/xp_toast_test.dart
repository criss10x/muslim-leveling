import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:muslim_leveling/widgets/xp_toast.dart';
import 'helpers/app_wrap.dart';

void main() {
  testWidgets('showXpToast menampilkan pill lalu hilang sendiri',
      (tester) async {
    await tester.pumpWidget(appWrap(Scaffold()));
    showXpToast(tester.element(find.byType(Scaffold)), 15);
    await tester.pump(const Duration(milliseconds: 250)); // animasi masuk
    expect(find.text('+15 XP'), findsOneWidget);
    await tester.pump(const Duration(seconds: 2)); // tahan + animasi keluar
    await tester.pumpAndSettle();
    expect(find.text('+15 XP'), findsNothing);
  });

  testWidgets('pill duduk 76 dp di atas bilah nav (inset tidak dihitung dua kali)',
      (tester) async {
    tester.view.physicalSize = const Size(1080, 2280); // 360x760 dp
    tester.view.devicePixelRatio = 3.0;
    // Android nav button 3 tombol: inset bawah 48 dp.
    tester.view.padding = const FakeViewPadding(bottom: 144);
    tester.view.viewPadding = const FakeViewPadding(bottom: 144);
    addTearDown(tester.view.reset);

    await tester.pumpWidget(appWrap(Scaffold()));
    showXpToast(tester.element(find.byType(Scaffold)), 10);
    await tester.pump(); // frame pertama: animasi mulai (toast belum terlihat)
    await tester.pump(const Duration(milliseconds: 250)); // diam di posisi akhir

    final r = tester.getRect(find.text('+10 XP'));
    const screenH = 760.0;
    const navInset = 48.0;
    // pill: tinggi baris teks, jadi tepi bawah pill <= tepi bawah Text.
    final gapAboveNav = (screenH - navInset) - r.bottom;
    expect(gapAboveNav, greaterThan(76 - 16),
        reason: 'pill tidak boleh menempel bilah nav');
    expect(gapAboveNav, lessThan(76 + 16),
        reason: 'pill harus ~76 dp di atas bilah nav; lebih tinggi berarti '
            'inset bawah dihitung dua kali');

    await tester.pump(const Duration(milliseconds: 2000));
    await tester.pumpAndSettle();
  });
}
