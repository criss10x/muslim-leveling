import 'dart:io';

import 'package:flutter/material.dart';

import '../l10n/app_localizations.dart';
import '../theme/app_theme.dart';

/// Kit kartu share bersama (ayat Quran + Asmaul Husna).
///
/// Dulu 17 preset background, badge Google Play, dan seluruh kontrol
/// (chip mode, grid swatch, chip rasio) hidup di dalam `quran_share_sheet.dart`.
/// Layar Asmaul Husna karena itu hanya bisa menyamainya dengan menyalin —
/// dan salinan kedua selalu menyimpang dari yang pertama. Sekarang keduanya
/// membaca dari file ini, jadi menambah preset berarti menambah di satu tempat.
///
/// Isi kartu TIDAK di sini: setiap layar merakit kontennya sendiri
/// (ayat = Arab + terjemahan, Asma = Arab + translit + arti).

enum ShareBgKind {
  solid,
  gradient,

  /// Foto bawaan app (9 preset di bawah).
  esthetic,

  /// Foto milik user sendiri. Tidak ada di [shareBgPresets]: isinya dibuat saat
  /// dipakai dari file yang tersimpan, karena tiap user fotonya beda.
  custom,
}

/// Satu preset background. Label TIDAK disimpan: 17 preset hanya punya 3 nilai
/// label (solid/gradasi/estetik), jadi menyimpannya 17x berarti 17 tempat untuk
/// lupa diterjemahkan. Label diturunkan dari [kind] lewat [modeLabel].
class ShareBgPreset {
  final IconData icon;
  final ShareBgKind kind;
  final BoxDecoration decoration;
  final Color fg;
  final Color sub;

  /// Opasitas dasar scrim gelap untuk preset foto: foto terang butuh nilai
  /// tinggi agar teks putih terbaca, foto gelap boleh rendah. 0 = tanpa scrim.
  ///
  /// Nilai ini patokan AWAL saja. User boleh menaikkannya lewat pengatur
  /// "Gelap" di kontrol: dulu angka ini dipatok per foto dan tidak bisa
  /// disentuh, sehingga foto terang yang teksnya kurang kontras tidak bisa
  /// ditolong user.
  final double scrim;

  const ShareBgPreset(
    this.icon,
    this.kind,
    this.decoration,
    this.fg,
    this.sub, {
    this.scrim = 0,
  });
}

/// Scrim awal untuk foto milik user. 0,45: cukup gelap agar teks putih lolos
/// kontras di atas foto terang, tanpa membuat foto gelap jadi hitam.
const double kCustomPhotoScrim = 0.45;

/// Batas pengatur "Gelap". 0,95 = foto praktis hitam, sudah tidak ada gunanya
/// digeser lebih jauh.
const double kScrimMax = 0.95;

/// Preset untuk foto user. Dibuat saat dipakai (bukan di [shareBgPresets])
/// karena isinya file milik user, bukan aset app.
ShareBgPreset customPhotoPreset(File file, {double scrim = kCustomPhotoScrim}) =>
    ShareBgPreset(
      Icons.photo,
      ShareBgKind.custom,
      BoxDecoration(
        // fit cover: kartu share punya 3 rasio berbeda, dan foto user bisa
        // rasio apa saja. cover memenuhi kartu tanpa distorsi; konsekuensinya
        // sisi yang berlebih dipotong.
        //
        // FilterQuality.medium: foto dikecilkan ke 1440px tapi tetap turun
        // resolusi saat digambar ke kartu, dan low (default) membuat hasil
        // ekspor bergerigi di tepi kontras tinggi.
        image: DecorationImage(
          image: FileImage(file),
          fit: BoxFit.cover,
          filterQuality: FilterQuality.medium,
        ),
      ),
      shareFg,
      shareSub,
      scrim: scrim,
    );

// fg = teks utama, sub = teks sekunder -> putih di background gelap.
const shareFg = Colors.white;
const shareSub = Color(0xFFE7EAE8);

