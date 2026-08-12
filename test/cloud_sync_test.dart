import 'dart:async';

import 'package:flutter_test/flutter_test.dart';
import 'package:muslim_leveling/services/cloud_sync.dart';

void main() {
  setUp(CloudSync.clearUser);
  tearDown(() {
    CloudSync.resetDocumentReader();
    CloudSync.clearUser();
  });

  test('load returns a present document', () async {
    CloudSync.recordAuthenticatedUser('test-user');
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
    CloudSync.recordAuthenticatedUser('test-user');
    CloudSync.documentReader = (_) async => null;

    expect(await CloudSync.load(failOnError: true), isNull);
  });

  test('load rethrows a reader error in strict mode', () async {
    CloudSync.recordAuthenticatedUser('test-user');
    CloudSync.documentReader = (_) async => throw StateError('Firestore down');

    await expectLater(
      CloudSync.load(failOnError: true),
      throwsA(isA<StateError>()),
    );
  });

  test('load keeps returning null for reader errors by default', () async {
    CloudSync.documentReader = (_) async => {'game': {'xp': 120}};
    await CloudSync.initWithUser('test-user');
    CloudSync.documentReader = (_) async => throw StateError('Firestore down');

    expect(await CloudSync.load(), isNull);
  });

  test('validation keeps writes disabled until the strict read completes', () async {
    final readCompleter = Completer<Map<String, dynamic>?>();
    CloudSync.documentReader = (id) {
      expect(id, 'test-user');
      return readCompleter.future;
    };

    final validation = CloudSync.initWithUser('test-user');

    expect(CloudSync.canSync, isFalse);
    expect(await CloudSync.saveGame({'xp': 120}), isFalse);

    readCompleter.complete({'game': {'xp': 120}});
    expect(await validation, {'game': {'xp': 120}});
    expect(CloudSync.canSync, isTrue);
  });

  test('validation read error leaves writes disabled', () async {
    CloudSync.documentReader = (_) async => throw StateError('Firestore down');

    await expectLater(
      CloudSync.initWithUser('test-user'),
      throwsA(isA<StateError>()),
    );

    expect(CloudSync.canSync, isFalse);
    expect(await CloudSync.saveGame({'xp': 120}), isFalse);
  });

  test('an old validation read cannot re-enable sync after an account change', () async {
    final oldRead = Completer<Map<String, dynamic>?>();
    CloudSync.documentReader = (id) {
      expect(id, 'old-user');
      return oldRead.future;
    };

    final validation = CloudSync.initWithUser('old-user');
    CloudSync.recordAuthenticatedUser('new-user');
    oldRead.complete({'game': {'xp': 120}});

    await expectLater(validation, throwsA(isA<StateError>()));
    expect(CloudSync.canSync, isFalse);
    expect(await CloudSync.saveGame({'xp': 120}), isFalse);
  });

  test('clearing the user invalidates a pending validation read', () async {
    final pendingRead = Completer<Map<String, dynamic>?>();
    CloudSync.documentReader = (_) => pendingRead.future;

    final validation = CloudSync.initWithUser('test-user');
    CloudSync.clearUser();
    pendingRead.complete({'game': {'xp': 120}});

    await expectLater(validation, throwsA(isA<StateError>()));
    expect(CloudSync.canSync, isFalse);
    expect(await CloudSync.saveGame({'xp': 120}), isFalse);
  });
}
