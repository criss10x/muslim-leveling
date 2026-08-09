import 'dart:convert';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'auth_service.dart';

/// One-time migration: Supabase user_data → Firestore doc for current user.
/// Data is bundled as an asset and injected once on first login.
class MigrationService {
  static const _migratedKey = 'supabase_migrated';

  /// Check if migration is needed and run it.
  /// Returns true if migration was performed.
  static Future<bool> maybeMigrate() async {
    final uid = AuthService.userId;
    if (uid == null || uid.isEmpty) return false;

    final prefs = await SharedPreferences.getInstance();
    if (prefs.getBool(_migratedKey) == true) return false;

    try {
      final json = await rootBundle.loadString('assets/supabase_export.json');
      final data = jsonDecode(json) as List<dynamic>;
      if (data.isEmpty) return false;

      // Pick the row with most XP (the user's main account)
      dynamic best = data.first;
      for (final row in data) {
        final xp = row['game']?['xp'] ?? 0;
        if (xp > (best['game']?['xp'] ?? 0)) best = row;
      }

      await FirebaseFirestore.instance
          .collection('user_data')
          .doc(uid)
          .set({
        'game': best['game'] ?? {},
        'learning': best['learning'] ?? {},
        'achievements': best['achievements'] ?? {},
        'migrated_from': 'supabase',
        'updated_at': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));

      await prefs.setBool(_migratedKey, true);
      return true;
    } catch (_) {
      return false; // silent: migration is best-effort
    }
  }
}