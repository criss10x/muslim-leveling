import 'package:flutter_test/flutter_test.dart';
import 'package:muslim_leveling/services/backup_merge.dart';
import 'package:muslim_leveling/services/cloud_sync.dart';

/// Regresi XP: HP berprogres rendah pernah menimpa cloud level 31 (10.400 XP)
/// jadi level 2 (53 XP) karena `saveGame` mengirim map `game` utuh.
void main() {
  setUp(CloudSync.clearUser);
  tearDown(() {
    CloudSync.resetDocumentReader();
    CloudSync.resetDocumentWriter();
    CloudSync.clearUser();
  });

  group('isXpRegression', () {
    test('regresi nyata (10400 → 53) tertangkap', () {
      expect(isXpRegression({'xp': 53}, {'xp': 10400}), isTrue);
    });

    test('lonjakan progres bukan regresi', () {
      expect(isXpRegression({'xp': 10500}, {'xp': 10400}), isFalse);
    });

    test('unlog sah (≤500 XP) tetap diizinkan', () {
      expect(isXpRegression({'xp': 10360}, {'xp': 10400}), isFalse);
      expect(isXpRegression({'xp': 9900}, {'xp': 10400}), isFalse);
    });

    test('tepat di ambang belum dianggap regresi', () {
      expect(isXpRegression({'xp': 9900}, {'xp': 10400}), isFalse); // drop 500
      expect(isXpRegression({'xp': 9899}, {'xp': 10400}), isTrue); // drop 501
    });

    test('doc cloud tanpa xp = 0, bukan regresi', () {
      expect(isXpRegression({'xp': 120}, {}), isFalse);
    });
  });

  group('isHistoryRegression', () {
    final remote3 = List.filled(3, {'date': '2026-09-21', 'prayer': 'subuh'});

    test('regresi lapangan: 158 XP/3 log → 0 XP/0 log tertangkap', () {
      // Drop XP cuma 158 → di bawah ambang, dulu LOLOS dan menghapus riwayat.
      expect(
        isHistoryRegression({'xp': 0, 'prayerLog': []}, {
          'xp': 158,
          'prayerLog': remote3,
        }),
        isTrue,
      );
    });

    test('unlog sah (hapus 1 log hari ini) tetap diizinkan', () {
      final remote = List.filled(10, 'x');
      expect(
        isHistoryRegression({'xp': 90, 'prayerLog': remote.sublist(1)}, {
          'xp': 120,
          'prayerLog': remote,
        }),
        isFalse,
      );
    });

    test('kerugian >1 log = regresi walau XP naik', () {
      expect(
        isHistoryRegression({'xp': 99999, 'prayerLog': []}, {
          'xp': 100,
          'prayerLog': List.filled(9, 'x'),
        }),
        isTrue,
        reason: 'XP naik tak menghalalkan hilangnya riwayat',
      );
    });

    test('cloud tanpa prayerLog tidak dianggap regresi riwayat', () {
      expect(
        isHistoryRegression({'xp': 100, 'prayerLog': []}, {'xp': 50}),
        isFalse,
      );
    });

    test('regresi XP lama (10400 → 53) tetap tertangkap', () {
      expect(
        isHistoryRegression({'xp': 53, 'prayerLog': []}, {
          'xp': 10400,
          'prayerLog': List.filled(236, 'x'),
        }),
        isTrue,
      );
    });
  });

  test('saveGame menolak push yang menghapus riwayat cloud (158 XP → 0)',
      () async {
    final written = <Map<String, dynamic>>[];
    CloudSync.documentReader = (_) async => {
          'game': {
            'xp': 158,
            'prayerLog': List.filled(3, {'date': '2026-09-21', 'prayer': 'subuh'}),
          },
        };
    CloudSync.documentWriter = (_, data) async => written.add(data);
    await CloudSync.initWithUser('krsnsuryana');

    expect(await CloudSync.saveGame({'xp': 0, 'prayerLog': []}), isTrue);

    expect(written, hasLength(1));
    expect(written.single['game']['xp'], 158, reason: 'cloud menang');
    expect(written.single['game']['prayerLog'], hasLength(3),
        reason: 'riwayat cloud dipertahankan');
  });

  test('saveGame menolak menimpa cloud berprogres lebih tinggi', () async {
    final written = <Map<String, dynamic>>[];
    CloudSync.documentReader = (_) async => {
          'game': {'xp': 10400, 'prayerLog': List.filled(236, 'x')},
        };
    CloudSync.documentWriter = (_, data) async => written.add(data);
    await CloudSync.initWithUser('krsnsuryana');

    expect(await CloudSync.saveGame({'xp': 53, 'prayerLog': []}), isTrue);

    expect(written, hasLength(1));
    expect(written.single['game']['xp'], 10400);
    expect(written.single['game']['prayerLog'], hasLength(236));
  });

  test('saveGame meneruskan unlog sah apa adanya', () async {
    final written = <Map<String, dynamic>>[];
    CloudSync.documentReader = (_) async => {'game': {'xp': 10400}};
    CloudSync.documentWriter = (_, data) async => written.add(data);
    await CloudSync.initWithUser('krsnsuryana');

    expect(await CloudSync.saveGame({'xp': 10280}), isTrue);
    expect(written.single['game']['xp'], 10280);
  });

  test('saveGame normal tidak membaca ulang dokumen', () async {
    var reads = 0;
    CloudSync.documentReader = (_) async {
      reads++;
      return {'game': {'xp': 100}};
    };
    CloudSync.documentWriter = (_, _) async {};
    await CloudSync.initWithUser('krsnsuryana');
    expect(reads, 1); // read validasi saja

    await CloudSync.saveGame({'xp': 150}); // maju → tak perlu read
    expect(reads, 1);
  });

  test('push kosong saat login di jendela pra-merge ditahan', () async {
    // Skenario lapangan 20:08:01: HP belum merge, tapi `_save` menembak state
    // kosong ke cloud yang masih punya 3 log. Harus ditahan + diheal.
    final written = <Map<String, dynamic>>[];
    CloudSync.documentReader = (_) async => {
          'game': {
            'xp': 158,
            'prayerLog': List.filled(3, {'date': '2026-09-21', 'prayer': 'subuh'}),
            'lifeTotals': {'subuh': 3},
          },
        };
    CloudSync.documentWriter = (_, data) async => written.add(data);
    await CloudSync.initWithUser('krsnsuryana');

    final saved = await CloudSync.saveGame({
      'xp': 0,
      'prayerLog': <dynamic>[],
      'lifeTotals': <String, dynamic>{},
    });

    expect(saved, isTrue);
    expect(written.single['game']['xp'], 158);
    expect(written.single['game']['lifeTotals'], {'subuh': 3},
        reason: 'lifeTotals cloud ikut diselamatkan');
  });
}
