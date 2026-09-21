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
}
