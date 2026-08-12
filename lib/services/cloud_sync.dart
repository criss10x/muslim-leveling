import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';

/// Sync 3 JSON blobs to Firestore. One doc per signed-in user.
/// Collection: `user_data`, doc ID = Firebase Auth uid.
class CloudSync {
  static String? _userId;
  static Future<Map<String, dynamic>?> Function(String id) _readDocument =
      _readFirestoreDocument;

  /// True only after Firebase Auth succeeds.
  static bool get canSync => _userId != null && _userId!.isNotEmpty;

  static String get _id {
    final id = _userId;
    if (id == null || id.isEmpty) {
      throw StateError('CloudSync used while signed out');
    }
    return id;
  }

  static void init(String id) {} // ponytail: no-op; cloud only after initWithUser

  static void initWithUser(String userId) => _userId = userId;
  static void clearUser() => _userId = null;

  static Future<bool> saveGame(Map<String, dynamic> data) =>
      _upsert({'game': data});

  static Future<bool> saveLearning(Map<String, dynamic> data) =>
      _upsert({'learning': data});

  static Future<bool> saveAchievements(Map<String, dynamic> data) =>
      _upsert({'achievements': data});

  static bool allSaved(Iterable<bool> results) =>
      results.every((saved) => saved);

  static Future<Map<String, dynamic>?> load({bool failOnError = false}) async {
    if (!canSync) return null;
    try {
      return await _readDocument(_id);
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
