import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import '../services/quran_data.dart';
import '../services/quran_audio_service.dart';
import 'quran_playback_sheet.dart';
import '../l10n/app_localizations.dart';

class QuranPlayerBar extends StatelessWidget {
  final QuranSurah surah;
  const QuranPlayerBar({super.key, required this.surah});

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: quranAudio,
      builder: (context, _) {
        final current = quranAudio.current;
        if (current == null) return const SizedBox.shrink();

        return Container(
          decoration: BoxDecoration(
            color: AppColors.surfaceContainerHigh,
            border: Border(
              top: BorderSide(
                color: AppColors.outlineVariant.withValues(alpha: 0.7),
              ),
            ),
          ),
          child: SafeArea(
            top: false,
            child: Padding(
              padding: const EdgeInsets.fromLTRB(12, 8, 12, 8),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  StreamBuilder<Duration>(
                    stream: quranAudio.position,
                    builder: (context, snap) {
                      return StreamBuilder<Duration?>(
                        stream: quranAudio.duration,
                        builder: (context, durSnap) {
                          final pos = snap.data ?? Duration.zero;
                          final dur = durSnap.data ?? Duration.zero;
                          final value = dur.inMilliseconds == 0
                              ? 0.0
                              : (pos.inMilliseconds / dur.inMilliseconds)
                                  .clamp(0.0, 1.0);
                          return LinearProgressIndicator(
                            value: value,
                            backgroundColor: AppColors.surfaceContainerLow,
                            color: AppColors.primary,
                            minHeight: 3,
                          );
                        },
                      );
                    },
                  ),
                  const SizedBox(height: 6),
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          AppL10n.of(context)
                              .qpNowPlaying(surah.nameLatin, current.ayah),
                          style: AppText.bodyLg()
                              .copyWith(color: AppColors.onSurface),
                        ),
                      ),
                      IconButton(
                        tooltip: AppL10n.of(context).qpPrevAyah,
                        icon: const Icon(Icons.skip_previous),
                        color: AppColors.onSurface,
                        onPressed: quranAudio.previous,
                      ),
                      IconButton(
                        tooltip: quranAudio.isPlaying
                            ? AppL10n.of(context).dlActPause
                            : AppL10n.of(context).qpPlay,
                        icon: Icon(quranAudio.isPlaying
                            ? Icons.pause_circle_filled
                            : Icons.play_circle_fill),
                        iconSize: 40,
                        color: AppColors.primary,
                        onPressed: quranAudio.toggle,
                      ),
                      IconButton(
                        tooltip: AppL10n.of(context).qpNextAyah,
                        icon: const Icon(Icons.skip_next),
                        color: AppColors.onSurface,
                        onPressed: quranAudio.next,
                      ),
                      IconButton(
                        tooltip: AppL10n.of(context).qpMurrotalSettings,
                        icon: const Icon(Icons.tune),
                        color: AppColors.onSurface,
                        onPressed: () =>
                            showQuranPlaybackSheet(context, surah: surah),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
