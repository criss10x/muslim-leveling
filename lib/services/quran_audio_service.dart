import 'package:flutter/foundation.dart';
import 'package:just_audio/just_audio.dart';
import 'quran_playlist.dart';
import 'quran_settings.dart';

AudioSource audioSourceForAyah(AyahRef ayah, {bool? isWeb}) {
  final uri = Uri.parse(ayah.audioUrl);
  return AudioSource.uri(uri);
}

/// Membungkus just_audio. Menerima angka (surat, range, repeat) dan
/// mengeluarkan posisi — tidak tahu apa pun soal widget.
class QuranAudioService extends ChangeNotifier {
  final AudioPlayer _player = AudioPlayer();

  List<AyahRef> _queue = const [];
  PlaybackRange? _range;
  int _repeat = 1;
  bool _repeatAll = false;
  String? _error;

  QuranAudioService() {
    // Indeks playlist berubah → ayat aktif berubah.
    _player.currentIndexStream.listen((_) => notifyListeners());
    _player.playerStateStream.listen((_) => notifyListeners());
    _player.playbackEventStream.listen(
      (_) {},
      onError: (Object e, StackTrace _) {
        _error = 'Gagal memuat audio: $e';
        debugPrint('QuranAudio playback error: $e');
        notifyListeners();
      },
    );
  }

  PlaybackRange? get range => _range;
  int get repeat => _repeat;
  bool get repeatAll => _repeatAll;
  String? get error => _error;
  bool get isPlaying => _player.playing;

  Stream<Duration> get position => _player.positionStream;
  Stream<Duration?> get duration => _player.durationStream;

  AyahRef? get current {
    final i = _player.currentIndex;
    if (i == null || i < 0 || i >= _queue.length) return null;
    return _queue[i];
  }

  /// Mode tak terbatas per ayat menang atas "ulangi semua": LoopMode.one
  /// membuat pemutaran tidak pernah mencapai akhir range, sehingga
  /// pengulangan range tidak pernah berlaku selama mode ini aktif.
  LoopMode get _loopMode {
    if (_repeat == kRepeatInfinite) return LoopMode.one;
    return _repeatAll ? LoopMode.all : LoopMode.off;
  }

  Future<void> start({required PlaybackRange range, int? startAyah}) async {
    _range = range;
    await _rebuild(startAyah: startAyah ?? range.from);
    if (_error == null) await _player.play();
  }

  Future<void> _rebuild({int? startAyah}) async {
    final r = _range;
    if (r == null) return;

    _queue = buildQueue(range: r, repeat: _repeat);
    final target = startAyah ?? current?.ayah ?? r.from;
    final index = _queue.indexWhere((a) => a.ayah == target);

    try {
      await _player.setAudioSource(
        ConcatenatingAudioSource(
          children: _queue
              .map(audioSourceForAyah)
              .toList(),
        ),
        initialIndex: index < 0 ? 0 : index,
      );
      await _player.setLoopMode(_loopMode);
      await _player.setSpeed(quranSettings.speed);
      _error = null;
    } catch (e) {
      _error = 'Gagal memuat audio: $e';
      debugPrint('QuranAudio _rebuild error: $e');
    }
    notifyListeners();
  }

  Future<void> toggle() async {
    if (_player.playing) {
      await _player.pause();
    } else {
      await _player.play();
    }
  }

  Future<void> next() async {
    // Dalam mode tak terbatas, LoopMode.one menahan ayat; next harus tetap maju.
    if (_repeat == kRepeatInfinite) {
      await _player.setLoopMode(LoopMode.off);
      await _player.seekToNext();
      await _player.setLoopMode(LoopMode.one);
      return;
    }
    await _player.seekToNext();
  }

  Future<void> previous() async {
    if (_repeat == kRepeatInfinite) {
      await _player.setLoopMode(LoopMode.off);
      await _player.seekToPrevious();
      await _player.setLoopMode(LoopMode.one);
      return;
    }
    await _player.seekToPrevious();
  }

  Future<void> stop() async {
    await _player.stop();
    _range = null;
    _queue = const [];
    notifyListeners();
  }

  /// Mengubah range membangun ulang playlist dan memulai dari awal range.
  Future<void> setRange(PlaybackRange value) async {
    _range = value;
    await _rebuild(startAyah: value.from);
    if (_error == null) await _player.play();
  }

  Future<void> setRepeat(int value) async {
    _repeat = value;
    await _rebuild(startAyah: current?.ayah);
    if (_error == null) await _player.play();
  }

  /// Tidak membangun ulang playlist — hanya mengubah perilaku di ujung antrean.
  Future<void> setRepeatAll(bool value) async {
    _repeatAll = value;
    await _player.setLoopMode(_loopMode);
    notifyListeners();
  }

  /// Diterapkan langsung tanpa menghentikan audio.
  Future<void> setSpeed(double value) async {
    await quranSettings.setSpeed(value);
    await _player.setSpeed(value);
    notifyListeners();
  }

  Future<void> retry() async {
    _error = null;
    await _rebuild(startAyah: current?.ayah);
    if (_error == null) await _player.play();
  }

  @override
  void dispose() {
    _player.dispose();
    super.dispose();
  }
}

final QuranAudioService quranAudio = QuranAudioService();
