import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../theme/app_theme.dart';
import '../../widgets/common.dart';
import '../../services/game_service.dart';

class DzikirItem {
  final String key;
  final String arabic;
  final String translit;
  final String translation;
  const DzikirItem(this.key, this.arabic, this.translit, this.translation);
}

const dzikirItems = [
  DzikirItem('subhanallah', 'سُبْحَانَ اللَّهِ', 'Subhanallah', 'Maha Suci Allah'),
  DzikirItem('alhamdulillah', 'الْحَمْدُ لِلَّهِ', 'Alhamdulillah', 'Segala puji bagi Allah'),
  DzikirItem('allahuakbar', 'اللَّهُ أَكْبَرُ', 'Allahu Akbar', 'Allah Maha Besar'),
  DzikirItem('astaghfirullah', 'أَسْتَغْفِرُ اللَّهَ', 'Astaghfirullah', 'Aku memohon ampun kepada Allah'),
  DzikirItem('hawla', 'لَا حَوْلَ وَلَا قُوَّةَ إِلَّا بِاللَّهِ', 'La hawla wala quwwata illa billah', 'Tiada daya & kekuatan kecuali dengan Allah'),
];

class DzikirTarget {
  final String label;
  final int count;
  const DzikirTarget(this.label, this.count);
}

const dzikirTargets = [
  DzikirTarget('33 × Tasbih setelah sholat', 33),
  DzikirTarget('99 × Asmaul Husna', 99),
  DzikirTarget('100 × Istighfar / Tahlil', 100),
];

/// Layar Dzikir penuh — tasbih digital.
class DzikirScreen extends StatefulWidget {
  const DzikirScreen({super.key});
  @override
  State<DzikirScreen> createState() => _DzikirScreenState();
}

class _DzikirScreenState extends State<DzikirScreen> {
  int _dzikirIdx = 0;
  int _targetIdx = 0;
  bool _busy = false;

  DzikirItem get _dzikir => dzikirItems[_dzikirIdx];
  int get _target => dzikirTargets[_targetIdx].count;

  Future<void> _tap() async {
    if (_busy) return;
    _busy = true;
    if (GameService.zikirVibrate) {
      unawaited(HapticFeedback.lightImpact());
    }
    await GameService.incrementZikir(key: _dzikir.key);
    if (mounted) setState(() {});
    _busy = false;
  }