final List<ShareBgPreset> shareBgPresets = [
  // Solid
  ShareBgPreset(
    Icons.circle,
    ShareBgKind.solid,
    const BoxDecoration(
      gradient: RadialGradient(
        center: Alignment(-0.35, -0.45),
        radius: 1.4,
        colors: [Color(0xFF1D6A45), Color(0xFF0B3D2E)],
      ),
    ),
    shareFg,
    shareSub,
  ),
  ShareBgPreset(
    Icons.circle,
    ShareBgKind.solid,
    const BoxDecoration(
      gradient: RadialGradient(
        center: Alignment(-0.35, -0.45),
        radius: 1.4,
        colors: [Color(0xFF244B73), Color(0xFF101E2B)],
      ),
    ),
    shareFg,
    shareSub,
  ),
  ShareBgPreset(
    Icons.circle,
    ShareBgKind.solid,
    const BoxDecoration(
      gradient: RadialGradient(
        center: Alignment(-0.35, -0.45),
        radius: 1.4,
        colors: [Color(0xFF5A3570), Color(0xFF2B1B33)],
      ),
    ),
    shareFg,
    shareSub,
  ),
  ShareBgPreset(
    Icons.circle,
    ShareBgKind.solid,
    const BoxDecoration(
      gradient: RadialGradient(
        center: Alignment(-0.35, -0.45),
        radius: 1.4,
        colors: [Color(0xFF6B4A1E), Color(0xFF3B2A10)],
      ),
    ),
    shareFg,
    shareSub,
  ),
  // Gradient
  ShareBgPreset(
    Icons.gradient,
    ShareBgKind.gradient,
    const BoxDecoration(
      gradient: LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        stops: [0.0, 0.5, 1.0],
        colors: [Color(0xFF022C22), Color(0xFF0F766E), Color(0xFF34D399)],
      ),
    ),
    shareFg,
    shareSub,
  ),
  ShareBgPreset(
    Icons.gradient,
    ShareBgKind.gradient,
    const BoxDecoration(
      gradient: LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        stops: [0.0, 0.5, 1.0],
        colors: [Color(0xFFF9CE34), Color(0xFFEE2A7B), Color(0xFF6228D7)],
      ),
    ),
    shareFg,
    shareSub,
  ),
  ShareBgPreset(
    Icons.gradient,
    ShareBgKind.gradient,
    const BoxDecoration(
      gradient: LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [Color(0xFF00E5FF), Color(0xFF1200FF)],
      ),
    ),
    shareFg,
    shareSub,
  ),
  ShareBgPreset(
    Icons.gradient,
    ShareBgKind.gradient,
    const BoxDecoration(
      gradient: LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [Color(0xFFBB73E0), Color(0xFFFF8DDB)],
      ),
    ),
    shareFg,
    shareSub,
  ),
  // Estetik
  ShareBgPreset(
    Icons.image,
    ShareBgKind.esthetic,
    const BoxDecoration(
      image: DecorationImage(
        image: AssetImage('assets/images/mosque_bg.jpg'),
        fit: BoxFit.cover,
      ),
    ),
    shareFg,
    shareSub,
    scrim: 0.78,
  ),
  ShareBgPreset(
    Icons.image,
    ShareBgKind.esthetic,
    const BoxDecoration(
      image: DecorationImage(
        image: AssetImage('assets/images/quran_bg_masjid_interior.jpg'),
        fit: BoxFit.cover,
      ),
    ),
    shareFg,
    shareSub,
    scrim: 0.62,
  ),
  ShareBgPreset(
    Icons.image,
    ShareBgKind.esthetic,
    const BoxDecoration(
      image: DecorationImage(
        image: AssetImage('assets/images/quran_bg_taman_laut.jpg'),
        fit: BoxFit.cover,
      ),
    ),
    shareFg,
    shareSub,
    scrim: 0.68,
  ),
  ShareBgPreset(
    Icons.image,
    ShareBgKind.esthetic,
    const BoxDecoration(
      image: DecorationImage(
        image: AssetImage('assets/images/quran_bg_malam_ufuk.jpg'),
        fit: BoxFit.cover,
      ),
    ),
    shareFg,
    shareSub,
    scrim: 0.30,
  ),
  ShareBgPreset(
    Icons.image,
    ShareBgKind.esthetic,
    const BoxDecoration(
      image: DecorationImage(
        image: AssetImage('assets/images/quran_bg_masjid_pantai.jpg'),
        fit: BoxFit.cover,
      ),
    ),
    shareFg,
    shareSub,
    scrim: 0.55,
  ),
  ShareBgPreset(
    Icons.image,
    ShareBgKind.esthetic,
    const BoxDecoration(
      image: DecorationImage(
        image: AssetImage('assets/images/quran_bg_fuji.jpg'),
        fit: BoxFit.cover,
      ),
    ),
    shareFg,
    shareSub,
    scrim: 0.65,
  ),
  ShareBgPreset(
    Icons.image,
    ShareBgKind.esthetic,
    const BoxDecoration(
      image: DecorationImage(
        image: AssetImage('assets/images/quran_bg_karpet_balkon.jpg'),
        fit: BoxFit.cover,
      ),
    ),
    shareFg,
    shareSub,
    scrim: 0.55,
  ),
  ShareBgPreset(
    Icons.image,
    ShareBgKind.esthetic,
    const BoxDecoration(
      image: DecorationImage(
        image: AssetImage('assets/images/quran_bg_taj_mahal.jpg'),
        fit: BoxFit.cover,
      ),
    ),
    shareFg,
    shareSub,
    scrim: 0.62,
  ),
  ShareBgPreset(
    Icons.image,
    ShareBgKind.esthetic,
    const BoxDecoration(
      image: DecorationImage(
        image: AssetImage('assets/images/quran_bg_fractal.jpg'),
        fit: BoxFit.cover,
      ),
    ),
    shareFg,
    shareSub,
    scrim: 0.25,
  ),
];

