import 'package:flutter/material.dart';

import '../l10n/app_localizations.dart';
import '../services/quran_api.dart' show quranUseEnglish;
import '../services/quran_data.dart';
import '../services/quran_situasi.dart';
import '../theme/app_icons.dart';
import '../theme/app_theme.dart';
import '../widgets/common.dart';
import 'quran_reader.dart';

/// Label situasi dari ARB. 54 id situasi tidak bisa dipetakan lewat
/// `Map<String, String Function(AppL10n)>` tanpa menulis 54 entri yang sama
/// panjangnya dengan ARB-nya sendiri, jadi label diambil dengan nama getter
/// yang sudah di-generate. Kalau ada id yang lupa ditambahkan, `describe`
/// mengembalikan null dan tes `ayat_situasi_screen_test.dart` gagal.
String situationLabel(AppL10n l10n, String id) => _describe(l10n, id) ?? '';

/// Deskripsi satu baris di bawah judul situasi (dipakai layar ayat).
String situationDesc(AppL10n l10n, String id) => _describe(l10n, id) ?? '';

String groupLabel(AppL10n l10n, String id) => switch (id) {
  'kacau' => l10n.situasiGroupKacau,
  'ujian' => l10n.situasiGroupUjian,
  'hubungan' => l10n.situasiGroupHubungan,
  'iman' => l10n.situasiGroupIman,
  'keputusan' => l10n.situasiGroupKeputusan,
  'ampunan' => l10n.situasiGroupAmpunan,
  'motivasi' => l10n.situasiGroupMotivasi,
  'syukur' => l10n.situasiGroupSyukur,
  'dunia' => l10n.situasiGroupDunia,
  _ => '',
};

String? _describe(AppL10n l10n, String id) => switch (id) {
  'sedih' => l10n.situasiSitSedih,
  'cemas' => l10n.situasiSitCemas,
  'marah' => l10n.situasiSitMarah,
  'kesepian' => l10n.situasiSitKesepian,
  'insecure' => l10n.situasiSitInsecure,
  'iri' => l10n.situasiSitIri,
  'putus-asa' => l10n.situasiSitPutusAsa,
  'burnout' => l10n.situasiSitBurnout,
  'fomo' => l10n.situasiSitFomo,
  'rezeki-sempit' => l10n.situasiSitRezekiSempit,
  'sakit' => l10n.situasiSitSakit,
  'kehilangan' => l10n.situasiSitKehilangan,
  'gagal' => l10n.situasiSitGagal,
  'dizalimi' => l10n.situasiSitDizalimi,
  'keluarga-besar' => l10n.situasiSitKeluargaBesar,
  'rumah-tangga' => l10n.situasiSitRumahTangga,
  'konflik-ortu' => l10n.situasiSitKonflikOrtu,
  'pasangan' => l10n.situasiSitPasangan,
  'putus-cinta' => l10n.situasiSitPutusCinta,
  'teman-toxic' => l10n.situasiSitTemanToxic,
  'parenting' => l10n.situasiSitParenting,
  'dikucilkan' => l10n.situasiSitDikucilkan,
  'memaafkan' => l10n.situasiSitMemaafkan,
  'futur' => l10n.situasiSitFutur,
  'jauh-dari-allah' => l10n.situasiSitJauhDariAllah,
  'tujuan-hidup' => l10n.situasiSitTujuanHidup,
  'munafik' => l10n.situasiSitMunafik,
  'was-was' => l10n.situasiSitWasWas,
  'baru-hijrah' => l10n.situasiSitBaruHijrah,
  'pilih-jodoh' => l10n.situasiSitPilihJodoh,
  'pilih-karier' => l10n.situasiSitPilihKarier,
  'merantau' => l10n.situasiSitMerantau,
  'kuliah-bisnis' => l10n.situasiSitKuliahBisnis,
  'istikharah' => l10n.situasiSitIstikharah,
  'quarter-life' => l10n.situasiSitQuarterLife,
  'setelah-maksiat' => l10n.situasiSitSetelahMaksiat,
  'merasa-kotor' => l10n.situasiSitMerasaKotor,
  'mulai-taubat' => l10n.situasiSitMulaiTaubat,
  'takut-azab' => l10n.situasiSitTakutAzab,
  'berani-bicara' => l10n.situasiSitBeraniBicara,
  'istiqomah' => l10n.situasiSitIstiqomah,
  'lawan-malas' => l10n.situasiSitLawanMalas,
  'jadi-pemimpin' => l10n.situasiSitJadiPemimpin,
  'versi-lebih-baik' => l10n.situasiSitVersiLebihBaik,
  'dapat-rezeki' => l10n.situasiSitDapatRezeki,
  'sembuh-lulus' => l10n.situasiSitSembuhLulus,
  'dapat-jodoh' => l10n.situasiSitDapatJodoh,
  'hati-tenang' => l10n.situasiSitHatiTenang,
  'lihat-alam' => l10n.situasiSitLihatAlam,
  'pagi-malam' => l10n.situasiSitPagiMalam,
  'ketidakadilan' => l10n.situasiSitKetidakadilan,
  'berlomba-dunia' => l10n.situasiSitBerlombaDunia,
  'doomscrolling' => l10n.situasiSitDoomscrolling,
  'dunia-makin-rusak' => l10n.situasiSitDuniaMakinRusak,
  _ => null,
};

