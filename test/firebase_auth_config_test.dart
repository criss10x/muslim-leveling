import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:muslim_leveling/services/auth_service.dart';

void main() {
  test('uses the Web OAuth client and Play signing certificate', () {
    final config =
        jsonDecode(File('android/app/google-services.json').readAsStringSync())
            as Map<String, dynamic>;
    final client = (config['client'] as List).single as Map;
    final oauthClients = client['oauth_client'] as List;
    final webClient = oauthClients.cast<Map>().singleWhere(
      (oauth) => oauth['client_type'] == 3,
    );
    final androidSha1s = oauthClients
        .cast<Map>()
        .where((oauth) => oauth['client_type'] == 1)
        .map((oauth) => oauth['android_info']['certificate_hash'])
        .toSet();

    expect(webClient['client_id'], AuthService.googleWebClientId);
    expect(
      androidSha1s,
      contains('714387b55178b56364101ca4a1e15450e2cd17e8'),
    );
  });
}