/// Default preset kartu share (gradient jade).
const int kShareDefaultPreset = 4;

/// Lebar kartu tetap; tinggi mengikuti rasio terpilih.
const double kShareCardWidth = 340;

/// Label kit dari l10n, dibungkus kelas kecil supaya kit tidak perlu tahu tipe
/// `AppL10n` dan tetap bisa dirender tes tanpa MaterialApp.
class ShareCardKitL10n {
  final String photoLabel;
  final String choosePhoto;
  final String changePhoto;
  final String photoChosen;
  final String scrimLabel;
  final String tabBackground;
  final String tabContent;
  final String tabSize;

  const ShareCardKitL10n({
    required this.photoLabel,
    required this.choosePhoto,
    required this.changePhoto,
    required this.photoChosen,
    required this.scrimLabel,
    required this.tabBackground,
    required this.tabContent,
    required this.tabSize,
  });

  static ShareCardKitL10n of(BuildContext context) {
    final l = AppL10n.of(context);
    return ShareCardKitL10n(
      photoLabel: l.qsModePhoto,
      choosePhoto: l.qsPhotoChoose,
      changePhoto: l.qsPhotoChange,
      photoChosen: l.qsPhotoChosen,
      scrimLabel: l.qsScrimLabel,
      tabBackground: l.qsTabBackground,
      tabContent: l.qsTabContent,
      tabSize: l.qsTabSize,
    );
  }
}

/// Label mode dari l10n — satu tempat, jadi tidak bisa drift dari ARB.
String shareModeLabel(BuildContext context, ShareBgKind kind) =>
    switch (kind) {
      ShareBgKind.solid => AppL10n.of(context).qsModeSolid,
      ShareBgKind.gradient => AppL10n.of(context).qsModeGradient,
      ShareBgKind.esthetic => AppL10n.of(context).qsModeEsthetic,
      ShareBgKind.custom => AppL10n.of(context).qsModePhoto,
    };

/// Ingat preset terakhir per mode, supaya ganti mode tidak mereset pilihan
/// (mis. pilih foto ke-3 di Estetik, geser ke Gradasi, balik ke Estetik →
/// masih foto ke-3).
class SharePresetMemory {
  final Map<ShareBgKind, int> _last = {ShareBgKind.gradient: kShareDefaultPreset};
  int _index = kShareDefaultPreset;

  /// Mode foto-user sedang terpilih. Disimpan terpisah dari [_index] karena
  /// preset foto user TIDAK ada di [shareBgPresets] (fotonya milik user).
  bool _custom = false;

  /// Foto yang sudah dipilih user, null kalau belum pernah.
  File? customPhoto;

  /// Kegelapan yang dipilih user lewat pengatur "Gelap". null = ikut patokan
  /// preset. Disimpan sebagai nilai PENUH, bukan selisih dari patokan, supaya
  /// user bisa MURNI meredupkannya juga: 9 foto bawaan punya patokan keras
  /// (0,25 sampai 0,78) yang dipilih sepihak oleh app, dan sebagian foto
  /// terang butuh lebih gelap sementara yang gelap justru butuh lebih terang.
  double? scrimOverride;

  int get index => _index;
  bool get isCustom => _custom;

  ShareBgPreset? get _customPreset =>
      customPhoto == null ? null : customPhotoPreset(customPhoto!);

  /// Preset yang sedang dipakai.
  ///
  /// Mode foto user TANPA foto jatuh ke preset default: memilih mode hanya
  /// memindahkan pilihan, dan kartu harus tetap tergambar sebelum user sempat
  /// memilih fotonya. Versi pertama memakai `_customPreset!` di sini dan
  /// melempar `Null check operator used on a null value` begitu user menekan
  /// chip "Foto Saya" lebih dulu.
  ShareBgPreset get preset => _custom
      ? (_customPreset ?? shareBgPresets[kShareDefaultPreset])
      : shareBgPresets[_index];

  /// Mode yang sedang dipilih. Beda dari `preset.kind` justru saat mode foto
  /// user belum ada fotonya: pilihan tetap "foto saya" (agar pemilih foto dan
  /// pengatur gelap muncul), sementara kartu memakai preset default.
  ShareBgKind get kind =>
      _custom ? ShareBgKind.custom : shareBgPresets[_index].kind;

