import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:muslim_leveling/l10n/app_localizations.dart';
import 'package:muslim_leveling/services/achievement_service.dart';

/// Cek fallback hint bekerja untuk def yang tidak punya unlockHint
/// eksplisit — kalau jatuh ke 'null' (mis. field lupa), locked medals
/// tetap punya teks petunjuk untuk user (kritik P0: locked = dead end).
void main() {
  for (final locale in AppL10n.supportedLocales) {
    final l10n = lookupAppL10n(locale);

    test('[${locale.languageCode}] hint fallback tidak null/empty', () {
      for (final d in AchievementService.defs) {
        expect(
          d.localizedHint(l10n),
          isNotEmpty,
          reason: '${d.id} harus punya hint (eksplisit atau fallback)',
        );
      }
    });

    test('[${locale.languageCode}] judul/desc semua medali terisi', () {
      for (final d in AchievementService.defs) {
        expect(d.localizedTitle(l10n), isNotEmpty, reason: d.id);
        expect(d.localizedDesc(l10n), isNotEmpty, reason: d.id);
      }
    });
  }

  test('hint eksplisit untuk def ambigu tampil apa adanya', () {
    final hints = {
      for (final d in AchievementService.defs) d.id: d.unlockHint,
    };
    expect(hints['hall_of_fame'], isNotNull);
    expect(hints['hall_of_fame']!.contains('achievement'), isTrue);
  });

  test('judul Indonesia tidak bocor ke English', () {
    final id = lookupAppL10n(const Locale('id'));
    final en = lookupAppL10n(const Locale('en'));
    final def = AchievementService.defs.firstWhere(
      (d) => d.id == 'langkah_pertama',
    );
    expect(def.localizedTitle(id), 'LANGKAH PERTAMA');
    expect(def.localizedTitle(en), 'FIRST STEP');
  });
}
