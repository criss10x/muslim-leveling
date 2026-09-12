import 'adzan_sound_store.dart';
import 'dart:convert';
import 'package:android_intent_plus/android_intent.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:sentry_flutter/sentry_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:timezone/data/latest_all.dart' as tz;
import 'package:timezone/timezone.dart' as tz;

/// Notification & Adzan Reminder service.
/// Port dari NotificationScheduler.kt + AdhanReminderReceiver.kt + BootReceiver.kt (main Kotlin).
///
/// Menggunakan flutter_local_notifications plugin (menggantikan AlarmManager manual).
/// Plugin ini otomatis handle:
/// - Notification channel setup
/// - Scheduled notifications dengan zonedSchedule
/// - Boot receiver untuk reschedule setelah reboot
///
/// Usage:
///   await NotificationService.init();
///   await NotificationService.scheduleAdhanReminders('Jakarta', timings);
///   await NotificationService.cancelAdhanReminders();
///   await NotificationService.setRemindersEnabled(true/false);

/// Jenis suara sebuah notifikasi terjadwal — menentukan channel yang dipakai
/// (suara channel Android immutable, jadi tiap jenis punya channel sendiri).
enum _NotifSound { silent, normal, adzan }

class NotificationService {
  static final _plugin = FlutterLocalNotificationsPlugin();

  // Aksen icon notif — konstanta brand, bukan AppColors.primary: notifikasi
  // muncul di luar app, jadi tidak ikut preset tema pengguna. Emerald 0xFF34D399
  // adalah warna primer identitas Muslim Leveling (sinkron dengan
  // AppColorsDark/Light.primary).
  static const _notifAccent = Color(0xFF34D399);

  // v2: channel v1 di sebagian device (Xiaomi/OEM A15) terlanjur terbuat
  // ambigu tanpa playSound eksplisit → dipin senyap & notif tak muncul.
  // Channel Android immutable, jadi bump ID + hapus v1.
  static const _channelId = 'adhan_reminders_v2';
  static const _legacyChannelId = 'adhan_reminders';
  static const _channelName = 'Pengingat Adzan';
  static const _channelDesc = 'Notifikasi pengingat waktu sholat';

  // Channel terpisah untuk notifikasi saat masuk waktu adzan, dengan suara
  // adzan (res/raw/adzan.mp3). Channel Android immutable setelah dibuat,
  // makanya pakai ID baru, bukan mengubah channel lama. v2: channel v1 di
  // sebagian device terlanjur terbuat tanpa suara — di-bump + v1 dihapus.
  static const _adzanChannelId = 'adhan_sound_v2';
  static const _legacyAdzanChannelId = 'adhan_sound_v1';
  static const _adzanChannelName = 'Adzan';
  static const _adzanChannelDesc = 'Notifikasi bersuara adzan saat masuk waktu sholat';

  /// Katalog pilihan suara adzan: (id pref, resource res/raw, label UI).
  /// 'adzan' = suara default versi lama. Channel Android immutable, jadi
  /// tiap varian punya channel sendiri: `adhan_sound_v2` (default) dan
  /// `adhan_sound_<id>_v1` untuk sisanya.
  static const adzanVariants = [
    ('adzan', 'adzan', 'Adzan Klasik'),
    ('a1', 'adzan_a1', 'Ahmad al-Nafees'),
    ('a2', 'adzan_a2', 'Hafiz Mustafa Özcan'),
    ('a4', 'adzan_a4', "Dubai's One TV by Mishary Rashid Alafasy"),
    ('a7', 'adzan_a7', 'Mishary Rashid Alafasy 2'),
    ('zahrani', 'adzan_zahrani', 'Mansour Al-Zahrani'),
  ];
  static const _prefAdzanVariant = 'adzan_variant';

  /// Varian aktif (di-cache dari prefs saat init, diupdate setAdzanVariant)
  /// supaya _detailsFor tetap sinkron tanpa baca prefs berulang.
  static String _variant = 'adzan';

  /// Content URI suara varian aktif. Null = varian default 'adzan' yang
  /// masih berupa raw resource APK. Varian lain didownload on-demand dari
  /// GitHub Releases (AdzanSoundStore) lalu dimainkan lewat FileProvider
  /// content URI — sistem Android membaca suara channel di luar app, jadi
  /// butuh URI + grant baca (AdzanSoundBridge.java).
  static UriAndroidNotificationSound? _variantSound;

  static const MethodChannel _soundChannel =
      MethodChannel('muslim_leveling/adzan_sound');

  static String _variantChannelId(String v) =>
      v == 'adzan' ? _adzanChannelId : 'adhan_sound_${v}_v2';

  static String _variantResource(String v) =>
      adzanVariants.firstWhere((e) => e.$1 == v,
          orElse: () => adzanVariants.first).$2;

