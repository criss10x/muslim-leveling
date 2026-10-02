import 'package:flutter_test/flutter_test.dart';
import 'package:muslim_leveling/services/learning_content.dart';

/// Penjaga konten multi-bahasa tab Belajar.
///
/// Aturan rumah (antislop R-02): em dash (U+2014) dilarang di copy yang tampil
/// ke user. Konten Bahasa Indonesia dan semua ARB aplikasi nol em dash, jadi
/// terjemahan pun harus nol.
/// True kalau blok tidak membawa teks apa pun (placeholder di sumber id).
bool _isEmptyBlock(ArticleBlock block) => switch (block) {
      Heading(:final text) => text.trim().isEmpty,
      Subheading(:final text) => text.trim().isEmpty,
      Paragraph(:final text) => text.trim().isEmpty,
      Highlight(:final text) => text.trim().isEmpty,
      EducatorNote(:final text) => text.trim().isEmpty,
      Cta(:final text) => text.trim().isEmpty,
      _ => true,
    };

void main() {
  const langs = <String>['en', 'ms', 'tr'];

  final allModules = LearningContent.categories
      .expand((category) => category.modules)
      .toList(growable: false);

  test('setiap modul punya terjemahan di semua bahasa', () {
    for (final lang in langs) {
      expect(
        LearningContent.isFullyTranslated(lang),
        isTrue,
        reason: 'bahasa $lang belum lengkap 32/32 modul',
      );

      for (final module in allModules) {
        expect(
          LearningContent.getArticle(module.id, lang: lang),
          isNotEmpty,
          reason: 'artikel ${module.id} kosong di $lang',
        );
        expect(
          LearningContent.getQuiz(module.id, lang: lang),
          hasLength(5),
          reason: 'kuis ${module.id} tidak 5 soal di $lang',
        );
        expect(
          LearningContent.titleFor(module.id, lang: lang),
          isNotEmpty,
          reason: 'judul ${module.id} kosong di $lang',
        );
      }
    }
  });

  test('tidak ada em dash di konten bahasa apa pun', () {
    for (final lang in <String>['id', ...langs]) {
      for (final module in allModules) {
        for (final block in LearningContent.getArticle(module.id, lang: lang)) {
          final text = switch (block) {
            Heading(:final text) => text,
            Subheading(:final text) => text,
            Paragraph(:final text) => text,
            Highlight(:final text) => text,
            EducatorNote(:final text) => text,
            Cta(:final text) => text,
            _ => '',
          };
          expect(
            text.contains('—'),
            isFalse,
            reason: 'em dash di artikel ${module.id} [$lang]: $text',
          );
        }

        for (final question in LearningContent.getQuiz(module.id, lang: lang)) {
          for (final field in <String>[
            question.question,
            question.explanation,
            ...question.options,
          ]) {
            expect(
              field.contains('—'),
              isFalse,
              reason: 'em dash di kuis ${module.id} [$lang]: $field',
            );
          }
        }

        expect(
          LearningContent.titleFor(module.id, lang: lang).contains('—'),
          isFalse,
          reason: 'em dash di judul ${module.id} [$lang]',
        );
      }
    }
  });

  test('terjemahan tidak kehilangan butir daftar', () {
    int bullets(List<ArticleBlock> blocks) => blocks
        .whereType<Paragraph>()
        .map((block) => '•'.allMatches(block.text).length)
        .fold(0, (sum, count) => sum + count);

    for (final lang in langs) {
      for (final module in allModules) {
        expect(
          bullets(LearningContent.getArticle(module.id, lang: lang)),
          bullets(LearningContent.getArticle(module.id)),
          reason: 'jumlah butir ${module.id} beda di $lang',
        );
      }
    }
  });

  test('terjemahan tidak kehilangan blok konten', () {
    // Tipe blok tidak dibandingkan satu-satu: sumber id tidak konsisten
    // (divider, paragraf kosong, blok Arab kadang EducatorNote kadang
    // Paragraph), jadi kesamaan tipe persis bukan invarian yang bermakna.
    // Yang dijaga: terjemahan tidak lebih sedikit blok berteks daripada
    // sumber id, supaya tidak ada isi yang hilang.
    int contentBlocks(List<ArticleBlock> blocks) => blocks
        .where((block) => block is! DividerBlock && !_isEmptyBlock(block))
        .length;

    for (final lang in langs) {
      for (final module in allModules) {
        expect(
          contentBlocks(LearningContent.getArticle(module.id, lang: lang)),
          greaterThanOrEqualTo(contentBlocks(LearningContent.getArticle(module.id))),
          reason: 'blok konten ${module.id} berkurang di $lang',
        );

        final sourceQuiz = LearningContent.getQuiz(module.id);
        final translatedQuiz = LearningContent.getQuiz(module.id, lang: lang);
        expect(
          translatedQuiz.map((question) => question.correctIndex).toList(),
          sourceQuiz.map((question) => question.correctIndex).toList(),
          reason: 'kunci jawaban ${module.id} berubah di $lang',
        );
      }
    }
  });
}
