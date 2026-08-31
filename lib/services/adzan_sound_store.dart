import 'dart:io';

import 'package:path_provider/path_provider.dart';

/// Download + cache suara adzan varian dari GitHub Releases.
/// Default ('adzan') tetap bundled di APK; varian lain diunduh on-demand
/// ke cache dir (cache-path di FileProvider lebih reliable daripada
/// app_flutter documents).
class AdzanSoundStore {
  static const _baseUrl =
      'https://github.com/criss10x/muslim-leveling/releases/download/adzan-variants-v1';
  static const _userAgent = 'MuslimLeveling/1.1.0 (Android; dart:io)';

  static Future<Directory> _dir() async {
    // ponytail: cache dir sudah di-cover file_paths.xml <cache-path>.
    // documents dir app_flutter TIDAK di-cover <files-path>.
    final cache = await getTemporaryDirectory();
    final d = Directory('${cache.path}/adzan');
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
  /// Retry 1x otomatis untuk transient failure (GitHub redirect/403).
  static Future<String> fetch(String fileName) async {
    final existing = await cachedPath(fileName);
    if (existing != null) return existing;

    final dir = await _dir();
    final tmp = File('${dir.path}/$fileName.tmp');

    Future<String> attempt() async {
      final client = HttpClient();
      try {
        client.connectionTimeout = const Duration(seconds: 20);
        final req = await client.getUrl(Uri.parse('$_baseUrl/$fileName.mp3'));
        req.headers.set(HttpHeaders.userAgentHeader, _userAgent);
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
      }
    }

    try {
      return await attempt();
    } catch (_) {
      // Satu retry untuk transient network / GitHub 403 tanpa UA.
      if (tmp.existsSync()) tmp.deleteSync();
      return await attempt();
    } finally {
      if (tmp.existsSync()) tmp.deleteSync();
    }
  }
}