  static String _variantLabel(String v) =>
      adzanVariants.firstWhere((e) => e.$1 == v,
          orElse: () => adzanVariants.first).$3;

  // Channel senyap — notif muncul tanpa suara (mode suara: senyap).
  static const _silentChannelId = 'adhan_silent_v1';
  static const _silentChannelName = 'Pengingat Senyap';
  static const _silentChannelDesc = 'Notifikasi pengingat sholat tanpa suara';

  static const _prefEnabled = 'reminders_enabled';
  static const _prefCity = 'city';
  static const _prefDate = 'date';
  static const _prefTimingsPrefix = 'timing_';
  static const _prefNotifMode = 'notif_mode'; // fokus/seimbang/intensif
  static const _prefSoundMode = 'notif_sound_mode'; // senyap/suara/adzan
  static const _prefPerPrayerSounds = 'per_prayer_sounds'; // {"subuh":"senyap",...}

  static const _wajibList = ['subuh', 'dzuhur', 'ashar', 'maghrib', 'isya'];

  /// ponytail: imsak & terbit = penanda waktu, BUKAN sholat wajib. Selalu
  /// senyap (tanpa suara), tidak bisa di-override user, dan hanya 1 pengingat
  /// tepat saat waktunya — tidak ikut mode fokus/seimbang/intensif.
  static const _markerList = ['imsak', 'terbit'];

  /// Urutan ini menentukan ID notifikasi — JANGAN menyisipkan di tengah.
  static const _allList = [..._wajibList, ..._markerList];

  // Ekspos untuk test invariant (lihat test/imsak_terbit_schedule_test.dart).
  @visibleForTesting
  static List<String> get wajibList => _wajibList;
  @visibleForTesting
  static List<String> get markerList => _markerList;
  @visibleForTesting
  static List<String> get allScheduledList => _allList;
  @visibleForTesting
  static int baseIdFor(String prayer) => _baseIdFor(prayer);
  @visibleForTesting
  static String titleFor(String prayer) => _titleFor(prayer);
  @visibleForTesting
  static String bodyFor(String prayer, String city, String mode, int i) =>
      _bodyFor(prayer, city, mode, i);

  /// ID notifikasi tetap per waktu (index × 10, + offset reminder 0–2).
  /// String.hashCode tidak dijamin stabil antar-run, jadi jangan dipakai.
  static int _baseIdFor(String prayer) => (_allList.indexOf(prayer) + 1) * 10;

  static bool _initialized = false;
  static bool get isInitialized => _initialized;

  // ═══════════════════════════════════════════
  //  Init
  // ═══════════════════════════════════════════

  static Future<void> init() async {
    if (_initialized) return;

    // Initialize timezone data
    tz.initializeTimeZones();
    // ponytail: WIB-only. Add city→timezone mapping when eastern users report
    // notifications fire at wrong times.
    tz.setLocalLocation(tz.getLocation('Asia/Jakarta'));

    // ic_stat_notif adalah aset khusus notif small icon: siluet putih di alpha,
    // di-generate dari android/notif-source.svg ke 5 kerapatan drawable-*.
    // ic_launcher tidak boleh dipakai di sini — sejak Android 5.0 sistem
    // memaksa small icon jadi siluet, dan icon launcher berwarna berubah
    // jadi kotak putih pekat di status bar.
    // flutter_local_notifications membutuhkan nama resource, bukan Android
    // resource reference (@drawable/...). Prefix membuat lookup default icon
    // gagal dengan PlatformException(invalid_icon).
    const androidInit = AndroidInitializationSettings('ic_stat_notif');
    const iosInit = DarwinInitializationSettings(
      requestAlertPermission: false,
      requestBadgePermission: false,
      requestSoundPermission: false,
    );
    const settings = InitializationSettings(android: androidInit, iOS: iosInit);

    await _plugin.initialize(
      settings,
      onDidReceiveNotificationResponse: _onNotificationTap,
    );

    // Muat pilihan suara adzan sebelum channel dibuat, supaya jadwal
    // berikutnya langsung pakai channel varian yang benar.
    final prefs = await SharedPreferences.getInstance();
    _variant = prefs.getString(_prefAdzanVariant) ?? 'adzan';
    // Guard versi lama/downgrade: id tak dikenal → kembali default.
    if (!adzanVariants.any((e) => e.$1 == _variant)) _variant = 'adzan';
    // Restore content URI varian dari cache (unduh di sesi sebelumnya).
    if (_variant != 'adzan') {
      try {
        _variantSound = await _soundForVariant(_variant);
      } catch (e) {
        debugPrint('[NotificationService] restore varian $_variant gagal: $e');
      }
      // Cache hilang (uninstall/reinstall) → channel tidak bisa dibuat
      // dengan suara varian. Kembali ke default, dan tulis pref-nya supaya
      // UI dan jadwal tetap konsisten.
      if (_variantSound == null) {
        _variant = 'adzan';
        await prefs.setString(_prefAdzanVariant, 'adzan');
      }
    }

    // Create channel (Android 8+)
    await _createChannel();

    _initialized = true;
    debugPrint('[NotificationService] initialized');
  }

