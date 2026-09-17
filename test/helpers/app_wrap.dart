import 'package:flutter/material.dart';

import 'package:muslim_leveling/l10n/app_localizations.dart';

/// Membungkus widget under test dengan MaterialApp + delegate l10n.
///
/// Dipakai semua tes widget supaya `AppL10n.of(context)` tidak null.
/// Locale default 'id' — default platform di flutter_test adalah en_US,
/// jadi tanpa locale eksplisit semua asersi string Indonesia akan gagal.
///
/// Tes yang menguji perilaku English panggil `appWrap(child, locale: Locale('en'))`.
///
/// `debugShowCheckedModeBanner` sengaja diteruskan: pita DEBUG ikut terpotret
/// di golden test, jadi tes yang membandingkan PNG harus bisa mematikannya.
Widget appWrap(
  Widget child, {
  Locale locale = const Locale('id'),
  ThemeData? theme,
  bool debugShowCheckedModeBanner = false,
}) => MaterialApp(
  locale: locale,
  supportedLocales: AppL10n.supportedLocales,
  localizationsDelegates: AppL10n.localizationsDelegates,
  theme: theme,
  debugShowCheckedModeBanner: debugShowCheckedModeBanner,
  home: child,
);
