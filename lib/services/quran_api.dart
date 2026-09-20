import 'dart:convert';
import 'dart:io';
import 'dart:ui' show Locale;
import '../services/quran_data.dart';

/// API key dari dokumentasi equran.id
const _base = 'https://equran.id/api/v2';
const _gadingBase = 'https://api.quran.gading.dev';
// Self-host di muslim.lifetimeleveling.com (Hostinger via GitHub auto-deploy).
const _selfHostBase = 'https://muslim.lifetimeleveling.com/api/tafsir';
// Inggris: edisi Saheeh International + transliterasi Latin. Satu panggilan
// mengembalikan ketiganya (Arab + Inggris + Latin) sekaligus.
const _cloudBase = 'https://api.alquran.cloud/v1';
const _editionsEn = 'quran-uthmani,en.sahih,en.transliteration';
// Tafsir Inggris, per-ayat, keyless (CDN jsDelivr di atas repo spa5k/tafsir_api
// yang menyalin tafsir quran.com). Al-Mukhtasar = ringkas, sepadan dgn tafsir
// Muyassar yang jadi default ringkas untuk Indonesia.
/// Terlihat oleh tes supaya salah ketik URL tertangkap tanpa jaringan.
const tafsirEnBaseForTest =
    'https://cdn.jsdelivr.net/gh/spa5k/tafsir_api@main/tafsir/en-tafsir-al-mukhtasar';
const _tafsirEnBase = tafsirEnBaseForTest;

/// Terjemahan Quran hanya 2 bahasa: Indonesia (aset lokal + equran.id) dan
/// Inggris (alquran.cloud). Locale apa pun selain `id` → Inggris.
/// ponytail: satu titik keputusan untuk seluruh aplikasi. Kalau nanti perlu
/// bahasa ketiga (mis. tafsir Turki), tambah cabangnya di sini — jangan
/// sebar `languageCode == 'id'` ke banyak berkas.
bool quranUseEnglish(Locale locale) => locale.languageCode != 'id';

/// Harakat & tanda baca Arab — dibuang sebelum membandingkan basmalah, karena
/// edisi Uthmani menulis syakal yang berbeda antar surat (`بِّسْمِ` vs `بِسْمِ`).
final _harakat = RegExp(r'[\u064B-\u065F\u0670\u06D6-\u06ED\u0640\uFEFF]');
const _basmalah = 'بِسْمِ ٱللَّهِ ٱلرَّحْمَٰنِ ٱلرَّحِيمِ';

String _bare(String s) => s.replaceAll(_harakat, '');

/// Buang basmalah yang ditempelkan di awal ayat 1.
///
/// alquran.cloud menempelkan basmalah ke ayat 1 untuk semua surat kecuali
/// Al-Fatihah (1 — basmalah memang ayat pertamanya) dan At-Taubah (9 — memang
/// tanpa basmalah). Reader sudah merender basmalah sebagai header sendiri
/// (`_basmalahHeader`), jadi tanpa dibuang pengguna melihatnya dua kali.
/// Kalau ayat 1 ternyata bukan basmalah, teks dikembalikan apa adanya —
/// fungsi ini tidak pernah memotong teks yang tidak dikenali.
String stripBasmalah(String arabic, int surahNumber) {
  if (surahNumber == 1 || surahNumber == 9) return arabic;
  final target = _bare(_basmalah);
  var buf = '';
  var last = -1;
  for (var i = 0; i < arabic.length; i++) {
    final ch = _bare(arabic[i]);
    if (ch.isEmpty) continue; // harakat: tidak dihitung
    buf += ch;
    last = i;
    if (buf.length >= target.length) {
      if (buf != target) return arabic; // bukan basmalah → jangan sentuh
      var j = last + 1;
      // Sisa harakat setelah huruf terakhir basmalah ikut dibuang.
      while (j < arabic.length && _bare(arabic[j]).isEmpty) {
        j++;
      }
      return arabic.substring(j).trim();
    }
  }
  return arabic;
}

class QuranApi {
  /// Ayat untuk surat [number].
  ///
  /// [english] true → terjemahan Inggris (alquran.cloud, Saheeh International).
  /// false → terjemahan Indonesia (equran.id) — perilaku lama.
  Future<List<QuranAyah>> ayahs(int number, {bool english = false}) async {
    if (english) return _ayahsEnglish(number);
    final client = HttpClient();
    try {
      final req = await client.getUrl(Uri.parse('$_base/surat/$number'));
      final res = await req.close();
      final body = await res.transform(utf8.decoder).join();
      final json = jsonDecode(body) as Map<String, dynamic>;
      final list = (json['data']['ayat'] as List).cast<Map<String, dynamic>>();
      return list.map((j) => QuranAyah(
        ayah: j['nomorAyat'] as int,
        arabic: j['teksArab'] as String,
        translation: j['teksIndonesia'] as String,
        latin: j['teksLatin'] as String?,
      )).toList(growable: false);
    } finally {
      client.close();
    }
  }

