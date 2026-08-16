import 'dart:async';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../theme/app_theme.dart';
import '../../widgets/common.dart';
import 'onboarding_screen.dart';
import 'dashboard_shell.dart';

/// Splash screen — pulsing shield + animated loading bar.
/// Logo, copy, and progress enter once before routing.
class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with TickerProviderStateMixin {
  late final AnimationController _entryCtl;
  late final AnimationController _barCtl;
  Timer? _navTimer;

  @override
  void initState() {
    super.initState();
    _entryCtl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 450),
    )..forward();
    _barCtl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 850),
    )..forward();
    _navTimer = Timer(const Duration(milliseconds: 900), _navigate);
  }

  Future<void> _navigate() async {
    var hasProfile = false;
    try {
      if (mounted) {
        final prefs = await SharedPreferences.getInstance();
        final done = prefs.getBool('onboarding_done') ?? false;
        final nickname = prefs.getString('nickname');
        hasProfile = done && nickname != null && nickname.isNotEmpty;
      }
    } catch (_) {
      // ponytail: onboarding is the safe fallback when local prefs fail.
    }
    if (!mounted) return;
    Navigator.of(context).pushReplacement(
      PageRouteBuilder(
        pageBuilder: (_, __, ___) =>
            hasProfile ? const DashboardShell() : const OnboardingScreen(),
        transitionsBuilder: (_, anim, __, child) =>
            FadeTransition(opacity: anim, child: child),
        transitionDuration: const Duration(milliseconds: 200),
      ),
    );
  }

  @override
  void dispose() {
    _entryCtl.dispose();
    _barCtl.dispose();
    _navTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final logoEntry = CurvedAnimation(
      parent: _entryCtl,
      curve: const Interval(0, 0.4, curve: Curves.easeOutCubic),
    );
    final copyEntry = CurvedAnimation(
      parent: _entryCtl,
      curve: const Interval(0.27, 1, curve: Curves.easeOutCubic),
    );
    return Scaffold(
      backgroundColor: AppColors.background,
      body: AmbientBackground(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                FadeTransition(
                  opacity: logoEntry,
                  child: ScaleTransition(
                    scale: Tween<double>(
                      begin: 0.96,
                      end: 1,
                    ).animate(logoEntry),
                    child: AnimatedBuilder(
                      animation: _entryCtl,
                      builder: (_, __) {
                        final t = _entryCtl.value;
                        final light = isLightTheme;
                        return Container(
                          key: const Key('splash-logo-card'),
                          width: 120,
                          height: 120,
                          decoration: BoxDecoration(
                            // Light: white raised card + hairline. Dark: surface + neon pulse.
                            color: light
                                ? AppColors.surfaceContainerLowest
                                : AppColors.surfaceContainer,
                            borderRadius: BorderRadius.circular(28),
                            border: Border.all(
                              color: light
                                  ? AppColors.primary.withValues(
                                      alpha: 0.45 + 0.25 * t,
                                    )
                                  : AppColors.primary.withValues(
                                      alpha: 0.3 + 0.2 * t,
                                    ),
                              width: light ? 1.5 : 2,
                            ),
                            // Glow pulse: dark-only. Light stays flat (Strava).
                            boxShadow: light
                                ? null
                                : [
                                    BoxShadow(
                                      color: AppColors.primary.withValues(
                                        alpha: 0.12 + 0.18 * t,
                                      ),
                                      blurRadius: 20,
                                      spreadRadius: 2,
                                    ),
                                  ],
                          ),
                          child: ColorFiltered(
                            colorFilter: ColorFilter.mode(
                              AppColors.primary,
                              BlendMode.srcIn,
                            ),
                            child: Image.asset(
                              'assets/images/logo_mark.png',
                              width: 64,
                              height: 64,
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                ),
                const SizedBox(height: AppSpacing.xl),
                // Light: deep emerald ink title. Dark: neon gradient mask.
                FadeTransition(
                  opacity: copyEntry,
                  child: SlideTransition(
                    position: Tween<Offset>(
                      begin: const Offset(0, 0.04),
                      end: Offset.zero,
                    ).animate(copyEntry),
                    child: isLightTheme
                        ? Text(
                            'MUSLIM LEVELING',
                            textAlign: TextAlign.center,
                            style: AppText.displayHero(40).copyWith(
                              color: AppColors.primary,
                              letterSpacing: -0.5,
                            ),
                          )
                        : ShaderMask(
                            shaderCallback: (rect) => LinearGradient(
                              colors: [
                                AppColors.primary,
                                AppColors.primaryFixed,
                              ],
                            ).createShader(rect),
                            child: Text(
                              'MUSLIM LEVELING',
                              textAlign: TextAlign.center,
                              style: AppText.displayHero(40).copyWith(
                                color: Colors.white,
                                letterSpacing: -0.5,
                              ),
                            ),
                          ),
                  ),
                ),
                const SizedBox(height: AppSpacing.sm),
                // Light: body ink for punch. onSurfaceVariant fades into canvas.
                FadeTransition(
                  opacity: copyEntry,
                  child: Text(
                    'Level Up iman, Level Up Kehidupanmu',
                    textAlign: TextAlign.center,
                    style: AppText.bodyMd().copyWith(
                      color: AppColors.onSurface,
                    ),
                  ),
                ),
                const SizedBox(height: AppSpacing.xl),
                SizedBox(
                  width: 200,
                  child: AnimatedBuilder(
                    animation: _barCtl,
                    builder: (_, __) => Stack(
                      children: [
                        Container(
                          height: 4,
                          decoration: BoxDecoration(
                            // Light track needs stronger inset vs canvas #E8EAED.
                            color: isLightTheme
                                ? AppColors.surfaceContainerHighest
                                : AppColors.surfaceContainerHigh,
                            borderRadius: BorderRadius.circular(2),
                          ),
                        ),
                        FractionallySizedBox(
                          key: const Key('splash-progress-fill'),
                          widthFactor: const Interval(
                            0.35,
                            1,
                            curve: Curves.easeOutCubic,
                          ).transform(_barCtl.value),
                          child: Container(
                            height: 4,
                            decoration: BoxDecoration(
                              // Light: solid deep primary (AA, no neon mint tail).
                              // Dark: neon jade→cyan brand flair.
                              color: isLightTheme ? AppColors.primary : null,
                              gradient: isLightTheme
                                  ? null
                                  : LinearGradient(
                                      colors: [
                                        AppColors.primary,
                                        AppColors.tertiary,
                                      ],
                                    ),
                              borderRadius: BorderRadius.circular(2),
                              boxShadow: isLightTheme
                                  ? null
                                  : [
                                      BoxShadow(
                                        color: AppColors.primary.withValues(
                                          alpha: 0.6,
                                        ),
                                        blurRadius: 8,
                                      ),
                                    ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: AppSpacing.md),
                Padding(
                  padding: const EdgeInsets.only(bottom: AppSpacing.md),
                  child: Text(
                    'v1.0.0', // ponytail: update when cutting release
                    style: AppText.labelCapsSm().copyWith(
                      color: AppColors.onSurfaceVariant.withValues(alpha: 0.6),
                    ),
                  ),
                ),
                Text(
                  'MEMUAT DATA PEJUANG...',
                  style: AppText.labelCaps().copyWith(
                    color: AppColors.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
