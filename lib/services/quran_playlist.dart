/// Logika murrotal yang tidak bergantung pada pemutar audio maupun widget,
/// supaya seluruh aturan range dan pengulangan bisa diuji tanpa device.

/// Menandai pengulangan tanpa batas. Dijalankan lewat LoopMode.one di player,
/// bukan dengan membangun playlist tak-hingga.
const int kRepeatInfinite = -1;

const String kQuranAudioBase = 'https://verses.quran.com/Alafasy/mp3';

String _pad3(int n) => n.toString().padLeft(3, '0');

String ayahAudioUrl(int surah, int ayah) =>
    '$kQuranAudioBase/${_pad3(surah)}${_pad3(ayah)}.mp3';

class AyahRef {
  final int surah, ayah;
  const AyahRef(this.surah, this.ayah);

  String get audioUrl => ayahAudioUrl(surah, ayah);

  @override
  bool operator ==(Object other) =>
      other is AyahRef && other.surah == surah && other.ayah == ayah;

  @override
  int get hashCode => Object.hash(surah, ayah);

  @override
  String toString() => 'AyahRef($surah:$ayah)';
}

/// Rentang ayat dalam satu surat. Invarian: 1 <= from <= to <= ayahCount,
/// sehingga rentang tidak pernah kosong.
class PlaybackRange {
  final int surah, from, to, ayahCount;

  const PlaybackRange._({
    required this.surah,
    required this.from,
    required this.to,
    required this.ayahCount,
  });

  factory PlaybackRange.full({required int surah, required int ayahCount}) =>
      PlaybackRange._(
          surah: surah, from: 1, to: ayahCount, ayahCount: ayahCount);

  int _clamp(int v) => v < 1 ? 1 : (v > ayahCount ? ayahCount : v);

  /// Menaikkan `to` bila `from` melewatinya — rentang kosong tidak pernah valid.
  PlaybackRange withFrom(int value) {
    final f = _clamp(value);
    return PlaybackRange._(
      surah: surah,
      from: f,
      to: to < f ? f : to,
      ayahCount: ayahCount,
    );
  }

  /// Menurunkan `from` bila `to` jatuh di bawahnya — cerminan dari withFrom.
  PlaybackRange withTo(int value) {
    final t = _clamp(value);
    return PlaybackRange._(
      surah: surah,
      from: from > t ? t : from,
      to: t,
      ayahCount: ayahCount,
    );
  }

  int get length => to - from + 1;
}

/// Membangun antrean ayat. Untuk repeat 1..N tiap ayat digandakan di tempat,
/// supaya hitungan berhenti tepat lalu maju sendiri ke ayat berikutnya.
List<AyahRef> buildQueue({
  required PlaybackRange range,
  required int repeat,
}) {
  final times = repeat == kRepeatInfinite ? 1 : repeat;
  final out = <AyahRef>[];
  for (var a = range.from; a <= range.to; a++) {
    for (var i = 0; i < times; i++) {
      out.add(AyahRef(range.surah, a));
    }
  }
  return out;
}
