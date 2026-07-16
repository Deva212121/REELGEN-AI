import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/settings_model.dart';

class SettingsService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<int> getCommissionReleaseDays() async {
    try {
      final doc = await _firestore.doc('settings/platform').get();
      if (doc.exists) {
        final settings = SettingsModel.fromFirestore(doc);
        return settings.commissionReleaseDays;
      }
    } catch (e) {
      print('Error fetching settings: $e');
    }
    return 7; // Default
  }

  Future<void> updateCommissionReleaseDays(int days) async {
    await _firestore.doc('settings/platform').set(
      {'commissionReleaseDays': days},
      SetOptions(merge: true),
    );
  }
}