import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:scrollable_positioned_list/scrollable_positioned_list.dart';
import 'package:wakelock_plus/wakelock_plus.dart';
import '../theme/app_theme.dart';
import '../services/quran_data.dart';
import '../services/quran_api.dart';
import '../services/quran_audio_service.dart';
import '../services/quran_playlist.dart';
import '../services/quran_settings.dart';
import '../widgets/quran_ayah_card.dart';
import '../widgets/quran_display_sheet.dart';
import '../widgets/quran_player_bar.dart';
import '../widgets/quran_tafsir_sheet.dart';

class QuranReader extends StatefulWidget {
  final QuranSurah surah;
  const QuranReader({super.key, required this.surah});

  @override
  State<QuranReader> createState() => _QuranReaderState();
}

class _QuranReaderState extends State<QuranReader> {
  final ItemScrollController _scrollController = ItemScrollController();

  List<QuranAyah> _ayahs = const [];
  bool _loading = true;
  int? _lastScrolledAyah;
  String? _shownError;
  List<QuranTafsir> _tafsir = const [];

  /// 1 untuk surat yg punya basmalah (semua kecuali Al-Fatihah & At-Tawbah).
  int get _basmalahOffset =>
      widget.surah.number != 1 && widget.surah.number != 9 ? 1 : 0;

  @override
  void initState() {
    super.initState();
    _load();
    quranAudio.addListener(_onAudioChanged);
  }

  @override
  void dispose() {
    quranAudio.removeListener(_onAudioChanged);
    quranAudio.stop();
    WakelockPlus.disable();
    super.dispose();
  }

  Future<void> _load() async {
    final num = widget.surah.number;
    // Fetch ayahs + tafsir from API, fallback ke lokal.
    try {
      final results = await Future.wait([
        quranApi.ayahs(num),
        quranApi.tafsir(num),
      ]);
      if (!mounted) return;
      setState(() {
        _ayahs = results[0] as List<QuranAyah>;
        _tafsir = results[1] as List<QuranTafsir>;
        _loading = false;
      });
    } catch (_) {
      // Fallback ke aset lokal
      try {
        final list = await quranData.ayahs(num);
        if (!mounted) return;
        setState(() {
          _ayahs = list;
          _tafsir = const [];
          _loading = false;
        });
      } catch (fallbackErr) {
        if (!mounted) return;
        setState(() => _loading = false);
      }
    }
  }

  void _onAudioChanged() {
    if (!mounted) return;

    if (quranAudio.isPlaying) {
      WakelockPlus.enable();
    } else {
      WakelockPlus.disable();
    }

    final current = quranAudio.current;
    if (current != null &&
        current.surah == widget.surah.number &&
        current.ayah != _lastScrolledAyah) {
      _lastScrolledAyah = current.ayah;
      if (_scrollController.isAttached) {
        _scrollController.scrollTo(
          index: current.ayah - 1 + _basmalahOffset,
          duration: const Duration(milliseconds: 350),
          curve: Curves.easeOut,
          alignment: 0.25,
        );
      }
    }

    final err = quranAudio.error;
    if (err != null && err != _shownError) {
      _shownError = err;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(err),
          action: SnackBarAction(
            label: 'Coba lagi',
            onPressed: () {
              _shownError = null;
              quranAudio.retry();
            },
          ),
        ),
      );
    }

    setState(() {});
  }

  void _playFrom(int ayah) {
    quranAudio.start(
      range: PlaybackRange.full(
        surah: widget.surah.number,
        ayahCount: widget.surah.ayahCount,
      ),
      startAyah: ayah,
    );
  }

  @override
  Widget build(BuildContext context) {
    final current = quranAudio.current;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.surfaceContainerLow,
        title: Text(
          widget.surah.nameLatin,
          style: AppText.headlineMd().copyWith(color: AppColors.onSurface),
        ),
        actions: [
          IconButton(
            tooltip: 'Setelan tampilan',
            icon: const Icon(Icons.settings),
            onPressed: () => showQuranDisplaySheet(context),
          ),
        ],
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : ScrollablePositionedList.builder(
              itemScrollController: _scrollController,
              padding: const EdgeInsets.only(bottom: 120, top: 8),
              itemCount: _ayahs.length + _basmalahOffset,
              itemBuilder: (_, i) {
                if (i == 0 && _basmalahOffset == 1) {
                  return _basmalahHeader();
                }
                final a = _ayahs[i - _basmalahOffset];
                return QuranAyahCard(
                  ayah: a,
                  active: current != null &&
                      current.surah == widget.surah.number &&
                      current.ayah == a.ayah,
                  onPlay: () => _playFrom(a.ayah),
                  onTafsir: () {
                    final t = _tafsir.where((e) => e.ayah == a.ayah);
                    if (t.isNotEmpty) {
                      showTafsirSheet(context, t.first);
                    }
                  },
                );
              },
            ),
      bottomNavigationBar: QuranPlayerBar(surah: widget.surah),
    );
  }

  /// Basmalah decorative header — visual pembeda, bukan bagian dari ayat.
  /// ponytail: ligatur ﷽ overflow di font besar, pakai teks pendek.
  Widget _basmalahHeader() {
    final showTr = quranSettings.showTranslation;
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 20),
      decoration: BoxDecoration(
        color: AppColors.primary.withValues(alpha: 0.06),
        borderRadius: BorderRadius.circular(AppRadius.xxl),
      ),
      child: Column(
        children: [
          FittedBox(
            fit: BoxFit.scaleDown,
            child: Text(
              'بسم الله',
              textAlign: TextAlign.center,
              textDirection: TextDirection.rtl,
              style: GoogleFonts.amiriQuran(
                fontSize: quranSettings.arabicFontSize + 4,
                height: 1.8,
                color: AppColors.onSurfaceVariant.withValues(alpha: 0.55),
              ),
            ),
          ),
          if (showTr) ...[
            const SizedBox(height: 4),
            Text(
              'Dengan nama Allah Yang Maha Pengasih, Maha Penyayang',
              textAlign: TextAlign.center,
              style: AppText.bodyMd().copyWith(
                fontSize: quranSettings.translationFontSize - 2,
                color: AppColors.onSurfaceVariant.withValues(alpha: 0.45),
              ),
            ),
          ],
        ],
      ),
    );
  }
}
