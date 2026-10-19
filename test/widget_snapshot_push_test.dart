import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:muslim_leveling/services/widget_snapshot.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  final calls = <MethodCall>[];

  void mockChannel(Future<Object?> Function(MethodCall) handler) {
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(
          const MethodChannel(WidgetSnapshot.channelName),
          handler,
        );
  }

  setUp(() {
    SharedPreferences.setMockInitialValues({});
    calls.clear();
    mockChannel((call) async {
      calls.add(call);
      return null;
    });
  });

  tearDown(() {
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(
          const MethodChannel(WidgetSnapshot.channelName),
          null,
        );
  });

  test('payload tersimpan di prefs dan channel dipanggil sekali', () async {
    await WidgetSnapshot.pushRaw({'today': '2026-10-19', 'quests': []});
    final p = await SharedPreferences.getInstance();
    expect(p.getString(WidgetSnapshot.prefKey), contains('2026-10-19'));
    expect(calls.single.method, 'refresh');
  });

  test('snapshot ditimpa, bukan menumpuk', () async {
    await WidgetSnapshot.pushRaw({'today': '2026-10-19'});
    await WidgetSnapshot.pushRaw({'today': '2026-10-20'});
    final p = await SharedPreferences.getInstance();
    expect(p.getString(WidgetSnapshot.prefKey), contains('2026-10-20'));
    expect(p.getString(WidgetSnapshot.prefKey), isNot(contains('2026-10-19')));
    expect(calls.length, 2);
  });

  test('channel gagal tidak melempar (widget bukan jalur kritis)', () async {
    mockChannel((call) async => throw PlatformException(code: 'x'));
    await expectLater(
      WidgetSnapshot.pushRaw({'today': '2026-10-19'}),
      completes,
    );
    // Snapshot tetap tersimpan meski channel gagal: prefs ditulis lebih dulu.
    final p = await SharedPreferences.getInstance();
    expect(p.getString(WidgetSnapshot.prefKey), contains('2026-10-19'));
  });

  test('kunci prefs bernama widget_snapshot_v1 (dibaca Kotlin)', () {
    expect(WidgetSnapshot.prefKey, 'widget_snapshot_v1');
    expect(WidgetSnapshot.channelName, 'ml/widget');
  });
}
