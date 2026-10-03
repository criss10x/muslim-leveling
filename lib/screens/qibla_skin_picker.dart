part of 'qibla_screen.dart';

/// ── Skin picker — bottom sheet pilih 5 dial ──
/// Preview dial hidup: painter asli dijalankan dengan azimut statis 292° (NW)
/// supaya user memilih dari bentuk dial, bukan dari nama. Skin aktif ditandai
/// cek + border primary.
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

/// Lebar tetap satu opsi preview.
///
/// Sengaja tetap, bukan `Expanded`: dengan `Row` + 5 `Expanded`, lebar tiap
/// opsi tertekan jadi ~47dp di layar 320dp sementara tingginya tetap 92dp, jadi
/// dial-nya dirender sebagai telur (rasio 1,95) dan tidak lagi terbaca sebagai
/// dial. Lebar tetap + AspectRatio menjaga bentuknya lingkaran di lebar apa pun.
const double _kSkinOptionWidth = 72;

class QiblaSkinPicker extends StatelessWidget {
  const QiblaSkinPicker({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppL10n.of(context);
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.md),
        child: ListenableBuilder(
          listenable: qiblaSkinNotifier,
          builder: (context, _) => Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                l10n.qiblaSkinTitle,
                style: AppText.titleLg().copyWith(color: AppColors.onSurface),
              ),
              const SizedBox(height: AppSpacing.xs),
              Text(
                l10n.qiblaSkinSubtitle,
                style: AppText.bodyMd().copyWith(
                  color: AppColors.onSurfaceVariant,
                  fontSize: 12,
                ),
              ),
              const SizedBox(height: AppSpacing.md),
              // Wrap: kelima opsi tetap tampil tanpa scroll di lebar berapa pun,
              // dan tiap dial tetap bulat karena lebarnya tidak lagi dipegang
              // Expanded.
              Wrap(
                spacing: AppSpacing.sm,
                runSpacing: AppSpacing.sm,
                children: [
                  for (final skin in QiblaSkin.values) _SkinOption(skin: skin),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Satu opsi: preview dial bulat + nama lengkap.
class _SkinOption extends StatelessWidget {
  const _SkinOption({required this.skin});

  final QiblaSkin skin;

  @override
  Widget build(BuildContext context) {
    final spec = specFor(skin);
    final selected = qiblaSkinNotifier.skin == skin;
    return Semantics(
      button: true,
      selected: selected,
      label: skin.label,
      child: SizedBox(
        width: _kSkinOptionWidth,
        // PressableScale membungkus dial DAN labelnya. Dulu hanya lingkarannya
        // yang bisa ditekan sementara nama skin di bawahnya display-only, jadi
        // ketukan pada label (target paling wajar) tidak melakukan apa pun.
        child: PressableScale(
          onTap: () async {
            await qiblaSkinNotifier.setSkin(skin);
            if (context.mounted) Navigator.pop(context);
          },
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Stack(
                clipBehavior: Clip.none,
                children: [
                  Container(
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: selected
                            ? AppColors.primary
                            : AppColors.outlineVariant.withValues(alpha: 0.4),
                        width: selected ? 2 : 1,
                      ),
                    ),
                    child: AspectRatio(
                      aspectRatio: 1,
                      child: ClipOval(
                        child: CustomPaint(
                          painter: _SkinPreviewPainter(spec: spec),
                        ),
                      ),
                    ),
                  ),
                  // Badge cek di sudut, bukan di tengah: centang di tengah
                  // menutupi jarum dial yang justru jadi pembeda antar skin.
                  if (selected)
                    Positioned(
                      right: 0,
                      bottom: 0,
                      child: Container(
                        padding: const EdgeInsets.all(2),
                        decoration: BoxDecoration(
                          color: AppColors.surfaceContainer,
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          AppIcons.checkCircle,
                          color: AppColors.primary,
                          size: 16,
                        ),
                      ),
                    ),
                ],
              ),
              const SizedBox(height: 6),
              Text(
                // Nama lengkap: dulu dipotong `split(' ').first` sehingga justru
                // kata yang menjelaskan karakternya yang hilang ("Antique Brass"
                // jadi "Antique", "Midnight Gold" jadi "Midnight").
                skin.label,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                textAlign: TextAlign.center,
                style: AppText.labelCapsSm().copyWith(
                  color:
                      selected ? AppColors.primary : AppColors.onSurfaceVariant,
                  fontSize: 10,
                  height: 1.25,
                ),
              ),
            ],
          ),
        ),
      ),
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
    final radius = math.min(size.width, size.height) / 2 - 4;

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
