import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';

class NotificationService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Send notification
  Future<void> sendNotification({
    required String userId,
    required String title,
    required String body,
    required String type, // order, payment, stock, invoice, etc.
    String? orderId,
    String? productId,
  }) async {
    try {
      final notification = {
        'userId': userId,
        'title': title,
        'body': body,
        'type': type,
        'orderId': orderId,
        'productId': productId,
        'isRead': false,
        'createdAt': FieldValue.serverTimestamp(),
      };
      await _firestore.collection('notifications').add(notification);
    } catch (e) {
      debugPrint('Notification send error: $e');
    }
  }

  // Get notifications for a user
  Stream<QuerySnapshot> getUserNotifications(String userId) {
    return _firestore
        .collection('notifications')
        .where('userId', isEqualTo: userId)
        .orderBy('createdAt', descending: true)
        .snapshots();
  }

  // Mark notification as read
  Future<void> markAsRead(String notificationId) async {
    await _firestore.collection('notifications').doc(notificationId).update({
      'isRead': true,
    });
  }

  // Get unread count
  Future<int> getUnreadCount(String userId) async {
    final snapshot = await _firestore
        .collection('notifications')
        .where('userId', isEqualTo: userId)
        .where('isRead', isEqualTo: false)
        .get();
    return snapshot.docs.length;
  }

  // Show toast notification
  void showToast(String message) {
    Fluttertoast.showToast(
      msg: message,
      toastLength: Toast.LENGTH_LONG,
      gravity: ToastGravity.BOTTOM,
      backgroundColor: Colors.black87,
      textColor: Colors.white,
    );
  }
}