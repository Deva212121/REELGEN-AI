import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'dart:io';

class AuditService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // ---------- Log Action ----------
  Future<void> logAction({
    required String action,
    required String module,
    Map<String, dynamic>? before,
    Map<String, dynamic>? after,
    String? orderId,
    String? productId,
    String? userId,
    String? ipAddress,
    bool success = true,
    String? errorMessage,
  }) async {
    try {
      final user = _auth.currentUser;
      final log = {
        'action': action,
        'module': module,
        'userId': userId ?? user?.uid ?? 'anonymous',
        'userEmail': user?.email ?? '',
        'userRole': await _getUserRole(user?.uid),
        'before': before,
        'after': after,
        'orderId': orderId,
        'productId': productId,
        'ipAddress': ipAddress ?? await _getIpAddress(),
        'success': success,
        'errorMessage': errorMessage,
        'timestamp': FieldValue.serverTimestamp(),
        'isDeleted': false,
      };

      await _firestore.collection('audit_logs').add(log);
    } catch (e) {
      // Don't throw — just log error
      print('Audit log failed: $e');
    }
  }

  // ---------- Get User Logs ----------
  Stream<QuerySnapshot> getUserLogs(String userId) {
    return _firestore
        .collection('audit_logs')
        .where('userId', isEqualTo: userId)
        .orderBy('timestamp', descending: true)
        .limit(100)
        .snapshots();
  }

  // ---------- Get Admin Logs ----------
  Stream<QuerySnapshot> getAdminLogs() {
    return _firestore
        .collection('audit_logs')
        .orderBy('timestamp', descending: true)
        .limit(100)
        .snapshots();
  }

  // ---------- Helpers ----------
  Future<String?> _getUserRole(String? uid) async {
    if (uid == null) return null;
    try {
      final doc = await _firestore.collection('users').doc(uid).get();
      return doc.data()?['role'] as String?;
    } catch (e) {
      return null;
    }
  }

  Future<String?> _getIpAddress() async {
    try {
      // For web, use window.location
      // For mobile, use platform channel
      return '0.0.0.0';
    } catch (e) {
      return null;
    }
  }
}