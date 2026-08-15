import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../theme/app_theme.dart';
import '../../widgets/common.dart';
import '../../widgets/city_picker.dart';
import '../../services/game_service.dart';
import '../../services/notification_service.dart';
import '../../services/prayer_service.dart';
import 'dashboard_shell.dart';

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

  int _page = 0;
  bool _busy = false;
  String? _city; // kota hasil deteksi/pilih — tampil sebagai ✓ Nama Kota

  @override
  void dispose() {
    _pageCtrl.dispose();
    _entry.dispose();
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
          if (granted) await _scheduleAdhanFromPrefs();
        } catch (_) {
          // ponytail: onboarding tetap selesai; pengingat bisa diaktifkan di Profil.
        }
      }
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool('onboarding_done', true);
      await prefs.setString('nickname', 'Pejuang');
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
                onPressed: _isLast || _busy ? null : _skip,
                child: Text('Lewati',
                    style: AppText.bodyMd().copyWith(
                        color: _isLast || _busy
                            ? AppColors.onSurfaceVariant.withValues(alpha: .4)
                            : AppColors.onSurfaceVariant)),
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
      child: Column(
        children: [
          const Spacer(),
          const _Mascot(emoji: '🛡️'),
          const SizedBox(height: AppSpacing.xl),
          Text('Selamat Datang, Muslim Warrior!',
              style: AppText.titleLg(), textAlign: TextAlign.center),
          const SizedBox(height: AppSpacing.md),
          Text(
            'Muslim Leveling mengubah perjalanan ibadahmu jadi petualangan. '
            'Selesaikan quest sholat, kumpulkan XP, naikkan level — '
            'bangun kebiasaan sholat konsisten sedikit demi sedikit.',
            style:
                AppText.bodyMd().copyWith(color: AppColors.onSurfaceVariant),
            textAlign: TextAlign.center,
          ),
          const Spacer(),
          HeroButton(
              label: 'Lanjut',
              trailingIcon: Icons.arrow_forward,
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
      child: Column(
        children: [
          const Spacer(),
          const _Mascot(emoji: '📍'),
          const SizedBox(height: AppSpacing.xl),
          Text('Butuh Lokasimu',
              style: AppText.titleLg(), textAlign: TextAlign.center),
          const SizedBox(height: AppSpacing.md),
          Text(
            'Untuk menghitung jadwal sholat & arah qiblat yang akurat, '
            'kami perlu akses lokasi. Lokasi tidak dibagikan ke siapa pun — '
            'semua perhitungan terjadi di HP-mu.',
            style:
                AppText.bodyMd().copyWith(color: AppColors.onSurfaceVariant),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: AppSpacing.md),
          if (confirmed)
            Text('✓ $_city',
                style:
                    AppText.bodyMd().copyWith(color: Colors.green.shade700)),
          const Spacer(),
          HeroButton(
              label: _busy
                  ? 'MENGAMBIL LOKASI...'
                  : (confirmed ? 'Lanjut' : 'Izinkan Lokasi'),
              onPressed: _busy ? null : (confirmed ? _next : _allowLocation)),
          const SizedBox(height: AppSpacing.sm),
          GhostButton(
              label: 'Pilih kota manual',
              icon: Icons.location_city,
              onPressed: _busy ? null : _pickCity),
          const SizedBox(height: AppSpacing.lg),
        ],
      ),
    );
  }

  Widget _page3() {
    return _PageBody(
      entry: _entry,
      child: Column(
        children: [
          const Spacer(),
          const _Mascot(emoji: '🔔'),
          const SizedBox(height: AppSpacing.xl),
          Text('Pengingat Adzan',
              style: AppText.titleLg(), textAlign: TextAlign.center),
          const SizedBox(height: AppSpacing.md),
          Text(
            'Biar tidak kelewat, kami kirim pengingat saat waktu sholat tiba.',
            style:
                AppText.bodyMd().copyWith(color: AppColors.onSurfaceVariant),
            textAlign: TextAlign.center,
          ),
          const Spacer(),
          HeroButton(
              label: _busy ? 'MENYALA...' : 'Izinkan Notifikasi',
              trailingIcon: Icons.notifications_active_outlined,
              onPressed: _busy ? null : () => _finish(enableNotif: true)),
          const SizedBox(height: AppSpacing.lg),
        ],
      ),
    );
  }
}

/// Satu halaman onboarding dengan animasi fade+slide saat masuk.
class _PageBody extends StatelessWidget {
  final Animation<double> entry;
  final Widget child;
  const _PageBody({required this.entry, required this.child});

  @override
  Widget build(BuildContext context) {
    final fade = CurvedAnimation(parent: entry, curve: Curves.easeOutCubic);
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: FadeTransition(
        opacity: fade,
        child: SlideTransition(
          position: Tween(begin: const Offset(0, 0.04), end: Offset.zero)
              .animate(fade),
          child: child,
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