  /// Kegelapan yang BENAR-BENAR dipakai kartu. Pengatur "Gelap" menampilkan
  /// angka ini supaya angka di slider sama dengan yang terlihat di kartu.
  double get effectiveScrim => (scrimOverride ?? preset.scrim).clamp(0.0, 0.95);

  void setEffectiveScrim(double v) => scrimOverride = v.clamp(0.0, 0.95);

  void selectPreset(ShareBgPreset p) {
    _custom = false;
    // Patokan gelap itu milik preset, jadi pilihan user dibuang saat pindah
    // preset. Membawanya ikut akan membuat foto berikutnya terbuka dengan
    // kegelapan milik foto sebelumnya.
    scrimOverride = null;
    _index = shareBgPresets.indexOf(p);
  }

  void selectCustomPhoto(File f) {
    customPhoto = f;
    _custom = true;
    scrimOverride = null;
  }

  void selectKind(ShareBgKind kind) {
    if (kind == this.kind) return;
    // Mode foto-user tidak punya nomor preset, jadi tidak ada yang diingat.
    if (!isCustom) _last[preset.kind] = _index;
    if (kind == ShareBgKind.custom) {
      _custom = true;
      scrimOverride = null;
      return;
    }
    _custom = false;
    scrimOverride = null;
    _index = _last[kind] ?? shareBgPresets.indexWhere((p) => p.kind == kind);
  }

  List<ShareBgPreset> presetsFor(ShareBgKind kind) => kind == ShareBgKind.custom
      ? [if (_customPreset != null) _customPreset!]
      : shareBgPresets.where((p) => p.kind == kind).toList();
}

// ── Google Play badge (aset RESMI) ────────────────────────────────

/// Tinggi ARTWORK badge minimum menurut Google Play Badge Guidelines
/// (28px digital). Versi lama di bawah angka ini: tingginya 15,7dp di kartu
/// 1:1 dan 20,7dp di 3:4, jadi teksnya tidak lagi memenuhi ambang keterbacaan
/// yang Google tetapkan.
const double kPlayBadgeArtworkHeight = 28;

/// Rasio tinggi ARTWORK terhadap tinggi BERKAS, per locale. Diukur langsung
/// dari berkasnya, bukan ditebak, karena tiap berkas beda padding:
///
/// - en: transparan 41px di SEMUA sisi, artwork 564x168 (rasio 0,672)
/// - id/tr: transparan 29px atas-bawah saja, artwork 646x192 (rasio 0,768)
///
/// Kotak transparan tidak terlihat, jadi yang wajib setinggi 28dp adalah
/// artwork-nya. Memakai satu angka untuk semua berkas membuat badge en tampak
/// lebih kecil dari yang dimaksud.
const Map<String, double> _gpArtworkHeightRatio = {
  'en': 168 / 250,
  'id': 192 / 250,
  'tr': 192 / 250,
};

/// Fallback untuk locale yang memakai berkas Indonesia.
const double _gpArtworkHeightRatioDefault = 192 / 250;

/// Rasio tinggi artwork berkas badge untuk [languageCode].
double gpArtworkHeightRatio(String languageCode) =>
    _gpArtworkHeightRatio[languageCode] ?? _gpArtworkHeightRatioDefault;

/// Rasio KOTAK aset (646/250), sudah termasuk padding transparannya.
///
/// Kotaknya diberi ukuran pasti, bukan diserahkan pada gambar: `Image` baru
/// punya ukuran setelah asetnya selesai di-decode, jadi tanpa ini badge-nya
/// sempat berukuran 0x0 dan tata letak kartu bergeser saat gambar muncul.
const double kPlayBadgeBoxRatio = 646 / 250;

/// Clear space wajib: seperempat tinggi badge di semua sisi.
const double kPlayBadgeClearSpace = kPlayBadgeArtworkHeight / 4;

/// Badge "Dapatkan di Google Play" dari aset RESMI Google.
///
/// Dulu digambar sendiri (Icons.play_arrow + dua baris teks). Itu melanggar
/// aturan badge Google: "jangan ubah warna, proporsi, spasi, atau aspek apa
/// pun", dan bentuknya memang beda — rasio 5,4:1 sementara aset resmi 3,365:1,
/// dengan logo play berwarna yang tidak mungkin ditiru Icons.
///
/// Asetnya dari domain Google (`play.google.com/intl/<locale>/badges/...`),
/// satu berkas per bahasa dan TIDAK diubah: tidak diskalakan non-proporsional,
/// tidak diwarnai ulang, tidak diberi efek.
class GooglePlayBadge extends StatelessWidget {
  /// Tinggi ARTWORK yang diinginkan. Default = ambang minimum Google.
  final double height;

