import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../theme/app_theme.dart';
import '../../widgets/common.dart';
import '../../widgets/city_picker.dart';
import '../../services/game_service.dart';
import '../../services/notification_service.dart';
import '../../services/prayer_service.dart';
import 'dashboard_shell.dart';
import '../theme/app_icons.dart';

/// Onboarding 3 halaman: welcome → lokasi → pengingat.
/// Permission diminta saat tombol halaman ditekan, bukan otomatis.
class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen>
    with SingleTickerProviderStateMixin {
  final _pageCtrl = PageController();
  late final AnimationController _entry = AnimationController(
      vsync: this, duration: const Duration(milliseconds: 600))
    ..forward();
  final _nickCtrl = TextEditingController();

  int _page = 0;
  bool _busy = false;
  String? _city; // kota hasil deteksi/pilih — tampil sebagai ✓ Nama Kota

  @override
  void dispose() {
    _pageCtrl.dispose();
    _entry.dispose();
    _nickCtrl.dispose();
    super.dispose();
  }

  bool get _isLast => _page == 2;

  Future<void> _next() async {
    if (_isLast) return;
    await _pageCtrl.nextPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOutCubic);
  }

  /// Halaman 2: minta lokasi, sinkron jadwal, tampilkan ✓ kota.
  Future<void> _allowLocation() async {
    if (_busy) return;
    setState(() => _busy = true);
    try {
      final loc = await PrayerService.getCurrentLocation();
      if (!mounted) return;
      if (loc.failure != null) {
        // ponytail: jangan simpan default — tampilkan error + fallback manual.
        // Bug lama: _syncPrayerSchedule() dipanggil walau failure, dan
        // loadLocation() auto-save "Kota Jakarta" → user luar Jawa salah kota.
        ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(loc.failure!.message)));
        return;
      }
      if (loc.name != null) {
        // ponytail: pola sama dengan JadwalTab._currentLocation — saveLocation
        // saja. Fetch jadwal + simpan timings + reschedule adzan di-handle
        // listener locationVersion di HomeTab (lihat _fetchTimingsSilently).
        await PrayerService.saveLocation(loc.id!, loc.name!);
        if (!mounted) return;
        setState(() => _city = loc.name);
      }
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  /// Pilih kota manual (fallback kalau GPS ditolak/mati).
  Future<void> _pickCity() async {
    final picked = await CityPicker.show(context);
    if (picked == null) return;
    // Sama seperti _changeLocation di JadwalTab — listener yang fetch sisanya.
    await PrayerService.saveLocation(picked.id, picked.name);
    if (!mounted) return;
    setState(() => _city = picked.name);
  }

  /// Halaman 3: minta notifikasi (bila diminta), tandai onboarding selesai.
  Future<void> _finish({bool enableNotif = true}) async {
    if (_busy) return;
    setState(() => _busy = true);
    try {
      if (enableNotif) {
        try {
          await NotificationService.init();
          final granted = await NotificationService.requestPermission();
          if (granted) {
            // Sama dengan toggle Profil: tanpa exact alarm jadwal gagal,
            // tanpa battery exemption OEM (Xiaomi/Oppo/Vivo) membunuh
            // alarm saat app ditutup → notif mati diam-diam.
            await NotificationService.ensureExactAlarmPermission();
            await NotificationService.ensureBatteryUnrestricted();
            await _scheduleAdhanFromPrefs();
          }
        } catch (_) {
          // ponytail: onboarding tetap selesai; pengingat bisa diaktifkan di Profil.
        }
      }
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool('onboarding_done', true);
      final raw = _nickCtrl.text.trim();
      // P2: nama pejuang opsional — kosong → "Pejuang" (tidak dipaksa).
      final nick = raw.isEmpty ? 'Pejuang' : raw;
      await prefs.setString('nickname', nick);
      if (!mounted) return;
      Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (_) => const DashboardShell()));
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  Future<void> _scheduleAdhanFromPrefs() async {
    final location = await PrayerService.loadLocation();
    if (location == null) return;
    final schedule = await PrayerService.fetchSchedule(
        cityId: location.id, cityName: location.name);
    if (schedule != null) {
      await GameService.setTimings(Timings(
        imsak: schedule['imsak'] ?? '04:30',
        subuh: schedule['subuh'] ?? '04:42',
        terbit: schedule['terbit'] ?? '05:55',
        dhuha: schedule['dhuha'] ?? '06:20',
        dzuhur: schedule['dzuhur'] ?? '12:01',
        ashar: schedule['ashar'] ?? '15:20',
        maghrib: schedule['maghrib'] ?? '17:55',
        isya: schedule['isya'] ?? '19:08',
      ));
      await NotificationService.scheduleAdhanReminders(
          location.name, schedule);
    }
  }

  Future<void> _skip() => _finish();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Column(
          children: [
            Align(
              alignment: Alignment.centerRight,
              child: TextButton(
                style: TextButton.styleFrom(
                  // P3: textbutton default ~36px, di-bawah 48dp guideline
                  minimumSize: const Size(48, 48),
                  tapTargetSize: MaterialTapTargetSize.padded,
                ),
                onPressed: _isLast || _busy ? null : _skip,
                child: Text(
                  'Lewati',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: AppText.bodyMd().copyWith(
                    color: _isLast || _busy
                        ? AppColors.onSurfaceVariant.withValues(alpha: .4)
                        : AppColors.onSurfaceVariant,
                  ),
                ),
              ),
            ),
            Expanded(
              child: PageView(
                controller: _pageCtrl,
                physics: _busy ? const NeverScrollableScrollPhysics() : null,
                onPageChanged: (i) => setState(() {
                  _page = i;
                  _entry.forward(from: 0);
                }),
                children: [_page1(), _page2(), _page3()],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // --- halaman ---

  Widget _page1() {
    return _PageBody(
      entry: _entry,
      semanticsLabel: 'Langkah 1 dari 3: Selamat Datang',
      child: Column(
        children: [
          const Spacer(),
          const _Mascot(emoji: '🛡️'),
          const SizedBox(height: AppSpacing.md),
          // P1: live XP preview — show don't tell. Satu kartu mock
          // langsung jawab "apa itu XP?" tanpa 43 kata copy.
          const _MockXpCard(),
          const SizedBox(height: AppSpacing.md),
          Text(
            'Selamat Datang, Muslim Warrior!',
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: AppText.titleLg(),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: AppSpacing.sm),
          Text(
            'Selesaikan quest sholat, kumpulkan XP, naikkan level.',
            maxLines: 3,
            overflow: TextOverflow.ellipsis,
            style:
                AppText.bodyMd().copyWith(color: AppColors.onSurfaceVariant),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: AppSpacing.md),
          // P2: input nama opsional — tidak dipaksa, soft placeholder.
          TextField(
            controller: _nickCtrl,
            maxLength: 20,
            maxLines: 1,
            textCapitalization: TextCapitalization.words,
            style: AppText.bodyMd().copyWith(color: AppColors.onSurface),
            decoration: InputDecoration(
              hintText: 'Nama pejuang (opsional — kosong: Pejuang)',
              hintStyle: AppText.bodyMd().copyWith(
                  color: AppColors.onSurfaceVariant.withValues(alpha: 0.6)),
              isDense: true,
              contentPadding: const EdgeInsets.symmetric(
                  horizontal: 14, vertical: 12),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(AppRadius.md),
                borderSide: BorderSide(color: AppColors.outlineVariant),
              ),
              counterText: '',
            ),
          ),
          const Spacer(),
          HeroButton(
              label: 'Lanjut',
              trailingIcon: AppIcons.arrowForward,
              onPressed: _next),
          const SizedBox(height: AppSpacing.lg),
        ],
      ),
    );
  }

  Widget _page2() {
    final confirmed = _city != null;
    return _PageBody(
      entry: _entry,
      semanticsLabel: 'Langkah 2 dari 3: Lokasi',
      child: Column(
        children: [
          const Spacer(),
          const _Mascot(emoji: '📍'),
          const SizedBox(height: AppSpacing.xl),
          Text(
            'Butuh Lokasimu',
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: AppText.titleLg(),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: AppSpacing.md),
          Text(
            'Untuk menghitung jadwal sholat & arah qiblat yang akurat, '
            'kami perlu akses lokasi. Lokasi tidak dibagikan ke siapa pun — '
            'semua perhitungan terjadi di HP-mu.',
            maxLines: 6,
            overflow: TextOverflow.ellipsis,
            style:
                AppText.bodyMd().copyWith(color: AppColors.onSurfaceVariant),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: AppSpacing.md),
          if (confirmed)
            Text(
              '✓ $_city',
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: AppText.bodyMd().copyWith(color: Colors.green.shade700),
            ),
          const Spacer(),
          HeroButton(
              label: _busy
                  ? 'MENGAMBIL LOKASI...'
                  : (confirmed ? 'Lanjut' : 'Izinkan Lokasi'),
              onPressed:
                  _busy ? null : (confirmed ? _next : _allowLocation)),
          const SizedBox(height: AppSpacing.sm),
          GhostButton(
              label: 'Pilih kota manual',
              icon: AppIcons.locationCity,
              onPressed: _busy ? null : _pickCity),
          const SizedBox(height: AppSpacing.lg),
        ],
      ),
    );
  }

  Widget _page3() {
    return _PageBody(
      entry: _entry,
      semanticsLabel: 'Langkah 3 dari 3: Pengingat Adzan',
      child: Column(
        children: [
          const Spacer(),
          const _Mascot(emoji: '🔔'),
          const SizedBox(height: AppSpacing.xl),
          Text(
            'Pengingat Adzan',
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: AppText.titleLg(),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: AppSpacing.md),
          Text(
            'Biar tidak kelewat, kami kirim pengingat saat waktu sholat tiba.',
            maxLines: 3,
            overflow: TextOverflow.ellipsis,
            style:
                AppText.bodyMd().copyWith(color: AppColors.onSurfaceVariant),
            textAlign: TextAlign.center,
          ),
          const Spacer(),
          HeroButton(
              label: _busy ? 'MENYALA...' : 'Izinkan Notifikasi',
              trailingIcon: AppIcons.notificationsActiveOutlined,
              onPressed: _busy ? null : () => _finish(enableNotif: true)),
          const SizedBox(height: AppSpacing.sm),
          // P0: escape dari halaman 3 — sebelumnya Lewati di-disable tanpa
          // alternatif visible (user terjebak di permission notif).
          GhostButton(
              label: 'Lewati, nanti saja',
              icon: AppIcons.close,
              onPressed: _busy ? null : () => _finish(enableNotif: false)),
          const SizedBox(height: AppSpacing.lg),
        ],
      ),
    );
  }
}

/// Satu halaman onboarding dengan animasi fade+slide saat masuk.
/// Wrap Semantics supaya TalkBack baca 'Langkah N dari 3'.
class _PageBody extends StatelessWidget {
  final Animation<double> entry;
  final Widget child;
  final String semanticsLabel;
  const _PageBody({
    required this.entry,
    required this.child,
    required this.semanticsLabel,
  });

  @override
  Widget build(BuildContext context) {
    final fade = CurvedAnimation(parent: entry, curve: Curves.easeOutCubic);
    return Semantics(
      container: true,
      label: semanticsLabel,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24),
        child: FadeTransition(
          opacity: fade,
          child: SlideTransition(
            position: Tween(begin: const Offset(0, 0.04), end: Offset.zero)
                .animate(fade),
            child: child,
          ),
        ),
      ),
    );
  }
}

