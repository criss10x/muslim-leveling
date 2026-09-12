import 'dart:convert';
import 'dart:io';

/// API Muslim v3 — Ensiklopedia Hadis (sumber: hadeethenc.com)
/// https://api.myquran.com/v3/doc#tag/Hadis
/// 2260 hadis, explore 5/page (452 halaman), random, show/{id}, cari/{keyword}.
const _base = 'https://api.myquran.com/v3/hadis/enc';

/// Jumlah hadis dalam ensiklopedia (kontrak API).
/// ponytail: ini CACAH ITEM, bukan rentang id — id di API sparse
/// (1751…66541; 1..2260 semuanya 404). Jangan pernah pakai sebagai id.
const hadisTotalCount = 2260;

/// Halaman per request pada endpoint explore (kontrak API).
const hadisExplorePageSize = 5;

/// Total halaman explore (452). Satu sumber untuk layar & highlight.
const hadisTotalPages =
    (hadisTotalCount + hadisExplorePageSize - 1) ~/ hadisExplorePageSize;

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
    // ponytail: explore → {ar,id}; cari → string Indonesia + focus. String =
    // hasil pencarian: teksnya sudah terjemahan, arab & grade kosong.
    final textMap = text is Map ? text : const <String, dynamic>{};
    final textStr = text is String ? text : '';
    return HadisItem(
      id: j['id'] as int,
      ar: (textMap['ar'] as String?) ?? '',
      idn: (textMap['id'] as String?) ?? textStr,
      // ponytail: cari/ tidak mengirim grade/takhrij → '' (chip & baris
      // takhrij otomatis disembunyikan; kartu tetap utuh).
      grade: (j['grade'] as String?) ?? '',
      takhrij: (j['takhrij'] as String?) ?? '',
      hikmah: j['hikmah'] as String?,
    );
  }
}

class HadisApi {
  // ponytail: satu client dipakai bersama → keep-alive antar paginasi,
  // tanpa TLS handshake ulang tiap "Muat Lagi". Tanpa timeout, request yang
  // menggantung bikin layar spinner selamanya ("kosong" versi lain).
  final HttpClient _client = HttpClient()
    ..connectionTimeout = const Duration(seconds: 8);

  Future<Map<String, dynamic>> _get(String path) async {
    final url = Uri.parse('$_base$path');
    for (var attempt = 0; ; attempt++) {
      final req = await _client.getUrl(url);
      final res = await req.close();
      final body = await res.transform(utf8.decoder).join();
      if (res.statusCode == 200) {
        return jsonDecode(body) as Map<String, dynamic>;
      }
      // ponytail: API ini rate-limit ketat (429, ±1 req/detik) dan UI
      // memanggilnya beruntun (Acak → Muat Lagi → Cari) — satu retry jeda
      // 1,2 dtk menutup mayoritas kegagalan; lebih dari itu memang error.
      if (res.statusCode != 429 || attempt >= 1) {
        throw Exception('Hadis API HTTP ${res.statusCode}');
      }
      await Future<void>.delayed(const Duration(milliseconds: 1200));
    }
  }

  /// Explore halaman [page] (1-based, 5 item/halaman).
  /// Ini juga cara AMAN mengambil hadis by posisi — id di API sparse, jadi
  /// `show(hitungDariTanggal)` selalu 404.
  Future<List<HadisItem>> explore(int page) async {
    final json = await _get('/explore?page=$page');
    return _parseList(json);
  }

  /// Satu hadis acak.
  Future<HadisItem> random() async {
    final json = await _get('/random');
    return HadisItem.fromJson(json['data'] as Map<String, dynamic>);
  }

  /// Cari by keyword — 10 item/halaman, total dari paging.
  Future<(List<HadisItem>, int)> search(String keyword) async {
    final json = await _get('/cari/${Uri.encodeComponent(keyword.trim())}');
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
