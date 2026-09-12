import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:muslim_leveling/screens/hadis_screen.dart';

/// Penjaga regresi: HadisScreen WAJIB punya Material ancestor (Scaffold).
///
/// Tanpa itu, `TextField` melempar "No Material widget found" dan seluruh
/// layar gagal build — gejalanya "halaman hadis kosong", bukan error API.
/// Dipush persis seperti aplikasi (dari Scaffold lewat Navigator).
void main() {
  testWidgets('HadisScreen render tanpa exception saat di-push', (
    tester,
  ) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Builder(
          builder: (c) => Scaffold(
            body: TextButton(
              onPressed: () => Navigator.push(
                c,
                MaterialPageRoute(builder: (_) => const HadisScreen()),
              ),
              child: const Text('buka'),
            ),
          ),
        ),
      ),
    );
    await tester.tap(find.text('buka'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 300));

    // Inti: tidak boleh ada "No Material widget found".
    expect(tester.takeException(), isNull);
    expect(find.byType(TextField), findsOneWidget);
    expect(find.text('Acak'), findsOneWidget);
    expect(find.text('Cari hadis…'), findsOneWidget);
  });
}
