import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:sentry_flutter/sentry_flutter.dart';

import 'backup_merge.dart';

/// Sync 3 JSON blobs to Firestore. One doc per signed-in user.
/// Collection: `user_data`, doc ID = Firebase Auth uid.
class CloudSync {
  static String? _pendingUserId;
  static String? _validatedUserId;
  static int _validationVersion = 0;
  static Future<Map<String, dynamic>?> Function(String id) _readDocument =
      _readFirestoreDocument;
  static Future<void> Function(String id, Map<String, dynamic> data)
      _writeDocument = _writeFirestoreDocument;

  /// XP terakhir yang diketahui ada di cloud (dari setiap read sukses).
  /// Dipakai menolak push yang akan meregresi progres cloud.
  static int? _cloudGameXp;

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
      _cloudGameXp = null; // akun berbeda → garis dasar XP berbeda
      _validationVersion++;
    }
    _pendingUserId = userId;
  }

  /// Validates [userId]'s remote document before allowing any cloud writes.
  static Future<Map<String, dynamic>?> initWithUser(String userId) async {
    recordAuthenticatedUser(userId);
    _validatedUserId = null;
    final validationVersion = ++_validationVersion;
    try {
      final remote = await load(failOnError: true);
      if (_pendingUserId != userId || _validationVersion != validationVersion) {
        throw StateError('CloudSync user changed during validation');
      }
      _validatedUserId = userId;
      return remote; // remote boleh null (user baru), tapi validasi sukses
    } catch (_) {
      // Network down / Firestore error: jangan throw, clear state
      _validatedUserId = null;
      _validationVersion++;
      return null;
    }
  }

  static void clearUser() {
    _pendingUserId = null;
    _validatedUserId = null;
    _cloudGameXp = null; // akun lain = garis dasar XP lain
    _validationVersion++;
  }

  /// Push game state ke cloud, TAPI tolak kalau akan meregresi progres cloud.
  ///
  /// ponytail: akar bug "sync mengikuti HP" — dulu map `game` dikirim utuh
  /// (SetOptions(merge:true) cuma merge di level *field*, jadi `game` tetap
  /// last-write-wins) sehingga device berprogres rendah menimpa cloud level 31
  /// → level 2. Guard di sini (choke point semua pemanggil) bukan di tiap caller.
  static Future<bool> saveGame(Map<String, dynamic> data) async {
    final known = _cloudGameXp;
    if (known != null && isXpRegression(data, {'xp': known})) {
      // Auto-heal: ambil state cloud, gabung (max-XP menang + data lokal
      // yang lebih kaya dipertahankan), lalu push hasil gabungan.
      final remote = (await load())?['game'];
      if (remote is! Map) return false; // tak bisa dipastikan → tahan push
      final merged = pickRicherGame(data, Map<String, dynamic>.from(remote));
      unawaited(
        Sentry.captureMessage(
          'CloudSync: blokir regresi XP lokal=${data['xp']} cloud=$known',
          level: SentryLevel.warning,
        ),
      );
      final saved = await _upsert({'game': merged});
      if (saved) _cloudGameXp = (merged['xp'] as num?)?.toInt() ?? known;
      return saved;
    }
    final saved = await _upsert({'game': data});
    if (saved) _cloudGameXp = (data['xp'] as num?)?.toInt();
    return saved;
  }

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
      final row = await _readDocument(id);
      _rememberCloudXp(row);
      return row;
    } catch (_) {
      if (failOnError) rethrow;
      return null;
    }
  }

  /// Catat XP game yang benar-benar ada di cloud. Null (doc kosong) sengaja
  /// TIDAK menghapus nilai lama — garis dasar tetap dari read terakhir yang sah.
  static void _rememberCloudXp(Map<String, dynamic>? row) {
    final game = row?['game'];
    if (game is! Map) return;
    final xp = (game['xp'] as num?)?.toInt();
    if (xp != null) _cloudGameXp = xp;
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

  @visibleForTesting
  static set documentWriter(
    Future<void> Function(String id, Map<String, dynamic> data) writer,
  ) => _writeDocument = writer;

  @visibleForTesting
  static void resetDocumentWriter() => _writeDocument = _writeFirestoreDocument;

  /// XP game terakhir yang diketahui ada di cloud (null bila belum pernah
  /// terbaca). Dipakai `GameService.load()` untuk heal di tempat tanpa read
  /// tambahan di jalur normal.
  static int? get knownCloudGameXp => _cloudGameXp;

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
    final id = _id;
    try {
      await _writeDocument(id, {
        ...extra,
        'updated_at': FieldValue.serverTimestamp(),
      });
      return true;
    } catch (_) {
      return false; // silent: local is source of truth
    }
  }

  static Future<void> _writeFirestoreDocument(
    String id,
    Map<String, dynamic> data,
  ) async {
    await FirebaseFirestore.instance.collection('user_data').doc(id).set(
          data,
          SetOptions(merge: true),
        );
  }
}