  Future<void> _reset() async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Reset counter?'),
        content: Text('Counter "${_dzikir.translit}" hari ini akan di-nolkan.'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('BATAL')),
          TextButton(onPressed: () => Navigator.pop(ctx, true), child: const Text('RESET')),
        ],
      ),
    );
    if (ok == true) {
      await GameService.resetZikir(_dzikir.key);
      if (mounted) setState(() {});
    }
  }

  @override
  Widget build(BuildContext context) {
    final total = GameService.zikirCountToday;
    final counts = GameService.zikirCountsToday;
    final current = counts[_dzikir.key] ?? 0;
    final progress = (current / _target).clamp(0.0, 1.0);
    final done = current >= _target;

    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            // Header
            Padding(
              padding: const EdgeInsets.fromLTRB(
                  AppSpacing.md, AppSpacing.md, AppSpacing.md, 0),
              child: Row(
                children: [
                  IconButton(
                    onPressed: () => Navigator.pop(context),
                    icon: const Icon(Icons.arrow_back),
                    tooltip: 'Kembali',
                  ),
                  const SizedBox(width: AppSpacing.sm),
                  Expanded(
                    child: Text('Dzikir', style: AppText.headlineMd()),
                  ),
                  // Getar on/off
                  IconButton(
                    onPressed: () async {
                      await GameService.setZikirVibrate(!GameService.zikirVibrate);
                      setState(() {});
                    },
                    tooltip: GameService.zikirVibrate ? 'Matikan getar' : 'Nyalakan getar',
                    icon: Icon(
                      GameService.zikirVibrate ? Icons.vibration : Icons.smartphone,
                      color: GameService.zikirVibrate ? AppColors.primary : AppColors.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              child: ListView(
                padding: const EdgeInsets.all(AppSpacing.md),
                children: [
                  // Total hari ini
                  FlatCard(
                    child: Row(
                      children: [
                        Icon(Icons.mosque, color: AppColors.secondaryFixed, size: 20),
                        const SizedBox(width: AppSpacing.sm),
                        Expanded(
                          child: Text('Total dzikir hari ini',
                              style: AppText.bodyMd().copyWith(color: AppColors.onSurfaceVariant)),
                        ),
                        Text(
                          '$total',
                          style: AppText.headlineMd().copyWith(
                            color: done ? AppColors.secondaryFixed : AppColors.primary,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: AppSpacing.md),

                  // Pilihan dzikir — chips
                  Text('PILIH DZIKIR', style: AppText.labelCapsSm().copyWith(color: AppColors.onSurfaceVariant)),
                  const SizedBox(height: AppSpacing.sm),
                  SizedBox(
                    height: 40,
                    child: ListView.separated(
                      scrollDirection: Axis.horizontal,
                      itemCount: dzikirItems.length,
                      separatorBuilder: (_, __) => const SizedBox(width: AppSpacing.sm),
                      itemBuilder: (context, i) {
                        final sel = i == _dzikirIdx;
                        return ChoiceChip(
                          label: Text(dzikirItems[i].translit),
                          selected: sel,
                          onSelected: (_) => setState(() => _dzikirIdx = i),
                        );
                      },
                    ),
                  ),
                  const SizedBox(height: AppSpacing.md),

                  // Teks dzikir (Arab, latin, terjemah)
                  FlatCard(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          _dzikir.arabic,
                          style: AppText.headlineLg().copyWith(color: AppColors.onSurface, height: 1.5),
                          textAlign: TextAlign.right,
                          textDirection: TextDirection.rtl,
                        ),
                        const SizedBox(height: AppSpacing.sm),
                        Text(_dzikir.translit,
                            style: AppText.bodyMd().copyWith(color: AppColors.primary)),
                        Text(_dzikir.translation,
                            style: AppText.bodyMd().copyWith(color: AppColors.onSurfaceVariant)),
                      ],
                    ),
                  ),
                  const SizedBox(height: AppSpacing.md),

                  // Pilihan target — chips
                  Text('TARGET', style: AppText.labelCapsSm().copyWith(color: AppColors.onSurfaceVariant)),
                  const SizedBox(height: AppSpacing.sm),
                  SizedBox(
                    height: 40,
                    child: ListView.separated(
                      scrollDirection: Axis.horizontal,
                      itemCount: dzikirTargets.length,
                      separatorBuilder: (_, __) => const SizedBox(width: AppSpacing.sm),
                      itemBuilder: (context, i) {
                        final sel = i == _targetIdx;
                        return ChoiceChip(
                          label: Text(dzikirTargets[i].label),
                          selected: sel,
                          onSelected: (_) => setState(() => _targetIdx = i),
                        );
                      },
                    ),
                  ),
                  const SizedBox(height: AppSpacing.lg),

                  // Tombol reset
                  Align(
                    alignment: Alignment.centerLeft,
                    child: TextButton.icon(
                      onPressed: current == 0 ? null : _reset,
                      icon: const Icon(Icons.restart_alt, size: 18),
                      label: const Text('Reset counter dzikir ini'),
                    ),
                  ),
                  const SizedBox(height: AppSpacing.sm),

                  // Ring progress + angka
                  SizedBox(
                    height: 200,
                    child: Center(
                      child: Stack(
                        alignment: Alignment.center,
                        children: [
                          SizedBox(
                            width: 180,
                            height: 180,
                            child: CircularProgressIndicator(
                              value: progress,
                              strokeWidth: 10,
                              backgroundColor: AppColors.surfaceContainerHighest,
                              valueColor: AlwaysStoppedAnimation(
                                done ? AppColors.secondaryFixed : AppColors.primary,
                              ),
                            ),
                          ),
                          Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                '$current',
                                style: AppText.displayHero(44).copyWith(
                                  color: done ? AppColors.secondaryFixed : AppColors.primary,
                                ),
                              ),
                              Text(
                                '/ $_target',
                                style: AppText.bodyMd().copyWith(color: AppColors.onSurfaceVariant),
                              ),
                              if (done)
                                Padding(
                                  padding: const EdgeInsets.only(top: AppSpacing.xs),
                                  child: Text('TARGET TERCAPAI',
                                      style: AppText.labelCapsSm().copyWith(color: AppColors.secondaryFixed)),
                                ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: AppSpacing.md),
                ],
              ),
            ),

            // Zona tap besar — seluruh area bawah bisa di-tap untuk menghitung
            SafeArea(
              top: false,
              child: Padding(
                padding: const EdgeInsets.fromLTRB(
                    AppSpacing.md, 0, AppSpacing.md, AppSpacing.md),
                child: PressableScale(
                  pressedScale: 0.96,
                  onTap: _tap,
                  child: Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(vertical: AppSpacing.lg),
                    decoration: BoxDecoration(
                      color: AppColors.primary,
                      borderRadius: BorderRadius.circular(AppRadius.xxl),
                    ),
                    child: Column(
                      children: [
                        Icon(Icons.touch_app, color: AppColors.onPrimary, size: 28),
                        const SizedBox(height: AppSpacing.xs),
                        Text(
                          'TAP DI MANA SAJA UNTUK DZIKIR',
                          style: AppText.labelCaps().copyWith(color: AppColors.onPrimary),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
