import 'dart:convert';

import 'package:flutter/services.dart' show rootBundle;

/// Ayat Rekomendasi — peta situasi hidup ke ayat Quran.
///
/// Isi file ini SENGAJA hanya data + pembacaan. Aturan mutunya:
///
/// - **Referensi saja, bukan teks.** Yang disimpan cuma `surah:ayah`; terjemahan
///   di-resolve saat render lewat [QuranData.ayahs] dengan
///   `quranUseEnglish(locale)` — jalur yang sama dengan tab Quran, Renungan, dan
///   pembaca Quran. Jadi tidak ada terjemahan yang ditulis ulang di sini, dan
///   pengguna ms/tr otomatis dapat terjemahan Inggris seperti di sisa app.
/// - **Kurasi manusia, bukan pencarian kata kunci.** Terbukti: ayat paling
///   terkenal untuk situasi sulit TIDAK ketangkap keyword emosi. `94:5`
///   ("sesudah kesulitan ada kemudahan") nol hasil untuk kata perasaan apa pun
///   karena ayatnya berbicara soal *kesulitan*, bukan *perasaan*; `93:3` dan
///   `65:3` juga tidak. Jadi daftar ini tidak boleh diturunkan otomatis.
/// - **Bahasa-agnostik.** Label & deskripsi situasi adalah chrome di ARB; file
///   ini tidak memuat teks yang perlu diterjemahkan.
///
/// Resep menambah situasi baru:
/// 1. Tambahkan entri di `assets/quran/situasi.json` (3 ayat, grup yang ada).
/// 2. Tambahkan kunci ARB `sit_<id>` + `sit_<id>_d` di 4 bahasa, lalu
///    `flutter gen-l10n`.
/// 3. Jalankan `flutter test test/quran_situasi_data_test.dart` — guard akan
///    menolak referensi ayat yang tidak ada, id duplikat, dan situasi kembar.
class SituationGroup {
  final String id;

  /// Salah satu dari 4 alasan besar orang membuka Quran:
  /// `shifa` (disembuhkan) · `huda` (diberi arah) · `dikuatkan` · `diingatkan`.
  final String umbrella;

  const SituationGroup({required this.id, required this.umbrella});

  factory SituationGroup.fromJson(Map<String, dynamic> j) =>
      SituationGroup(id: j['id'] as String, umbrella: j['umbrella'] as String);
}

/// Satu situasi hidup + ayat yang dikurasi untuknya.
///
/// [ayahs] panjangnya 3 (dijaga guard, bukan asumsi). Urutannya bermakna:
/// pertama = paling sering dijadikan pegangan untuk situasi ini.
class Situation {
  final String id;
  final String group;
  final List<({int surah, int ayah})> ayahs;

  const Situation({
    required this.id,
    required this.group,
    required this.ayahs,
  });

  factory Situation.fromJson(Map<String, dynamic> j) => Situation(
    id: j['id'] as String,
    group: j['group'] as String,
    ayahs: (j['ayahs'] as List)
        .map((e) => (surah: e['surah'] as int, ayah: e['ayah'] as int))
        .toList(growable: false),
  );
}

class QuranSituasi {
  List<SituationGroup>? _groups;
  List<Situation>? _situations;

  /// Urutan tampil di layar = urutan di JSON, jadi menaruh situasi paling sering
  /// dibuka di awal file itu berpengaruh langsung ke UX.
  Future<void> _ensure() async {
    if (_situations != null) return;
    // ponytail: di bawah assets/quran/ supaya ikut terdaftar lewat entri aset
    // yang sudah ada — tidak perlu menyentuh pubspec.yaml.
    final raw = await rootBundle.loadString('assets/quran/situasi.json');
    final j = jsonDecode(raw) as Map<String, dynamic>;
    _groups = (j['groups'] as List)
        .map((e) => SituationGroup.fromJson(e as Map<String, dynamic>))
        .toList(growable: false);
    _situations = (j['situations'] as List)
        .map((e) => Situation.fromJson(e as Map<String, dynamic>))
        .toList(growable: false);
  }

  Future<List<SituationGroup>> groups() async {
    await _ensure();
    return _groups!;
  }

  Future<List<Situation>> all() async {
    await _ensure();
    return _situations!;
  }

  Future<Situation?> byId(String id) async {
    for (final s in await all()) {
      if (s.id == id) return s;
    }
    return null;
  }

  /// ponytail: reset antar widget-test. Singleton yang menyimpan cache lintas
  /// test = sumber flake (pola yang sama sudah dipakai DailyHighlightService).
  void resetForTest() {
    _groups = null;
    _situations = null;
  }
}

final quranSituasi = QuranSituasi();
