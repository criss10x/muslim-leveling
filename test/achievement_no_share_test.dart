import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:muslim_leveling/l10n/app_localizations.dart';
import 'package:muslim_leveling/services/achievement_service.dart';
import 'package:muslim_leveling/theme/app_icons.dart';
import 'package:muslim_leveling/widgets/achievement_medal.dart';

import 'helpers/app_wrap.dart';

/// Guard arah produk: medali itu pencapaian pribadi, bukan bahan pamer.
/// Kartu share "Aku unlock X" sengaja dibuang dari achievement — yang boleh
/// dibagikan cuma kartu ayat (Quran). Tanpa tes ini, tombolnya bisa kembali
/// lewat refactor tanpa ada yang sadar.
///
/// ponytail: async tap → `pump(Duration)`, bukan `pumpAndSettle()`. Popup
/// unlock punya ShimmerSweep yang `repeat()` — pumpAndSettle tidak akan
/// pernah settle.
void main() {
  AchievementDef def() => AchievementService.defs.first;

  /// Tempatkan tombol pemicu supaya punya BuildContext di bawah MaterialApp.
  Future<void> pumpTrigger(
    WidgetTester tester,
    void Function(BuildContext) open, {
    Locale locale = const Locale('id'),
  }) async {
    await tester.pumpWidget(
      appWrap(
        Builder(
          builder: (context) => Scaffold(
            body: Center(
              child: ElevatedButton(
                onPressed: () => open(context),
                child: const Text('buka'),
              ),
            ),
          ),
        ),
        locale: locale,
      ),
    );
    await tester.tap(find.text('buka'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 400));
  }

  for (final locale in AppL10n.supportedLocales) {
    final code = locale.languageCode;
    final shareWord = code == 'en' ? 'Share' : 'Bagikan';

    testWidgets('popup medali baru ($code) tidak menawarkan share', (
      tester,
    ) async {
      await pumpTrigger(
        tester,
        (c) => showAchievementUnlock(c, def()),
        locale: locale,
      );

      // Popup benar-benar terbuka — kalau tidak, findsNothing di bawah
      // lolos palsu.
      expect(find.text(lookupAppL10n(locale).achBtnAwesome), findsOneWidget);
      expect(find.text(shareWord), findsNothing);
      expect(find.byIcon(AppIcons.share), findsNothing);

      await tester.pumpWidget(const SizedBox());
    });

    testWidgets('dialog detail medali ($code) tidak menawarkan share', (
      tester,
    ) async {
      await pumpTrigger(
        tester,
        (c) => showAchievementDetail(
          c,
          def(),
          unlocked: true,
          unlockedDate: '2026-01-01',
        ),
        locale: locale,
      );

      // Dialog benar-benar terbuka (judul medali pertama = unlockHint-nya).
      expect(
        find.text(def().localizedDesc(lookupAppL10n(locale))),
        findsOneWidget,
      );
      expect(
        find.text(shareWord),
        findsNothing,
        reason: 'tombol share pamer kembali ke dialog detail',
      );
      expect(find.byIcon(AppIcons.share), findsNothing);

      await tester.pumpWidget(const SizedBox());
    });
  }

  test('share_card.dart sudah tidak ada di repo', () {
    // Artefak pamer satu-satunya. Kalau file ini muncul lagi berarti arah
    // produknya dibalik — bukan sekadar refactor.
    expect(
      File('lib/widgets/share_card.dart').existsSync(),
      isFalse,
      reason: 'kartu share achievement dihidupkan lagi',
    );
  });
}
