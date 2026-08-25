import 'dart:io';

import 'package:path_provider/path_provider.dart';

/// Download + cache suara adzan varian dari GitHub Releases.
/// Default ('adzan') tetap bundled di APK; varian lain diunduh on-demand
/// ke documents dir, lalu dipakai suara channel notifikasi lewat
/// FileProvider content URI (lihat AdzanSoundBridge di sisi Android).
class AdzanSoundStore {
  static const _baseUrl =
      'https://github.com/criss10x/muslim-leveling/releases/download/adzan-variants-v1';

  static Future<Directory> _dir() async {
    final docs = await getApplicationDocumentsDirectory();
    final d = Directory('${docs.path}/adzan');
    if (!d.existsSync()) d.createSync(recursive: true);
    return d;
  }

  /// Path file cache, atau null kalau belum diunduh.
  static Future<String?> cachedPath(String fileName) async {
    final d = await _dir();
    final f = File('${d.path}/$fileName.mp3');
    return f.existsSync() && f.lengthSync() > 0 ? f.path : null;
  }

  /// Unduh (atau pakai cache), return path lokal.
  static Future<String> fetch(String fileName) async {
    final existing = await cachedPath(fileName);
    if (existing != null) return existing;

    final dir = await _dir();
    final tmp = File('${dir.path}/$fileName.tmp');
    final client = HttpClient();
    try {
      // GitHub release redirect (302 → objects.githubusercontent.com)
      // diikuti otomatis oleh HttpClient.
      final req = await client.getUrl(Uri.parse('$_baseUrl/$fileName.mp3'));
      final res = await req.close();
      if (res.statusCode != 200) {
        throw HttpException('HTTP ${res.statusCode}');
      }
      final sink = tmp.openWrite();
      await res.forEach(sink.add);
      await sink.flush();
      await sink.close();
      // Rename atomik — file .mp3 tidak pernah terlihat setengah jadi.
      await tmp.rename('${dir.path}/$fileName.mp3');
      return '${dir.path}/$fileName.mp3';
    } finally {
      client.close(force: true);
      if (tmp.existsSync()) tmp.deleteSync();
    }
  }
}
