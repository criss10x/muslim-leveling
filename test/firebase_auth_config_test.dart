import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:muslim_leveling/services/auth_service.dart';

void main() {
  test('uses the Web OAuth client from google-services.json', () {
    final config =
        jsonDecode(File('android/app/google-services.json').readAsStringSync())
            as Map<String, dynamic>;
    final clients = (config['client'] as List).single as Map;
    final oauthClients = clients['oauth_client'] as List;
    final webClient = (oauthClients.single as Map)['client_id'] as String;

    expect(AuthService.googleWebClientId, webClient);
  });
}
