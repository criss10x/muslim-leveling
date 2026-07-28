import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:muslim_leveling/widgets/rub_el_hizb_badge.dart';

void main() {
  Widget wrap(Widget child) =>
      MaterialApp(home: Scaffold(body: Center(child: child)));

  testWidgets('menampilkan nomor surat di tengah badge', (tester) async {
    await tester.pumpWidget(wrap(const RubElHizbBadge(number: 18)));

    expect(find.text('18'), findsOneWidget);
  });

  testWidgets('badge berukuran persegi sesuai parameter size', (tester) async {
    await tester.pumpWidget(wrap(const RubElHizbBadge(number: 1, size: 40)));

    final size = tester.getSize(find.byType(RubElHizbBadge));
    expect(size.width, 40);
    expect(size.height, 40);
  });

  testWidgets('menggambar ornamen lewat CustomPaint', (tester) async {
    await tester.pumpWidget(wrap(const RubElHizbBadge(number: 114)));

    expect(
      find.descendant(
        of: find.byType(RubElHizbBadge),
        matching: find.byType(CustomPaint),
      ),
      findsWidgets,
    );
  });
}
