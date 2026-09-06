import 'dart:convert';
import 'dart:io';
import '../services/quran_data.dart';

/// API key dari dokumentasi equran.id
const _base = 'https://equran.id/api/v2';
const _gadingBase = 'https://api.quran.gading.dev';
// Self-host di muslim.lifetimeleveling.com (Hostinger via GitHub auto-deploy).
const _selfHostBase = 'https://muslim.lifetimeleveling.com/api/tafsir';

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

  /// Fetch tafsir for surah [number].
  /// Chain: self-host (Hostinger) → gading.dev → equran.id.
  /// Returns short (Muyassar) + long (Kemenag) tafsir per ayat.
  Future<List<QuranTafsir>> tafsir(int number) async {
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
    final client = HttpClient();
    try {
      final req = await client.getUrl(uri);
      if (userAgent != null) {
        req.headers.set(HttpHeaders.userAgentHeader, userAgent);
      }
      final res = await req.close();
      final body = await res.transform(utf8.decoder).join();
      return parse(jsonDecode(body));
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
