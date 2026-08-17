import 'dart:async';
import 'package:flutter/material.dart';
import 'package:vibration/vibration.dart';
import '../../theme/app_theme.dart';
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
  DzikirTarget('33', 33),
  DzikirTarget('99', 99),
  DzikirTarget('100', 100),
];

/// Layar Dzikir penuh — tasbih digital.
/// Seluruh layar = zona tap (GestureDetector opaque); kontrol kecil
/// (back / getar / reset / chips) menyerap gesture sendiri lewat arena.
class DzikirScreen extends StatefulWidget {
  const DzikirScreen({super.key});
  @override
  State<DzikirScreen> createState() => _DzikirScreenState();
}

class _DzikirScreenState extends State<DzikirScreen>
    with SingleTickerProviderStateMixin {
  int _dzikirIdx = 0;
  int _targetIdx = 0;
  bool _busy = false;
  late final AnimationController _pulse;

  DzikirItem get _dzikir => dzikirItems[_dzikirIdx];
  int get _target => dzikirTargets[_targetIdx].count;

  @override
  void initState() {
    super.initState();
    // Pop kecil tiap tap — feedback visual tanpa perlu widget state.
    _pulse = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 160),
      reverseDuration: const Duration(milliseconds: 120),
      lowerBound: 0.94,
      value: 1.0,
    );
  }

  @override
  void dispose() {
    _pulse.dispose();
    super.dispose();
  }

  Future<void> _tap() async {
    if (_busy) return;
    _busy = true;
    if (GameService.zikirVibrate) {
      // vibrate(), bukan lightImpact() — impact haptic sering no-op di OEM
      // Android; Vibration.vibrate() langsung tarik motor getar via plugin.
      unawaited(Vibration.vibrate(duration: 50));
    }
    _pulse.forward(from: 0.94);
    await GameService.incrementZikir(key: _dzikir.key);
    // Counter aktif capai target → auto reset aktif dari 0 (total harian tetap).
    if (mounted) {
      setState(() {});
      final c = GameService.zikirCountsToday[_dzikir.key] ?? 0;
      if (c >= _target) {
        await GameService.resetZikir(_dzikir.key);
        if (mounted) setState(() {});
      }
    }
    _busy = false;
  }

  Future<void> _reset() async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Reset counter?'),
        content: Text(
            'Counter "${_dzikir.translit}" akan di-nolkan dari 0.\nTotal dzikir hari ini TETAP dihitung.'),
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
        child: GestureDetector(
          behavior: HitTestBehavior.opaque,
          onTap: _tap,
          child: Column(
            children: [
              _header(total, current),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      // Dzikir aktif — Arab besar, latin, terjemah.
                      Text(
                        _dzikir.arabic,
                        textAlign: TextAlign.center,
                        textDirection: TextDirection.rtl,
                        style: AppText.headlineLg().copyWith(
                          color: AppColors.onSurface,
                          height: 1.6,
                        ),
                      ),
                      const SizedBox(height: AppSpacing.sm),
                      Text(
                        _dzikir.translit,
                        textAlign: TextAlign.center,
                        style: AppText.titleLg().copyWith(color: AppColors.primary),
                      ),
                      Text(
                        _dzikir.translation,
                        textAlign: TextAlign.center,
                        style: AppText.bodyMd().copyWith(color: AppColors.onSurfaceVariant),
                      ),
                      const SizedBox(height: AppSpacing.lg),
                      // Ring hero — pop tiap tap.
                      ScaleTransition(
                        scale: _pulse,
                        child: _ring(progress, done, current),
                      ),
                      const SizedBox(height: AppSpacing.sm),
                      // Afordansi: seluruh layar bisa di-tap.
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.touch_app,
                              size: 16, color: AppColors.onSurfaceVariant.withValues(alpha: 0.7)),
                          const SizedBox(width: AppSpacing.xs),
                          Text(
                            'Ketuk di mana saja untuk berdzikir',
                            style: AppText.bodyMd().copyWith(
                              color: AppColors.onSurfaceVariant,
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
              _selectors(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _header(int total, int current) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(AppSpacing.sm, AppSpacing.sm, AppSpacing.sm, 0),
      child: Row(
        children: [
          IconButton(
            onPressed: () => Navigator.pop(context),
            icon: const Icon(Icons.arrow_back),
            tooltip: 'Kembali',
          ),
          const SizedBox(width: AppSpacing.xs),
          Text('Dzikir', style: AppText.headlineMd()),
          const Spacer(),
          // Total hari ini — pill compact.
          Container(
            padding: const EdgeInsets.symmetric(horizontal: AppSpacing.sm, vertical: 6),
            decoration: BoxDecoration(
              color: AppColors.surfaceContainer,
              borderRadius: BorderRadius.circular(AppRadius.pill),
            ),
            child: Text(
              'Hari ini: $total',
              style: AppText.labelCapsSm().copyWith(color: AppColors.onSurfaceVariant),
            ),
          ),
          const SizedBox(width: AppSpacing.xs),
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
          IconButton(
            onPressed: current == 0 ? null : _reset,
            tooltip: 'Reset counter ini',
            icon: const Icon(Icons.restart_alt),
          ),
        ],
      ),
    );
  }

  Widget _ring(double progress, bool done, int current) {
    final accent = done ? AppColors.secondaryFixed : AppColors.primary;
    return SizedBox(
      width: 200,
      height: 200,
      child: Stack(
        alignment: Alignment.center,
        children: [
          SizedBox(
            width: 200,
            height: 200,
            child: CircularProgressIndicator(
              value: progress,
              strokeWidth: 12,
              strokeCap: StrokeCap.round,
              backgroundColor: AppColors.surfaceContainerHighest,
              valueColor: AlwaysStoppedAnimation(accent),
            ),
          ),
          Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                '$current',
                style: AppText.displayHero(48).copyWith(color: accent),
              ),
              Text(
                '/ $_target',
                style: AppText.bodyMd().copyWith(color: AppColors.onSurfaceVariant),
              ),
              if (done)
                Padding(
                  padding: const EdgeInsets.only(top: AppSpacing.xs),
                  child: Text(
                    'TARGET TERCAPAI',
                    style: AppText.labelCapsSm().copyWith(color: AppColors.secondaryFixed),
                  ),
                ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _selectors() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(AppSpacing.md, 0, AppSpacing.md, AppSpacing.md),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('DZIKIR', style: AppText.labelCapsSm().copyWith(color: AppColors.onSurfaceVariant)),
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
          const SizedBox(height: AppSpacing.sm),
          Row(
            children: [
              Text('TARGET',
                  style: AppText.labelCapsSm().copyWith(color: AppColors.onSurfaceVariant)),
              const SizedBox(width: AppSpacing.sm),
              Expanded(
                child: SizedBox(
                  height: 40,
                  child: ListView.separated(
                    scrollDirection: Axis.horizontal,
                    itemCount: dzikirTargets.length,
                    separatorBuilder: (_, __) => const SizedBox(width: AppSpacing.sm),
                    itemBuilder: (context, i) {
                      final sel = i == _targetIdx;
                      return ChoiceChip(
                        label: Text('${dzikirTargets[i].count}×'),
                        selected: sel,
                        onSelected: (_) => setState(() => _targetIdx = i),
                      );
                    },
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}