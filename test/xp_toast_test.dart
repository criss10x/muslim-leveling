import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:muslim_leveling/widgets/xp_toast.dart';

void main() {
  testWidgets('showXpToast menampilkan pill lalu hilang sendiri',
      (tester) async {
    await tester.pumpWidget(const MaterialApp(home: Scaffold()));
    showXpToast(tester.element(find.byType(Scaffold)), 15);
    await tester.pump(const Duration(milliseconds: 250)); // animasi masuk
    expect(find.text('+15 XP'), findsOneWidget);
    await tester.pump(const Duration(seconds: 2)); // tahan + animasi keluar
    await tester.pumpAndSettle();
    expect(find.text('+15 XP'), findsNothing);
  });
}
