import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:sentry_flutter/sentry_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'theme/app_theme.dart';
import 'services/theme_service.dart';
import 'screens/splash_screen.dart';
import 'services/notification_service.dart';
import 'services/cloud_sync.dart';
import 'services/game_service.dart';
import 'services/quran_settings.dart';

// ponytail: Sentry wrap runApp, init setelah — apapun error di init, UI tetap muncul
void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await SentryFlutter.init(
    (options) {
      options.dsn = 'https://8c85da...0096@o4511691396677632.ingest.de.sentry.io/4511691401330768';
      options.environment = const String.fromEnvironment('SENTRY_ENVIRONMENT', defaultValue: 'production');
      options.release = const String.fromEnvironment('SENTRY_RELEASE', defaultValue: 'muslim-leveling@1.0.0+1');
      options.tracesSampleRate = 0.1;
      options.attachScreenshot = true;
      options.debug = false;
    },
    appRunner: () => runApp(const MuslimLevelingApp()),
  );
  _initAsync();
}

Future<void> _initAsync() async {
  try {
    final prefs = await SharedPreferences.getInstance();
    final deviceId = prefs.getString('device_id');
    if (deviceId == null) {
      final newId = '${_rand36()}-${_rand36()}-${_rand36()}';
      await prefs.setString('device_id', newId);
      CloudSync.init(newId);
    } else {
      CloudSync.init(deviceId);
    }
  } catch (e) {
    Sentry.captureException(e, withScope: (s) => s.setTag('init_step', 'device_id'));
  }

  try {
    await quranSettings.load();
  } catch (e) {
    Sentry.captureException(e, withScope: (s) => s.setTag('init_step', 'quran_settings'));
  }

  try {
    await NotificationService.init();
  } catch (e) {
    Sentry.captureException(e, withScope: (s) => s.setTag('init_step', 'notification'));
  }

  try {
    await GameService.load();
    await GameService.reconcileCosmeticLapse(isPro: true);
  } catch (e) {
    Sentry.captureException(e, withScope: (s) => s.setTag('init_step', 'game_service'));
  }

  try {
    SystemChrome.setSystemUIOverlayStyle(
      SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.light,
        systemNavigationBarColor: AppColorsDark.background,
        systemNavigationBarIconBrightness: Brightness.light,
      ),
    );
  } catch (_) {} // ponytail: UI style failure is cosmetic, not actionable
}

String _rand36() => BigInt.from(Random().nextInt(1 << 48)).toRadixString(36).padLeft(8, '0');

class MuslimLevelingApp extends StatefulWidget {
  const MuslimLevelingApp({super.key});
  @override
  State<MuslimLevelingApp> createState() => MuslimLevelingAppState();
}

class MuslimLevelingAppState extends State<MuslimLevelingApp> {
  @override
  void initState() {
    super.initState();
    themeNotifier.load();
  }

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: themeNotifier,
      builder: (context, _) {
        return MaterialApp(
          title: 'Muslim Leveling',
          debugShowCheckedModeBanner: false,
          theme: AppTheme.light(),
          darkTheme: AppTheme.dark(),
          themeMode: themeNotifier.mode,
          home: const SplashScreen(),
        );
      },
    );
  }
}
