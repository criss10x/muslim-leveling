import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:muslim_leveling/widgets/city_picker.dart';

void main() {
  testWidgets('picker requires province before filtering kabupaten kota', (
    tester,
  ) async {
    late Future<({String id, String name})?> selection;
    await tester.pumpWidget(
      MaterialApp(
        home: Builder(
          builder: (context) => TextButton(
            onPressed: () {
              selection = CityPicker.show(
                context,
                cityLoader: (_) async => ['Kab. Badung', 'Kota Denpasar'],
              );
            },
            child: const Text('Buka'),
          ),
        ),
      ),
    );

    await tester.tap(find.text('Buka'));
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
    expect(await selection, (id: 'Bali/Kab. Badung', name: 'Kab. Badung'));
  });
}
