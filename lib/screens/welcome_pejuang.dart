import 'package:flutter/material.dart';
import '../../theme/app_theme.dart';
import '../../widgets/common.dart';
import 'character_creation.dart';

/// First-use mission briefing with a compact, gamified introduction.
class WelcomePejuangScreen extends StatefulWidget {
  const WelcomePejuangScreen({super.key});

  @override
  State<WelcomePejuangScreen> createState() => _WelcomePejuangScreenState();
}

class _WelcomePejuangScreenState extends State<WelcomePejuangScreen>
    with SingleTickerProviderStateMixin {
  late final AnimationController _entryCtl;

  @override
  void initState() {
    super.initState();
    _entryCtl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 710),
    )..forward();
  }

  @override
  void dispose() {
    _entryCtl.dispose();
    super.dispose();
  }

  Animation<double> _fade(double start, double end) => CurvedAnimation(
    parent: _entryCtl,
    curve: Interval(start, end, curve: Curves.easeOutCubic),
  );

  Widget _enter({
    required Widget child,
    required double start,
    required double end,
  }) {
    final animation = _fade(start, end);
    return FadeTransition(
      opacity: animation,
      child: SlideTransition(
        position: Tween<Offset>(
          begin: const Offset(0, 0.04),
          end: Offset.zero,
        ).animate(animation),
        child: child,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: AmbientBackground(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
            child: Column(
              children: [
                const SizedBox(height: AppSpacing.lg),
                _enter(child: _header(), start: 0, end: 0.4),
                const SizedBox(height: AppSpacing.lg),
                _enter(
                  start: 0.3,
                  end: 0.55,
                  child: _benefit(
                    Icons.mosque_outlined,
                    'Quest Sholat',
                    'Sholat → XP → streak',
                    AppColors.primary,
                  ),
                ),
                const SizedBox(height: AppSpacing.sm),
                _enter(
                  start: 0.4,
                  end: 0.65,
                  child: _benefit(
                    Icons.menu_book_outlined,
                    'Belajar Islam',
                    'Artikel & quiz Islam',
                    AppColors.tertiary,
                  ),
                ),
                const SizedBox(height: AppSpacing.sm),
                _enter(
                  start: 0.5,
                  end: 0.75,
                  child: _benefit(
                    Icons.military_tech_outlined,
                    'Raih Badge',
                    'Konsisten, raih badge',
                    AppColors.secondaryContainer,
                  ),
                ),
                const SizedBox(height: AppSpacing.lg),
                _enter(
                  start: 0.65,
                  end: 1,
                  child: HeroButton(
                    label: 'MULAI MISI PERTAMA',
                    trailingIcon: Icons.arrow_forward,
                    onPressed: () => Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (_) => const CharacterCreationScreen(),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: AppSpacing.sm),
                Text(
                  'Pelan-pelan, yang penting istiqomah.',
                  style: AppText.bodyMd().copyWith(
                    color: AppColors.onSurfaceVariant,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: AppSpacing.lg),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _header() {
    final light = isLightTheme;
    return Column(
      children: [
        Container(
          width: 72,
          height: 72,
          decoration: BoxDecoration(
            color: AppColors.surfaceContainer,
            borderRadius: BorderRadius.circular(AppRadius.xl),
            border: Border.all(color: AppColors.primary.withValues(alpha: 0.3)),
            boxShadow: light
                ? null
                : [
                    BoxShadow(
                      color: AppColors.primary.withValues(alpha: 0.18),
                      blurRadius: 18,
                    ),
                  ],
          ),
          child: ColorFiltered(
            colorFilter: ColorFilter.mode(AppColors.primary, BlendMode.srcIn),
            child: Image.asset(
              'assets/images/logo_mark.png',
              width: 44,
              height: 44,
            ),
          ),
        ),
        const SizedBox(height: AppSpacing.md),
        Text(
          'SELAMAT DATANG',
          style: AppText.displayHero(30).copyWith(color: AppColors.onSurface),
        ),
        const SizedBox(height: AppSpacing.xs),
        Text(
          'Mulai perjalanan baikmu hari ini.',
          style: AppText.bodyMd().copyWith(color: AppColors.onSurfaceVariant),
        ),
      ],
    );
  }

  Widget _benefit(IconData icon, String title, String copy, Color accent) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.md,
        vertical: AppSpacing.sm,
      ),
      decoration: BoxDecoration(
        color: AppColors.surfaceContainer.withValues(alpha: 0.6),
        borderRadius: BorderRadius.circular(AppRadius.lg),
        border: Border.all(color: accent.withValues(alpha: 0.2)),
      ),
      child: Row(
        children: [
          Icon(icon, color: accent, size: 22),
          const SizedBox(width: AppSpacing.sm),
          Expanded(flex: 2, child: Text(title, style: AppText.titleLg())),
          Expanded(
            flex: 3,
            child: Text(
              copy,
              style: AppText.bodyMd().copyWith(
                color: AppColors.onSurfaceVariant,
                fontSize: 12,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              textAlign: TextAlign.right,
            ),
          ),
        ],
      ),
    );
  }
}
