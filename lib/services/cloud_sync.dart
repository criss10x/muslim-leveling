import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';

/// Sync 3 JSON blobs to Firestore. One doc per signed-in user.
/// Collection: `user_data`, doc ID = Firebase Auth uid.
class CloudSync {
  static String? _pendingUserId;
  static String? _validatedUserId;
  static int _validationVersion = 0;
  static Future<Map<String, dynamic>?> Function(String id) _readDocument =
      _readFirestoreDocument;

  /// True only after Firebase Auth and a strict Firestore read both succeed.
  static bool get canSync =>
      _pendingUserId != null &&
      _pendingUserId!.isNotEmpty &&
      _pendingUserId == _validatedUserId;

  static String get _id {
    final id = _validatedUserId;
    if (!canSync || id == null || id.isEmpty) {
      throw StateError('CloudSync used while signed out');
    }
    return id;
  }

  static void init(String id) {} // ponytail: no-op; cloud only after initWithUser

  /// Records Firebase Auth state without starting an unawaited Firestore read.
  static void recordAuthenticatedUser(String userId) {
    if (_pendingUserId != userId) {
      _validatedUserId = null;
      _validationVersion++;
    }
    _pendingUserId = userId;
  }

  /// Validates [userId]'s remote document before allowing any cloud writes.
  static Future<Map<String, dynamic>?> initWithUser(String userId) async {
    recordAuthenticatedUser(userId);
    _validatedUserId = null;
    final validationVersion = ++_validationVersion;
    final remote = await load(failOnError: true);
    if (_pendingUserId != userId || _validationVersion != validationVersion) {
      throw StateError('CloudSync user changed during validation');
    }
    _validatedUserId = userId;
    return remote;
  }

  static void clearUser() {
    _pendingUserId = null;
    _validatedUserId = null;
    _validationVersion++;
  }

  static Future<bool> saveGame(Map<String, dynamic> data) =>
      _upsert({'game': data});

  static Future<bool> saveLearning(Map<String, dynamic> data) =>
      _upsert({'learning': data});

  static Future<bool> saveAchievements(Map<String, dynamic> data) =>
      _upsert({'achievements': data});

  static bool allSaved(Iterable<bool> results) =>
      results.every((saved) => saved);

  static Future<Map<String, dynamic>?> load({bool failOnError = false}) async {
    final id = canSync
        ? _id
        : failOnError
        ? _pendingUserId
        : null;
    if (id == null || id.isEmpty) return null;
    try {
      return await _readDocument(id);
    } catch (_) {
      if (failOnError) rethrow;
      return null;
    }
  }

  static Future<Map<String, dynamic>?> _readFirestoreDocument(String id) async {
    final doc = await FirebaseFirestore.instance
        .collection('user_data')
        .doc(id)
        .get();
    return doc.exists ? doc.data() : null;
  }

  @visibleForTesting
  static set documentReader(
    Future<Map<String, dynamic>?> Function(String id) reader,
  ) => _readDocument = reader;

  @visibleForTesting
  static void resetDocumentReader() => _readDocument = _readFirestoreDocument;

  static Future<Map<String, dynamic>?> loadGame() async {
    final row = await load();
    return row?['game'] as Map<String, dynamic>?;
  }

  static Future<Map<String, dynamic>?> loadLearning() async {
    final row = await load();
    return row?['learning'] as Map<String, dynamic>?;
  }

  static Future<Map<String, dynamic>?> loadAchievements() async {
    final row = await load();
    return row?['achievements'] as Map<String, dynamic>?;
  }

  static Future<bool> _upsert(Map<String, dynamic> extra) async {
    if (!canSync) return false;
    try {
      await FirebaseFirestore.instance.collection('user_data').doc(_id).set(
        {
          ...extra,
          'updated_at': FieldValue.serverTimestamp(),
        },
        SetOptions(merge: true),
      );
      return true;
    } catch (_) {
      return false; // silent: local is source of truth
    }
  }
}