  /// Arab + Inggris + transliterasi dalam satu panggilan.
  /// Edisi dipilih lewat `identifier`, bukan urutan array — urutan respons
  /// adalah kontrak pihak ketiga yang bisa berubah tanpa pemberitahuan.
  Future<List<QuranAyah>> _ayahsEnglish(int number) async {
    final json = await _fetchJson(
      Uri.parse('$_cloudBase/surah/$number/editions/$_editionsEn'),
      userAgent: 'MuslimLeveling/1.1',
    );
    final editions = {
      for (final e in (json['data'] as List).cast<Map<String, dynamic>>())
        (e['edition'] as Map<String, dynamic>)['identifier'] as String: e,
    };
    List<Map<String, dynamic>> ayahsOf(String id) =>
        ((editions[id]?['ayahs'] ?? const []) as List)
            .cast<Map<String, dynamic>>();
    final ar = ayahsOf('quran-uthmani');
    final en = ayahsOf('en.sahih');
    final lat = ayahsOf('en.transliteration');
    if (ar.isEmpty) throw const FormatException('alquran.cloud: ayat kosong');
    return List.generate(ar.length, (i) {
      return QuranAyah(
        ayah: ar[i]['numberInSurah'] as int,
        arabic: stripBasmalah(ar[i]['text'] as String, number),
        translation: i < en.length ? en[i]['text'] as String : '',
        latin: i < lat.length ? lat[i]['text'] as String? : null,
      );
    }, growable: false);
  }

  /// Fetch tafsir for surah [number].
  /// Chain: self-host (Hostinger) → gading.dev → equran.id.
  /// Returns short (Muyassar) + long (Kemenag) tafsir per ayat.
  /// [english] true → tafsir Inggris (Al-Mukhtasar). Indonesia tetap
  /// self-host → gading.dev → equran.id seperti semula.
  Future<List<QuranTafsir>> tafsir(int number, {bool english = false}) async {
    if (english) return _tafsirEnglish(number);
    try {
      return await _fetch(
        Uri.parse('$_selfHostBase/$number.json'),
        _parseSelfHosted,
        userAgent: 'MuslimLeveling/1.1',
      );
    } catch (_) {
      // Self-host down → fallback gading.dev
      try {
        return await _fetch(
          Uri.parse('$_gadingBase/surah/$number'),
          _parseGading,
          userAgent: 'MuslimLeveling/1.1',
        );
      } catch (_) {
        // gading.dev down → fallback equran.id (long saja)
        return _tafsirFallback(number);
      }
    }
  }

  Future<List<QuranTafsir>> _fetch(
    Uri uri,
    List<QuranTafsir> Function(dynamic body) parse, {
    String? userAgent,
  }) async {
    return parse(await _fetchJson(uri, userAgent: userAgent));
  }

  Future<dynamic> _fetchJson(Uri uri, {String? userAgent}) async {
    final client = HttpClient();
    try {
      final req = await client.getUrl(uri);
      if (userAgent != null) {
        req.headers.set(HttpHeaders.userAgentHeader, userAgent);
      }
      final res = await req.close();
      final body = await res.transform(utf8.decoder).join();
      return jsonDecode(body);
    } finally {
      client.close();
    }
  }

  List<QuranTafsir> _parseSelfHosted(dynamic json) {
    final ayahs = (json['ayahs'] as List).cast<Map<String, dynamic>>();
    return ayahs.map(QuranTafsir.fromSelfHosted).toList(growable: false);
  }

  List<QuranTafsir> _parseGading(dynamic json) {
    final verses = (json['data']['verses'] as List)
        .cast<Map<String, dynamic>>();
    return verses.map(QuranTafsir.fromGading).toList(growable: false);
  }

  /// Tafsir Inggris: satu berkas per surat, `[{surah,ayah,text}]`.
  /// Disimpan sebagai `longText` saja; tafsir Inggris tidak punya varian
  /// ringkas/panjang, jadi `quranSettings.useShortTafsir` tidak berpengaruh.
  Future<List<QuranTafsir>> _tafsirEnglish(int number) async {
    final json = await _fetchJson(
      Uri.parse('$_tafsirEnBase/$number.json'),
      userAgent: 'MuslimLeveling/1.1',
    );
    return (json as List).cast<Map<String, dynamic>>().map((j) {
      return QuranTafsir(
        ayah: j['ayah'] as int? ?? 0,
        shortText: '',
        longText: (j['text'] as String?) ?? '',
      );
    }).toList(growable: false);
  }

  /// Fallback terakhir: equran.id v2 (tafsir Kemenag long saja, tanpa short).
  Future<List<QuranTafsir>> _tafsirFallback(int number) async {
    final client = HttpClient();
    try {
      final req = await client.getUrl(Uri.parse('$_base/tafsir/$number'));
      final res = await req.close();
      final body = await res.transform(utf8.decoder).join();
      final json = jsonDecode(body) as Map<String, dynamic>;
      final list = (json['data']['tafsir'] as List).cast<Map<String, dynamic>>();
      return list.map((j) => QuranTafsir(
        ayah: j['ayat'] as int,
        shortText: '',
        longText: j['teks'] as String,
      )).toList(growable: false);
    } finally {
      client.close();
    }
  }
}

final quranApi = QuranApi();
