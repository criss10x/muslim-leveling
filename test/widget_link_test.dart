import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:muslim_leveling/services/widget_link.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() {
    SharedPreferences.setMockInitialValues({});
    WidgetLink.reset();
  });

  test('permintaan masuk dan bisa dikonsumsi', () {
    WidgetLink.requestQuests();
    expect(WidgetLink.pending, 1);
    WidgetLink.consume();
    expect(WidgetLink.pending, 0);
  });

  test('permintaan berulang tidak saling menimpa', () {
    // Inti perbaikan: bool akan hilang di sini karena consume men-set ulang
    // nilai yang sama dan ValueNotifier bungkam. Kounter tidak.
    WidgetLink.requestQuests();
    WidgetLink.consume();
    WidgetLink.requestQuests();
    expect(WidgetLink.pending, 1, reason: 'permintaan kedua tetap terhitung');

    WidgetLink.requestQuests();
    WidgetLink.requestQuests();
    expect(WidgetLink.pending, 3);
    WidgetLink.consume();
    WidgetLink.consume();
    expect(WidgetLink.pending, 1);
  });

  test('consume tidak membuat pending negatif', () {
    WidgetLink.consume();
    WidgetLink.consume();
    expect(WidgetLink.pending, 0);
  });

  test('penanda yang ditulis Kotlin dibaca dan dihapus', () async {
    final p = await SharedPreferences.getInstance();
    // Kotlin menulis dengan prefix `flutter.`; dari Dart kuncinya tanpa prefix.
    await p.setBool(WidgetLink.prefKey, true);

    expect(await WidgetLink.takePending(), isTrue);
    expect(p.getBool(WidgetLink.prefKey), isNull, reason: 'harus sekali pakai');
    expect(
      await WidgetLink.takePending(),
      isFalse,
      reason: 'penanda sudah dihapus',
    );
  });

  test('tanpa penanda mengembalikan false, tidak melempar', () async {
    expect(await WidgetLink.takePending(), isFalse);
  });

  test('kunci disimpan tanpa prefix (Kotlin yang menambah flutter.)', () {
    expect(WidgetLink.prefKey, 'widget_open_quests');
    expect(WidgetLink.deepLinkHost, 'quests');
  });
}
