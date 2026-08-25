import 'dart:convert';
import 'dart:io';

/// API Muslim v3 — Ensiklopedia Hadis (sumber: hadeethenc.com)
/// https://api.myquran.com/v3/doc#tag/Hadis
/// 2260 hadis, explore 5/page (452 halaman), random, show/{id}, cari/{keyword}.
const _base = 'https://api.myquran.com/v3/hadis/enc';

/// Total hadis dalam ensiklopedia (kontrak API).
const hadisTotalCount = 2260;

/// Halaman per request pada endpoint explore (kontrak API).
const hadisExplorePageSize = 5;

class HadisItem {
  final int id;
  final String ar, idn, grade, takhrij;
  final String? hikmah;
  const HadisItem({
    required this.id,
    required this.ar,
    required this.idn,
    required this.grade,
    required this.takhrij,
    this.hikmah,
  });

  factory HadisItem.fromJson(Map<String, dynamic> j) {
    final text = j['text'];
    // ponytail: explore → {ar,id}; cari/show → string Indonesia. String =
    // hasil pencarian: teksnya sudah terjemahan, arab & grade kosong.
    final textMap = text is Map ? text : const <String, dynamic>{};
    final textStr = text is String ? text : '';
    return HadisItem(
      id: j['id'] as int,
      ar: (textMap['ar'] as String?) ?? '',
      idn: (textMap['id'] as String?) ?? textStr,
      grade: (j['grade'] as String?) ?? '',
      takhrij: (j['takhrij'] as String?) ?? '',
      hikmah: j['hikmah'] as String?,
    );
  }
}

class HadisApi {
  // ponytail: satu client dipakai bersama → keep-alive antar paginasi,
  // tanpa TLS handshake ulang tiap "Muat Lagi".
  final HttpClient _client = HttpClient();

  Future<Map<String, dynamic>> _get(String path) async {
    final req = await _client.getUrl(Uri.parse('$_base$path'));
    final res = await req.close();
    final body = await res.transform(utf8.decoder).join();
    if (res.statusCode != 200) {
      throw Exception('Hadis API HTTP ${res.statusCode}');
    }
    return jsonDecode(body) as Map<String, dynamic>;
  }

  /// Explore halaman [page] (1-based, 5 item/halaman).
  Future<List<HadisItem>> explore(int page) async {
    final json = await _get('/explore?page=$page');
    return _parseList(json);
  }

  /// Satu hadis acak.
  Future<HadisItem> random() async {
    final json = await _get('/random');
    return HadisItem.fromJson(json['data'] as Map<String, dynamic>);
  }

  /// Detail hadis by id (grade + takhrij + hikmah lengkap).
  Future<HadisItem> show(int id) async {
    final json = await _get('/show/$id');
    return HadisItem.fromJson(json['data'] as Map<String, dynamic>);
  }

  /// Cari by keyword — 10 item/halaman, total dari paging.
  Future<(List<HadisItem>, int)> search(String keyword) async {
    final json =
        await _get('/cari/${Uri.encodeComponent(keyword.trim())}');
    final data = json['data'] as Map<String, dynamic>? ?? const {};
    final paging = data['paging'] as Map<String, dynamic>? ?? const {};
    final list = _parseList(json);
    return (list, (paging['total_data'] as num?)?.toInt() ?? list.length);
  }

  List<HadisItem> _parseList(Map<String, dynamic> json) {
    final data = json['data'] as Map<String, dynamic>? ?? const {};
    final hadis = data['hadis'] as List? ?? const [];
    return hadis
        .cast<Map<String, dynamic>>()
        .map(HadisItem.fromJson)
        .toList(growable: false);
  }
}
final hadisApi = HadisApi();
