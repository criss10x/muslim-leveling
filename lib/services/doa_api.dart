import 'dart:convert';
import 'dart:io';

/// API Doa & Dzikir equran.id — https://equran.id/apidev/doa
/// GET /api/doa → {status, total, data:[{id, grup, nama, ar, tr, idn, tentang, tag}]}
const _base = 'https://equran.id/api';

class DoaItem {
  final int id;
  final String grup, nama, ar, tr, idn, tentang;

  /// 22 tag terkurasi dari API (mis. ['tidur','malam']). Kosakata pencarian
  /// paling presisi: doa "Doa Sebelum Tidur 1" tidak memuat kata "tidur" di
  /// artinya, tapi tag-nya ada.
  final List<String> tag;

  const DoaItem({
    required this.id,
    required this.grup,
    required this.nama,
    required this.ar,
    required this.tr,
    required this.idn,
    required this.tentang,
    this.tag = const [],
  });

  factory DoaItem.fromJson(Map<String, dynamic> j) => DoaItem(
        id: j['id'] as int,
        grup: j['grup'] as String? ?? '',
        nama: j['nama'] as String? ?? '',
        ar: j['ar'] as String? ?? '',
        tr: j['tr'] as String? ?? '',
        idn: j['idn'] as String? ?? '',
        tentang: j['tentang'] as String? ?? '',
        tag: ((j['tag'] as List?) ?? const []).map((t) => '$t').toList(),
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

  /// Alias kata kunci non-Indonesia untuk 22 tag terkurasi API.
  ///
  /// Konten doa SELURUHNYA berbahasa Indonesia (API hanya satu bahasa), jadi
  /// user en/tr yang mengetik "sleep" tidak akan menemukan apa pun. Ini
  /// JEMBATAN pencarian, bukan terjemahan konten: kosakatanya terbatas pada 22
  /// tag, jadi tabel tetap kecil dan tidak perlu terjemahan penuh.
  static const tagAlias = <String, List<String>>{
    'ampunan': ['forgiveness', 'pardon', 'bağışlanma', 'affetme'],
    'harta': ['wealth', 'property', 'mal', 'servet'],
    'hutang': ['debt', 'loan', 'borç'],
    'jenazah': ['funeral', 'death', 'dead', 'cenaze', 'ölüm'],
    'kabar': ['news', 'haber'],
    'kamar mandi': ['bathroom', 'toilet', 'tuvalet', 'banyo'],
    'keburukan': ['evil', 'harm', 'kötülük'],
    'malam': ['night', 'evening', 'gece', 'akşam'],
    'musibah': ['calamity', 'disaster', 'misfortune', 'musibet', 'felaket'],
    'orang tua': ['parents', 'father', 'mother', 'ebeveyn', 'anne', 'baba'],
    'pakaian': ['clothing', 'clothes', 'dress', 'giysi', 'elbise'],
    'perjalanan': ['travel', 'journey', 'trip', 'yolculuk', 'seyahat'],
    'perlindungan': ['protection', 'refuge', 'koruma', 'sığınma'],
    'rezeki': ['provision', 'sustenance', 'livelihood', 'rızık'],
    'sakit': ['illness', 'sick', 'disease', 'hastalık'],
    'sedih': ['sadness', 'sad', 'grief', 'sorrow', 'üzüntü', 'keder'],
    'sifat buruk': ['bad character', 'vice', 'kötü huy'],
    'sulit': ['hardship', 'difficulty', 'zorluk', 'sıkıntı'],
    'syirik': ['shirk', 'polytheism', 'şirk'],
    'tidur': ['sleep', 'bed', 'uyku', 'yatak'],
    'umum': ['general', 'genel'],
    'wudhu': ['ablution', 'abdest'],
  };

  /// Pencarian lokal atas cache 227 doa.
  ///
  /// TIDAK ada request: API tidak punya pencarian (`/api/doa/cari/x` → 404,
  /// `?q=`/`?search=` diabaikan) dan seluruh katalog sudah di memori sejak
  /// layar dibuka, jadi menyaring di sini instan.
  ///
  /// Urutan hasil: cocok di nama/grup/tag lebih dulu (paling relevan), lalu
  /// cocok di arti doa. Karena itu "rezeki" mengembalikan 2 dari nama/tag dan
  /// 7 kalau arti ikut dicari — 5 sisanya tetap muncul, tapi di bawah.
  List<DoaItem> search(String keyword) {
    final all = _cache;
    if (all == null) return const [];
    final k = keyword.trim().toLowerCase();
    if (k.isEmpty) return const [];

    // Kata kunci efektif: yang diketik + tag lokal yang aliasnya cocok, jadi
    // "sleep" ikut menemukan doa bertag "tidur".
    final keys = <String>{k};
    for (final e in tagAlias.entries) {
      for (final alias in e.value) {
        if (alias.contains(k) || k.contains(alias)) keys.add(e.key);
      }
    }
    bool inPrimary(DoaItem d) =>
        keys.any((x) => d.nama.toLowerCase().contains(x)) ||
        keys.any((x) => d.grup.toLowerCase().contains(x)) ||
        d.tag.any((t) => keys.any((x) => t.contains(x)));
    bool inMeaning(DoaItem d) =>
        keys.any((x) => d.idn.toLowerCase().contains(x));

    final primary = <DoaItem>[], secondary = <DoaItem>[];
    for (final d in all) {
      if (inPrimary(d)) {
        primary.add(d);
      } else if (inMeaning(d)) {
        secondary.add(d);
      }
    }
    return [...primary, ...secondary];
  }

  /// Suntik data tanpa jaringan (khusus tes).
  void seedForTest(List<DoaItem> items) => _cache = List.unmodifiable(items);
}

final doaApi = DoaApi();
