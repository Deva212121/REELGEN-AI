import 'package:cloud_firestore/cloud_firestore.dart';

class SettingsModel {
  final int commissionReleaseDays; // Default: 7

  SettingsModel({this.commissionReleaseDays = 7});

  factory SettingsModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return SettingsModel(
      commissionReleaseDays: data['commissionReleaseDays'] ?? 7,
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'commissionReleaseDays': commissionReleaseDays,
    };
  }
}