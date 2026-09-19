import 'dart:async';

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../l10n/app_localizations.dart';
import '../../theme/app_theme.dart';
import '../../widgets/common.dart';
import '../../widgets/city_picker.dart';
import '../../widgets/gender_picker.dart';
import '../../widgets/locale_picker.dart';
import '../../widgets/xp_toast.dart';
import '../../services/game_service.dart';
import '../../services/locale_service.dart';
import '../../services/notification_service.dart';
import '../../services/onboarding_progress.dart';
import '../../services/prayer_service.dart';
import 'dashboard_shell.dart';
import '../theme/app_icons.dart';

/// Onboarding 6 halaman: bahasa → nama → Ikhwan/Akhwat → cara main →
/// lokasi → pengingat.
///
/// Urutan bahasa di depan bukan gaya-gayaan: halaman 2-6 langsung terbaca
/// dalam bahasa yang dipilih, karena pilihan di-apply saat kartu ditekan
/// (bukan ditunda ke akhir).
///
/// Permission diminta saat tombol halaman ditekan, bukan otomatis.
class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen>
    with SingleTickerProviderStateMixin {
  static const _total = 6;

  final _pageCtrl = PageController();
  late final AnimationController _entry = AnimationController(
      vsync: this, duration: const Duration(milliseconds: 600))
    ..forward();
  final _nickCtrl = TextEditingController();

  int _page = 0;
  bool _busy = false;

  /// true begitu user menyentuh layar (pindah halaman). Dipakai untuk
  /// membatalkan hasil `_restoreProgress()` yang bisa selesai BELAKANGAN —
  /// lihat komentar di sana.
  bool _touched = false;
  String? _city; // kota hasil deteksi/pilih — tampil sebagai ✓ Nama Kota

  /// Alasan GPS gagal, ditahan di layar (bukan SnackBar yang hilang sendiri).
  /// Tanpa ini, user yang menolak GPS cuma melihat tombol yang sama dan tidak
  /// tahu harus apa — padahal Android tidak memunculkan dialog lagi setelah
  /// permanent-deny.
  String? _locError;

  /// '' = belum dijawab. Dibedakan dari 'male'/'female' karena hanya
  /// 'male' yang menyembunyikan fitur haid — lihat ProfilTab.
  String _gender = '';

  @override
  void initState() {
    super.initState();
    _restoreProgress();
  }

  /// Lanjutkan di halaman terakhir user, bukan halaman 1.
  ///
  /// Tanpa ini app yang dibunuh OS (atau di-background lalu ditutup, atau HP
  /// restart) membuang semua halaman yang sudah dilewati. Dulu jawaban baru
  /// ditulis di halaman 6, jadi keluar di halaman 4 = mulai dari nol.
  Future<void> _restoreProgress() async {
    final r = await OnboardingProgress.resume();
    if (!mounted) return;
    // ponytail: user yang sudah bergerak menang. Restore async bisa selesai
    // setelah user menekan Lanjut; tanpa penjaga ini halaman melompat mundur
    // di bawah jarinya.
    if (_touched || _page != 0) return;
    // Gender tidak ditimpa kalau user sudah memilih di sesi ini — restore
    // tidak boleh menang atas tap yang baru saja terjadi.
    if (_gender.isEmpty) _gender = r.gender;
    final target = r.page >= _total ? _total - 1 : r.page;
    if (target <= 0) return;
    _pageCtrl.jumpToPage(target);
    setState(() => _page = target);
  }

  @override
  void dispose() {
    _pageCtrl.dispose();
    _entry.dispose();
    _nickCtrl.dispose();
    super.dispose();
  }

  bool get _isLast => _page == _total - 1;

  Future<void> _next() async {
    if (_isLast) return;
    await _pageCtrl.nextPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOutCubic);
  }

  Future<void> _prev() async {
    if (_page == 0) return;
    await _pageCtrl.previousPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOutCubic);
  }

  /// Halaman lokasi: minta lokasi, sinkron jadwal, tampilkan ✓ kota.
  Future<void> _allowLocation() async {
    if (_busy) return;
    setState(() {
      _busy = true;
      _locError = null;
    });
    try {
      final loc = await PrayerService.getCurrentLocation();
      if (!mounted) return;
      if (loc.failure != null) {
        // ponytail: jangan simpan default — tampilkan alasan + fallback manual.
        // Bug lama: _syncPrayerSchedule() dipanggil walau failure, dan
        // loadLocation() auto-save "Kota Jakarta" → user luar Jawa salah kota.
        //
        // Alasan ditahan di layar, bukan SnackBar: setelah permanent-deny
        // dialog OS tidak muncul lagi, jadi user butuh tahu bahwa tombolnya
        // tidak rusak dan ada jalur lain (pilih kota manual).
        setState(() => _locError = loc.failure!.message);
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
    // ponytail: _locError dibuang di sini, bukan cuma _city diisi. Cabang CTA
    // di bawah digerakkan `_locError != null`, jadi tanpa baris ini urutan
    // "GPS gagal → pilih kota manual" berakhir buntu: kota sudah terisi tapi
    // tombolnya tetap "Pilih kota manual" dan "Lanjut" tak pernah muncul.
    // Jejak lama tidak berguna lagi begitu user memilih — bukan ditahan.
    setState(() {
      _city = picked.name;
      _locError = null;
    });
  }

  /// Halaman terakhir: minta notifikasi (bila diminta), tandai onboarding selesai.
  ///
  /// ponytail: HANYA izin notifikasi di sini. Dulu satu tap juga membuka
  /// Settings "Alarm & pengingat" + dialog battery-optimization — tiga surface
  /// OS untuk satu janji copy. Sekarang keduanya dipicu di tempat yang jelas
  /// alasannya: toggle notifikasi di Profil / saat menyimpan jadwal adhan.
  Future<void> _finish({bool enableNotif = true}) async {
    if (_busy) return;
    // Tangkap l10n sebelum await: pakai context setelah await =
    // use_build_context_synchronously (warning = CI merah).
    final l10n = AppL10n.of(context);
    setState(() => _busy = true);
    // True kalau user menekan "Izinkan Notifikasi" tapi izinnya tidak diberikan
    // — jalur ini dulu selesai dalam diam, jadi user mengira pengingat aktif.
    var notifDenied = false;
    try {
      // ponytail: jawaban disimpan SEBELUM dialog izin OS, bukan sesudah.
      // Dialog sistem bisa membunuh proses (app di-background lalu di-kill),
      // dan dulu semua jawaban ada di belakang rantai izin → user yang sudah
      // mengisi 5 halaman mengulang dari nol. Tidak ada yang bergantung pada
      // hasil izin di sini, jadi urutannya bebas.
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool('onboarding_done', true);
      final raw = _nickCtrl.text.trim();
      // Nama pejuang opsional — kosong → default (tidak dipaksa).
      final nick = raw.isEmpty ? l10n.onbDefaultNickname : raw;
      await prefs.setString('nickname', nick);
      // ponytail: gender di prefs, bukan GameState — pola sama dengan
      // nickname. Efeknya gender tidak ikut cloud backup, jadi copy privasi
      // di halaman 3 ("cuma dipakai untuk menyembunyikan menu") tetap benar.
      await prefs.setString(kGenderPrefKey, _gender);
      // Sudah sampai ujung: hapus penanda halaman supaya tidak ada yang
      // dilanjutkan kalau app dibuka lagi (gender tetap, Profil membacanya).
      await OnboardingProgress.clear();

      if (enableNotif) {
        try {
          await NotificationService.init();
          final granted = await NotificationService.requestPermission();
          if (granted) {
            await _scheduleAdhanFromPrefs();
          } else {
            notifDenied = true;
          }
        } catch (_) {
          // ponytail: onboarding tetap selesai; pengingat bisa diaktifkan di Profil.
          notifDenied = true;
        }
      }
      if (!mounted) return;
      // Kabari sebelum pergi kalau izinnya ditolak: dulu jalur ini selesai
      // dalam diam dan user mengira pengingat sudah aktif.
      if (notifDenied) {
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text(l10n.onbNotifDenied)));
      }
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

  @override
  Widget build(BuildContext context) {
    final l10n = AppL10n.of(context);
    return PopScope(
      // Android back di halaman >1 harus mundur satu langkah, bukan keluar app:
      // onboarding adalah root route (splash pakai pushReplacement), jadi back
      // bawaan membuang semua jawaban yang sudah diisi tanpa peringatan.
      canPop: _page == 0 && !_busy,
      onPopInvokedWithResult: (didPop, _) {
        if (didPop || _busy) return;
        _prev();
      },
      child: Scaffold(
        backgroundColor: AppColors.background,
        body: SafeArea(
          child: Column(
            children: [
              // Progres visual, bukan cuma untuk TalkBack. HudHeader = pola meta
              // yang sudah dipakai tab lain (belajar_tab, jadwal_tab).
              // ExcludeSemantics: _PageBody sudah membawa kalimat
              // "Langkah n dari 6" untuk pembaca layar — tanpa ini TalkBack
              // membacakan progres dua kali.
              Padding(
                padding: const EdgeInsets.fromLTRB(24, AppSpacing.md, 24, 0),
                child: ExcludeSemantics(
                  child: HudHeader(l10n.onbProgressLabel,
                      meta: '${_page + 1}/$_total'),
                ),
              ),
              Expanded(
                child: PageView(
                  controller: _pageCtrl,
                  physics:
                      _busy ? const NeverScrollableScrollPhysics() : null,
                  onPageChanged: (i) {
                    _touched = true;
                    // ponytail: tidak di-await — satu int + satu string di
                    // SharedPreferences, dan menunggunya bikin pindah halaman
                    // terasa menggantung. Paling buruk user mundur satu
                    // halaman, bukan mengulang dari nol.
                    unawaited(OnboardingProgress.savePage(i, _gender));
                    setState(() {
                      _page = i;
                      _entry.forward(from: 0);
                    });
                  },
                  children: [
                    _pageBahasa(),
                    _pageNama(),
                    _pageGender(),
                    _pageCaraMain(),
                    _pageLokasi(),
                    _pageNotif(),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // --- halaman ---

  /// Halaman 1: bahasa. Tap = langsung ganti (localeNotifier yang rebuild
  /// seluruh app), jadi halaman ini sendiri jadi buktinya.
  Widget _pageBahasa() {
    final l10n = AppL10n.of(context);
    return _PageBody(
      entry: _entry,
      semanticsLabel: l10n.onbStepOf('1', '$_total'),
      child: Column(
        children: [
          const Spacer(),
          const _Mascot(icon: AppIcons.translate),
          const SizedBox(height: AppSpacing.lg),
          _Title(l10n.onbLangTitle),
          const SizedBox(height: AppSpacing.sm),
          _Body(l10n.onbLangBody),
          const SizedBox(height: AppSpacing.lg),
          // ListenableBuilder: baris terpilih harus pindah saat ditekan.
          ListenableBuilder(
            listenable: localeNotifier,
            builder: (context, _) => Column(
              children: [
                LocaleOption(
                  value: null,
                  label: l10n.localeSystem,
                  current: localeNotifier.override,
                ),
                for (final locale in LocaleNotifier.supported)
                  LocaleOption(
                    value: locale,
                    label: locale.languageCode == 'id'
                        ? l10n.localeIndonesian
                        : l10n.localeEnglish,
                    current: localeNotifier.override,
                  ),
              ],
            ),
          ),
          const Spacer(),
          HeroButton(
              label: l10n.onbContinue,
              trailingIcon: AppIcons.arrowForward,
              onPressed: _next),
          const SizedBox(height: AppSpacing.lg),
        ],
      ),
    );
  }

  /// Halaman 2: nama pejuang (opsional).
  Widget _pageNama() {
    final l10n = AppL10n.of(context);
    return _PageBody(
      entry: _entry,
      semanticsLabel: l10n.onbStepOf('2', '$_total'),
      child: Column(
        children: [
          const Spacer(),
          const _Mascot(icon: AppIcons.shieldOutlined),
          const SizedBox(height: AppSpacing.lg),
          _Title(l10n.onbNameTitle),
          const SizedBox(height: AppSpacing.sm),
          _Body(l10n.onbNameBody),
          const SizedBox(height: AppSpacing.lg),
          TextField(
            controller: _nickCtrl,
            maxLength: 20,
            maxLines: 1,
            // Counter ditampilkan (dulu counterText: ''): karakter ke-21
            // ditolak diam-diam, jadi user tidak tahu kenapa ketikannya macet.
            // ponytail: pakai counter bawaan TextField, bukan widget sendiri.
            buildCounter: (_, {required currentLength, required isFocused, maxLength}) =>
                Text('$currentLength/$maxLength',
                    style: AppText.labelCapsSm()
                        .copyWith(color: AppColors.onSurfaceVariant)),
            textCapitalization: TextCapitalization.words,
            style: AppText.bodyMd().copyWith(color: AppColors.onSurface),
            decoration: InputDecoration(
              hintText: l10n.onbNicknameHint,
              hintStyle: AppText.bodyMd().copyWith(
                  color: AppColors.onSurfaceVariant.withValues(alpha: 0.6)),
              isDense: true,
              contentPadding: const EdgeInsets.symmetric(
                  horizontal: 14, vertical: 12),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(AppRadius.md),
                borderSide: BorderSide(color: AppColors.outlineVariant),
              ),
            ),
          ),
          const Spacer(),
          HeroButton(
              label: l10n.onbContinue,
              trailingIcon: AppIcons.arrowForward,
              onPressed: _next),
          const SizedBox(height: AppSpacing.lg),
        ],
      ),
    );
  }

  /// Halaman 3: Ikhwan / Akhwat. Istilah Arab dipakai apa adanya di kedua
  /// bahasa — tidak ada yang perlu diterjemahkan, dan lebih pas untuk konteks
  /// ibadah daripada "Pria/Wanita".
  ///
  /// Tanpa ikon: font Phosphor yang di-vendor tidak punya glyph gender, dan
  /// dua kartu dengan glyph identik lebih membingungkan daripada tanpa ikon.
  Widget _pageGender() {
    final l10n = AppL10n.of(context);
    return _PageBody(
      entry: _entry,
      semanticsLabel: l10n.onbStepOf('3', '$_total'),
      child: Column(
        children: [
          const Spacer(),
          _Title(l10n.onbGenderTitle),
          const SizedBox(height: AppSpacing.md),
          // Alasan sebenarnya hanya satu: menyembunyikan baris Periode Haid.
          _Body(l10n.onbGenderWhy),
          const SizedBox(height: AppSpacing.lg),
          for (final (label, value) in [
            (l10n.onbGenderIkhwan, 'male'),
            (l10n.onbGenderAkhwat, 'female'),
          ])
            _GenderCard(
              label: label,
              selected: _gender == value,
              onTap: () => setState(() => _gender = value),
            ),
          const SizedBox(height: AppSpacing.sm),
          _Body(l10n.onbGenderPrivacy),
          const Spacer(),
          // ponytail: label lama "Lewati" bertabrakan dengan tombol Lewati
          // kanan-atas yang artinya lain (dan tidak maju sama sekali) → user
          // menekan yang salah, atau menekan ini dan menyimpulkan app rusak.
          // Sekarang: label menyebut fungsinya, dan ia maju seperti tombol
          // mana pun di posisi itu. Ikon dihapus — halaman ini zero-ikon.
          GhostButton(
              label: l10n.onbGenderSkip,
              onPressed: () {
                setState(() => _gender = '');
                _next();
              }),
          const SizedBox(height: AppSpacing.sm),
          HeroButton(
              label: l10n.onbContinue,
              trailingIcon: AppIcons.arrowForward,
              onPressed: _next),
          const SizedBox(height: AppSpacing.lg),
        ],
      ),
    );
  }

  /// Halaman 4: penjelasan quest/XP/achievement + kartu demo yang bisa ditekan.
  Widget _pageCaraMain() {
    final l10n = AppL10n.of(context);
    return _PageBody(
      entry: _entry,
      semanticsLabel: l10n.onbStepOf('4', '$_total'),
      child: Column(
        children: [
          const Spacer(),
          _Title(l10n.onbHowTitle),
          const SizedBox(height: AppSpacing.sm),
          _Body(l10n.onbHowBody),
          const SizedBox(height: AppSpacing.lg),
          for (final (icon, title, body) in [
            (AppIcons.checkCircle, l10n.onbHowQuestTitle, l10n.onbHowQuestBody),
            (AppIcons.bolt, l10n.onbHowXpTitle, l10n.onbHowXpBody),
            (AppIcons.emojiEvents, l10n.onbHowAchTitle, l10n.onbHowAchBody),
          ])
            _HowRow(icon: icon, title: title, body: body),
          const SizedBox(height: AppSpacing.md),
          const _MockXpCard(),
          const SizedBox(height: AppSpacing.xs),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(AppIcons.touchApp,
                  size: 16, color: AppColors.onSurfaceVariant),
              const SizedBox(width: AppSpacing.xs),
              Flexible(
                child: Text(
                  l10n.onbHowDemoHint,
                  style: AppText.bodyMd()
                      .copyWith(color: AppColors.onSurfaceVariant),
                ),
              ),
            ],
          ),
          const Spacer(),
          HeroButton(
              label: l10n.onbContinue,
              trailingIcon: AppIcons.arrowForward,
              onPressed: _next),
          const SizedBox(height: AppSpacing.lg),
        ],
      ),
    );
  }

  Widget _pageLokasi() {
    final l10n = AppL10n.of(context);
    final confirmed = _city != null;
    return _PageBody(
      entry: _entry,
      semanticsLabel: l10n.onbStepOf('5', '$_total'),
      child: Column(
        children: [
          const Spacer(),
          const _Mascot(icon: AppIcons.locationOn),
          const SizedBox(height: AppSpacing.xl),
          _Title(l10n.onbLocationTitle),
          const SizedBox(height: AppSpacing.md),
          _Body(l10n.onbLocationBody),
          const SizedBox(height: AppSpacing.md),
          if (confirmed)
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(AppIcons.checkCircle,
                    size: 18, color: AppColors.primary),
                const SizedBox(width: AppSpacing.xs),
                Flexible(
                  child: Text(
                    _city!,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: AppText.bodyMd()
                        .copyWith(color: AppColors.onSurface),
                  ),
                ),
              ],
            )
          else if (_locError != null)
            // Alasan gagal ditahan di layar, dan user diarahkan ke jalur yang
            // pasti berhasil (pilih kota manual) — bukan disuruh coba lagi
            // tombol yang dialognya sudah tidak akan muncul lagi.
            _Body(_locError!),
          const Spacer(),
          // ponytail: cabangnya diurut `confirmed` DULU, baru `_locError`.
          // Urutan sebaliknya (error dulu) bikin buntu: setelah user memilih
          // kota manual, `_locError` masih ada jejaknya, jadi CTA tetap
          // "Pilih kota manual" dan "Lanjut" tak pernah muncul. Dengan
          // `confirmed` di depan, kota yang sudah terisi selalu menang.
          if (confirmed)
            HeroButton(
                label: l10n.onbContinue,
                trailingIcon: AppIcons.arrowForward,
                onPressed: _busy ? null : _next)
          else if (_locError != null)
            HeroButton(
                label: l10n.onbLocationPickManual,
                trailingIcon: AppIcons.arrowForward,
                onPressed: _busy ? null : _pickCity)
          else
            HeroButton(
                label: _busy
                    ? l10n.onbLocationLoading
                    : l10n.onbLocationAllow,
                onPressed: _busy ? null : _allowLocation),
          const SizedBox(height: AppSpacing.sm),
          if (!confirmed && _locError != null)
            GhostButton(
                label: l10n.onbLocationRetry,
                icon: AppIcons.myLocation,
                onPressed: _busy ? null : _allowLocation)
          else if (!confirmed)
            GhostButton(
                label: l10n.onbLocationPickManual,
                icon: AppIcons.locationCity,
                onPressed: _busy ? null : _pickCity),
          if (!confirmed) ...[
            const SizedBox(height: AppSpacing.sm),
            // Jalan keluar jujur: menolak lokasi bukan jalan buntu. Kota
            // default sudah dipakai jadwal (loadLocation() fallback) dan bisa
            // diganti di Profil — labelnya menyebut konsekuensinya, bukan
            // "Lewati" yang ambigu.
            GhostButton(
                label: l10n.onbLocationLater,
                onPressed: _busy ? null : _next),
            const SizedBox(height: AppSpacing.xs),
            _Body(l10n.onbLocationLaterHint),
          ],
          const SizedBox(height: AppSpacing.lg),
        ],
      ),
    );
  }

  Widget _pageNotif() {
    final l10n = AppL10n.of(context);
    return _PageBody(
      entry: _entry,
      semanticsLabel: l10n.onbStepOf('6', '$_total'),
      child: Column(
        children: [
          const Spacer(),
          const _Mascot(icon: AppIcons.notificationsActiveOutlined),
          const SizedBox(height: AppSpacing.xl),
          _Title(l10n.onbNotifTitle),
          const SizedBox(height: AppSpacing.md),
          _Body(l10n.onbNotifBody),
          const Spacer(),
          HeroButton(
              label: _busy ? l10n.onbNotifLoading : l10n.onbNotifAllow,
              trailingIcon: AppIcons.notificationsActiveOutlined,
              onPressed: _busy ? null : () => _finish(enableNotif: true)),
          const SizedBox(height: AppSpacing.sm),
          // P0: escape dari halaman terakhir — sebelumnya Lewati di-disable
          // tanpa alternatif visible (user terjebak di permission notif).
          GhostButton(
              label: l10n.onbNotifSkip,
              icon: AppIcons.close,
              onPressed: _busy ? null : () => _finish(enableNotif: false)),
          const SizedBox(height: AppSpacing.lg),
        ],
      ),
    );
  }
}

/// Judul halaman — satu tempat supaya maxLines/style tidak menyimpang.
class _Title extends StatelessWidget {
  final String text;
  const _Title(this.text);

  @override
  Widget build(BuildContext context) => Semantics(
        header: true,
        child: Text(
          text,
          textAlign: TextAlign.center,
          style: AppText.titleLg(),
        ),
      );
}

/// Body copy halaman.
///
/// Tanpa `maxLines`: halaman sudah bisa di-scroll (_PageBody), jadi teks
/// panjang dibiarkan wrap. Yang dulu terpotong pertama justru `onbGenderWhy`
/// — justifikasi untuk pertanyaan yang invasif.
class _Body extends StatelessWidget {
  final String text;
  const _Body(this.text);

  @override
  Widget build(BuildContext context) => Text(
        text,
        style: AppText.bodyMd().copyWith(color: AppColors.onSurfaceVariant),
        textAlign: TextAlign.center,
      );
}

/// Kartu pilihan Ikhwan/Akhwat — target besar, satu baris, tanpa ikon.
class _GenderCard extends StatelessWidget {
  final String label;
  final bool selected;
  final VoidCallback onTap;
  const _GenderCard({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.xs),
      child: Material(
        color: selected
            ? AppColors.primaryContainer
            : AppColors.surfaceContainerLow,
        borderRadius: BorderRadius.circular(AppRadius.lg),
        child: InkWell(
          borderRadius: BorderRadius.circular(AppRadius.lg),
          onTap: onTap,
          child: Semantics(
            selected: selected,
            button: true,
            child: SizedBox(
              height: 60,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    label,
                    style: AppText.titleLg().copyWith(
                      color: selected
                          ? AppColors.onPrimaryContainer
                          : AppColors.onSurface,
                      letterSpacing: 1.5,
                    ),
                  ),
                  if (selected) ...[
                    const SizedBox(width: AppSpacing.sm),
                    Icon(AppIcons.checkCircle, color: AppColors.primary),
                  ],
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// Satu baris penjelasan di halaman "Cara Main".
class _HowRow extends StatelessWidget {
  final IconData icon;
  final String title;
  final String body;
  const _HowRow({required this.icon, required this.title, required this.body});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.sm),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 20, color: AppColors.primary),
          const SizedBox(width: AppSpacing.sm),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: AppText.bodyLg().copyWith(color: AppColors.onSurface),
                ),
                Text(
                  body,
                  style: AppText.bodyMd()
                      .copyWith(color: AppColors.onSurfaceVariant),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// Satu halaman onboarding dengan animasi fade+slide saat masuk.
/// Wrap Semantics supaya TalkBack baca 'Langkah N dari 6'.
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
      // LayoutBuilder + ConstrainedBox(minHeight) + IntrinsicHeight: trik baku
      // supaya Spacer tetap bekerja saat konten pendek, TAPI halaman bisa
      // di-scroll saat konten tinggi (layar kecil / font besar). Tanpa ini,
      // Spacer kolaps dan Column jebol — terukur 196px di 320x568 @1.5.
      child: LayoutBuilder(
        builder: (context, constraints) => SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: ConstrainedBox(
            constraints: BoxConstraints(minHeight: constraints.maxHeight),
            child: IntrinsicHeight(
              child: FadeTransition(
                opacity: fade,
                child: SlideTransition(
                  position:
                      Tween(begin: const Offset(0, 0.04), end: Offset.zero)
                          .animate(fade),
                  child: child,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// Kunci kartu demo XP — publik supaya tes bisa menekannya tanpa bergantung
/// pada teks '+50 XP' yang juga muncul di toast (finder teks jadi ambigu
/// tepat setelah kartu ditekan sekali).
const kOnbXpDemoCardKey = ValueKey('onbXpDemoCard');

/// Mock XP card — preview loop 'sholat → XP'.
///
/// Bisa ditekan: toast +50 XP sungguhan supaya user melihat hadiahnya, TAPI
/// tidak ada satu pun panggilan GameService di sini. Kalau bocor, user bisa
/// menaikkan XP dengan menekan kartu di onboarding berulang kali.
/// Dijaga test/onboarding_gender_test.dart (tes 'demo XP ... anti-cheat').
class _MockXpCard extends StatelessWidget {
  const _MockXpCard();

  @override
  Widget build(BuildContext context) {
    final l10n = AppL10n.of(context);
    return Semantics(
      button: true,
      label: l10n.onbXpDemoSemantics,
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          key: kOnbXpDemoCardKey,
          borderRadius: BorderRadius.circular(AppRadius.lg),
          onTap: () => showXpToast(context, 50),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            decoration: BoxDecoration(
              color: AppColors.surfaceContainer,
              borderRadius: BorderRadius.circular(AppRadius.lg),
              border:
                  Border.all(color: AppColors.primary.withValues(alpha: 0.25)),
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
                  '${l10n.prayerSubuh} ✓',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style:
                      AppText.labelCaps().copyWith(color: AppColors.onSurface),
                ),
                const SizedBox(width: 10),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 9, vertical: 4),
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
        ),
      ),
    );
  }
}

/// Anchor optik halaman — ikon Phosphor, bukan emoji sistem.
///
/// ponytail: app ini vendoring Phosphor justru supaya tidak ada glyph acak dari
/// font emoji Android. Emoji juga tidak menskala dengan setelan ukuran font
/// user (fontSize mati), jadi ini sekaligus perbaikan a11y.
/// Ukuran 64 = radius lama (128px lingkaran), hanya bentuknya yang berubah.
class _Mascot extends StatelessWidget {
  final IconData icon;
  const _Mascot({required this.icon});

  @override
  Widget build(BuildContext context) => Icon(icon, size: 64, color: AppColors.primary);
}
