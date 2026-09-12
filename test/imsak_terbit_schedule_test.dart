import 'package:flutter_test/flutter_test.dart';
import 'package:muslim_leveling/services/notification_service.dart';

void main() {
  // ponytail: imsak & terbit = penanda waktu, selalu senyap. Test ini menjaga
  // invariant itu: kalau ada yang menambahkan keduanya ke daftar wajib
  // (sehingga bisa dibunyikan / ikut mode intensif), dia langsung gagal.
  test('imsak & terbit bukan sholat wajib', () {
    expect(NotificationService.wajibList, isNot(contains('imsak')));
    expect(NotificationService.wajibList, isNot(contains('terbit')));
    expect(NotificationService.wajibList.length, 5);
  });

  test('imsak & terbit ada di daftar marker (dijadwalkan, tapi senyap)', () {
    expect(NotificationService.markerList, ['imsak', 'terbit']);
    expect(NotificationService.allScheduledList, contains('imsak'));
    expect(NotificationService.allScheduledList, contains('terbit'));
  });

  test('ID notifikasi sholat wajib tidak berubah setelah marker ditambah', () {
    // 10..50 harus tetap milik subuh..isya — kalau bergeser, pengingat lama
    // di perangkat user tidak tertimpa dan notif ganda muncul.
    expect(NotificationService.baseIdFor('subuh'), 10);
    expect(NotificationService.baseIdFor('dzuhur'), 20);
    expect(NotificationService.baseIdFor('ashar'), 30);
    expect(NotificationService.baseIdFor('maghrib'), 40);
    expect(NotificationService.baseIdFor('isya'), 50);
    // marker dapat ID baru di ujung, tidak menabrak milik wajib
    expect(NotificationService.baseIdFor('imsak'), 60);
    expect(NotificationService.baseIdFor('terbit'), 70);
  });

  test('judul notif imsak/terbit tidak menyebut "Sholat"', () {
    expect(NotificationService.titleFor('imsak'), '🕌 Imsak');
    expect(NotificationService.titleFor('terbit'), '🕌 Terbit');
    expect(NotificationService.titleFor('subuh'), '🕌 Waktunya Sholat Subuh');
  });

  test('body notif imsak/terbit menjelaskan maknanya', () {
    final imsak = NotificationService.bodyFor('imsak', 'Jakarta', 'seimbang', 0);
    final terbit = NotificationService.bodyFor('terbit', 'Jakarta', 'seimbang', 0);
    expect(imsak, contains('imsak'));
    expect(imsak, contains('Jakarta'));
    expect(terbit, contains('terbit'));
    // terbit menandai berakhirnya Subuh, bukan waktu sholat baru
    expect(terbit, contains('Subuh'));
  });
}
