import 'package:flutter_test/flutter_test.dart';
import 'package:just_audio/just_audio.dart';
import 'package:muslim_leveling/services/quran_audio_service.dart';
import 'package:muslim_leveling/services/quran_playlist.dart';
import 'package:muslim_leveling/services/quran_qari.dart' hide ayahAudioUrl;

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

  test('creates UriAudioSource for direct playback', () {
    final source = audioSourceForAyah(const AyahRef(1, 1), kQariList.first.urlPattern);
    expect(source, isA<UriAudioSource>());
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
    test('full surat', () {
      final r = PlaybackRange.full(surah: 2, ayahCount: 286);
      final q = buildQueue(r);
      expect(q.length, 286);
    });

    test('range di tengah surat tidak menyertakan ayat sebelumnya', () {
      final r =
          PlaybackRange.full(surah: 2, ayahCount: 286).withFrom(5).withTo(10);
      final q = buildQueue(r);
      expect(q.first, const AyahRef(2, 5));
      expect(q.last, const AyahRef(2, 10));
      expect(q.length, 6);
    });
  });
}
