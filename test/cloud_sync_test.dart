import 'package:flutter_test/flutter_test.dart';
import 'package:muslim_leveling/services/cloud_sync.dart';

void main() {
  setUp(() => CloudSync.initWithUser('test-user'));
  tearDown(() {
    CloudSync.resetDocumentReader();
    CloudSync.clearUser();
  });

  test('load returns a present document', () async {
    CloudSync.documentReader = (id) async {
      expect(id, 'test-user');
      return {'game': {'xp': 120}};
    };

    expect(
      await CloudSync.load(failOnError: true),
      {'game': {'xp': 120}},
    );
  });

  test('load returns null for an absent document', () async {
    CloudSync.documentReader = (_) async => null;

    expect(await CloudSync.load(failOnError: true), isNull);
  });

  test('load rethrows a reader error in strict mode', () async {
    CloudSync.documentReader = (_) async => throw StateError('Firestore down');

    await expectLater(
      CloudSync.load(failOnError: true),
      throwsA(isA<StateError>()),
    );
  });

  test('load keeps returning null for reader errors by default', () async {
    CloudSync.documentReader = (_) async => throw StateError('Firestore down');

    expect(await CloudSync.load(), isNull);
  });
}
