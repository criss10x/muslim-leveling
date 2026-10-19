import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:muslim_leveling/services/widget_sync.dart';

void main() {
  setUp(() => SharedPreferences.setMockInitialValues({}));

  test('fetch hanya sekali per hari', () async {
    var fetches = 0;
    Future<int> fake() async => ++fetches;

    await WidgetSync.ensureWeek(fetch: fake, today: '2026-10-19');
    await WidgetSync.ensureWeek(fetch: fake, today: '2026-10-19');
    expect(fetches, 1, reason: 'hari yang sama tidak boleh fetch ulang');

    await WidgetSync.ensureWeek(fetch: fake, today: '2026-10-20');
    expect(fetches, 2, reason: 'hari baru wajib fetch');
  });

  test('fetch gagal tidak menandai hari selesai, jadi dicoba lagi', () async {
    var panggilan = 0;
    Future<int> gagal() async {
      panggilan++;
      throw Exception('offline');
    }

    await WidgetSync.ensureWeek(fetch: gagal, today: '2026-10-19');
    expect(panggilan, 1);
    await WidgetSync.ensureWeek(fetch: gagal, today: '2026-10-19');
    expect(panggilan, 2, reason: 'gagal tidak boleh dianggap sudah selesai');
  });

  test('fetch yang mengembalikan 0 hari juga tidak menandai selesai', () async {
    var panggilan = 0;
    Future<int> kosong() async {
      panggilan++;
      return 0;
    }

    await WidgetSync.ensureWeek(fetch: kosong, today: '2026-10-19');
    await WidgetSync.ensureWeek(fetch: kosong, today: '2026-10-19');
    expect(panggilan, 2, reason: '0 hari berarti belum dapat jadwal');
  });

  test('berhasil menandai hari, hari berikutnya fetch lagi', () async {
    var fetches = 0;
    Future<int> ok() async {
      fetches++;
      return 7;
    }

    await WidgetSync.ensureWeek(fetch: ok, today: '2026-10-19');
    final p = await SharedPreferences.getInstance();
    expect(p.getString(WidgetSync.weekStampKey), '2026-10-19');
    await WidgetSync.ensureWeek(fetch: ok, today: '2026-10-21');
    expect(fetches, 2);
  });
}