  static Future<void> _createChannel() async {
    final androidChannel = AndroidNotificationChannel(
      _channelId,
      _channelName,
      description: _channelDesc,
      importance: Importance.high,
      playSound: true,
      vibrationPattern: Int64List.fromList([0, 300, 200, 300]),
      enableVibration: true,
    );

    final androidPlugin = _plugin
        .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>();

    // Satu channel per varian suara adzan — suara channel tidak bisa
    // diubah setelah dibuat. Channel hanya dibuat untuk varian yang
    // aktif; makeNotificationChannel idempotent (update bila sudah ada).
    for (final (id, _, label) in adzanVariants) {
      if (id != 'adzan' && id != _variant) continue;
      final channel = AndroidNotificationChannel(
        _variantChannelId(id),
        id == 'adzan' ? _adzanChannelName : 'Adzan — $label',
        description: _adzanChannelDesc,
        importance: Importance.high,
        // Default = raw resource APK; varian = content URI file unduhan.
        sound: id == 'adzan'
            ? const RawResourceAndroidNotificationSound('adzan')
            : _variantSound,
        // Usage alarm supaya adzan tetap terdengar penuh, tidak dipotong
        // aturan suara notifikasi biasa.
        audioAttributesUsage: AudioAttributesUsage.alarm,
        vibrationPattern: Int64List.fromList([0, 300, 200, 300]),
        enableVibration: true,
      );
      await androidPlugin?.createNotificationChannel(channel);
    }

    // Channel varian v1 sudah yatim (resource mp3-nya tidak lagi dibundel
    // di APK sejak download on-demand) — buang supaya tidak jadi channel
    // bisu di pengaturan sistem.
    for (final (id, _, _) in adzanVariants) {
      if (id != 'adzan') {
        await androidPlugin?.deleteNotificationChannel('adhan_sound_${id}_v1');
      }
    }

    final silentChannel = AndroidNotificationChannel(
      _silentChannelId,
      _silentChannelName,
      description: _silentChannelDesc,
      importance: Importance.high,
      playSound: false,
      vibrationPattern: Int64List.fromList([0, 300, 200, 300]),
      enableVibration: true,
    );

    // Setting channel gak bisa diubah setelah dibuat — buang versi lama
    // yang mungkin terlanjur soundless/senyap-dipin.
    await androidPlugin?.deleteNotificationChannel(_legacyAdzanChannelId);
    await androidPlugin?.deleteNotificationChannel(_legacyChannelId);
    await androidPlugin?.createNotificationChannel(androidChannel);
    await androidPlugin?.createNotificationChannel(silentChannel);
  }

  /// Buka layar pengaturan sistem Android untuk channel adzan, supaya user
  /// bisa cek/atur suaranya langsung. Fallback: pengaturan notifikasi app.
  static Future<void> openChannelSettings() async {
    const pkg = 'id.muslimleveling.muslim_leveling';
    final channelId = _variantChannelId(_variant);
    try {
      final intent = AndroidIntent(
        action: 'android.settings.CHANNEL_NOTIFICATION_SETTINGS',
        arguments: {
          'android.provider.extra.APP_PACKAGE': pkg,
          'android.provider.extra.CHANNEL_ID': channelId,
        },
      );
      await intent.launch();
    } catch (_) {
      const fallback = AndroidIntent(
        action: 'android.settings.APP_NOTIFICATION_SETTINGS',
        arguments: {'android.provider.extra.APP_PACKAGE': pkg},
      );
      await fallback.launch();
    }
  }

  /// Buka halaman Auto-start MIUI (Xiaomi) / izin "Autostart" OEM.
  /// Fallback berlapis: pengaturan baterai → detail app. Return false kalau
  /// semua gagal (bukan device MIUI/OEM — user tinggal lihat instruksi).
  static Future<bool> openOemAutoStartSettings() async {
    const pkg = 'id.muslimleveling.muslim_leveling';
    // MIUI 12+ autostart management page
    const targets = [
      ('com.miui.securitycenter', 'com.miui.permcenter.autostart.AutoStartManagementActivity'),
      // MIUI lama
      ('com.miui.securitycenter', 'com.miui.permcenter.autostart.AutoStartManagementActivity'),
      // Oppo/Realme/OnePlus ColorOS
      ('com.coloros.safecenter', 'com.coloros.safecenter.permission.startup.StartupAppListActivity'),
      // Vivo
      ('com.vivo.permissionmanager', 'com.vivo.permissionmanager.activity.BgStartUpManagerActivity'),
    ];
    for (final (pkgName, activity) in targets) {
      try {
        await AndroidIntent(
          action: 'android.intent.action.MAIN',
          package: pkgName,
          componentName: '$pkgName/$activity',
        ).launch();
        return true;
      } catch (_) {}
    }
    // Fallback: detail app (user scroll ke "Baterai"/"Autostart" manual)
    try {
      await AndroidIntent(
        action: 'android.settings.APPLICATION_DETAILS_SETTINGS',
        arguments: {'package': pkg},
      ).launch();
      return true;
    } catch (_) {
      return false;
    }
  }

