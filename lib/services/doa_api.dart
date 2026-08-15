import 'dart:convert';
import 'dart:io';

/// API Doa & Dzikir equran.id — https://equran.id/apidev/doa
/// GET /api/doa → {status, total, data:[{id, grup, nama, ar, tr, idn, tentang, tag}]}
const _base = 'https://equran.id/api';

class DoaItem {
  final int id;
  final String grup, nama, ar, tr, idn, tentang;
  const DoaItem({
    required this.id,
    required this.grup,
    required this.nama,
    required this.ar,
    required this.tr,
    required this.idn,
    required this.tentang,
  });

  factory DoaItem.fromJson(Map<String, dynamic> j) => DoaItem(
        id: j['id'] as int,
        grup: j['grup'] as String? ?? '',
        nama: j['nama'] as String? ?? '',
        ar: j['ar'] as String? ?? '',
        tr: j['tr'] as String? ?? '',
        idn: j['idn'] as String? ?? '',
        tentang: j['tentang'] as String? ?? '',
      );
}

class DoaApi {
  List<DoaItem>? _cache;

  /// Fetch semua doa sekali, cache in-memory. Grup diambil client-side
  /// dari list (API list udah berurutan per grup, 44 grup / 227 doa).
  Future<List<DoaItem>> fetchAll() async {
    final cached = _cache;
    if (cached != null) return cached;
    final client = HttpClient();
    try {
      final req = await client.getUrl(Uri.parse('$_base/doa'));
      final res = await req.close();
      final body = await res.transform(utf8.decoder).join();
      final json = jsonDecode(body) as Map<String, dynamic>;
      final list = (json['data'] as List).cast<Map<String, dynamic>>();
      _cache = list.map(DoaItem.fromJson).toList(growable: false);
      return _cache!;
    } finally {
      client.close();
    }
  }

  /// Grup unik urut kemunculan di API + jumlah doa per grup.
  Future<List<(String, int)>> fetchGroups() async {
    final all = await fetchAll();
    final groups = <String, int>{};
    for (final d in all) {
      groups[d.grup] = (groups[d.grup] ?? 0) + 1;
    }
    return groups.entries.map((e) => (e.key, e.value)).toList();
  }

  List<DoaItem> byGrup(String grup) {
    final all = _cache;
    if (all == null) return const [];
    return all.where((d) => d.grup == grup).toList();
  }
}

final doaApi = DoaApi();
