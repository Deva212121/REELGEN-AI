import 'package:cloud_firestore/cloud_firestore.dart';

class ArchiveService {
  static const int RETENTION_DAYS = 365; // 1 year

  // ---------- Archive Old Orders ----------
  static Future<void> archiveOldOrders() async {
    final cutoffDate = DateTime.now().subtract(Duration(days: RETENTION_DAYS));

    final snapshot = await FirebaseFirestore.instance
        .collection('orders')
        .where('createdAt', isLessThan: cutoffDate)
        .get();

    for (final doc in snapshot.docs) {
      await doc.reference.update({
        'isArchived': true,
        'archivedAt': FieldValue.serverTimestamp(),
      });
    }
  }

  // ---------- Delete Archived Data ----------
  static Future<void> deleteArchivedData() async {
    final snapshot = await FirebaseFirestore.instance
        .collection('orders')
        .where('isArchived', isEqualTo: true)
        .get();

    for (final doc in snapshot.docs) {
      await doc.reference.delete();
    }
  }
}