  /// Request POST_NOTIFICATIONS permission (Android 13+).
  /// Returns true if granted.
  static Future<bool> requestPermission() async {
    if (!_initialized) await init();
    final androidPlugin = _plugin
        .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>();
    if (androidPlugin == null) return true; // iOS or other

    final granted = await androidPlugin.requestNotificationsPermission();
    return granted ?? false;
  }

  /// Cek status real notifikasi — bukan cuma prefs.
  /// Return true hanya kalau permission granted DAN user enable di prefs.
  static Future<bool> areNotificationsEnabled() async {
    if (!_initialized) await init();
    final androidPlugin = _plugin
        .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>();
    if (androidPlugin == null) return true; // iOS or other
    return await androidPlugin.areNotificationsEnabled() ?? false;
  }

  /// Pastikan izin exact alarm (Android 12+). Tanpa izin ini zonedSchedule
  /// mode exact melempar PlatformException dan TIDAK ADA notif terjadwal
  /// sama sekali. Kalau belum diizinkan, buka halaman sistem
  /// "Alarm & pengingat". Return status akhir.
  static Future<bool> ensureExactAlarmPermission() async {
    if (!_initialized) await init();
    final androidPlugin = _plugin
        .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>();
    if (androidPlugin == null) return true; // iOS or other

    final canExact =
        await androidPlugin.canScheduleExactNotifications() ?? false;
    if (canExact) return true;
    final granted = await androidPlugin.requestExactAlarmsPermission();
    return granted ?? false;
  }

  /// Minta pengecualian battery optimization (dialog sistem). Penyebab
  /// paling umum notif terjadwal tidak pernah muncul: OEM (Xiaomi/Oppo/
  /// Vivo/Realme dkk) membunuh alarm app yang "dioptimalkan" saat app
  /// ditutup. Return true kalau sudah dikecualikan.
  static Future<bool> ensureBatteryUnrestricted() async {
    try {
      final status = await Permission.ignoreBatteryOptimizations.status;
      if (status.isGranted) return true;
      final res = await Permission.ignoreBatteryOptimizations.request();
      return res.isGranted;
    } catch (e) {
      debugPrint('[NotificationService] battery optimization check gagal: $e');
      return false;
    }
  }

  /// Jumlah notifikasi yang benar-benar terjadwal di sistem —
  /// dipakai untuk verifikasi setelah toggle diaktifkan.
  static Future<int> pendingCount() async {
    final pending = await _plugin.pendingNotificationRequests();
    return pending.length;
  }

  // ═══════════════════════════════════════════
  //  Schedule / Cancel
  // ═══════════════════════════════════════════

  /// Schedule adzan reminders for all 5 wajib prayers.
  /// [city] for notification text, [timings] map of prayer → "HH:mm".
  static Future<void> scheduleAdhanReminders(
    String city,
    Map<String, String> timings,
  ) async {
    if (!_initialized) await init();
    if (timings.isEmpty) return;

    // Cancel existing first
    await cancelAlarms();

    // Persist to prefs for reboot reschedule
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_prefEnabled, true);
    await prefs.setString(_prefCity, city);
    final today = DateTime.now();
    final todayStr =
        '${today.year}-${today.month.toString().padLeft(2, '0')}-${today.day.toString().padLeft(2, '0')}';
    await prefs.setString(_prefDate, todayStr);
    for (final prayer in _allList) {
      final t = timings[prayer];
      if (t != null && t.isNotEmpty) {
        await prefs.setString('$_prefTimingsPrefix$prayer', t);
      }
    }

