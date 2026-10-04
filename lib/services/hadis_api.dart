import 'dart:convert';
import 'dart:io';

/// Ensiklopedia Hadis — dua sumber, satu peran masing-masing.
///
/// `api.myquran.com/v3/hadis/enc` adalah PROXY dari `hadeethenc.com`: id, teks
/// Arab, dan perilaku 404-nya identik 1:1. Tapi proxy itu hanya punya
/// terjemahan Indonesia (`text: {ar, id}`) dan MENGABAIKAN `?lang=`/`?language=`
/// (sudah diuji: responsnya identik). Terjemahan Inggris/Turki hanya ada di
/// sumber aslinya.
///
/// Jadi pembagiannya: proxy = indeks + bahasa Indonesia (cepat, 0,17 dtk, paginasi
/// mapan), sumber asli = terjemahan per bahasa. Layar tetap memakai paginasi yang
/// sama (452 halaman) dan rotasi harian yang sama seperti sebelumnya.
const _proxy = 'https://api.myquran.com/v3/hadis/enc';
const _source = 'https://hadeethenc.com/api/v1';

/// Apakah label grade berarti sahih, dalam bahasa apa pun yang dikirim sumber.
///
/// Label IKUT BAHASA: id "Sahih"/"Hadis sahih", en "Authentic"/"Authentic
/// hadith", tr "Sahih Hadis". Mencari kata "sahih" saja gagal di bahasa Inggris.
bool isSahihGrade(String grade) {
  final g = grade.toLowerCase();
  return g.contains('sahih') || g.contains('authentic') || g.contains('hasan');
}

/// Jumlah hadis di katalog. Ini CACAH ITEM, bukan rentang id — id di API ini
/// sparse (1751…66541; 1..2260 semuanya 404). Jangan pernah dipakai sebagai id.
const hadisTotalCount = 2260;

/// Item per halaman explore (kontrak layar: 5 kartu).
const hadisExplorePageSize = 5;

/// Total halaman explore. Satu sumber untuk layar & highlight harian.
const hadisTotalPages =
    (hadisTotalCount + hadisExplorePageSize - 1) ~/ hadisExplorePageSize;

/// Bahasa konten hadis yang benar-benar tersedia.
///
/// `ms` SENGAJA tidak ada: API tidak punya terjemahan Melayu (diuji → 404).
/// Locale Melayu memakai Inggris — bahasa kedua yang paling dipahami, pola yang
/// sama dipakai aplikasi Muslim lain yang tak punya terjemahan Melayu.
enum HadisLang {
  id('id'),
  en('en'),
  tr('tr');

  const HadisLang(this.code);

  final String code;

  /// `ms` dan locale lain → Inggris.
  static HadisLang of(String languageCode) {
    for (final l in values) {
      if (l.code == languageCode) return l;
    }
    return HadisLang.en;
  }
}

class HadisItem {
  final int id;

  /// Teks Arab — selalu ada, tak bergantung bahasa terjemahan.
  final String ar;

  /// Terjemahan sesuai bahasa yang diminta.
  final String idn;

  final String grade, takhrij;
  final String? hikmah;
  const HadisItem({
    required this.id,
    required this.ar,
    required this.idn,
    required this.grade,
    required this.takhrij,
    this.hikmah,
  });

  /// Dari respons sumber asli `hadeeths/one`.
  ///
  /// `hadeeth` = terjemahan, `hadeeth_ar` = Arab, `attribution` = takhrij,
  /// `hints` = poin pelajaran (inilah isi field `hikmah` di proxy), `grade`
  /// sudah diterjemahkan ("Authentic"/"Sahih Hadis").
  factory HadisItem.fromSource(Map<String, dynamic> j) {
    return HadisItem(
      id: int.tryParse('${j['id']}') ?? 0,
      ar: (j['hadeeth_ar'] as String?) ?? '',
      idn: (j['hadeeth'] as String?) ?? '',
      grade: (j['grade'] as String?) ?? '',
      takhrij: (j['attribution'] as String?) ?? '',
      hikmah: _hintsText(j['hints']),
    );
  }

  /// Dari proxy: explore → `text: {ar,id}`; cari → `text` String (terjemahan).
  factory HadisItem.fromProxy(Map<String, dynamic> j) {
    final text = j['text'];
    final textMap = text is Map ? text : const <String, dynamic>{};
    return HadisItem(
      id: j['id'] as int,
      ar: (textMap['ar'] as String?) ?? '',
      idn: text is String ? text : (textMap['id'] as String?) ?? '',
      // cari/ tidak mengirim grade/takhrij → '' (chip otomatis disembunyikan).
      grade: (j['grade'] as String?) ?? '',
      takhrij: (j['takhrij'] as String?) ?? '',
      hikmah: j['hikmah'] as String?,
    );
  }

  static String? _hintsText(dynamic hints) {
    final list = hints is List ? hints : const [];
    final text = list
        .map((h) => h.toString().trim())
        .where((h) => h.isNotEmpty)
        .join('\n');
    return text.isEmpty ? null : text;
  }

  /// Apakah hadis ini berderajat sahih.
  ///
  /// Label grade IKUT BAHASA: id "Sahih"/"Hadis sahih", en "Authentic"/"Authentic
  /// hadith", tr "Sahih Hadis". Mencari kata "sahih" saja akan gagal di bahasa
  /// Inggris, jadi ketiganya dikenali.
  bool get isSahih => isSahihGrade(grade);

