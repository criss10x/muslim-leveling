import 'package:flutter_test/flutter_test.dart';
import 'package:muslim_leveling/services/quran_playlist.dart';

void main() {
  group('ayahAudioUrl', () {
    test('memberi nomor berpadding tiga digit', () {
      expect(ayahAudioUrl(1, 1),
          'https://verses.quran.com/Alafasy/mp3/001001.mp3');
      expect(ayahAudioUrl(2, 286),
          'https://verses.quran.com/Alafasy/mp3/002286.mp3');
      expect(ayahAudioUrl(114, 6),
          'https://verses.quran.com/Alafasy/mp3/114006.mp3');
    });
  });

  group('PlaybackRange', () {
    test('full() mencakup seluruh surat', () {
      final r = PlaybackRange.full(surah: 1, ayahCount: 7);
      expect(r.from, 1);
      expect(r.to, 7);
    });

    test('withFrom melewati to akan mendorong to ikut naik', () {
      final r = PlaybackRange.full(surah: 1, ayahCount: 7).withTo(3);
      final moved = r.withFrom(5);
      expect(moved.from, 5);
      expect(moved.to, 5);
    });

    test('withTo di bawah from akan menarik from ikut turun', () {
      final r = PlaybackRange.full(surah: 1, ayahCount: 7).withFrom(4);
      final moved = r.withTo(2);
      expect(moved.from, 2);
      expect(moved.to, 2);
    });

    test('nilai di luar batas surat dijepit', () {
      final r = PlaybackRange.full(surah: 1, ayahCount: 7);
      expect(r.withTo(99).to, 7);
      expect(r.withFrom(0).from, 1);
    });
  });

  group('buildQueue', () {
    test('repeat 1 menghasilkan tiap ayat sekali', () {
      final r = PlaybackRange.full(surah: 1, ayahCount: 7).withFrom(1).withTo(3);
      final q = buildQueue(range: r, repeat: 1);
      expect(q, [
        const AyahRef(1, 1),
        const AyahRef(1, 2),
        const AyahRef(1, 3),
      ]);
    });

    test('repeat N menggandakan tiap ayat berurutan', () {
      final r = PlaybackRange.full(surah: 1, ayahCount: 7).withFrom(1).withTo(2);
      final q = buildQueue(range: r, repeat: 3);
      expect(q, [
        const AyahRef(1, 1),
        const AyahRef(1, 1),
        const AyahRef(1, 1),
        const AyahRef(1, 2),
        const AyahRef(1, 2),
        const AyahRef(1, 2),
      ]);
    });

    test('repeat tak terbatas menghasilkan tiap ayat sekali', () {
      // Mode tak terbatas dijalankan LoopMode.one di player, bukan lewat
      // playlist — playlist tak-hingga tidak mungkin dibangun.
      final r = PlaybackRange.full(surah: 1, ayahCount: 7).withFrom(1).withTo(3);
      final q = buildQueue(range: r, repeat: kRepeatInfinite);
      expect(q.length, 3);
    });

    test('range di tengah surat tidak menyertakan ayat sebelumnya', () {
      final r =
          PlaybackRange.full(surah: 2, ayahCount: 286).withFrom(5).withTo(10);
      final q = buildQueue(range: r, repeat: 1);
      expect(q.first, const AyahRef(2, 5));
      expect(q.last, const AyahRef(2, 10));
      expect(q.length, 6);
    });
  });
}
