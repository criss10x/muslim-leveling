import 'package:flutter/foundation.dart';
import 'package:just_audio/just_audio.dart';
import 'dart:async';
import 'quran_playlist.dart';
import 'quran_settings.dart';

AudioSource audioSourceForAyah(AyahRef ayah, String urlPattern) {
  final url = ayahAudioUrlWithPattern(ayah.surah, ayah.ayah, urlPattern);
  return AudioSource.uri(Uri.parse(url));
}

/// Membungkus just_audio. Menerima angka (surat, range) dan
/// mengeluarkan posisi — tidak tahu apa pun soal widget.
class QuranAudioService extends ChangeNotifier {
  final AudioPlayer _player = AudioPlayer();

  List<AyahRef> _queue = const [];
  PlaybackRange? _range;
  bool _repeatAll = false;
  String? _error;
  Timer? _sleepTimer;
  bool _endOfSurah = false; // sleep mode -1 berhenti di akhir queue

  QuranAudioService() {
    // ponytail: XP dengar dihapus — audio berjalan tanpa tracking XP.
    // Indeks playlist berubah → ayat aktif berubah.
    _player.currentIndexStream.listen((_) => notifyListeners());
    _player.playerStateStream.listen((_) => notifyListeners());
    _player.playbackEventStream.listen(
      (e) {
        if (_endOfSurah && e.processingState == ProcessingState.completed) {
          _player.pause();
          _endOfSurah = false;
          notifyListeners();
        }
      },
      onError: (Object e, StackTrace _) {
        _error = 'Gagal memuat audio: $e';
        debugPrint('QuranAudio playback error: $e');
        notifyListeners();
      },
    );
  }

  PlaybackRange? get range => _range;
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

  LoopMode get _loopMode => _repeatAll ? LoopMode.all : LoopMode.off;

  Future<void> start({required PlaybackRange range, int? startAyah}) async {
    _range = range;
    await _rebuild(startAyah: startAyah ?? range.from);
    if (_error == null) await _player.play();
  }

  Future<void> _rebuild({int? startAyah}) async {
    final r = _range;
    if (r == null) return;

    _queue = buildQueue(r);
    final target = startAyah ?? current?.ayah ?? r.from;
    final index = _queue.indexWhere((a) => a.ayah == target);
    final pattern = quranSettings.qari.urlPattern;

    try {
      await _player.setAudioSource(
        ConcatenatingAudioSource(
          children: _queue.map((a) => audioSourceForAyah(a, pattern)).toList(),
        ),
        initialIndex: index < 0 ? 0 : index,
      );
      await _player.setLoopMode(_loopMode);
      await _player.setSpeed(quranSettings.speed);
      _error = null;
      _scheduleSleep();
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

  Future<void> next() async => _player.seekToNext();
  Future<void> previous() async => _player.seekToPrevious();

  Future<void> stop() async {
    await _player.stop();
    _sleepTimer?.cancel();
    _endOfSurah = false;
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

  /// Rebuild queue pake qari baru tanpa ubah range/repeat.
  Future<void> rebuildQueue() async {
    await _rebuild(startAyah: current?.ayah);
    if (_error == null && _player.playing) await _player.play();
  }

  void _scheduleSleep() {
    _sleepTimer?.cancel();
    _endOfSurah = false;
    final minutes = quranSettings.sleepMinutes;
    if (minutes == 0) return;
    if (minutes == -1) {
      _endOfSurah = true;
      return;
    }
    _sleepTimer = Timer(Duration(minutes: minutes), () {
      _player.pause();
      notifyListeners();
    });
  }

  /// Panggil saat sleep timer diubah di sheet — reset tanpa rebuild.
  void rescheduleSleep() {
    _scheduleSleep();
  }

  @override
  void dispose() {
    _sleepTimer?.cancel();
    _player.dispose();
    super.dispose();
  }
}

final QuranAudioService quranAudio = QuranAudioService();
