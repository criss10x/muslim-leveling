import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:muslim_leveling/l10n/app_localizations.dart';
import 'package:muslim_leveling/screens/belajar_article.dart';
import 'package:muslim_leveling/screens/belajar_tab.dart';
import 'package:muslim_leveling/services/learning_content.dart';
import 'package:muslim_leveling/services/locale_service.dart';
import 'helpers/app_wrap.dart';

/// Guard: chrome tab Belajar dibaca dari ARB, bukan literal Indonesia.
///
/// Dulu `belajar_tab`/`belajar_article`/`belajar_quiz`/`belajar_result`
/// menyimpan 'LEARNING HUB', 'SANTRI DIGITAL', 'Kembali', 'LANJUT KE QUIZ',
/// 'BENAR!', 'HASIL QUIZ', 'Diperoleh', 'COBA LAGI', 'N min baca' — jadi menu
/// Belajar tetap Indonesia di locale en/tr/ms. Label kategori bahkan disimpan
/// sebagai field `label` di `LearningCategory` (const), sehingga tidak mungkin
/// ikut locale. Tes ini gagal kalau literal itu kembali.
///
/// Isi kurikulum (judul modul, artikel, soal kuis, penjelasan) SENGAJA tetap
/// Indonesia — itu materi akidah yang butuh review manusia, bukan chrome.
void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  GoogleFonts.config.allowRuntimeFetching = false;
  setUp(() => SharedPreferences.setMockInitialValues({}));

  /// Teks yang benar-benar terlihat di render tree, dipakai sebagai pembanding
  /// (bukan daftar terjemahan kedua yang bisa basi).
  Future<Set<String>> renderedText(WidgetTester t, Widget w, Locale locale) async {
    await t.pumpWidget(appWrap(w, locale: locale));
    await t.pump();
    await t.pump(const Duration(milliseconds: 200));
    return t
        .widgetList<Text>(find.byType(Text))
        .map((x) => x.data ?? '')
        .where((s) => s.isNotEmpty)
        .toSet();
  }

  for (final locale in LocaleNotifier.supported) {
    final code = locale.languageCode;
    final l10n = lookupAppL10n(locale);

    testWidgets('belajar $code: header + ribbondari ARB', (t) async {
      final seen = await renderedText(t, const BelajarTab(), locale);
      expect(seen, contains(l10n.btHubCaps));
      expect(seen, contains(l10n.btHeroTitle));
      expect(seen, contains(l10n.btSubtitle));
      expect(seen, contains(l10n.btRibbon));
    });

    testWidgets('belajar $code: label kategori dari ARB', (t) async {
      final seen = await renderedText(t, const BelajarTab(), locale);
      for (final cat in LearningContent.categories) {
        expect(seen, contains(cat.labelFor(l10n)),
            reason: '$code: kategori ${cat.id} tidak pakai ARB');
      }
    });

    testWidgets('belajar $code: tombol + header artikel dari ARB', (t) async {
      final first = LearningContent.categories.first.modules.first;
      final seen =
          await renderedText(t, BelajarArticleScreen(moduleId: first.id), locale);
      expect(seen, contains(l10n.blContinueQuiz));
    });
  }

  test('labelFor tidak punya case yatim (kategori baru wajib masuk switch)', () {
    // labelFor() memetakan id → getter ARB di dalam Dart, jadi kategori yang
    // ditambah tanpa case akan diam-diam tampil sebagai 'Praktik Ibadah'.
    // Menambah kategori = tambah case + key btCat*, dan tes ini memaksanya.
    final known = {
      for (final c in LearningContent.categories) c.id,
    };
    expect(
      known,
      {'akidah', 'alquran', 'keyakinan', 'rukun_islam', 'praktik_ibadah'},
      reason: 'kategori berubah — verifikasi switch di '
          'LearningCategory.labelFor() masih menangani semua id',
    );
  });

  test('ARB: key chrome belajar ada di SEMUA locale dan tidak kosong', () {
    for (final locale in AppL10n.supportedLocales) {
      final l = lookupAppL10n(locale);
      final values = [
        l.btHubCaps,
        l.btHeroTitle,
        l.btRibbon,
        l.btSubtitle,
        l.btMinutes(5),
        l.blMinutesRead(5),
        l.btModulesDone(1, 2),
        l.blContinueQuiz,
        l.bqNextQuestion,
        l.bqSeeResult,
        l.bqCorrect,
        l.bqNotYetRight,
        l.bqQuizUnavailable,
        l.blResultCaps,
        l.blCorrectCount(1, 2),
        l.blEarned,
        l.blTryAgain,
        l.dlBack,
        l.tpDark,
        l.tpLight,
      ];
      for (final v in values) {
        expect(v.trim(), isNotEmpty,
            reason: '${locale.languageCode}: key chrome belajar kosong');
      }
    }
  });
}
