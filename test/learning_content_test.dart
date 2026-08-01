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

  test('kategori Keyakinan membawa sepuluh artikel WHY Islam berurutan', () {
    const expectedTitles = [
      'Aku Muslim Karena Apa?',
      'Untuk Apa Aku Diciptakan?',
      'Kenapa Harus Salat Lima Waktu?',
      'Kenapa Al-Quran Tidak Cukup Dibaca Saja?',
      'Kenapa Ada Halal dan Haram? Apa Allah Membatasi Kita?',
      'Kalau Allah Baik, Kenapa Hidup Tetap Berat?',
      'Kenapa Doaku Belum Dikabulkan?',
      'Kalau Semua Sudah Ditakdirkan, Kenapa Aku Harus Berusaha?',
      'Kenapa Harus Bertobat Kalau Aku Terus Mengulang Salah?',
      'Iman yang Dewasa Itu Seperti Apa?',
    ];
    final categories = LearningContent.categories
        .where((category) => category.id == 'keyakinan')
        .toList();

    expect(categories, hasLength(1));
    final category = categories.single;
    expect(category.modules.map((module) => module.id), [
      'why_4.1',
      'why_4.2',
      'why_4.3',
      'why_4.4',
      'why_4.5',
      'why_4.6',
      'why_4.7',
      'why_4.8',
      'why_4.9',
      'why_4.10',
    ]);
    expect(category.modules.map((module) => module.title), expectedTitles);
    expect(LearningContent.isModuleUnlocked('why_4.1', const []), isTrue);
    expect(LearningContent.isModuleUnlocked('why_4.2', const []), isFalse);
  });

  test(
    'artikel Keyakinan dan quiznya dapat diakses dengan jawaban tersebar',
    () {
      final category = LearningContent.categories.singleWhere(
        (category) => category.id == 'keyakinan',
      );
      final correctIndexes = <int>[];

      for (final module in category.modules) {
        expect(
          LearningContent.getArticle(module.id).whereType<Heading>(),
          isNotEmpty,
        );
        final quiz = LearningContent.getQuiz(module.id);
        expect(quiz, hasLength(5));
        expect(
          quiz.map((question) => question.correctIndex).toSet(),
          containsAll(<int>{0, 1, 2, 3}),
        );
        correctIndexes.addAll(quiz.map((question) => question.correctIndex));
        for (final question in quiz) {
          expect(question.options, hasLength(4));
          expect(question.correctIndex, inInclusiveRange(0, 3));
          expect(question.explanation, isNotEmpty);
        }
      }

      expect(correctIndexes.toSet(), containsAll(<int>{0, 1, 2, 3}));
    },
  );
}
