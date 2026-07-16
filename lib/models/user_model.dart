import 'package:cloud_firestore/cloud_firestore.dart';

class UserModel {
  final String uid;
  final String displayName;
  final String email;
  final String role; // influencer, vendor, admin, super_admin, sub_admin
  final String? assignedPartnerId; // sirf sub-admin ke liye

  UserModel({
    required this.uid,
    required this.displayName,
    required this.email,
    required this.role,
    this.assignedPartnerId,
  });

  factory UserModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return UserModel(
      uid: doc.id,
      displayName: data['displayName'] ?? '',
      email: data['email'] ?? '',
      role: data['role'] ?? 'influencer',
      assignedPartnerId: data['assignedPartnerId'],
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'displayName': displayName,
      'email': email,
      'role': role,
      'assignedPartnerId': assignedPartnerId,
    };
  }
}