    await _scheduleAlarms(city, timings);
    debugPrint('[NotificationService] scheduled ${timings.length} adhan reminders for $city');
  }

  /// Cancel all scheduled adhan reminders.
  static Future<void> cancelAdhanReminders() async {
    await cancelAlarms();
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_prefEnabled, false);
    debugPrint('[NotificationService] cancelled all adhan reminders');
  }

  /// Enable/disable without clearing saved timings.
  static Future<void> setRemindersEnabled(bool enabled) async {
    if (!_initialized) await init();
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_prefEnabled, enabled);

    if (!enabled) {
      await cancelAlarms();
    } else {
      // Reschedule from saved timings
      final city = prefs.getString(_prefCity) ?? '';
      final timings = await _readTimingsFromPrefs(prefs);
      if (city.isNotEmpty && timings.isNotEmpty) {
        await _scheduleAlarms(city, timings);
      }
    }
  }

  static Future<bool> isRemindersEnabled() async {
    final prefs = await SharedPreferences.getInstance();
    final prefEnabled = prefs.getBool(_prefEnabled) ?? false;
    if (!prefEnabled) return false;
    // Toggle ON di prefs tapi permission dicabut → notif tidak jalan.
    // Sync prefs dengan status real.
    final realEnabled = await areNotificationsEnabled();
    if (!realEnabled) {
      await prefs.setBool(_prefEnabled, false);
      return false;
    }
    return true;
  }

  // ═══════════════════════════════════════════
  //  Notif mode (fokus/seimbang/intensif) — for Gap I
  // ═══════════════════════════════════════════

  static Future<String> getNotifMode() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_prefNotifMode) ?? 'seimbang';
  }

  static Future<void> setNotifMode(String mode) async {
    if (!_initialized) await init();
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_prefNotifMode, mode);
    // Reschedule with new mode if enabled
    if (await isRemindersEnabled()) {
      final city = prefs.getString(_prefCity) ?? '';
      final timings = await _readTimingsFromPrefs(prefs);
      if (city.isNotEmpty && timings.isNotEmpty) {
        await scheduleAdhanReminders(city, timings);
      }
    }
  }

  /// Mode suara notifikasi: senyap (notif saja), suara (suara standar),
  /// adzan (suara adzan penuh saat masuk waktu sholat).
  static Future<String> getSoundMode() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_prefSoundMode) ?? 'adzan';
  }

  /// Simpan mode pengingat + mode suara sekaligus, lalu reschedule SEKALI
  /// kalau pengingat aktif — dipakai tombol Simpan di profil supaya gak
  /// reschedule dua kali.
  static Future<void> applyNotifSettings({
    required String mode,
    required String soundMode,
  }) async {
    if (!_initialized) await init();
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_prefNotifMode, mode);
    await prefs.setString(_prefSoundMode, soundMode);
    if (await isRemindersEnabled()) {
      final city = prefs.getString(_prefCity) ?? '';
      final timings = await _readTimingsFromPrefs(prefs);
      if (city.isNotEmpty && timings.isNotEmpty) {
        await scheduleAdhanReminders(city, timings);
      }
    }
  }

  /// Mode suara per sholat (override global). Key = nama sholat
  /// ('subuh'..'isya'), value = 'senyap'/'suara'/'adzan'.
  /// Empty map = semua sholat ikut mode global dari tab Profil.
  static Future<Map<String, String>> getPerPrayerSounds() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_prefPerPrayerSounds);
    if (raw == null || raw.isEmpty) return {};
    try {
      final decoded = jsonDecode(raw);
      if (decoded is Map<String, dynamic>) {
        return decoded.map((k, v) => MapEntry(k, v.toString()));
      }
    } catch (_) {}
    return {};
  }

  /// Set mode suara satu sholat, simpan, lalu reschedule kalau pengingat
  /// aktif. Mode sholat lain tidak disentuh.
  static Future<void> setPerPrayerSound(String prayer, String sound) async {
    if (!_initialized) await init();
    final prefs = await SharedPreferences.getInstance();
    final map = await getPerPrayerSounds();
    map[prayer] = sound;
    await prefs.setString(_prefPerPrayerSounds, jsonEncode(map));
    if (await isRemindersEnabled()) {
      final city = prefs.getString(_prefCity) ?? '';
      final timings = await _readTimingsFromPrefs(prefs);
      if (city.isNotEmpty && timings.isNotEmpty) {
        await _scheduleAlarms(city, timings);
      }
    }
  }

  /// Hapus override satu sholat → kembali ikut mode global Profil.
  static Future<void> clearPerPrayerSound(String prayer) async {
    if (!_initialized) await init();
    final prefs = await SharedPreferences.getInstance();
    final map = await getPerPrayerSounds();
    map.remove(prayer);
    await prefs.setString(_prefPerPrayerSounds, jsonEncode(map));
    if (await isRemindersEnabled()) {
      final city = prefs.getString(_prefCity) ?? '';
      final timings = await _readTimingsFromPrefs(prefs);
      if (city.isNotEmpty && timings.isNotEmpty) {
        await _scheduleAlarms(city, timings);
      }
    }
  }

  // ═══════════════════════════════════════════
  //  Pilihan suara adzan (varian)
  // ═══════════════════════════════════════════

  /// Id varian suara adzan aktif ('adzan', 'a1', ...).
  static Future<String> getAdzanVariant() async {
    final prefs = await SharedPreferences.getInstance();
    final v = prefs.getString(_prefAdzanVariant) ?? 'adzan';
    return adzanVariants.any((e) => e.$1 == v) ? v : 'adzan';
  }

  /// Sudah diunduh ke cache lokal? (untuk ikon centang/status di UI)
  static Future<bool> isVariantDownloaded(String variant) async {
    if (variant == 'adzan') return true;
    return await AdzanSoundStore.cachedPath(_variantResource(variant)) != null;
  }

  /// Suara varian non-default: unduh (atau pakai cache) → FileProvider
  /// content URI → UriAndroidNotificationSound.
  /// Melempar error kalau gagal (UI menampilkan pesan + kembali ke default).
  static Future<UriAndroidNotificationSound> _soundForVariant(
    String variant,
  ) async {
    final path = await AdzanSoundStore.fetch(_variantResource(variant));
    final uri = await _soundChannel.invokeMethod<String>(
      'contentUri',
      {'filePath': path},
    );
    if (uri == null || uri.isEmpty) {
      throw StateError('content URI kosong untuk $variant');
    }
    return UriAndroidNotificationSound(uri);
  }

  /// Ganti suara adzan: download varian bila perlu, pastikan channel
  /// varian baru ada, simpan pref, lalu reschedule pengingat supaya
  /// jadwal berikutnya pakai suara baru.
  static Future<void> setAdzanVariant(String variant) async {
    if (!adzanVariants.any((e) => e.$1 == variant)) return;
    if (!_initialized) await init();
    if (variant != _variant) {
      // Download bisa gagal — jangan ganti state sebelum suara siap.
      if (variant != 'adzan') {
        _variantSound = await _soundForVariant(variant);
      }
      _variant = variant;
      await _createChannel(); // buat channel varian baru (idempotent)
    }
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_prefAdzanVariant, variant);
    if (await isRemindersEnabled()) {
      final city = prefs.getString(_prefCity) ?? '';
      final timings = await _readTimingsFromPrefs(prefs);
      if (city.isNotEmpty && timings.isNotEmpty) {
        await _scheduleAlarms(city, timings);
      }
    }
  }

  // ═══════════════════════════════════════════
  //  Internal: scheduling logic
  // ═══════════════════════════════════════════

  static Future<void> _scheduleAlarms(
    String city,
    Map<String, String> timings,
  ) async {
    final now = DateTime.now();
    final mode = await getNotifMode();
    final soundMode = await getSoundMode();
    final perPrayer = await getPerPrayerSounds();

    // ponytail: imsak & terbit selalu senyap + 1 reminder saja, jadi
    // dikerjakan di loop terpisah — tidak menyentuh logika wajib di bawah.
    for (final marker in _markerList) {
      final timeStr = timings[marker];
      if (timeStr == null || timeStr.isEmpty) continue;
      final parts = timeStr.split(':');
      if (parts.length != 2) continue;
      final hour = int.tryParse(parts[0]);
      final minute = int.tryParse(parts[1]);
      if (hour == null || minute == null) continue;
      var scheduledTime = DateTime(now.year, now.month, now.day, hour, minute);
      if (!scheduledTime.isAfter(now)) {
        scheduledTime = scheduledTime.add(const Duration(days: 1));
      }
      try {
        await _scheduleOne(
          id: _baseIdFor(marker),
          title: _titleFor(marker),
          body: _bodyFor(marker, city, mode, 0),
          scheduledTime: scheduledTime,
          sound: _NotifSound.silent,
        );
      } catch (e) {
        debugPrint('[NotificationService] gagal jadwalkan $marker: $e');
      }
    }

    for (final prayer in _wajibList) {
      final timeStr = timings[prayer];
      if (timeStr == null || timeStr.isEmpty) continue;

      final parts = timeStr.split(':');
      if (parts.length != 2) continue;
      final hour = int.tryParse(parts[0]);
      final minute = int.tryParse(parts[1]);
      if (hour == null || minute == null) continue;

      // Notification ID per prayer
      final notifId = _baseIdFor(prayer);

      // Schedule based on mode
      final schedules = _getScheduleTimes(mode, hour, minute, now);
      for (var i = 0; i < schedules.length; i++) {
        var scheduledTime = schedules[i];
        // Sudah lewat hari ini → mulai besok. Notifikasi berulang harian
        // (matchDateTimeComponents), jadi tetap bunyi walau app tak dibuka;
        // jam presisi di-refresh tiap app dibuka.
        if (!scheduledTime.isAfter(now)) {
          scheduledTime = scheduledTime.add(const Duration(days: 1));
        }
        // Elemen terakhir = tepat waktu adzan. Jenis suara mengikuti
        // pilihan user per sholat (override) atau mode global: senyap
        // semua / suara standar semua / adzan hanya saat masuk waktu
        // (pra-adzan tetap suara standar).
        final isMain = i == schedules.length - 1;
        final sound = switch (perPrayer[prayer] ?? soundMode) {
          'senyap' => _NotifSound.silent,
          'suara' => _NotifSound.normal,
          _ => isMain ? _NotifSound.adzan : _NotifSound.normal,
        };
        try {
          await _scheduleOne(
            id: notifId + i, // unique ID per reminder
            title: _titleFor(prayer),
            body: _bodyFor(prayer, city, mode, i),
            scheduledTime: scheduledTime,
            sound: sound,
          );
        } catch (e) {
          // Satu reminder gagal total — lanjutkan sisanya, jangan abort.
          debugPrint('[NotificationService] gagal jadwalkan $prayer+$i: $e');
        }
      }
    }
  }

  /// Get list of scheduled times based on notif mode.
  /// Returns list of DateTime for each reminder.
  static List<DateTime> _getScheduleTimes(
    String mode,
    int hour,
    int minute,
    DateTime now,
  ) {
    final today = DateTime(now.year, now.month, now.day, hour, minute);

    switch (mode) {
      case 'fokus':
        // At adzan time only (1 reminder)
        return [today];
      case 'intensif':
        // 30 min before + 5 min before + at adzan time (3 reminders)
        return [
          today.subtract(const Duration(minutes: 30)),
          today.subtract(const Duration(minutes: 5)),
          today,
        ];
      case 'seimbang':
      default:
        // 15 min before + at adzan time (2 reminders)
        return [
          today.subtract(const Duration(minutes: 15)),
          today,
        ];
    }
  }

  static String _titleFor(String prayer) {
    final cap = prayer[0].toUpperCase() + prayer.substring(1);
    // ponytail: imsak & terbit bukan sholat — judulnya jangan "Waktunya Sholat".
    if (_markerList.contains(prayer)) return '🕌 $cap';
    return '🕌 Waktunya Sholat $cap';
  }

  static String _bodyFor(String prayer, String city, String mode, int reminderIndex) {
    final loc = city.isNotEmpty ? 'di $city. ' : '';
    switch (prayer) {
      case 'imsak':
        return 'Sudah masuk imsak ${loc}Berhenti makan & minum ya. 🌙';
      case 'terbit':
        return 'Matahari terbit ${loc}Waktu Subuh berakhir, Dhuha sudah masuk. ☀️';
    }
    switch (mode) {
      case 'intensif':
        if (reminderIndex == 0) return '30 menit lagi masuk waktu $prayer ${loc}Persiapan ya! 🔥';
        if (reminderIndex == 1) return '5 menit lagi masuk waktu $prayer ${loc}Segera siap! ⚡';
        return 'Sudah masuk waktu sholat $prayer ${loc}Yuk jaga streak! 🔥';
      case 'fokus':
        return 'Sudah masuk waktu sholat $prayer ${loc}Yuk jaga streak! 🔥';
      case 'seimbang':
      default:
        if (reminderIndex == 0) return '15 menit lagi masuk waktu $prayer ${loc}Persiapan ya! 🌙';
        return 'Sudah masuk waktu sholat $prayer ${loc}Yuk jaga streak! 🔥';
    }
  }

  static NotificationDetails _detailsFor(_NotifSound sound) {
    final isAdzan = sound == _NotifSound.adzan;
    final androidDetails = AndroidNotificationDetails(
      switch (sound) {
        _NotifSound.silent => _silentChannelId,
        _NotifSound.normal => _channelId,
        _NotifSound.adzan => _variantChannelId(_variant),
      },
      switch (sound) {
        _NotifSound.silent => _silentChannelName,
        _NotifSound.normal => _channelName,
        _NotifSound.adzan => 'Adzan${_variant == 'adzan' ? '' : ' — ${_variantLabel(_variant)}'}',
      },
      channelDescription: switch (sound) {
        _NotifSound.silent => _silentChannelDesc,
        _NotifSound.normal => _channelDesc,
        _NotifSound.adzan => _adzanChannelDesc,
      },
      importance: Importance.high,
      priority: Priority.high,
      category: AndroidNotificationCategory.alarm,
      playSound: sound != _NotifSound.silent,
      // Varian aktif: default = raw resource, sisanya content URI unduhan
      // (sudah di-cache di _variantSound sejak init/setAdzanVariant).
      sound: isAdzan
          ? (_variant == 'adzan'
                ? const RawResourceAndroidNotificationSound('adzan')
                : _variantSound)
          : null,
      audioAttributesUsage: isAdzan
          ? AudioAttributesUsage.alarm
          : AudioAttributesUsage.notification,
      vibrationPattern: Int64List.fromList([0, 300, 200, 300]),
      enableVibration: true,
      autoCancel: true,
      // Aksen siluet ic_stat_notif di header notif — Android mewarnai alpha
      // putihnya dengan ini.
      color: _notifAccent,
    );
    const iosDetails = DarwinNotificationDetails(
      presentAlert: true,
      presentBadge: true,
      presentSound: true,
    );
    return NotificationDetails(android: androidDetails, iOS: iosDetails);
  }

  static Future<void> _scheduleOne({
    required int id,
    required String title,
    required String body,
    required DateTime scheduledTime,
    required _NotifSound sound,
  }) async {
    Future<void> schedule(AndroidScheduleMode mode, _NotifSound s) {
      return _plugin.zonedSchedule(
        id,
        title,
        body,
        tz.TZDateTime.from(scheduledTime, tz.local),
        _detailsFor(s),
        androidScheduleMode: mode,
        uiLocalNotificationDateInterpretation:
            UILocalNotificationDateInterpretation.absoluteTime,
        matchDateTimeComponents: DateTimeComponents.time,
      );
    }

    // Fallback berlapis — satu pengingat yang gagal gak boleh bikin
    // seluruh penjadwalan mati diam-diam:
    // 1) exact  2) inexact (izin "Alarm & pengingat" ditolak)
    // 3) inexact dengan suara standar (mis. resource suara adzan bermasalah).
    try {
      await schedule(AndroidScheduleMode.exactAllowWhileIdle, sound);
    } on PlatformException catch (e) {
      debugPrint('[NotificationService] exact gagal (${e.code}) id=$id, '
          'coba inexact');
      try {
        await schedule(AndroidScheduleMode.inexactAllowWhileIdle, sound);
      } on PlatformException catch (e2) {
        debugPrint('[NotificationService] inexact gagal (${e2.code}) id=$id, '
            'coba suara standar');
        await schedule(
            AndroidScheduleMode.inexactAllowWhileIdle, _NotifSound.normal);
      }
    }
  }

  static Future<void> cancelAlarms() async {
    // App ini cuma menjadwalkan pengingat adzan, jadi cancelAll aman —
    // sekaligus bersih-bersih jadwal lama ber-ID hashCode dari versi sebelumnya.
    try {
      await _plugin.cancelAll();
    } catch (e, st) {
      // Gagal cancel TIDAK boleh menggagalkan reschedule: ID notif
      // deterministik (10..52), jadi jadwal baru menimpa yang lama.
      // Ini juga satu-satunya panggilan tak terlindungi yang dilewati
      // Simpan & Tes Notifikasi — kirim ke Sentry biar akar masalah
      // kelihatan di dashboard.
      debugPrint('[NotificationService] cancelAll gagal: $e');
      await Sentry.captureException(e, stackTrace: st);
    }
  }

  // ═══════════════════════════════════════════
  //  Prefs helpers
  // ═══════════════════════════════════════════

  static Future<Map<String, String>> _readTimingsFromPrefs(
    SharedPreferences prefs,
  ) async {
    final result = <String, String>{};
    for (final prayer in _allList) {
      final t = prefs.getString('$_prefTimingsPrefix$prayer');
      if (t != null && t.isNotEmpty) {
        result[prayer] = t;
      }
    }
    return result;
  }

  // ═══════════════════════════════════════════
  //  Notification tap handler
  // ═══════════════════════════════════════════

  static void _onNotificationTap(NotificationResponse response) {
    debugPrint('[NotificationService] notification tapped: ${response.payload}');
    // App will open to home — could add deep linking later
  }

  /// Send a test notification (for settings dialog).
  /// Channel/suaranya mengikuti mode suara yang sedang dipilih, jadi user
  /// langsung dengar hasil setting-nya.
  /// [soundModeOverride]: preview pilihan di dialog TANPA menyimpan/
  /// reschedule apa pun — tombol Tes murni menampilkan notif.
  static Future<void> sendTestNotification(String mode,
      {String? soundModeOverride}) async {
    if (!_initialized) await init();

    final message = switch (mode) {
      'fokus' => 'Mode Fokus aktif! Pengingat hanya saat masuk waktu adzan.',
      'seimbang' => 'Mode Seimbang aktif! Pengingat semua sholat wajib 15 menit sebelum adzan.',
      'intensif' => 'Mode Intensif aktif! Diingetin 30 menit & 5 menit sebelum sholat. Pertahanin streak! 🔥',
      _ => 'Notifikasi Muslim Leveling siap! 🔔',
    };

    final soundMode = soundModeOverride ?? await getSoundMode();
    final details = _detailsFor(switch (soundMode) {
      'senyap' => _NotifSound.silent,
      'adzan' => _NotifSound.adzan,
      _ => _NotifSound.normal,
    });

    final cap = mode[0].toUpperCase() + mode.substring(1);
    await _plugin.show(
      99,
      'Muslim Leveling Mode: $cap',
      message,
      details,
    );
  }

  /// Tes suara adzan — bunyikan notifikasi lewat channel adzan sekarang juga,
  /// supaya user bisa verifikasi suara tanpa menunggu waktu sholat.
  static Future<void> sendTestAdzanSound() async {
    if (!_initialized) await init();

    await _plugin.show(
      98,
      '🕌 Tes Suara Adzan',
      'Kalau adzan terdengar, notifikasi kamu siap! Kalau tidak, cek volume alarm HP.',
      _detailsFor(_NotifSound.adzan),
    );
  }
}
