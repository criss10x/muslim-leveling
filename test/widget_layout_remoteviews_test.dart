import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

/// Penjaga layout widget home screen.
///
/// RemoteViews hanya boleh memakai kelas view dari daftar resmi Android.
/// Selain itu launcher gagal inflate dan menampilkan "Can't load widget" —
/// tanpa stack trace ke user dan tanpa error di build. Ini persis yang
/// terjadi pada `<View>` (garis pemisah): compile hijau, APK valid, widget
/// mati di HP.
///
/// Daftar: developer.android.com/develop/ui/views/appwidgets/advanced#create_the_app_widget_layout
void main() {
  const allowed = {
    // layout
    'AdapterViewFlipper',
    'FrameLayout',
    'GridLayout',
    'GridView',
    'LinearLayout',
    'ListView',
    'RelativeLayout',
    'StackView',
    'ViewFlipper',
    // widget
    'AnalogClock',
    'Button',
    'Chronometer',
    'ImageButton',
    'ImageView',
    'ProgressBar',
    'TextClock',
    'TextView',
    // API 31+
    'CheckBox',
    'RadioButton',
    'RadioGroup',
    'Switch',
  };

  final layout = File(
    'android/app/src/main/res/layout/quest_widget.xml',
  );

  /// Nama elemen (tag) di XML layout. Regex cukup di sini: file-nya milik kita,
  /// tanpa CDATA atau komentar berisi tag.
  List<String> elemsOf(String xml) => RegExp(r'<([A-Za-z][A-Za-z0-9_]*)')
      .allMatches(xml.replaceAll(RegExp(r'<!--.*?-->', dotAll: true), ''))
      .map((m) => m.group(1)!)
      .toSet()
      .toList();

  test('layout widget memakai view yang diizinkan RemoteViews', () {
    expect(layout.existsSync(), isTrue, reason: 'layout tidak ditemukan');
    final xml = layout.readAsStringSync();

    final illegal = elemsOf(xml).where((e) => !allowed.contains(e)).toList();
    expect(
      illegal,
      isEmpty,
      reason:
          'Kelas ini tidak boleh ada di layout widget: $illegal. '
          'Ganti <View> dengan <FrameLayout> atau <TextView> berisi background.',
    );
  });

  test('setiap id yang ditulis Kotlin ada di layout', () {
    final xml = layout.readAsStringSync();
    final ids = RegExp(r'@\+id/([a-z_]+)')
        .allMatches(xml)
        .map((m) => m.group(1)!)
        .toSet();

    final kotlin = File(
      'android/app/src/main/kotlin/id/muslimleveling/muslim_leveling/'
      'QuestWidgetProvider.kt',
    ).readAsStringSync();
    final used = RegExp(r'R\.id\.([a-z_]+)')
        .allMatches(kotlin)
        .map((m) => m.group(1)!)
        .toSet();

    expect(
      used.difference(ids),
      isEmpty,
      reason: 'Kotlin merujuk id yang tidak ada di layout',
    );
    // Arah sebaliknya juga dijaga: id yang dikirim ke RemoteViews tapi tidak
    // pernah ada di layout akan gagal senyap saat runtime (setTextViewText
    // pada id tak dikenal = no-op, widget tampak kosong).
    //
    // `clock` dikecualikan dengan sadar: TextClock menggambar waktunya sendiri
    // di sisi Android, jadi Kotlin tidak pernah menyentuhnya. Kalau nanti ada
    // id lain yang muncul di sini, itu tanda ada view yang lupa diisi.
    const diisiOlehSistem = {'clock'};
    expect(
      ids.difference(used).difference(diisiOlehSistem),
      isEmpty,
      reason: 'ada id di layout yang tidak pernah dipakai Kotlin',
    );
  });

  test('setiap R.string yang ditulis Kotlin dideklarasikan', () {
    final kotlin = File(
      'android/app/src/main/kotlin/id/muslimleveling/muslim_leveling/'
      'QuestWidgetProvider.kt',
    ).readAsStringSync();
    final used = RegExp(r'R\.string\.([a-z_]+)')
        .allMatches(kotlin)
        .map((m) => m.group(1)!)
        .toSet();

    final strings = File(
      'android/app/src/main/res/values/widget_strings.xml',
    ).readAsStringSync();
    final declared = RegExp(r'name="([a-z_]+)"')
        .allMatches(strings)
        .map((m) => m.group(1)!)
        .toSet();

    expect(used.difference(declared), isEmpty, reason: 'string hilang');
  });
}