  /// Salinan dengan teks dari sumber asli, mempertahankan ar bila sumber kosong.
  HadisItem mergeSource(HadisItem src) => HadisItem(
        id: id,
        ar: src.ar.isEmpty ? ar : src.ar,
        idn: src.idn.isEmpty ? idn : src.idn,
        grade: src.grade.isEmpty ? grade : src.grade,
        takhrij: src.takhrij.isEmpty ? takhrij : src.takhrij,
        hikmah: src.hikmah ?? hikmah,
      );
}

class HadisApi {
  // ponytail: satu client dipakai bersama → keep-alive antar paginasi, tanpa TLS
  // handshake ulang tiap "Muat Lagi". Tanpa timeout, request yang menggantung
  // bikin layar spinner selamanya.
  final HttpClient _client = HttpClient()
    ..connectionTimeout = const Duration(seconds: 8);

  /// Cache per (bahasa, id). Membuka ulang layar / menekan "Muat Lagi" tidak
  /// menembak jaringan lagi.
  final Map<String, HadisItem> _items = {};
  static const _cacheCap = 400;

  /// Seam test: bahasa yang terakhir diminta layar. Dipakai tes widget untuk
  /// membuktikan locale benar-benar sampai ke service (tanpa jaringan).
  HadisLang? lastRequestedLang;

  /// Seam test: suntik item tanpa jaringan.
  void seedForTest(List<HadisItem> items) {
    for (final it in items) {
      _items['${HadisLang.id.code}:${it.id}'] = it;
    }
  }

  void resetForTest() => _items.clear();

  Future<Map<String, dynamic>> _get(Uri url) async {
    for (var attempt = 0; ; attempt++) {
      final req = await _client.getUrl(url);
      req.headers.set(HttpHeaders.acceptHeader, 'application/json');
      final res = await req.close();
      final body = await res.transform(utf8.decoder).join();
      if (res.statusCode == 200) {
        return jsonDecode(body) as Map<String, dynamic>;
      }
      // Kedua API rate-limit (429) dan UI memanggilnya beruntun — satu retry
      // jeda 1,2 dtk menutup mayoritas kegagalan; lebih dari itu memang error.
      if (res.statusCode != 429 || attempt >= 1) {
        throw Exception('Hadis API HTTP ${res.statusCode}');
      }
      await Future<void>.delayed(const Duration(milliseconds: 1200));
    }
  }

  /// Terjemahan satu id dari sumber asli, di-cache.
  Future<HadisItem> _fromSource(int id, HadisLang lang) async {
    final key = '${lang.code}:$id';
    final hit = _items[key];
    if (hit != null) return hit;

    final j = await _get(
      Uri.parse('$_source/hadeeths/one/?language=${lang.code}&id=$id'),
    );
    final item = HadisItem.fromSource(j);
    if (_items.length >= _cacheCap) _items.clear();
    _items[key] = item;
    return item;
  }

  /// Ganti teks item proxy dengan bahasa aktif. Paralel: 5 request berurutan
  /// @1 dtk = 5 dtk terasa berat untuk satu halaman.
  Future<List<HadisItem>> _inLang(List<HadisItem> items, HadisLang lang) async {
    if (lang == HadisLang.id) return items;
    return Future.wait(items.map((it) async {
      try {
        return it.mergeSource(await _fromSource(it.id, lang));
      } catch (_) {
        // Id tanpa terjemahan di bahasa ini / jaringan → tampil apa adanya,
        // jangan gagalkan seluruh halaman.
        return it;
      }
    }));
  }

  /// Explore halaman [page] (1-based, 5 item) dalam bahasa [lang].
  Future<List<HadisItem>> explore(int page, HadisLang lang) async {
    // Dicatat SEBELUM jaringan: ini niat pemanggil, dan tetap benar walau
    // request gagal (dipakai tes widget tanpa jaringan).
    lastRequestedLang = lang;
    final json = await _get(Uri.parse('$_proxy/explore?page=$page'));
    return _inLang(_parseProxyList(json), lang);
  }

  /// Satu hadis acak dalam bahasa [lang].
  Future<HadisItem> random(HadisLang lang) async {
    final json = await _get(Uri.parse('$_proxy/random'));
    final item = HadisItem.fromProxy(json['data'] as Map<String, dynamic>);
    if (lang == HadisLang.id) return item;
    try {
      return item.mergeSource(await _fromSource(item.id, lang));
    } catch (_) {
      return item;
    }
  }

  /// Cari by keyword. Index pencarian hanya ada di proxy (Indonesia), jadi kata
  /// kunci dikirim ke sana sebagai JEMBATAN, lalu teksnya diambil dalam bahasa
  /// aktif. Batasnya: user Inggris yang mengetik "prayer" tak menemukan apa pun
  /// karena index jembatannya hanya mengenal kata Indonesia.
  Future<(List<HadisItem>, int)> search(String keyword, HadisLang lang) async {
    lastRequestedLang = lang;
    final json = await _get(
      Uri.parse('$_proxy/cari/${Uri.encodeComponent(keyword.trim())}'),
    );
    final data = (json['data'] as Map?) ?? const {};
    final paging = (data['paging'] as Map?) ?? const {};
    final items = _parseProxyList(json);
    final total = int.tryParse('${paging['total_data']}') ?? items.length;
    return (await _inLang(items, lang), total);
  }

  List<HadisItem> _parseProxyList(Map<String, dynamic> json) {
    final data = (json['data'] as Map?) ?? const {};
    final hadis = (data['hadis'] as List?) ?? const [];
    return hadis
        .cast<Map<String, dynamic>>()
        .map(HadisItem.fromProxy)
        .toList(growable: false);
  }
}

final hadisApi = HadisApi();
