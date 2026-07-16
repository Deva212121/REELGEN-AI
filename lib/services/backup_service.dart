import 'dart:convert';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';

class BackupService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseStorage _storage = FirebaseStorage.instance;

  // ---------- Backup All Collections ----------
  Future<String> createBackup() async {
    try {
      final collections = ['orders', 'products', 'users', 'partner_stock', 'inventory_movements', 'audit_logs'];
      final backupData = <String, dynamic>{};

      for (final collection in collections) {
        final snapshot = await _firestore.collection(collection).get();
        final documents = snapshot.docs.map((doc) {
          return {
            'id': doc.id,
            'data': doc.data(),
          };
        }).toList();
        backupData[collection] = documents;
      }

      final jsonData = jsonEncode(backupData);
      final timestamp = DateTime.now().millisecondsSinceEpoch;
      final fileName = 'backup_$timestamp.json';

      // Upload to Firebase Storage
      final ref = _storage.ref().child('backups/$fileName');
      await ref.putString(jsonData);

      return await ref.getDownloadURL();
    } catch (e) {
      throw Exception('Backup failed: $e');
    }
  }
}