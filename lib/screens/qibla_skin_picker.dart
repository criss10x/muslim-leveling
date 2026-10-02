part of 'qibla_screen.dart';

/// ── Skin picker — bottom sheet pilih 5 dial ──
/// Pola identik ThemePresetPicker: ListenableBuilder + preview dial live
/// (CustomPaint jalan nyata, azimut statis 292° NW) supaya user memilih dari
/// preview hidup, bukan nama teks. Skin aktif ditandai cek.
Future<void> showQiblaSkinPicker(BuildContext context) {
  return showModalBottomSheet<void>(
    context: context,
    backgroundColor: AppColors.surfaceContainer,
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(AppRadius.xl)),
    ),
    builder: (_) => const QiblaSkinPicker(),
  );
}

class QiblaSkinPicker extends StatelessWidget {
  const QiblaSkinPicker({super.key});

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.md),
        child: ListenableBuilder(
          listenable: qiblaSkinNotifier,
          builder: (context, _) => Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                AppL10n.of(context).qiblaSkinTitle,
                style: AppText.titleLg().copyWith(color: AppColors.onSurface),
              ),
              const SizedBox(height: AppSpacing.sm),
              Text(
                AppL10n.of(context).qiblaSkinSubtitle,
                style: AppText.bodyMd().copyWith(
                  color: AppColors.onSurfaceVariant,
                  fontSize: 12,
                ),
              ),
              const SizedBox(height: AppSpacing.md),
              SizedBox(
                height: 116,
                child: Row(
                  children: [
                    for (final skin in QiblaSkin.values) ...[
                      Expanded(child: _SkinOption(skin: skin)),
                      if (skin != QiblaSkin.values.last)
                        const SizedBox(width: AppSpacing.xs),
                    ],
                  ],
                ),
              ),
              const SizedBox(height: AppSpacing.sm),
            ],
          ),
        ),
      ),
    );
  }
}

/// Satu opsi: circular preview dial + label.
class _SkinOption extends StatelessWidget {
  const _SkinOption({required this.skin});

  final QiblaSkin skin;

  @override
  Widget build(BuildContext context) {
    final spec = specFor(skin);
    final selected = qiblaSkinNotifier.skin == skin;
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        PressableScale(
          onTap: () async {
            await qiblaSkinNotifier.setSkin(skin);
            if (context.mounted) Navigator.pop(context);
          },
          child: Container(
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(
                color: selected
                    ? AppColors.primary
                    : AppColors.outlineVariant.withValues(alpha: 0.4),
                width: selected ? 2 : 1,
              ),
            ),
            child: ClipOval(
              child: SizedBox(
                width: 92,
                height: 92,
                child: CustomPaint(
                  painter: _SkinPreviewPainter(spec: spec),
                  child: selected
                      ? Center(
                          child: Icon(
                            AppIcons.checkCircle,
                            color: AppColors.primary,
                            size: 26,
                          ),
                        )
                      : null,
                ),
              ),
            ),
          ),
        ),
        const SizedBox(height: 6),
        Text(
          skin.label.split(' ').first,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: AppText.labelCapsSm().copyWith(
            color: selected ? AppColors.primary : AppColors.onSurfaceVariant,
            fontSize: 9,
          ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }
}

/// Preview dial statis dengan azimuth 0 + bearing 292 (NW) — lebih hidup
/// daripada cukup nama skin; painter asli dipanggil dengan rotated 0.
class _SkinPreviewPainter extends CustomPainter {
  _SkinPreviewPainter({required this.spec});

  final QiblaSkinSpec spec;

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2 - 4;

    // muka dial
    final bg = Paint()
      ..shader = RadialGradient(
        colors: [spec.faceTop, spec.faceBottom],
      ).createShader(Rect.fromCircle(center: center, radius: radius));
    canvas.drawCircle(center, radius, bg);

    // ring (thin)
    canvas.drawCircle(
      center,
      radius - 2,
      Paint()
        ..color = spec.ring.withValues(alpha: 0.8)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2,
    );

    // tick 4 arah
    canvas.save();
    canvas.translate(center.dx, center.dy);
    for (var i = 0; i < 360; i += 90) {
      final angle = (i - 90) * math.pi / 180;
      final r1 = radius - 8;
      final r2 = radius - 14;
      canvas.drawLine(
        Offset(math.cos(angle) * r1, math.sin(angle) * r1),
        Offset(math.cos(angle) * r2, math.sin(angle) * r2),
        Paint()
          ..color = spec.tickMajor
          ..strokeWidth = 2,
      );
    }
    canvas.restore();

    // jarum (NW): 292° = -68deg → head di kiri-atas
    final rel = 292;       // bearing kiblat statis untuk preview
    final rad = (rel - 90) * math.pi / 180;
    final tip = Offset(
      center.dx + math.cos(rad) * (radius - 18),
      center.dy + math.sin(rad) * (radius - 18),
    );
    canvas.drawLine(
      center,
      tip,
      Paint()
        ..color = spec.needle
        ..strokeWidth = 3,
    );
    // head panah kecil
    final hh = Offset(
      center.dx + math.cos(rad) * (radius - 14),
      center.dy + math.sin(rad) * (radius - 14),
    );
    canvas.drawCircle(hh, 4, Paint()..color = spec.needle);

    // hub kecil
    canvas.drawCircle(center, 5, Paint()..color = spec.ring);
  }

  @override
  bool shouldRepaint(covariant _SkinPreviewPainter oldDelegate) =>
      oldDelegate.spec != spec;
}
