// Mock HTTP minimal untuk tes: `HttpClient()` di dalam `flutter_test` selalu
// gagal, jadi jalur "koneksi berhasil" tidak bisa diuji tanpa ini.
//
// PENTING — kenapa state-nya global dan mutable, bukan per-test:
// `PrayerService._discoveryClient` adalah `static final`, jadi ia dibuat SEKALI
// pada akses pertama dan memakai HttpOverrides yang aktif saat itu. Reset
// HttpOverrides di tengah file tidak menggantinya. Jadi overrides dipasang
// sekali (setUpAll) dan perilakunya diubah lewat [mockEquranCities] /
// [mockEquranOffline] — dibaca saat request, bukan saat client dibuat.
//
// Hanya cukup untuk Equran `POST /kabkota`; anggota lain sengaja melempar
// supaya panggilan tak terduga gagal keras, bukan diam-diam.
import 'dart:async';
import 'dart:convert';
import 'dart:io';

Map<String, List<String>> _cities = const {};
bool _offline = false;

/// Pasang mock. Panggil di `setUpAll`. Perilaku diatur per-tes.
void installMockEquran() {
  HttpOverrides.global = _Overrides();
}

/// Server menjawab normal: provinsi → daftar kabupaten/kota.
void mockEquranCities(Map<String, List<String>> provinceToCities) {
  _cities = provinceToCities;
  _offline = false;
}

/// Server tidak terjangkau (koneksi mati / timeout).
void mockEquranOffline() {
  _offline = true;
  _cities = const {};
}

class _Overrides extends HttpOverrides {
  @override
  HttpClient createHttpClient(SecurityContext? context) => _Client();
}

class _Client implements HttpClient {
  @override
  Duration? connectionTimeout;
  @override
  Duration idleTimeout = const Duration(seconds: 15);
  @override
  bool autoUncompress = true;
  @override
  String? userAgent;

  @override
  Future<HttpClientRequest> postUrl(Uri url) async {
    if (_offline) throw const SocketException('mock: no route to host');
    return _Request();
  }

  @override
  dynamic noSuchMethod(Invocation invocation) =>
      throw UnimplementedError('mock HttpClient: ${invocation.memberName}');
}

class _Request implements HttpClientRequest {
  @override
  final HttpHeaders headers = _Headers();

  String _body = '';

  @override
  void write(Object? object) => _body = '$object';

  @override
  Future<HttpClientResponse> close() async {
    final provinsi =
        (jsonDecode(_body) as Map<String, dynamic>)['provinsi'] as String?;
    // Provinsi tidak ada di peta = server menjawab 200 dengan data kosong,
    // persis seperti provinsi salah di API asli.
    return _Response(
      jsonEncode({'code': 200, 'data': _cities[provinsi] ?? const <String>[]}),
    );
  }

  @override
  dynamic noSuchMethod(Invocation invocation) => throw UnimplementedError(
      'mock HttpClientRequest: ${invocation.memberName}');
}

class _Headers implements HttpHeaders {
  @override
  ContentType? contentType;

  @override
  dynamic noSuchMethod(Invocation invocation) =>
      throw UnimplementedError('mock HttpHeaders: ${invocation.memberName}');
}

class _Response extends Stream<List<int>> implements HttpClientResponse {
  _Response(this.body);
  final String body;

  @override
  int get statusCode => 200;

  @override
  int get contentLength => utf8.encode(body).length;

  @override
  HttpClientResponseCompressionState get compressionState =>
      HttpClientResponseCompressionState.notCompressed;

  @override
  StreamSubscription<List<int>> listen(
    void Function(List<int> event)? onData, {
    Function? onError,
    void Function()? onDone,
    bool? cancelOnError,
  }) =>
      Stream<List<int>>.value(utf8.encode(body)).listen(
        onData,
        onError: onError,
        onDone: onDone,
        cancelOnError: cancelOnError,
      );

  @override
  dynamic noSuchMethod(Invocation invocation) => throw UnimplementedError(
      'mock HttpClientResponse: ${invocation.memberName}');
}
