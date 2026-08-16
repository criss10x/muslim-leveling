import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../theme/app_theme.dart';

/// Toast XP micro-reward (Delight Tier 2, micro-level):
/// pill emas slide-up + spring, bukan SnackBar sistem.
/// Grant baru menggantikan toast yang masih tampil (anti-numpuk).
OverlayEntry? _active;
AnimationController? _ctrl;

void showXpToast(BuildContext context, int xp) {
  HapticFeedback.mediumImpact();

  final overlay = Overlay.of(context, rootOverlay: true);
  _ctrl?.dispose();
  _active?.remove();

  final ctrl = AnimationController(
    vsync: overlay,
    duration: const Duration(milliseconds: 200),
  );
  _ctrl = ctrl;

  final entry = OverlayEntry(builder: (ctx) {
    final mq = MediaQuery.of(ctx);
    return IgnorePointer(
      child: AnimatedBuilder(
        animation: ctrl,
        builder: (_, __) {
          final t = Curves.elasticOut.transform(ctrl.value.clamp(0.0, 1.0));
          return Positioned(
            left: 0,
            right: 0,
            bottom: (mq.viewPadding.bottom + 76) * t + mq.viewPadding.bottom,
            child: Opacity(
              opacity: ctrl.value < 0.2 ? ctrl.value / 0.2 : 1.0,
              child: Center(
                child: Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: AppSpacing.lg, vertical: AppSpacing.xs + 2),
                  decoration: BoxDecoration(
                    color: AppColors.secondaryFixed,
                    borderRadius: BorderRadius.circular(AppRadius.pill),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.auto_awesome, size: 14, color: AppColors.onSecondary),
                      const SizedBox(width: 6),
                      Text(
                        '+$xp XP',
                        style: GoogleFonts.jetBrainsMono(
                          fontSize: 13,
                          fontWeight: FontWeight.w700,
                          letterSpacing: 0.5,
                          color: AppColors.onSecondary,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  });

  _active = entry;
  overlay.insert(entry);
  ctrl.forward();

  Future.delayed(const Duration(milliseconds: 1600), () {
    if (_active == entry && entry.mounted) {
      ctrl.reverse().whenComplete(() {
        if (entry.mounted) entry.remove();
        if (_active == entry) _active = null;
        if (_ctrl == ctrl) _ctrl = null;
      });
    }
  });
}