  const GooglePlayBadge({super.key, this.height = kPlayBadgeArtworkHeight});

  /// Aset resmi per locale. Melayu memakai berkas Indonesia: Google tidak
  /// menerbitkan badge Melayu, dan berkasnya byte-identik dengan versi
  /// Indonesia.
  static String assetFor(String languageCode) => switch (languageCode) {
    'en' => 'assets/images/gp_badge/en.png',
    'tr' => 'assets/images/gp_badge/tr.png',
    // id + ms (+ locale lain yang belum punya badge sendiri)
    _ => 'assets/images/gp_badge/id.png',
  };

  @override
  Widget build(BuildContext context) {
    // Badge ikut bahasa aplikasi, sama seperti teks kartunya.
    final locale = Localizations.localeOf(context).languageCode;
    final asset = assetFor(locale);
    // Tinggi kotak DITURUNKAN dari tinggi artwork yang diinginkan, memakai
    // padding berkas yang bersangkutan.
    final boxHeight = height / gpArtworkHeightRatio(locale);
    return SizedBox(
      height: boxHeight,
      width: boxHeight * kPlayBadgeBoxRatio,
      child: Image.asset(
        asset,
        fit: BoxFit.contain,
        // Tanpa ini Flutter memakai filter low-res dan tepi hurufnya bergerigi
        // di hasil ekspor kartu.
        filterQuality: FilterQuality.high,
        alignment: Alignment.centerLeft,
        // Badge tidak boleh gagal diam-diam: kalau asetnya hilang, kartunya
        // tetap harus terender (dan jelas ada yang salah).
        errorBuilder: (_, __, ___) => Icon(
          Icons.android,
          size: height,
          color: Colors.white,
        ),
      ),
    );
  }
}

/// Footer kartu: badge Google Play RESMI + nama app.
///
/// Dulu badge-nya bikinan sendiri dan di sebelahnya ditulis "Google Play" lagi.
/// Sekarang badge resmi sudah memuat tulisan itu, jadi yang ditambahkan hanya
/// identitas app-nya. Clear space badge dijaga seperempat tinggi badge (aturan
/// Google) lewat [kPlayBadgeClearSpace].
class ShareCardFooter extends StatelessWidget {
  final double s;
  final double q;
  final Color fg;
  final Color sub;

  /// Tinggi artwork badge. Dinaikkan oleh pemanggil kalau ruangnya cukup.
  final double badgeHeight;

  const ShareCardFooter({
    super.key,
    required this.s,
    required this.q,
    required this.fg,
    required this.sub,
    this.badgeHeight = kPlayBadgeArtworkHeight,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      // Clear space: seperempat tinggi badge di semua sisi, di atas dan
      // sekeliling badge.
      padding: EdgeInsets.only(
        top: kPlayBadgeClearSpace,
        bottom: kPlayBadgeClearSpace,
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          GooglePlayBadge(height: badgeHeight),
          SizedBox(width: 10 * s + kPlayBadgeClearSpace),
          Flexible(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'Muslim Leveling',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: 12 * q,
                    fontWeight: FontWeight.w800,
                    color: fg,
                  ),
                ),
                Text(
                  'Level Up Iman',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: 8 * q,
                    color: sub.withValues(alpha: 0.7),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// Scrim gelap untuk preset estetik: foto terang butuh scrim kuat agar teks
/// putih terbaca, foto gelap cukup lemah.
class ShareScrim extends StatelessWidget {
  /// Kegelapan efektif 0..0,95. Diambil dari [SharePresetMemory.effectiveScrim]
  /// supaya pengatur "Gelap" ikut terbaca; preset solid/gradasi bernilai 0
  /// sehingga tidak tergambar sama sekali.
  final double scrim;

  const ShareScrim({super.key, required this.scrim});

  @override
  Widget build(BuildContext context) {
    if (scrim <= 0) {
      return const SizedBox.shrink();
    }
    return Positioned.fill(
      child: DecoratedBox(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Colors.black.withValues(
                alpha: (scrim - 0.28).clamp(0.10, 0.95),
              ),
              Colors.black.withValues(alpha: scrim.clamp(0.10, 0.95)),
            ],
          ),
        ),
      ),
    );
  }
}

/// Satu chip toggle konten (Arab / Terjemahan / Arti).
class ShareContentChipSpec {
  final String label;
  final IconData icon;
  final bool selected;
  final VoidCallback onTap;
  const ShareContentChipSpec({
    required this.label,
    required this.icon,
    required this.selected,
    required this.onTap,
  });
}

/// Seluruh kontrol di bawah preview kartu: chip mode background, grid swatch,
/// chip toggle konten, chip rasio. Dipakai sama persis oleh share ayat Quran
/// dan share Asmaul Husna — yang berbeda hanya isi chip kontennya.
/// Tab pada panel kontrol share.
enum _ShareTab { background, content, size }

class ShareCardControls extends StatefulWidget {
  final SharePresetMemory memory;
  final VoidCallback onChanged;
  final List<ShareContentChipSpec> contentChips;
  final double aspect;
  final ValueChanged<double> onAspectChanged;

