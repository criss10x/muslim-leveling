import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
// Impor langsung: FlutterLocalNotificationsPlatform tidak ikut di-reexport
// (daftar `show` paket itu terbatas), padahal tes butuh mendaftarkannya.
// Paket ini dependency transitif resmi dari flutter_local_notifications.
// ignore: depend_on_referenced_packages
import 'package:flutter_local_notifications_platform_interface/flutter_local_notifications_platform_interface.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:muslim_leveling/screens/onboarding_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'helpers/app_wrap.dart';

/// Guard: halaman notifikasi onboarding harus meminta pengecualian battery
/// optimization, bukan cuma izin notifikasi.
///
/// Alasannya bukan estetika: tanpa exemption, OEM (Xiaomi/Oppo/Vivo/Realme)
/// membunuh alarm saat app ditutup dan adzan tidak pernah bunyi — satu-satunya
/// penyebab notif mati diam-diam yang TIDAK punya fallback (beda dari izin
/// exact alarm, yang jatuh ke inexactAllowWhileIdle).
///
/// Jalur ini pernah dibuang di 01a15fc lalu dikembalikan; tes ini yang
/// menahannya supaya tidak terbuang lagi tanpa sengaja.
const _notifChannel = MethodChannel(
  'dexterous.com/flutter/local_notifications',
);
const _permChannel = MethodChannel('flutter.baseflow.com/permissions/methods');

/// Permission.ignoreBatteryOptimizations.value (permission_handler 11.x).
const _ignoreBatteryOptimizations = 16;

/// PermissionStatus.denied / granted.
const _denied = 0;
const _granted = 1;

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late List<String> calls;

  /// Mock kedua channel plugin. [notifGranted] meniru jawaban dialog izin OS;
  /// exemption baterai selalu mulai dari "belum diizinkan" supaya jalur
  /// request-nya benar-benar dilewati.
  void mockPlugins(WidgetTester tester, {required bool notifGranted}) {
    calls = [];
    tester.binding.defaultBinaryMessenger.setMockMethodCallHandler(
      _notifChannel,
      (c) async {
        calls.add('notif.${c.method}');
        return switch (c.method) {
          // initialize HARUS mengembalikan non-null: null membuat
          // NotificationService.init() melempar, jalur izin dilewati
          // diam-diam, dan tes jadi hijau palsu.
          'initialize' => true,
          'requestNotificationsPermission' => notifGranted,
          'areNotificationsEnabled' => notifGranted,
          'pendingNotificationRequests' => <Object>[],
          _ => null,
        };
      },
    );
    tester.binding.defaultBinaryMessenger.setMockMethodCallHandler(
      _permChannel,
      (c) async {
        calls.add('perm.${c.method}');
        return switch (c.method) {
          'checkPermissionStatus' => _denied,
          'requestPermissions' => <int, int>{
            _ignoreBatteryOptimizations: _granted,
          },
          _ => null,
        };
      },
    );
  }

  void unmockPlugins(WidgetTester tester) {
    tester.binding.defaultBinaryMessenger.setMockMethodCallHandler(
      _notifChannel,
      null,
    );
    tester.binding.defaultBinaryMessenger.setMockMethodCallHandler(
      _permChannel,
      null,
    );
  }

  setUp(() {
    // flutter_test tidak menjalankan plugin registrant: tanpa baris ini
    // FlutterLocalNotificationsPlatform.instance masih uninitialized dan
    // NotificationService.init() melempar LateInitializationError — jalur izin
    // dilewati diam-diam dan tes jadi hijau palsu.
    FlutterLocalNotificationsPlatform.instance =
        AndroidFlutterLocalNotificationsPlugin();
  });

  /// Maju ke halaman 6 tanpa menyentuh GPS: tombol lokasi tidak ditekan.
  Future<void> toNotifPage(WidgetTester tester) async {
    for (var i = 0; i < 5; i++) {
      await tester.fling(find.byType(PageView), const Offset(-400, 0), 800);
      await tester.pumpAndSettle();
    }
    expect(find.text('Izinkan Notifikasi'), findsOneWidget);
  }

  /// Pump terbatas — DashboardShell punya timer, pumpAndSettle bisa menggantung.
  Future<void> settle(WidgetTester tester) async {
    for (var i = 0; i < 15; i++) {
      await tester.pump(const Duration(milliseconds: 100));
    }
  }

  testWidgets('izin notifikasi diberikan → exemption baterai diminta', (
    tester,
  ) async {
    SharedPreferences.setMockInitialValues({});
    mockPlugins(tester, notifGranted: true);
    await tester.pumpWidget(appWrap(OnboardingScreen()));
    await toNotifPage(tester);

    await tester.tap(find.text('Izinkan Notifikasi'));
    await settle(tester);

    expect(
      calls,
      contains('perm.requestPermissions'),
      reason: 'exemption baterai tidak diminta — adzan akan dibunuh OEM',
    );
    expect(
      calls.indexOf('perm.requestPermissions'),
      greaterThan(calls.indexOf('notif.requestNotificationsPermission')),
      reason: 'exemption diminta sebelum izin notifikasi ada',
    );
    unmockPlugins(tester);
  });

  testWidgets('izin notifikasi ditolak → exemption baterai tidak diminta', (
    tester,
  ) async {
    SharedPreferences.setMockInitialValues({});
    mockPlugins(tester, notifGranted: false);
    await tester.pumpWidget(appWrap(OnboardingScreen()));
    await toNotifPage(tester);

    await tester.tap(find.text('Izinkan Notifikasi'));
    await settle(tester);

    // Tanpa izin notifikasi, exemption tidak ada gunanya: tidak ada yang
    // dijadwalkan untuk dibunuh OEM.
    expect(calls, isNot(contains('perm.requestPermissions')));
    unmockPlugins(tester);
  });
}
