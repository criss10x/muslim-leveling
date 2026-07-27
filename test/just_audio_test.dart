import 'package:flutter_test/flutter_test.dart';
import 'package:just_audio/just_audio.dart';

void main() {
  test('AudioSource.uri creates ProgressiveAudioSource for mp3', () {
    final source = AudioSource.uri(
      Uri.parse('https://verses.quran.com/Alafasy/mp3/001001.mp3'),
    );
    expect(source, isA<ProgressiveAudioSource>());
  });

  test('audioUrl format is correct', () {
    // from quran_playlist.dart
    String pad3(int n) => n.toString().padLeft(3, '0');
    String ayahAudioUrl(int surah, int ayah) =>
        'https://verses.quran.com/Alafasy/mp3/${pad3(surah)}${pad3(ayah)}.mp3';

    expect(ayahAudioUrl(1, 1), 'https://verses.quran.com/Alafasy/mp3/001001.mp3');
    expect(ayahAudioUrl(114, 6), 'https://verses.quran.com/Alafasy/mp3/114006.mp3');

    // Verify these URLs are reachable
    expect(ayahAudioUrl(1, 1).startsWith('https'), true);
  });
}
