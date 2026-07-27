import 'package:flutter/material.dart';
import 'package:scrollable_positioned_list/scrollable_positioned_list.dart';
import 'package:wakelock_plus/wakelock_plus.dart';
import '../theme/app_theme.dart';
import '../services/quran_data.dart';
import '../services/quran_audio_service.dart';
import '../services/quran_playlist.dart';
import '../widgets/quran_ayah_card.dart';
import '../widgets/quran_display_sheet.dart';
import '../widgets/quran_player_bar.dart';

class QuranReader extends StatefulWidget {
  final QuranSurah surah;
  const QuranReader({super.key, required this.surah});

  @override
  State<QuranReader> createState() => _QuranReaderState();
}

class _QuranReaderState extends State<QuranReader> {
  // ScrollablePositionedList, bukan ListView: auto-scroll harus melompat ke
  // indeks ayat sementara tinggi tiap kartu berbeda-beda.
  final ItemScrollController _scrollController = ItemScrollController();

  List<QuranAyah> _ayahs = const [];
  bool _loading = true;
  int? _lastScrolledAyah;
  String? _shownError;

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
    final list = await quranData.ayahs(widget.surah.number);
    if (!mounted) return;
    setState(() {
      _ayahs = list;
      _loading = false;
    });
  }

  void _onAudioChanged() {
    if (!mounted) return;

    // Layar tetap menyala selama murrotal berjalan — orang membaca sambil
    // mendengarkan, dan layar mati di tengah bacaan mengganggu.
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
          index: current.ayah - 1,
          duration: const Duration(milliseconds: 350),
          curve: Curves.easeOut,
          alignment: 0.25,
        );
      }
    }

    // Penjagaan _shownError mencegah snackbar sama muncul berulang, karena
    // listener terpanggil tiap kali state pemutar berubah.
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
            icon: const Icon(Icons.text_fields),
            onPressed: () => showQuranDisplaySheet(context),
          ),
        ],
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : ScrollablePositionedList.builder(
              itemScrollController: _scrollController,
              padding: const EdgeInsets.only(bottom: 120, top: 8),
              itemCount: _ayahs.length,
              itemBuilder: (_, i) {
                final a = _ayahs[i];
                return QuranAyahCard(
                  ayah: a,
                  active: current != null &&
                      current.surah == widget.surah.number &&
                      current.ayah == a.ayah,
                  onPlay: () => _playFrom(a.ayah),
                );
              },
            ),
      bottomNavigationBar: QuranPlayerBar(surah: widget.surah),
    );
  }
}
