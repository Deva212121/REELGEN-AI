import 'package:cloud_firestore/cloud_firestore.dart';

class FeatureFlags {
  static final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  static Future<bool> isEnabled(String feature) async {
    try {
      final doc = await _firestore.doc('feature_flags/$feature').get();
      return doc.data()?['enabled'] ?? false;
    } catch (e) {
      return false;
    }
  }

  static Future<void> setEnabled(String feature, bool enabled) async {
    await _firestore.doc('feature_flags/$feature').set({
      'enabled': enabled,
      'updatedAt': FieldValue.serverTimestamp(),
    });
  }

  static Future<Map<String, bool>> getAllFlags() async {
    final snapshot = await _firestore.collection('feature_flags').get();
    final flags = <String, bool>{};
    for (final doc in snapshot.docs) {
      flags[doc.id] = doc.data()['enabled'] ?? false;
    }
    return flags;
  }
}