/// Mock XP card — preview loop 'sholat → XP' di page 1.
/// ponytail: reuses surfaceContainer/primary tokens, no new widgets.
class _MockXpCard extends StatelessWidget {
  const _MockXpCard();

  @override
  Widget build(BuildContext context) {
    return Semantics(
      label: 'Contoh: Subuh selesai, ditambah 50 XP',
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        decoration: BoxDecoration(
          color: AppColors.surfaceContainer,
          borderRadius: BorderRadius.circular(AppRadius.lg),
          border: Border.all(color: AppColors.primary.withValues(alpha: 0.25)),
          boxShadow: [
            BoxShadow(
              color: AppColors.primary.withValues(alpha: 0.12),
              blurRadius: 10,
              spreadRadius: 1,
            ),
          ],
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(AppIcons.checkCircle, size: 18, color: AppColors.primary),
            const SizedBox(width: 8),
            Text(
              'Subuh ✓',
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: AppText.labelCaps().copyWith(color: AppColors.onSurface),
            ),
            const SizedBox(width: 10),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 4),
              decoration: BoxDecoration(
                color: AppColors.primary,
                borderRadius: BorderRadius.circular(99),
              ),
              child: Text(
                '+50 XP',
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: AppText.labelCapsSm()
                    .copyWith(color: AppColors.surfaceContainerLowest),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _Mascot extends StatelessWidget {
  final String emoji;
  const _Mascot({required this.emoji});

  @override
  Widget build(BuildContext context) => CircleAvatar(
        radius: 64,
        backgroundColor: AppColors.surfaceContainerHigh,
        child: Text(emoji, style: const TextStyle(fontSize: 64)),
      );
}