  /// Buka pemilih foto user (kamera/galeri) dan pasang hasilnya ke [memory].
  final Future<void> Function() onPickPhoto;

  const ShareCardControls({
    super.key,
    required this.memory,
    required this.onChanged,
    required this.contentChips,
    required this.aspect,
    required this.onAspectChanged,
    required this.onPickPhoto,
  });

  @override
  State<ShareCardControls> createState() => _ShareCardControlsState();
}

class _ShareCardControlsState extends State<ShareCardControls> {
  _ShareTab _tab = _ShareTab.background;

  SharePresetMemory get memory => widget.memory;
  VoidCallback get onChanged => widget.onChanged;
  List<ShareContentChipSpec> get contentChips => widget.contentChips;
  double get aspect => widget.aspect;
  ValueChanged<double> get onAspectChanged => widget.onAspectChanged;
  Future<void> Function() get onPickPhoto => widget.onPickPhoto;

  @override
  Widget build(BuildContext context) {
    // memory.kind, BUKAN preset.kind: saat mode foto user belum ada fotonya,
    // preset jatuh ke default (kind-nya gradasi) padahal pilihan user adalah
    // "foto saya" — memakai preset.kind membuat pemilih foto tidak muncul.
    final kind = memory.kind;
    final presets = memory.presetsFor(kind);
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
      child: Column(
        // Tab selalu terlihat; isinya berganti. Sebelumnya keenam kelompok
        // kontrol tampil bertumpuk (~356dp) sehingga preview hanya dapat 20%
        // tinggi layar di 360x640. Sekarang yang menetap hanya satu baris tab
        // plus isi tab aktif.
        children: [
          _tabBar(context),
          const SizedBox(height: 12),
          AnimatedSize(
            duration: const Duration(milliseconds: 180),
            curve: Curves.easeOut,
            alignment: Alignment.topCenter,
            child: switch (_tab) {
              _ShareTab.background => _backgroundTab(context, kind, presets),
              _ShareTab.content => _contentTab(),
              _ShareTab.size => _sizeTab(),
            },
          ),
        ],
      ),
    );
  }

