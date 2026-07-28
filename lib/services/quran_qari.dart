/// Qari untuk murrotal.
class QuranQari {
  final String id;
  final String name;
  /// Pola URL: replace {surah} dan {ayah} dengan 3-digit.
  final String urlPattern;

  const QuranQari({required this.id, required this.name, required this.urlPattern});
}

/// 6 qari dari equran.id + Alafasy sebagai default.
const List<QuranQari> kQariList = [
  QuranQari(
    id: 'Alafasy',
    name: 'Alafasy',
    urlPattern: 'https://verses.quran.com/Alafasy/mp3/{surah}{ayah}.mp3',
  ),
  QuranQari(
    id: '01',
    name: 'Abdullah Al-Juhany',
    urlPattern:
        'https://cdn.equran.id/audio-partial/Abdullah-Al-Juhany/{surah}{ayah}.mp3',
  ),
  QuranQari(
    id: '02',
    name: 'Abdul Muhsin Al-Qasim',
    urlPattern:
        'https://cdn.equran.id/audio-partial/Abdul-Muhsin-Al-Qasim/{surah}{ayah}.mp3',
  ),
  QuranQari(
    id: '03',
    name: 'Abdurrahman As-Sudais',
    urlPattern:
        'https://cdn.equran.id/audio-partial/Abdurrahman-as-Sudais/{surah}{ayah}.mp3',
  ),
  QuranQari(
    id: '04',
    name: 'Ibrahim Al-Dossari',
    urlPattern:
        'https://cdn.equran.id/audio-partial/Ibrahim-Al-Dossari/{surah}{ayah}.mp3',
  ),
  QuranQari(
    id: '05',
    name: 'Misyari Rasyid Al-Afasi',
    urlPattern:
        'https://cdn.equran.id/audio-partial/Misyari-Rasyid-Al-Afasi/{surah}{ayah}.mp3',
  ),
  QuranQari(
    id: '06',
    name: 'Yasser Al-Dosari',
    urlPattern:
        'https://cdn.equran.id/audio-partial/Yasser-Al-Dosari/{surah}{ayah}.mp3',
  ),
];

String ayahAudioUrl(int surah, int ayah, String urlPattern) {
  final s = surah.toString().padLeft(3, '0');
  final a = ayah.toString().padLeft(3, '0');
  return urlPattern.replaceAll('{surah}', s).replaceAll('{ayah}', a);
}
