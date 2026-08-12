import 'package:flutter_test/flutter_test.dart';
import 'package:muslim_leveling/services/auth_service.dart';

void main() {
  test('builds a Firebase credential from an ID token without an access token', () {
    final credential = AuthService.googleCredentialForTokens(
      idToken: 'test-id-token',
    );

    expect(credential, isNotNull);
  });
}
