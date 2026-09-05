import 'dart:convert';
import 'dart:io';
import '../services/quran_data.dart';

/// API key dari dokumentasi equran.id
const _base = 'https://equran.id/api/v2';
const _gadingBase = 'https://api.quran.gading.dev';

class QuranApi {
  /// Fetch ayahs for surah [number] from API, with transliteration teksLatin.
  Future<List<QuranAyah>> ayahs(int number) async {
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

  /// Fetch tafsir for surah [number] from gading.dev API.
  /// Returns short (Muyassar) + long (Kemenag) tafsir per ayat.
  Future<List<QuranTafsir>> tafsir(int number) async {
    final client = HttpClient();
    try {
      final req = await client.getUrl(Uri.parse('$_gadingBase/surah/$number'));
      req.headers.set(HttpHeaders.userAgentHeader, 'MuslimLeveling/1.1');
      final res = await req.close();
      final body = await res.transform(utf8.decoder).join();
      final json = jsonDecode(body) as Map<String, dynamic>;
      final verses = (json['data']['verses'] as List)
          .cast<Map<String, dynamic>>();
      return verses.map((j) => QuranTafsir.fromGading(j)).toList(growable: false);
    } catch (_) {
      // Fallback ke equran.id jika gading.dev down
      return _tafsirFallback(number);
    } finally {
      client.close();
    }
  }

  /// Fallback: equran.id v2 (tafsir Kemenag long saja, tanpa short).
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