  /// Isi tab Latar: mode background + swatch/pemilih foto + pengatur gelap.
  Widget _backgroundTab(
    BuildContext context,
    ShareBgKind kind,
    List<ShareBgPreset> presets,
  ) {
    final showScrim = kind == ShareBgKind.esthetic ||
        (kind == ShareBgKind.custom && memory.customPhoto != null);
    return Column(
      children: [
        // ── Mode background ──
        //
        // Wrap, bukan Row: sejak mode "Foto Saya" ditambahkan ada 4 chip, dan
        // labelnya memanjang di beberapa bahasa (Inggris "Esthetic"/"My
        // Photo", Turki "Fotoğrafım"). Row melaporkan "RenderFlex overflowed"
        // di layar 420dp dan lebih parah lagi di HP 360dp; Wrap memindahkan
        // chip yang tidak muat ke baris berikutnya.
        Wrap(
          alignment: WrapAlignment.center,
          spacing: 8,
          runSpacing: 4,
          children: [
            _modeChip(context, ShareBgKind.solid, Icons.circle),
            _modeChip(context, ShareBgKind.gradient, Icons.gradient),
            _modeChip(context, ShareBgKind.esthetic, Icons.image),
            _modeChip(context, ShareBgKind.custom, Icons.photo),
          ],
        ),
        const SizedBox(height: 10),
        // ── Pilihan warna/gambar dalam mode terpilih ──
        //
        // Tingginya dibatasi dan bisa digeser: 9 preset foto bawaan butuh 3
        // baris di 360dp, dan tanpa batas ini tinggi tab ikut melonjak,
        // persis masalah yang sedang diperbaiki.
        ConstrainedBox(
          constraints: const BoxConstraints(maxHeight: 132),
          child: SingleChildScrollView(
            child: kind == ShareBgKind.custom
                ? _customPicker(context)
                : Wrap(
                    alignment: WrapAlignment.center,
                    spacing: 8,
                    runSpacing: 8,
                    children: [
                      for (var k = 0; k < presets.length; k++) ...[
                        Semantics(
                          button: true,
                          label: presets.length == 1
                              ? shareModeLabel(context, presets[k].kind)
                              : '${shareModeLabel(context, presets[k].kind)} '
                                  '${k + 1}',
                          selected: !memory.isCustom &&
                              shareBgPresets.indexOf(presets[k]) ==
                                  memory.index,
                          child: InkWell(
                            onTap: () {
                              memory.selectPreset(presets[k]);
                              onChanged();
                            },
                            borderRadius: BorderRadius.circular(12),
                            child: SizedBox(
                              width: 48,
                              height: 48,
                              child: Center(
                                child: AnimatedContainer(
                                  duration: const Duration(milliseconds: 200),
                                  width: 40,
                                  height: 40,
                                  decoration: presets[k].decoration.copyWith(
                                    border:
                                        !memory.isCustom &&
                                            shareBgPresets.indexOf(presets[k]) ==
                                                memory.index
                                        ? Border.all(
                                            color: AppColors.primary,
                                            width: 2.5,
                                          )
                                        : null,
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
          ),
        ),
        // ── Pengatur gelap: hanya untuk background FOTO ──
        //
        // Warna solid dan gradasi sengaja tidak ikut: keduanya sudah jadi
        // warna bersih (gradasi jade = identitas app), dan menaikkan
        // kegelapan di sana sama saja mematikannya. Ini juga keputusan user.
        // Mode foto user TANPA foto belum punya gambar, dan kartunya jatuh ke
        // preset default (gradasi), jadi pengaturnya belum ada gunanya.
        if (showScrim) ...[
          const SizedBox(height: 6),
          Row(
            children: [
              SizedBox(
                width: 54,
                child: Text(
                  ShareCardKitL10n.of(context).scrimLabel,
                  style: AppText.bodyMd().copyWith(
                    fontSize: 12,
                    color: AppColors.onSurfaceVariant,
                  ),
                ),
              ),
              Expanded(
                child: Slider(
                  value: memory.effectiveScrim,
                  max: kScrimMax,
                  // Label a11y: tanpa ini TalkBack hanya bilang "slider".
                  label: '${(memory.effectiveScrim * 100).round()}%',
                  onChanged: (v) {
                    memory.setEffectiveScrim(v);
                    onChanged();
                  },
                ),
              ),
              SizedBox(
                width: 38,
                child: Text(
                  '${(memory.effectiveScrim * 100).round()}%',
                  textAlign: TextAlign.end,
                  style: AppText.bodyMd().copyWith(
                    fontSize: 12,
                    color: AppColors.onSurfaceVariant,
                  ),
                ),
              ),
            ],
          ),
        ],
      ],
    );
  }

  /// Isi tab Isi: chip Arab / Terjemahan (atau Arti pada kartu Asma).
  Widget _contentTab() {
    // Wrap, bukan Row: dua chip ini (Arab 53dp + Terjemahan 133dp) melebihi
    // ruang 296dp di layar 360dp dan melaporkan "RenderFlex overflowed by 3,5
    // pixels" sejak sebelum tab ini ada. Labelnya lebih panjang lagi di Turki.
    return Wrap(
      alignment: WrapAlignment.center,
      spacing: 8,
      runSpacing: 8,
      children: contentChips.map(_contentChip).toList(),
    );
  }

  /// Isi tab Ukuran: rasio kartu 9:16 / 3:4 / 1:1.
  Widget _sizeTab() {
    return Wrap(
      alignment: WrapAlignment.center,
      spacing: 8,
      runSpacing: 8,
      children: [
        for (final (a, label) in const [
          (9 / 16, '9:16'),
          (3 / 4, '3:4'),
          (1.0, '1:1'),
        ])
          _ratioChip(label, a),
      ],
    );
  }

  /// Satu baris tab. Ikon + label; label bisa menyusut di layar sempit.
  Widget _tabBar(BuildContext context) {
    final l10n = ShareCardKitL10n.of(context);
    return Row(
      children: [
        for (final tab in _ShareTab.values)
          Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 3),
              child: _tabButton(
                tab,
                switch (tab) {
                  _ShareTab.background => l10n.tabBackground,
                  _ShareTab.content => l10n.tabContent,
                  _ShareTab.size => l10n.tabSize,
                },
                switch (tab) {
                  _ShareTab.background => Icons.palette_outlined,
                  _ShareTab.content => Icons.text_fields,
                  _ShareTab.size => Icons.aspect_ratio,
                },
              ),
            ),
          ),
      ],
    );
  }

  Widget _tabButton(_ShareTab tab, String label, IconData icon) {
    final selected = _tab == tab;
    return Semantics(
      button: true,
      selected: selected,
      label: label,
      child: InkWell(
        onTap: () => setState(() => _tab = tab),
        borderRadius: BorderRadius.circular(AppRadius.pill),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
          decoration: BoxDecoration(
            color: selected
                ? AppColors.primary.withValues(alpha: 0.16)
                : AppColors.surfaceContainerLow,
            borderRadius: BorderRadius.circular(AppRadius.pill),
            border: selected
                ? Border.all(color: AppColors.primary, width: 1.2)
                : null,
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon,
                  size: 15,
                  color: selected ? AppColors.primary : AppColors.onSurfaceVariant),
              const SizedBox(width: 5),
              Flexible(
                child: Text(
                  label,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: AppText.bodyMd().copyWith(
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                    color: selected
                        ? AppColors.primary
                        : AppColors.onSurfaceVariant,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// Isi mode "foto saya": swatch foto yang sedang dipakai + tombol pilih/ganti.
  ///
  /// Tombolnya selalu tampil, bukan hanya saat belum ada foto: mengganti foto
  /// adalah hal yang wajar dilakukan berkali-kali sampai dapat yang pas.
  Widget _customPicker(BuildContext context) {
    final l10n = ShareCardKitL10n.of(context);
    final has = memory.customPhoto != null;
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        if (memory.isCustom && has) ...[
          Semantics(
            selected: true,
            label: l10n.photoChosen,
            child: Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                border: Border.all(color: AppColors.primary, width: 2.5),
                borderRadius: BorderRadius.circular(12),
              ),
              clipBehavior: Clip.antiAlias,
              child: Image.file(
                memory.customPhoto!,
                fit: BoxFit.cover,
                // errorBuilder: file bisa sudah tidak ada (dibersihkan sistem).
                // Tanpa ini kartu share melempar dan sheet-nya mati.
                errorBuilder: (_, __, ___) => Icon(
                  Icons.broken_image_outlined,
                  color: AppColors.onSurfaceVariant,
                ),
              ),
            ),
          ),
          const SizedBox(width: 12),
        ],
        FilledButton.tonalIcon(
          onPressed: () async {
            await onPickPhoto();
            onChanged();
          },
          icon: Icon(has ? Icons.swap_horiz : Icons.add_photo_alternate_outlined,
              size: 18),
          label: Text(has ? l10n.changePhoto : l10n.choosePhoto),
        ),
      ],
    );
  }

  Widget _contentChip(ShareContentChipSpec spec) {
    final Color fg = spec.selected ? Colors.white : Colors.white70;
    return InkWell(
      onTap: spec.onTap,
      borderRadius: BorderRadius.circular(AppRadius.pill),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: spec.selected
              ? AppColors.primary.withValues(alpha: 0.9)
              : Colors.white.withValues(alpha: 0.08),
          borderRadius: BorderRadius.circular(AppRadius.pill),
          border: spec.selected
              ? null
              : Border.all(color: Colors.white.withValues(alpha: 0.25)),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(spec.icon, size: 15, color: fg),
            const SizedBox(width: 6),
            Text(
              spec.label,
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w700,
                color: fg,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _ratioChip(String label, double a) {
    final selected = aspect == a;
    return InkWell(
      onTap: () => onAspectChanged(a),
      borderRadius: BorderRadius.circular(AppRadius.pill),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        decoration: BoxDecoration(
          color: selected
              ? AppColors.primary.withValues(alpha: 0.16)
              : AppColors.surfaceContainerLow,
          borderRadius: BorderRadius.circular(AppRadius.pill),
          border: selected
              ? Border.all(color: AppColors.primary, width: 1.2)
              : null,
        ),
        child: Text(
          label,
          style: AppText.bodyMd().copyWith(
            fontWeight: FontWeight.w700,
            color: selected ? AppColors.primary : AppColors.onSurfaceVariant,
          ),
        ),
      ),
    );
  }

  Widget _modeChip(BuildContext context, ShareBgKind kind, IconData icon) {
    final selected = memory.kind == kind;
    return InkWell(
      onTap: () {
        memory.selectKind(kind);
        onChanged();
      },
      borderRadius: BorderRadius.circular(AppRadius.pill),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          decoration: BoxDecoration(
            color: selected
                ? AppColors.primary.withValues(alpha: 0.16)
                : AppColors.surfaceContainerLow,
            borderRadius: BorderRadius.circular(AppRadius.pill),
            border: selected
                ? Border.all(color: AppColors.primary, width: 1.2)
                : null,
          ),
          child: Row(
            children: [
              Icon(icon, size: 16, color: AppColors.primary),
              const SizedBox(width: 6),
            Text(
              shareModeLabel(context, kind),
              style: AppText.bodyMd().copyWith(fontWeight: FontWeight.w600),
            ),
          ],
        ),
      ),
    );
  }
}