/// Halaman "Ayat rekomendasi" — dua mode dalam satu route:
///
/// - [situationId] null  -> daftar 54 situasi, dikelompokkan 9 grup.
/// - [situationId] diisi -> SATU ayat untuk situasi itu + tombol "ayat lain" dan
///   "buka di Quran".
///
/// ponytail: satu widget untuk dua mode (bukan dua layar) karena layar ayat
/// hanya butuh satu parameter dan tidak punya state sendiri di luar pilihan
/// ayat; memisahkannya berarti menambah route + plumbing tanpa manfaat.
class AyatSituasiScreen extends StatefulWidget {
  final String? situationId;

  const AyatSituasiScreen({super.key, this.situationId});

  @override
  State<AyatSituasiScreen> createState() => _AyatSituasiScreenState();
}

class _AyatSituasiScreenState extends State<AyatSituasiScreen> {
  List<SituationGroup> _groups = const [];
  List<Situation> _situations = const [];
  bool _loading = true;

  // ── mode ayat ──
  QuranSurah? _surah;
  QuranAyah? _ayah;
  int? _refSurah;
  int? _refAyah;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final groups = await quranSituasi.groups();
    final situations = await quranSituasi.all();
    if (!mounted) return;
    setState(() {
      _groups = groups;
      _situations = situations;
      _loading = false;
    });
    if (widget.situationId != null) await _nextAyat();
  }

  /// Ambil ayat berikutnya lalu resolve teksnya. Urutannya penting: kalau
  /// resolve gagal, ayat yang SUDAH tampil tidak diganti — layar jangan kosong
  /// hanya karena satu kegagalan I/O.
  Future<void> _nextAyat() async {
    final id = widget.situationId;
    if (id == null) return;
    final ref = quranSituasi.nextAyat(id);
    if (ref == null) return;
    // Locale dibaca SEBELUM await: memakai context setelah await adalah
    // pelanggaran use_build_context_synchronously, dan guard `mounted` di
    // bawah tidak menutup kasus itu di mata analyzer.
    final english = quranUseEnglish(Localizations.localeOf(context));
    try {
      final surahs = await quranData.surahs();
      final surah = surahs[ref.surah - 1];
      final ayahs = await quranData.ayahs(ref.surah, english: english);
      if (!mounted) return;
      setState(() {
        _surah = surah;
        _ayah = ayahs[ref.ayah - 1];
        _refSurah = ref.surah;
        _refAyah = ref.ayah;
      });
    } catch (_) {
      // Diamkan: teks lama tetap tampil, tombol tetap bisa ditekan lagi.
    }
  }

  void _openInQuran() {
    final surah = _surah;
    if (surah == null) return;
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => QuranReader(surah: surah, initialAyah: _refAyah),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppL10n.of(context);
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        surfaceTintColor: Colors.transparent,
        leading: IconButton(
          icon: Icon(AppIcons.arrowBack, color: AppColors.onSurface),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          widget.situationId == null ? l10n.situasiTitle : _situationTitle(l10n),
          style: AppText.titleLg().copyWith(color: AppColors.onSurface),
          maxLines: 2,
        ),
      ),
      body: _loading
          ? const Center(
              child: CircularProgressIndicator(),
            )
          : widget.situationId == null
              ? _list(l10n)
              : _ayatMode(l10n),
    );
  }

  String _situationTitle(AppL10n l10n) =>
      situationLabel(l10n, widget.situationId!) ;

  // ── mode daftar ──

  Widget _list(AppL10n l10n) {
    // ponytail: dikelompokkan per grup supaya 54 baris tidak jadi dinding teks;
    // satu ListView (bukan nested scroll) — header grup jadi baris biasa.
    final children = <Widget>[];
    for (final g in _groups) {
      final items = _situations.where((s) => s.group == g.id).toList();
      if (items.isEmpty) continue;
      children.add(HudHeader(groupLabel(l10n, g.id)));
      for (final s in items) {
        children.add(
          Padding(
            padding: const EdgeInsets.only(bottom: AppSpacing.xs),
            child: FlatCard(
              padding: const EdgeInsets.symmetric(
                horizontal: AppSpacing.md,
                vertical: AppSpacing.sm,
              ),
              child: PressableScale(
                pressedScale: 0.98,
                onTap: () => Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (_) => AyatSituasiScreen(situationId: s.id),
                  ),
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: Text(
                        situationLabel(l10n, s.id),
                        style: AppText.bodyMd().copyWith(
                          color: AppColors.onSurface,
                        ),
                      ),
                    ),
                    Icon(
                      AppIcons.chevronRight,
                      size: 18,
                      color: AppColors.onSurfaceVariant,
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      }
      children.add(const SizedBox(height: AppSpacing.md));
    }
    return ListView(
      // SafeArea: konten paling bawah tidak boleh tertutup nav bar 3 tombol.
      padding: EdgeInsets.fromLTRB(
        AppSpacing.md,
        AppSpacing.xs,
        AppSpacing.md,
        AppSpacing.md + MediaQuery.viewPaddingOf(context).bottom,
      ),
      children: children,
    );
  }

  // ── mode ayat ──

  Widget _ayatMode(AppL10n l10n) {
    final ayah = _ayah;
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            if (ayah == null)
              const Expanded(
                child: Center(child: CircularProgressIndicator()),
              )
            else
              // Terpusat, bukan menempel atas: terukur, konten ayat cuma setinggi
              // 68..330px sementara ruang sampai tombol 871px di layar 915 →
              // sebelumnya ada ruang mati 541px di bawah ayat, terbaca seperti
              // layar yang belum selesai memuat. Center + SingleChildScrollView:
              // ayat pendek terpusat, ayat panjang tetap bisa digulir.
              Expanded(
                child: Center(
                  child: SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      const SizedBox(height: AppSpacing.sm),
                      Text(
                        'QS. ${_surah?.nameLatin ?? ''} ${_refSurah ?? ''}:${_refAyah ?? ''}',
                        style: AppText.labelCapsSm().copyWith(
                          color: AppColors.primary,
                        ),
                      ),
                      const SizedBox(height: AppSpacing.md),
                      Text(
                        ayah.arabic,
                        textAlign: TextAlign.right,
                        textDirection: TextDirection.rtl,
                        style: AppText.arabic(28).copyWith(
                          color: AppColors.onSurface,
                        ),
                      ),
                      const SizedBox(height: AppSpacing.md),
                      Text(
                        ayah.translation,
                        style: AppText.bodyLg().copyWith(
                          color: AppColors.onSurfaceVariant,
                          height: 1.6,
                        ),
                      ),
                    ],
                  ),
                  ),
                ),
              ),
            const SizedBox(height: AppSpacing.md),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: _nextAyat,
                    icon: Icon(AppIcons.refresh, size: 18),
                    label: Text(l10n.situasiOtherAyah),
                  ),
                ),
                const SizedBox(width: AppSpacing.sm),
                Expanded(
                  child: FilledButton.icon(
                    onPressed: ayah == null ? null : _openInQuran,
                    icon: Icon(AppIcons.menuBookOutlined, size: 18),
                    label: Text(l10n.situasiOpenInQuran),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
