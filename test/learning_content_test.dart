import 'package:flutter_test/flutter_test.dart';
import 'package:muslim_leveling/services/learning_content.dart';

void main() {
  const expectedTitles = [
    'Al-Quran Mengaku Apa Tentang Dirinya?',
    'Nabi Muhammad ﷺ: Mengapa Beliau Layak Dipercaya?',
    'Tantangan Al-Quran: Bisakah Manusia Membuat yang Serupa?',
    'Bagaimana Al-Quran Dijaga Sejak Masa Nabi ﷺ?',
    'Satu Pesan selama 23 Tahun: Mengapa Al-Quran Konsisten?',
    'Keajaiban Angka, Sains, dan Sejarah: Cara Menilainya dengan Bijak',
    'Setelah Mengenal Al-Quran, Mengapa Memilih Beriman?',
  ];

  final quranCategory = LearningContent.categories.singleWhere(
    (category) => category.id == 'alquran',
  );

  test('seri Al-Quran berisi tujuh artikel yang tersambung', () {
    expect(quranCategory.modules.map((module) => module.title), expectedTitles);

    for (final module in quranCategory.modules) {
      expect(
        LearningContent.getArticle(module.id).whereType<Heading>(),
        isNotEmpty,
      );
      expect(LearningContent.getQuiz(module.id), hasLength(5));
    }
  });

  test('quiz Al-Quran memiliki pilihan utuh dan jawaban benar tersebar', () {
    final correctIndexes = <int>[];

    for (final module in quranCategory.modules) {
      final quiz = LearningContent.getQuiz(module.id);
      correctIndexes.addAll(quiz.map((question) => question.correctIndex));
      for (final question in quiz) {
        expect(question.options, hasLength(4));
        expect(question.correctIndex, inInclusiveRange(0, 3));
        expect(question.explanation, isNotEmpty);
      }
    }

    expect(correctIndexes.toSet(), containsAll(<int>{0, 1, 2, 3}));
  });

  test('modul Al-Quran terbuka berurutan', () {
    final first = quranCategory.modules.first;
    final second = quranCategory.modules[1];

    expect(LearningContent.isModuleUnlocked(first.id, const []), isTrue);
    expect(LearningContent.isModuleUnlocked(second.id, const []), isFalse);
    expect(
      LearningContent.isModuleUnlocked(second.id, [
        const ModuleProgress(moduleId: 'akidah_1.3', completed: true),
      ]),
      isTrue,
    );
  });
}
