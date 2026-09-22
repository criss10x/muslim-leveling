import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
// Impor langsung: platform interface tidak di-reexport oleh paket utama,
// padahal tes butuh mendaftarkan implementasi Android-nya.
// ignore: depend_on_referenced_packages
import 'package:flutter_local_notifications_platform_interface/flutter_local_notifications_platform_interface.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:muslim_leveling/l10n/app_localizations.dart';
import 'package:muslim_leveling/services/game_service.dart';
import 'package:muslim_leveling/services/locale_service.dart';
import 'package:muslim_leveling/services/notification_service.dart';
import 'package:muslim_leveling/widgets/common.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'helpers/app_wrap.dart';

/// Guard tiga perbaikan Fase 1 yang tersisa (Task 1.7, HUD Home, Task 1.9).
///
/// Semuanya punya pola gagal yang sama: teks *terlihat* benar di satu bahasa,
/// jadi bug-nya tak kelihatan sampai user benar-benar ganti bahasa.
const _notifChannel = MethodChannel(
  'dexterous.com/flutter/local_notifications',
);

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late List<String> scheduledTitles;
  late List<String> scheduledBodies;

  /// Mock channel notif. `zonedSchedule` adalah satu-satunya cara teks notif
  /// diamati: service tidak menyimpannya di memori, payload langsung diserahkan
  /// ke Android — itu justru akar masalah Task 1.7.
  void mockNotifChannel(WidgetTester tester) {
    scheduledTitles = [];
    scheduledBodies = [];
    tester.binding.defaultBinaryMessenger.setMockMethodCallHandler(
      _notifChannel,
      (c) async {
        switch (c.method) {
          // Harus non-null, kalau tidak init() melempar dan tes hijau palsu.
          case 'initialize':
            return true;
          case 'areNotificationsEnabled':
            return true;
          case 'pendingNotificationRequests':
            return <Object>[];
          case 'zonedSchedule':
            final args = c.arguments as Map?;
            scheduledTitles.add('${args?['title']}');
            scheduledBodies.add('${args?['body']}');
            return null;
          default:
            return null;
        }
      },
    );
  }

  void unmockNotifChannel(WidgetTester tester) {
    tester.binding.defaultBinaryMessenger.setMockMethodCallHandler(
      _notifChannel,
      null,
    );
  }

  setUp(() {
    // flutter_test tak menjalankan plugin registrant: tanpa baris ini
    // FlutterLocalNotificationsPlatform.instance masih uninitialized.
    FlutterLocalNotificationsPlatform.instance =
        AndroidFlutterLocalNotificationsPlugin();
  });

  tearDown(() {
    LocaleNotifier.onLocaleChanged = null;
  });

  group('Task 1.7 — notif adzan ikut bahasa', () {
    testWidgets('ganti bahasa menjadwalkan ulang teks notif', (tester) async {
      SharedPreferences.setMockInitialValues({
        'app_locale': 'id',
        // Pengingat aktif: tanpa ini reschedule memang tidak jalan
        // (dan diam-diam tidak ada notif yang perlu diperbaiki).
        'reminders_enabled': true,
        'city': 'Kab. Badung',
        'timing_subuh': '04:42',
        'timing_dzuhur': '12:05',
        'timing_ashar': '15:20',
        'timing_maghrib': '18:10',
        'timing_isya': '19:20',
      });
      // Panaskan dulu tanpa hook: singleton membawa state dari tes sebelumnya,
      // jadi panggilan pemanasnya sendiri bisa ikut menjadwalkan.
      LocaleNotifier.onLocaleChanged = null;
      await localeNotifier.setLocale(const Locale('id'));
      mockNotifChannel(tester);
      LocaleNotifier.onLocaleChanged = NotificationService.rescheduleForLocale;

      await tester.runAsync(() async {
        await localeNotifier.setLocale(const Locale('en'));
      });

      expect(
        scheduledTitles,
        isNotEmpty,
        reason: 'ganti bahasa tidak menjadwalkan ulang — notif tetap Indonesia',
      );
      expect(
        scheduledTitles.any((t) => t.contains('Fajr')),
        isTrue,
        reason: 'judul notif tidak ikut bahasa baru: $scheduledTitles',
      );
      expect(
        scheduledTitles.any((t) => t.contains('Subuh')),
        isFalse,
        reason: 'notif Indonesia masih terjadwal setelah ganti ke English',
      );
      unmockNotifChannel(tester);
    });

    testWidgets('bahasa sama → tidak reschedule (jangan buang kerja)',
        (tester) async {
      SharedPreferences.setMockInitialValues({
        'app_locale': 'en',
        'reminders_enabled': true,
        'city': 'Kab. Badung',
        'timing_subuh': '04:42',
      });
      LocaleNotifier.onLocaleChanged = null;
      await localeNotifier.setLocale(const Locale('en'));
      mockNotifChannel(tester);
      LocaleNotifier.onLocaleChanged = NotificationService.rescheduleForLocale;

      await tester.runAsync(() async {
        await localeNotifier.setLocale(const Locale('en'));
      });

      expect(scheduledTitles, isEmpty);
      unmockNotifChannel(tester);
    });

    testWidgets('pengingat mati → tidak reschedule', (tester) async {
      SharedPreferences.setMockInitialValues({
        'app_locale': 'id',
        'reminders_enabled': false,
        'city': 'Kab. Badung',
        'timing_subuh': '04:42',
      });
      LocaleNotifier.onLocaleChanged = null;
      await localeNotifier.setLocale(const Locale('id'));
      mockNotifChannel(tester);
      LocaleNotifier.onLocaleChanged = NotificationService.rescheduleForLocale;

      await tester.runAsync(() async {
        await localeNotifier.setLocale(const Locale('en'));
      });

      expect(scheduledTitles, isEmpty);
      unmockNotifChannel(tester);
    });
  });

  group('HUD Home — countdown & label ikut bahasa', () {
    final timings = Timings(
      subuh: '04:42',
      terbit: '06:00',
      dhuha: '06:30',
      dzuhur: '12:05',
      ashar: '15:20',
      maghrib: '18:10',
      isya: '19:20',
    );

    test('countdown memakai key ARB, bukan literal Indonesia', () async {
      final id = await AppL10n.delegate.load(const Locale('id'));
      final en = await AppL10n.delegate.load(const Locale('en'));

      final idNext = GameService.nextPrayerInfo(timings, id);
      final enNext = GameService.nextPrayerInfo(timings, en);

      // Bentuk teksnya beda per bahasa — inilah yang dulu tidak mungkin,
      // karena countdown dirakit dari literal '${h}j ${m}m ... lagi'.
      expect(idNext.countdown, isNot(enNext.countdown));
      expect(idNext.countdown, contains('lagi'));
      expect(enNext.countdown, contains('left'));
    });

    test('nama & label sholat dari ARB di kedua locale', () async {
      final en = await AppL10n.delegate.load(const Locale('en'));
      final next = GameService.nextPrayerInfo(timings, en);
      expect(
        ['Fajr', 'Dhuhr', 'Asr', 'Maghrib', 'Isha'],
        contains(next.name),
      );

      final current = GameService.currentPrayerInfo(timings, en);
      expect(
        ['Prayer Times', 'SUNNAH DHUHA', 'COUNTDOWN TO'],
        contains(current.label),
        reason: 'label HUD masih literal Indonesia: ${current.label}',
      );
    });
  });

  group('Task 1.9 — penanda bahasa konten', () {
    testWidgets('locale id + konten Indonesia → penanda tidak muncul',
        (tester) async {
      await tester.pumpWidget(appWrap(
        const Scaffold(
          body: ContentLangNote(locale: Locale('id'), contentIsEnglish: false),
        ),
        locale: const Locale('id'),
      ));
      final l10n = lookupAppL10n(const Locale('id'));
      expect(find.text(l10n.contentNoteIndonesian), findsNothing);
    });

    testWidgets('locale en + konten Indonesia → penanda Indonesia muncul',
        (tester) async {
      await tester.pumpWidget(appWrap(
        const Scaffold(
          body: ContentLangNote(locale: Locale('en'), contentIsEnglish: false),
        ),
        locale: const Locale('en'),
      ));
      final l10n = lookupAppL10n(const Locale('en'));
      expect(find.text(l10n.contentNoteIndonesian), findsOneWidget);
    });

    testWidgets('locale tr → penanda Inggris (tr dapat terjemahan Inggris)',
        (tester) async {
      await tester.pumpWidget(appWrap(
        const Scaffold(
          body: ContentLangNote(locale: Locale('tr'), contentIsEnglish: true),
        ),
        locale: const Locale('tr'),
      ));
      final l10n = lookupAppL10n(const Locale('tr'));
      expect(find.text(l10n.contentNoteInEnglish), findsOneWidget);
    });

    test('semua bahasa di supported punya kedua key penanda', () {
      for (final locale in AppL10n.supportedLocales) {
        final l10n = lookupAppL10n(locale);
        expect(l10n.contentNoteIndonesian.isNotEmpty, isTrue,
            reason: 'contentNoteIndonesian kosong di ${locale.languageCode}');
        expect(l10n.contentNoteInEnglish.isNotEmpty, isTrue,
            reason: 'contentNoteInEnglish kosong di ${locale.languageCode}');
      }
    });
  });
}
