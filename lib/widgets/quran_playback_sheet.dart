import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import '../services/quran_data.dart';
import '../services/quran_audio_service.dart';
import '../services/quran_playlist.dart';
import '../services/quran_settings.dart';
import '../services/quran_qari.dart';

Future<void> showQuranPlaybackSheet(
  BuildContext context, {
  required QuranSurah surah,
}) {
  return showModalBottomSheet<void>(
    context: context,
    backgroundColor: AppColors.surfaceContainer,
    isScrollControlled: true,
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(AppRadius.xl)),
    ),
    builder: (_) => _PlaybackSheet(surah: surah),
  );
}

class _PlaybackSheet extends StatelessWidget {
  final QuranSurah surah;
  const _PlaybackSheet({required this.surah});

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: quranAudio,
      builder: (context, _) {
        final range = quranAudio.range ??
            PlaybackRange.full(surah: surah.number, ayahCount: surah.ayahCount);

        return SafeArea(
          child: SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 20),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Text('Setelan Murrotal',
                      style: AppText.headlineMd()
                          .copyWith(color: AppColors.onSurface)),
                  const SizedBox(height: 16),

                  // ── Range ayat ──
                  Text('Rentang ayat',
                      style: AppText.labelCaps()
                          .copyWith(color: AppColors.onSurfaceVariant)),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Expanded(
                        child: _AyahDropdown(
                          label: 'Dari',
                          value: range.from,
                          max: surah.ayahCount,
                          onChanged: (v) =>
                              quranAudio.setRange(range.withFrom(v)),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _AyahDropdown(
                          label: 'Sampai',
                          value: range.to,
                          max: surah.ayahCount,
                          onChanged: (v) =>
                              quranAudio.setRange(range.withTo(v)),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),

                  // ── Ulangi semua ──
                  SwitchListTile(
                    contentPadding: EdgeInsets.zero,
                    value: quranAudio.repeatAll,
                    onChanged: (v) => quranAudio.setRepeatAll(v),
                    title: Text('Ulangi rentang',
                        style: AppText.bodyLg()
                            .copyWith(color: AppColors.onSurface)),
                    subtitle: Text(
                      'Kembali ke ayat ${range.from} setelah ayat '
                      '${range.to} selesai',
                      style: AppText.bodyMd()
                          .copyWith(color: AppColors.onSurfaceVariant),
                    ),
                  ),
                  const SizedBox(height: 12),

                  // ── Kecepatan ──
                  Text('Kecepatan',
                      style: AppText.labelCaps()
                          .copyWith(color: AppColors.onSurfaceVariant)),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 8,
                    children: [
                      for (final s in kSpeedOptions)
                        ChoiceChip(
                          label: Text('${s}x'),
                          selected: quranSettings.speed == s,
                          onSelected: (_) => quranAudio.setSpeed(s),
                        ),
                    ],
                  ),
                  const SizedBox(height: 20),

                  // ── Qari ──
                  Text('Qari',
                      style: AppText.labelCaps()
                          .copyWith(color: AppColors.onSurfaceVariant)),
                  const SizedBox(height: 8),
                  _QariDropdown(),
                  const SizedBox(height: 20),

                  // ── Sleep timer ──
                  Text('Tidur otomatis',
                      style: AppText.labelCaps()
                          .copyWith(color: AppColors.onSurfaceVariant)),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 8,
                    children: [
                      for (final m in kSleepOptions)
                        ChoiceChip(
                          label: Text(m == -1
                              ? 'Akhir surat'
                              : m == 0
                                  ? 'Off'
                                  : '${m}m'),
                          selected: quranSettings.sleepMinutes == m,
                          onSelected: (_) {
                            quranSettings.setSleepMinutes(m);
                            quranAudio.rescheduleSleep();
                          },
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

class _AyahDropdown extends StatelessWidget {
  final String label;
  final int value, max;
  final ValueChanged<int> onChanged;

  const _AyahDropdown({
    required this.label,
    required this.value,
    required this.max,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return InputDecorator(
      decoration: InputDecoration(
        labelText: label,
        labelStyle:
            AppText.bodyMd().copyWith(color: AppColors.onSurfaceVariant),
        filled: true,
        fillColor: AppColors.surfaceContainerLow,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppRadius.xl),
          borderSide: BorderSide.none,
        ),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<int>(
          value: value,
          isExpanded: true,
          dropdownColor: AppColors.surfaceContainerHigh,
          style: AppText.bodyLg().copyWith(color: AppColors.onSurface),
          items: [
            for (var i = 1; i <= max; i++)
              DropdownMenuItem(value: i, child: Text('$i')),
          ],
          onChanged: (v) {
            if (v != null) onChanged(v);
          },
        ),
      ),
    );
  }
}

class _QariDropdown extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return InputDecorator(
      decoration: InputDecoration(
        filled: true,
        fillColor: AppColors.surfaceContainerLow,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppRadius.xl),
          borderSide: BorderSide.none,
        ),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: quranSettings.qariId,
          isExpanded: true,
          dropdownColor: AppColors.surfaceContainerHigh,
          style: AppText.bodyLg().copyWith(color: AppColors.onSurface),
          items: [
            for (final q in kQariList)
              DropdownMenuItem(value: q.id, child: Text(q.name)),
          ],
          onChanged: (v) {
            if (v != null) {
              quranSettings.setQari(v);
              quranAudio.rebuildQueue();
            }
          },
        ),
      ),
    );
  }
}
