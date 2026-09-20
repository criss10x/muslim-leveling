import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:muslim_leveling/widgets/city_picker.dart';
import 'package:muslim_leveling/theme/app_icons.dart';
import 'helpers/app_wrap.dart';

void main() {
  testWidgets('picker requires province before filtering kabupaten kota', (
    tester,
  ) async {
    late Future<({String id, String name, bool abroad})?> selection;
    await tester.pumpWidget(
      appWrap(Builder(
          builder: (context) => TextButton(
            onPressed: () {
              selection = CityPicker.show(
                context,
                cityLoader: (_) async => ['Kab. Badung', 'Kota Denpasar'],
              );
            }, child: const Text('Buka'), ),
        ),),
    );

    await tester.tap(find.text('Buka'));
    await tester.pumpAndSettle();
    // Langkah pertama sekarang pilih wilayah; Indonesia masuk ke alur lama.
    expect(find.text('Pilih Wilayah'), findsOneWidget);
    expect(find.text('Luar Negeri'), findsOneWidget);
    expect(find.text('Indonesia'), findsOneWidget);
    await tester.tap(find.text('Indonesia'));
    await tester.pumpAndSettle();
    expect(find.text('Pilih Provinsi'), findsOneWidget);
    expect(find.text('Pilih Kabupaten/Kota'), findsNothing);

    await tester.enterText(find.byType(TextField), 'bali');
    await tester.pump();
    await tester.tap(find.text('Bali'));
    await tester.pumpAndSettle();
    expect(find.text('Pilih Kabupaten/Kota'), findsOneWidget);

    await tester.enterText(find.byType(TextField), 'badung');
    await tester.pump();
    await tester.tap(find.text('Kab. Badung'));
    expect(
      await selection,
      (id: 'Bali/Kab. Badung', name: 'Kab. Badung', abroad: false),
    );
  });

  testWidgets('picker ignores a stale city result after changing province', (
    tester,
  ) async {
    final bali = Completer<List<String>>();
    await tester.pumpWidget(
      appWrap(Builder(
          builder: (context) => TextButton(
            onPressed: () {
              CityPicker.show(
                context,
                cityLoader: (province) => province == 'Bali'
                    ? bali.future
                    : Future.value(['Kota Serang']),
              );
            }, child: const Text('Buka'), ),
        ),),
    );

    await tester.tap(find.text('Buka'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Indonesia'));
    await tester.pumpAndSettle();
    await tester.enterText(find.byType(TextField), 'bali');
    await tester.pump();
    await tester.tap(find.text('Bali'));
    await tester.pump();
    // panah balik sekarang satu tingkat: kabkota → provinsi (bukan → wilayah)
    await tester.tap(find.byIcon(AppIcons.arrowBack));
    await tester.pump();
    await tester.enterText(find.byType(TextField), 'banten');
    await tester.pump();
    await tester.tap(find.text('Banten'));
    await tester.pumpAndSettle();
    expect(find.text('Kota Serang'), findsOneWidget);

    bali.complete(['Kab. Badung']);
    await tester.pumpAndSettle();
    expect(find.text('Kota Serang'), findsOneWidget);
    expect(find.text('Kab. Badung'), findsNothing);
  });
}
