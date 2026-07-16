import 'dart:convert';
import 'package:cloud_firestore/cloud_firestore.dart';

class BulkService {
  // ---------- Export Orders to CSV ----------
  static Future<String> exportOrders() async {
    final snapshot = await FirebaseFirestore.instance.collection('orders').get();
    final orders = snapshot.docs.map((doc) => doc.data()).toList();
    return jsonEncode(orders);
  }

  // ---------- Import Orders ----------
  static Future<void> importOrders(String jsonData) async {
    final orders = jsonDecode(jsonData) as List;
    final batch = FirebaseFirestore.instance.batch();

    for (final order in orders) {
      final ref = FirebaseFirestore.instance.collection('orders').doc();
      batch.set(ref, order);
    }

    await batch.commit();
  }
}