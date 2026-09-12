import 'dart:async';
import 'package:flutter/material.dart';
import '../../theme/app_theme.dart';
import '../../widgets/common.dart';
import '../../widgets/city_picker.dart';
import '../../services/prayer_service.dart';
import '../../services/game_service.dart';
import '../../services/notification_service.dart';
import '../../services/hijri_service.dart';
import 'qibla_screen.dart';
import 'hari_penting_screen.dart';
import '../theme/app_icons.dart';

/// Jadwal Sholat — V3 logic ported to V1 design.
/// Shows next prayer countdown, 5 daily prayers with logged status,
/// and info card about data source.
class JadwalTab extends StatefulWidget {
  const JadwalTab({super.key});

  @override
  State<JadwalTab> createState() => _JadwalTabState();
}

class _JadwalTabState extends State<JadwalTab> {
  Map<String, String>? _jadwal;
  String _cityName = 'Jakarta';
  String _cityId = '';
  bool _loading = true;
  String? _error;
  HijriDay? _hijriToday;
  // Mode suara per sholat (override global Profil). Dimuat di _loadAndFetch
  // karena prefs async; dipakai sinkron di _schedule().
  Map<String, String> _perPrayerSounds = {};
  String _globalSound = 'adzan';
  String _adzanVariant = 'adzan';
  // Varian yang sedang diunduh (null = tidak ada).
  String? _downloadingVariant;

  @override
  void initState() {
    super.initState();
    _loadAndFetch();
    // ponytail: fire-and-forget — tanggal Hijriah hari ini untuk strip header.
    unawaited(_loadHijriToday());
    // Refetch saat kota diganti dari tab lain (profil/onboarding).
    PrayerService.locationVersion.addListener(_loadAndFetch);
    // Rebuild status "sudah dilog" saat sholat dicentang di tab Home.
    GameService.stateVersion.addListener(_onStateChanged);
  }

  Future<void> _loadHijriToday() async {
    final d = await hijriService.today();
    if (mounted) setState(() => _hijriToday = d);
  }

  @override
  void dispose() {
    PrayerService.locationVersion.removeListener(_loadAndFetch);
    GameService.stateVersion.removeListener(_onStateChanged);
    super.dispose();
  }

  void _onStateChanged() {
    if (mounted) setState(() {});
  }

  Future<void> _loadAndFetch() async {
    // Mode suara per sholat bisa berubah dari tab Profil (global) atau
    // bottom sheet di tab ini — selalu refresh supaya icon sinkron.
    final sounds = await NotificationService.getPerPrayerSounds();
    final global = await NotificationService.getSoundMode();
    final variant = await NotificationService.getAdzanVariant();
    if (mounted) {
      setState(() {
        _perPrayerSounds = sounds;
        _globalSound = global;
        _adzanVariant = variant;
      });
    }
    final loc = await PrayerService.loadLocation();
    // loadLocation() sekarang selalu return non-null (default Jakarta).
    _cityId = loc!.id;
    _cityName = loc.name;
    await _fetch();
  }

  Future<void> _changeLocation() async {
    final picked = await CityPicker.show(context);
    if (picked == null) return;
    // saveLocation membump locationVersion → _loadAndFetch jalan via listener
    // (sekalian home_tab ikut refresh timing + reschedule notif adzan).
    await PrayerService.saveLocation(picked.id, picked.name);
  }

  Future<void> _fetch() async {
    if (_cityId.isEmpty) return _loadAndFetch();
    setState(() {
      _loading = true;
      _error = null;
    });
    final j = await PrayerService.fetchSchedule(
      cityId: _cityId,
      cityName: _cityName,
    );
    if (!mounted) return;
    if (j != null) {
      await GameService.setTimings(
        Timings(
          imsak: j['imsak'] ?? '04:30',
          subuh: j['subuh'] ?? '04:42',
          terbit: j['terbit'] ?? '05:55',
          dhuha: j['dhuha'] ?? '06:20',
          dzuhur: j['dzuhur'] ?? '12:01',
          ashar: j['ashar'] ?? '15:20',
          maghrib: j['maghrib'] ?? '17:55',
          isya: j['isya'] ?? '19:08',
        ),
      );
    }
    setState(() {
      _loading = false;
      _jadwal = j;
      if (j == null) {
        _error = 'Gagal memuat jadwal. Periksa koneksi.';
      } else if (j['lokasi']?.isNotEmpty == true) {
        _cityName = j['lokasi']!;
      }
    });
  }

