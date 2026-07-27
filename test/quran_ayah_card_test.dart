import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:muslim_leveling/services/quran_data.dart';
import 'package:muslim_leveling/services/quran_settings.dart';
import 'package:muslim_leveling/widgets/quran_ayah_card.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() async {
    SharedPreferences.setMockInitialValues({});
    await quranSettings.load();
  });

  const ayah = QuranAyah(
    ayah: 1,
    arabic: 'بِسْمِ ٱللَّهِ',
    translation: 'Dengan menyebut nama Allah',
  );

  Widget wrap(Widget child) => MaterialApp(home: Scaffold(body: child));

  testWidgets('menampilkan teks Arab dan terjemahan', (tester) async {
    await tester.pumpWidget(wrap(
      QuranAyahCard(ayah: ayah, active: false, onPlay: () {}),
    ));

    expect(find.text('بِسْمِ ٱللَّهِ'), findsOneWidget);
    expect(find.text('Dengan menyebut nama Allah'), findsOneWidget);
  });

  testWidgets('menyembunyikan terjemahan sesuai setelan', (tester) async {
    await quranSettings.setShowTranslation(false);
    await tester.pumpWidget(wrap(
      QuranAyahCard(ayah: ayah, active: false, onPlay: () {}),
    ));
    await tester.pumpAndSettle();

    expect(find.text('بِسْمِ ٱللَّهِ'), findsOneWidget);
    expect(find.text('Dengan menyebut nama Allah'), findsNothing);
  });

  testWidgets('ukuran font Arab mengikuti setelan', (tester) async {
    await quranSettings.setArabicFontSize(40);
    await tester.pumpWidget(wrap(
      QuranAyahCard(ayah: ayah, active: false, onPlay: () {}),
    ));
    await tester.pumpAndSettle();

    final text = tester.widget<Text>(find.text('بِسْمِ ٱللَّهِ'));
    expect(text.style?.fontSize, 40);
  });

  testWidgets('tombol play memanggil callback', (tester) async {
    var tapped = 0;
    await tester.pumpWidget(wrap(
      QuranAyahCard(ayah: ayah, active: false, onPlay: () => tapped++),
    ));

    await tester.tap(find.byIcon(Icons.play_arrow));
    expect(tapped, 1);
  });
}