  String _todayLabel() {
    final d = DateTime.now();
    const months = [
      'Januari',
      'Februari',
      'Maret',
      'April',
      'Mei',
      'Juni',
      'Juli',
      'Agustus',
      'September',
      'Oktober',
      'November',
      'Desember',
    ];
    const days = [
      'Senin',
      'Selasa',
      'Rabu',
      'Kamis',
      'Jumat',
      'Sabtu',
      'Minggu',
    ];
    return '${days[d.weekday - 1]}, ${d.day} ${months[d.month - 1]} ${d.year}';
  }

  /// Compute next prayer name, time, and countdown (port V3 logic).
  ({String name, String time, String countdown}) _nextPrayer() {
    final j = _jadwal;
    if (j == null || _loading) {
      return (name: '—', time: '--:--', countdown: 'memuat...');
    }

    final now = TimeOfDay.now();
    final prayers = [
      ('Subuh', j['subuh'] ?? ''),
      ('Dzuhur', j['dzuhur'] ?? ''),
      ('Ashar', j['ashar'] ?? ''),
      ('Maghrib', j['maghrib'] ?? ''),
      ('Isya', j['isya'] ?? ''),
    ];

    final minsNow = now.hour * 60 + now.minute;

    for (final p in prayers) {
      if (p.$2.isEmpty) continue;
      final parts = p.$2.split(':');
      if (parts.length != 2) continue;
      final h = int.tryParse(parts[0]) ?? 0;
      final m = int.tryParse(parts[1]) ?? 0;
      final minsP = h * 60 + m;
      if (minsP > minsNow) {
        final diff = minsP - minsNow;
        final hh = diff ~/ 60;
        final mm = diff % 60;
        final countdown = hh > 0 ? '${hh}j ${mm}m lagi' : '${mm}m lagi';
        return (name: p.$1, time: p.$2, countdown: countdown);
      }
    }

    // All passed → Subuh tomorrow
    return (name: 'Subuh', time: j['subuh'] ?? '04:42', countdown: 'besok');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: SafeArea(
        bottom: false,
        child: RefreshIndicator(
          color: AppColors.primary,
          onRefresh: _fetch,
          child: ListView(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: const EdgeInsets.only(bottom: 100),
            children: [
              const SizedBox(height: AppSpacing.lg),
              _header(),
              const SizedBox(height: AppSpacing.lg),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
                child: _nextPrayerCard(),
              ),
              const SizedBox(height: AppSpacing.sm),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
                child: _qiblaButton(),
              ),
              const SizedBox(height: AppSpacing.lg),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
                child: _schedule(),
              ),
              const SizedBox(height: AppSpacing.lg),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
                child: _adzanSoundCard(),
              ),
              const SizedBox(height: AppSpacing.lg),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
                child: _infoCard(),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _header() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Waktu Sholat',
            style: AppText.displayHero(32).copyWith(color: AppColors.onSurface),
          ),
          const SizedBox(height: 4),
          Text(
            _todayLabel(),
            style: AppText.bodyMd().copyWith(color: AppColors.onSurfaceVariant),
          ),
          // Tombol Hari Penting Islam — selalu render (data statis,
          // tidak perlu API). Fallback label kalau tanggal hijriah gagal
          // dimuat; kalau berhasil tampilkan tanggal sebagai affordance.
          const SizedBox(height: AppSpacing.sm),
          _hariPentingButton(),
          const SizedBox(height: AppSpacing.sm),
          Row(
            children: [
              _locationIconButton(onTap: _currentLocation),
              const SizedBox(width: AppSpacing.sm),
              Expanded(
                child: _locationButton(
                  icon: AppIcons.search,
                  label: 'Cari Kota',
                  onTap: _changeLocation,
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.xs),
          Text(
            _cityName,
            style: AppText.labelCaps().copyWith(
              color: AppColors.onSurfaceVariant,
              fontSize: 11,
            ),
          ),
        ],
      ),
    );
  }

  Widget _locationButton({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
  }) {
    return PressableScale(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.sm,
          vertical: AppSpacing.sm + 2,
        ),
        decoration: BoxDecoration(
          color: AppColors.surfaceContainerLow,
          borderRadius: BorderRadius.circular(AppRadius.xl),
          border: Border.all(
            color: AppColors.outlineVariant.withValues(alpha: 0.3),
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 16, color: AppColors.primary),
            const SizedBox(width: AppSpacing.xs),
            Flexible(
              child: Text(
                label,
                style: AppText.labelCaps().copyWith(
                  color: AppColors.onSurface,
                  fontSize: 11,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _locationIconButton({required VoidCallback onTap}) {
    return PressableScale(
      onTap: onTap,
      child: SizedBox.square(
        dimension: 44,
        child: DecoratedBox(
          decoration: BoxDecoration(
            color: AppColors.surfaceContainerLow,
            borderRadius: BorderRadius.circular(AppRadius.xl),
            border: Border.all(
              color: AppColors.outlineVariant.withValues(alpha: 0.3),
            ),
          ),
          child: Icon(AppIcons.myLocation, size: 18, color: AppColors.primary),
        ),
      ),
    );
  }

  /// Tombol Hari Penting Islam — pill konsisten dengan tombol lokasi.
  /// Selalu render: data statis (hijriImportantDates const), tidak di-gate
  /// API hijriah. Kalau tanggal berhasil dimuat tampilkan sebagai affordance,
  /// kalau gagal tampilkan label netral 'Hari Penting Islam'.
  /// Touch target ≥44px (SizedBox height 44 + padding horizontal).
  /// Semantics label eksplisit untuk TalkBack.
  Widget _hariPentingButton() {
    final label = _hijriToday != null
        ? hijriLabel(_hijriToday!)
        : 'Hari Penting Islam';
    return Semantics(
      button: true,
      label: 'Tanggal Hijriah, buka Hari Penting Islam',
      child: PressableScale(
        onTap: () => Navigator.of(context).push(MaterialPageRoute(
          builder: (_) => const HariPentingScreen(),
        )),
        child: Container(
          height: 44,
          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.sm + 2),
          decoration: BoxDecoration(
            color: AppColors.surfaceContainerLow,
            borderRadius: BorderRadius.circular(AppRadius.xl),
            border: Border.all(
              color: AppColors.outlineVariant.withValues(alpha: 0.3),
            ),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(AppIcons.calendarMonth, size: 16, color: AppColors.primary),
              const SizedBox(width: AppSpacing.xs),
              Text(
                label,
                style: AppText.bodyMd().copyWith(
                  color: AppColors.primary,
                  fontSize: 12,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _currentLocation() async {
    // GPS → save → auto-refresh via listener
    final result = await PrayerService.getCurrentLocation();
    if (result.failure != null) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            result.failure!.message,
            style: AppText.bodyMd().copyWith(color: AppColors.onSurface),
          ),
          backgroundColor: AppColors.surfaceContainerLowest,
        ),
      );
      return;
    }
    await PrayerService.saveLocation(result.id!, result.name!);
  }

  Widget _qiblaButton() {
    return PressableScale(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => QiblaScreen(cityName: _cityName)),
        );
      },
      // Tint gold tenang — kiblat = item spesial tab ini, tapi bukan hero.
      child: Container(
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.md,
          vertical: AppSpacing.sm + 2,
        ),
        decoration: BoxDecoration(
          color: AppColors.secondaryContainer.withValues(alpha: 0.10),
          borderRadius: BorderRadius.circular(AppRadius.xxl),
        ),
        child: Row(
          children: [
            Icon(AppIcons.explore, size: 22, color: AppColors.secondaryFixed),
            const SizedBox(width: AppSpacing.sm),
            Text(
              'Kompas Kiblat',
              style: AppText.titleLg().copyWith(
                fontSize: 15,
                color: AppColors.onSurface,
              ),
            ),
            const Spacer(),
            Icon(
              AppIcons.arrowForwardIos,
              size: 14,
              color: AppColors.secondaryFixed,
            ),
          ],
        ),
      ),
    );
  }

  Widget _nextPrayerCard() {
    final next = _nextPrayer();
    // Solid raised + primary tint/glow — same language as Home/Belajar/Profil.
    final light = isLightTheme;
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(AppRadius.xxl),
        boxShadow: light
            ? null
            : [
                BoxShadow(
                  color: AppColors.primary.withValues(alpha: 0.22),
                  blurRadius: 28,
                  offset: const Offset(0, 10),
                ),
              ],
      ),
      child: Container(
        padding: const EdgeInsets.all(AppSpacing.lg),
        decoration: BoxDecoration(
          color: AppColors.surfaceContainerLow,
          gradient: light
              ? null
              : LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    AppColors.primary.withValues(alpha: 0.14),
                    AppColors.surfaceContainerLow,
                  ],
                ),
          borderRadius: BorderRadius.circular(AppRadius.xxl),
          border: Border.all(
            color: AppColors.primary.withValues(alpha: light ? 0.35 : 0.45),
          ),
        ),
        child: _loading
            ? Center(
                child: Padding(
                  padding: const EdgeInsets.all(24),
                  child: CircularProgressIndicator(color: AppColors.primary),
                ),
              )
            : _error != null
            ? Center(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    children: [
                      Icon(AppIcons.cloudOff, color: AppColors.error, size: 32),
                      const SizedBox(height: 8),
                      Text(
                        _error!,
                        textAlign: TextAlign.center,
                        style: AppText.bodyMd().copyWith(
                          color: AppColors.onSurfaceVariant,
                        ),
                      ),
                      const SizedBox(height: 8),
                      TextButton(
                        onPressed: _fetch,
                        child: Text(
                          'Coba lagi',
                          style: AppText.bodyMd().copyWith(
                            color: AppColors.primary,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              )
            : Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'SHOLAT BERIKUTNYA',
                            style: AppText.labelCaps().copyWith(
                              color: AppColors.primary,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            next.name,
                            style: AppText.headlineLg().copyWith(
                              color: AppColors.onSurface,
                            ),
                          ),
                        ],
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: AppSpacing.sm,
                          vertical: 6,
                        ),
                        decoration: BoxDecoration(
                          color: AppColors.secondaryFixed.withValues(
                            alpha: 0.12,
                          ),
                          borderRadius: BorderRadius.circular(AppRadius.pill),
                          border: Border.all(
                            color: AppColors.secondaryFixed.withValues(
                              alpha: 0.35,
                            ),
                          ),
                        ),
                        child: Row(
                          children: [
                            Icon(
                              AppIcons.timer,
                              size: 14,
                              color: AppColors.secondaryFixed,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              next.countdown,
                              style: AppText.labelCaps().copyWith(
                                color: AppColors.secondaryFixed,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: AppSpacing.md),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      light
                          ? Text(
                              next.time,
                              style: AppText.displayHero(
                                40,
                              ).copyWith(color: AppColors.primary),
                            )
                          : ShaderMask(
                              shaderCallback: (rect) => LinearGradient(
                                colors: [
                                  AppColors.primary,
                                  AppColors.primaryFixed,
                                ],
                              ).createShader(rect),
                              child: Text(
                                next.time,
                                style: AppText.displayHero(
                                  40,
                                ).copyWith(color: Colors.white),
                              ),
                            ),
                      Container(
                        width: 40,
                        height: 40,
                        decoration: BoxDecoration(
                          color: AppColors.primary.withValues(alpha: 0.15),
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: AppColors.primary.withValues(alpha: 0.45),
                          ),
                        ),
                        child: Icon(
                          AppIcons.notificationsActive,
                          color: AppColors.primary,
                          size: 20,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
      ),
    );
  }

  Widget _schedule() {
    final j = _jadwal;
    final now = TimeOfDay.now();
    final next = _nextPrayer();
    final minsNow = now.hour * 60 + now.minute;

    ({
      String name,
      String id,
      String time,
      IconData icon,
      bool isNext,
      bool isLogged,
    })
    row(String name, String id, String time, IconData icon) {
      if (time.isEmpty) {
        return (
          name: name,
          id: id,
          time: '--:--',
          icon: icon,
          isNext: false,
          isLogged: false,
        );
      }
      final parts = time.split(':');
      if (parts.length != 2) {
        return (
          name: name,
          id: id,
          time: time,
          icon: icon,
          isNext: false,
          isLogged: false,
        );
      }
      final h = int.tryParse(parts[0]) ?? 0;
      final m = int.tryParse(parts[1]) ?? 0;
      final mins = h * 60 + m;
      final isNext = name == next.name && mins > minsNow;
      final isLogged = GameService.isPrayerCheckedToday(id);
      return (
        name: name,
        id: id,
        time: time,
        icon: icon,
        isNext: isNext,
        isLogged: isLogged,
      );
    }

    final items = [
      row('Imsak', 'imsak', j?['imsak'] ?? '', AppIcons.hourglassSimple),
      row('Subuh', 'subuh', j?['subuh'] ?? '', AppIcons.wbTwilight),
      row('Terbit', 'terbit', j?['terbit'] ?? '', AppIcons.sunDim),
      row('Dzuhur', 'dzuhur', j?['dzuhur'] ?? '', AppIcons.wbSunny),
      row('Ashar', 'ashar', j?['ashar'] ?? '', AppIcons.wbCloudy),
      row('Maghrib', 'maghrib', j?['maghrib'] ?? '', AppIcons.wbTwilight),
      row('Isya', 'isya', j?['isya'] ?? '', AppIcons.nightlight),
    ];

    final logged = items.where((it) => it.isLogged).length;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        HudHeader(
          'JADWAL HARI INI',
          meta: '$logged/5',
          accent: logged == 5 ? AppColors.primary : null,
        ),
        ...items.map(
          (it) => Padding(
            padding: const EdgeInsets.only(bottom: AppSpacing.xs),
            child: _scheduleRow(
              it.name,
              it.time,
              it.icon,
              it.isNext,
              it.isLogged,
              it.id,
              _perPrayerSounds[it.id] ?? _globalSound,
            ),
          ),
        ),
      ],
    );
  }

  Widget _scheduleRow(
    String name,
    String time,
    IconData icon,
    bool isNext,
    bool isLogged,
    String prayerId,
    String sound,
  ) {
    // ponytail: imsak & terbit selalu senyap — tap tidak membuka picker suara,
    // jadi tidak ada jalan bagi user untuk memberi suara ke keduanya.
    final isMarker = _markerIds.contains(prayerId);
    final iconColor = isNext
        ? AppColors.tertiary
        : isLogged
        ? AppColors.primary
        : AppColors.onSurfaceVariant;

    return GestureDetector(
      // ponytail: seluruh row = buka setting suara sholat ini (picker sama
      // dengan icon kanan). Tap target lebih besar, icon tetap visual cue.
      onTap: isMarker ? null : () => _showSoundPicker(prayerId, sound),
      behavior: HitTestBehavior.opaque,
      child: Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.md,
        vertical: AppSpacing.sm,
      ),
      decoration: BoxDecoration(
        color: isNext
            ? AppColors.tertiary.withValues(alpha: 0.06)
            : AppColors.surfaceContainerLow,
        borderRadius: BorderRadius.circular(AppRadius.xxl),
        border: isNext
            ? Border.all(color: AppColors.tertiary.withValues(alpha: 0.5))
            : null,
      ),
      child: Row(
        children: [
          Icon(icon, color: iconColor, size: 22),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  name,
                  style: AppText.titleLg().copyWith(
                    fontSize: 16,
                    color: isLogged
                        ? AppColors.onSurfaceVariant
                        : AppColors.onSurface,
                  ),
                ),
                if (isNext)
                  Text(
                    'BERIKUTNYA',
                    style: AppText.labelCaps().copyWith(
                      color: AppColors.tertiary,
                      fontSize: 9,
                    ),
                  )
                else if (isLogged)
                  Text(
                    '✓ SUDAH DILOG',
                    style: AppText.labelCaps().copyWith(
                      color: AppColors.primary.withValues(alpha: 0.7),
                      fontSize: 9,
                    ),
                  ),
              ],
            ),
          ),
          Text(
            time,
            style: TextStyle(
              fontFamily: 'monospace',
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: isNext ? AppColors.tertiary : AppColors.onSurface,
            ),
          ),
          const SizedBox(width: AppSpacing.sm),
          _soundIcon(sound, prayerId),
        ],
      ),
      ),
    );
  }

  // ponytail: imsak & terbit — penanda waktu, selalu senyap, tanpa picker.
  static const _markerIds = {'imsak', 'terbit'};

  // Ikon mode suara di kanan tiap baris sholat. Tap = buka picker.
  static const _soundIcons = {
    'senyap': (AppIcons.volumeOffRounded, 'Senyap'),
    'suara': (AppIcons.notificationsRounded, 'Suara'),
    'adzan': (AppIcons.volumeUpRounded, 'Adzan'),
  };

  Widget _soundIcon(String sound, String prayerId) {
    // Marker (imsak/terbit) selalu senyap: tampilkan ikon volume-off statis,
    // bukan kontrol yang bisa di-tap.
    if (_markerIds.contains(prayerId)) {
      return Icon(
        AppIcons.volumeOffRounded,
        size: 20,
        color: AppColors.onSurfaceVariant.withValues(alpha: 0.5),
      );
    }
    final (iconData, label) = _soundIcons[sound] ??
        (AppIcons.notificationsNoneRounded, 'Mengikuti global');
    return GestureDetector(
      onTap: () => _showSoundPicker(prayerId, sound),
      child: Icon(iconData, size: 20, color: AppColors.onSurfaceVariant),
    );
  }

  void _showSoundPicker(String prayerId, String current) {
    // true = sholat ini punya override eksplisit; false = ikut global.
    final isOverride = _perPrayerSounds.containsKey(prayerId);
    showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.surfaceContainerHigh,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(AppRadius.lg)),
      ),
      builder: (ctx) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.lg,
            vertical: AppSpacing.md,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Notifikasi $prayerId',
                style: AppText.titleLg().copyWith(
                  color: AppColors.onSurface,
                ),
              ),
              const SizedBox(height: AppSpacing.md),
              _soundOption(prayerId, isOverride && current == 'senyap', 'senyap',
                  AppIcons.volumeOffRounded, 'Senyap — tanpa suara'),
              _soundOption(prayerId, isOverride && current == 'suara', 'suara',
                  AppIcons.notificationsRounded, 'Suara — notifikasi standar HP'),
              _soundOption(prayerId, isOverride && current == 'adzan', 'adzan',
                  AppIcons.volumeUpRounded, 'Adzan — suara adzan penuh'),
              _soundOption(
                prayerId,
                !isOverride,
                _globalSound,
                AppIcons.notificationsNoneRounded,
                'Ikuti pengaturan global',
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _soundOption(String prayerId, bool selected, String value,
      IconData icon, String label) {
    return InkWell(
      onTap: () async {
        Navigator.pop(context);
        // value == _globalSound → hapus override agar kembali ikut global.
        if (value == _globalSound) {
          await NotificationService.clearPerPrayerSound(prayerId);
        } else {
          await NotificationService.setPerPrayerSound(prayerId, value);
        }
        final sounds = await NotificationService.getPerPrayerSounds();
        final global = await NotificationService.getSoundMode();
        if (mounted) {
          setState(() {
            _perPrayerSounds = sounds;
            _globalSound = global;
          });
        }
      },
      child: Container(
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.md,
          vertical: AppSpacing.sm,
        ),
        margin: const EdgeInsets.only(bottom: AppSpacing.xs),
        decoration: BoxDecoration(
          color: selected
              ? AppColors.primary.withValues(alpha: 0.12)
              : Colors.transparent,
          borderRadius: BorderRadius.circular(AppRadius.md),
          border: Border.all(
            color: selected
                ? AppColors.primary.withValues(alpha: 0.4)
                : AppColors.outlineVariant.withValues(alpha: 0.3),
          ),
        ),
        child: Row(
          children: [
            Icon(icon,
                size: 20,
                color: selected
                    ? AppColors.primary
                    : AppColors.onSurfaceVariant),
            const SizedBox(width: AppSpacing.md),
            Expanded(
              child: Text(
                label,
                style: AppText.bodyMd().copyWith(
                  color: selected ? AppColors.primary : AppColors.onSurface,
                ),
              ),
            ),
            if (selected)
              Icon(AppIcons.checkCircleRounded,
                  size: 18, color: AppColors.primary),
          ],
        ),
      ),
    );
  }

  /// Kartu pilihan suara adzan: radio per varian + tombol tes.
  /// Varian selain default diunduh on-demand (~1-2MB) lalu dipakai
  /// sebagai suara channel notifikasi.
  Widget _adzanSoundCard() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        HudHeader('SUARA ADZAN'),
        Container(
          padding: const EdgeInsets.all(AppSpacing.md),
          decoration: BoxDecoration(
            color: AppColors.surfaceContainerLow,
            borderRadius: BorderRadius.circular(AppRadius.xxl),
            border: Border.all(
              color: AppColors.outlineVariant.withValues(alpha: 0.3),
            ),
          ),
          child: Column(
            children: [
              for (final (id, _, label) in NotificationService.adzanVariants)
                _adzanVariantRow(id, label),
              const SizedBox(height: AppSpacing.xs),
              SizedBox(
                width: double.infinity,
                child: TextButton.icon(
                  onPressed: _downloadingVariant == null
                      ? NotificationService.sendTestAdzanSound
                      : null,
                  icon: const Icon(AppIcons.playCircleOutline, size: 18),
                  label: const Text('Tes suara'),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _adzanVariantRow(String id, String label) {
    final selected = id == _adzanVariant;
    final downloading = _downloadingVariant == id;
    return InkWell(
      onTap: downloading ? null : () => _pickAdzanVariant(id),
      borderRadius: BorderRadius.circular(AppRadius.md),
      child: Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.xs,
          vertical: AppSpacing.sm,
        ),
        child: Row(
          children: [
            Icon(
              selected
                  ? AppIcons.radioButtonCheckedRounded
                  : AppIcons.radioButtonOffRounded,
              size: 20,
              color: selected
                  ? AppColors.primary
                  : AppColors.onSurfaceVariant,
            ),
            const SizedBox(width: AppSpacing.md),
            Expanded(
              child: Text(
                label,
                style: AppText.bodyMd().copyWith(
                  color: selected
                      ? AppColors.onSurface
                      : AppColors.onSurfaceVariant,
                ),
              ),
            ),
            // Status download: default selalu siap (bundled di APK).
            if (downloading)
              SizedBox.square(
                dimension: 16,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  color: AppColors.primary,
                ),
              )
            else if (id != 'adzan')
              FutureBuilder<bool>(
                future: NotificationService.isVariantDownloaded(id),
                builder: (context, snap) => Icon(
                  snap.data == true
                      ? AppIcons.checkCircleRounded
                      : AppIcons.downloadRounded,
                  size: 18,
                  color: selected
                      ? AppColors.primary
                      : AppColors.onSurfaceVariant,
                ),
              ),
          ],
        ),
      ),
    );
  }

  Future<void> _pickAdzanVariant(String id) async {
    if (id == _adzanVariant) return;
    final wasDownloaded = await NotificationService.isVariantDownloaded(id);
    if (!wasDownloaded && mounted) {
      setState(() => _downloadingVariant = id);
    }
    try {
      await NotificationService.setAdzanVariant(id);
      if (mounted) setState(() => _adzanVariant = id);
    } catch (_) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Gagal mengunduh suara adzan. Periksa koneksi lalu coba lagi.',
              style: AppText.bodyMd().copyWith(color: AppColors.onSurface),
            ),
            backgroundColor: AppColors.surfaceContainerLowest,
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _downloadingVariant = null);
    }
  }

  Widget _infoCard() {
    // Footnote tenang, bukan kartu — sumber data cukup sekali dibaca.
    return Text(
      'Jadwal dari data KEMENAG RI via api.myquran.com untuk $_cityName. '
      'Ter-update otomatis saat tab dibuka; tap nama kota di atas untuk ganti lokasi.',
      style: AppText.bodyMd().copyWith(
        color: AppColors.onSurfaceVariant.withValues(alpha: 0.7),
        fontSize: 11,
        height: 1.5,
      ),
    );
  }
}
