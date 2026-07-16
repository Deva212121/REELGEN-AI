import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/order_model.dart' as order_models;
import '../models/product_model.dart';

class AnalyticsService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // ---------- Today's Revenue ----------
  Future<double> getTodayRevenue() async {
    final today = DateTime.now();
    final startOfDay = DateTime(today.year, today.month, today.day);
    final endOfDay = DateTime(today.year, today.month, today.day, 23, 59, 59);

    final snapshot = await _firestore
        .collection('orders')
        .where('status', isEqualTo: 'delivered')
        .where('deliveredAt', isGreaterThanOrEqualTo: startOfDay)
        .where('deliveredAt', isLessThanOrEqualTo: endOfDay)
        .get();

    double total = 0;
    for (final doc in snapshot.docs) {
      total += (doc.data()['orderAmount'] ?? 0);
    }
    return total;
  }

  // ---------- Monthly Revenue ----------
  Future<double> getMonthlyRevenue() async {
    final now = DateTime.now();
    final startOfMonth = DateTime(now.year, now.month, 1);
    final endOfMonth = DateTime(now.year, now.month + 1, 0, 23, 59, 59);

    final snapshot = await _firestore
        .collection('orders')
        .where('status', isEqualTo: 'delivered')
        .where('deliveredAt', isGreaterThanOrEqualTo: startOfMonth)
        .where('deliveredAt', isLessThanOrEqualTo: endOfMonth)
        .get();

    double total = 0;
    for (final doc in snapshot.docs) {
      total += (doc.data()['orderAmount'] ?? 0);
    }
    return total;
  }

  // ---------- Last 15 Days Revenue ----------
  Future<Map<DateTime, double>> getRevenueLast15Days() async {
    final endDate = DateTime.now();
    final startDate = endDate.subtract(const Duration(days: 15));
    final snapshot = await _firestore
        .collection('orders')
        .where('status', isEqualTo: 'delivered')
        .where('deliveredAt', isGreaterThanOrEqualTo: startDate)
        .where('deliveredAt', isLessThanOrEqualTo: endDate)
        .get();

    final Map<DateTime, double> dailyRevenue = {};
    for (final doc in snapshot.docs) {
      final data = doc.data();
      final deliveredAt = (data['deliveredAt'] as Timestamp?)?.toDate();
      if (deliveredAt != null) {
        final day = DateTime(deliveredAt.year, deliveredAt.month, deliveredAt.day);
        dailyRevenue[day] = (dailyRevenue[day] ?? 0) + (data['orderAmount'] ?? 0);
      }
    }
    return dailyRevenue;
  }

  // ---------- Last 30 Days Revenue ----------
  Future<Map<DateTime, double>> getRevenueLast30Days() async {
    final endDate = DateTime.now();
    final startDate = endDate.subtract(const Duration(days: 30));
    final snapshot = await _firestore
        .collection('orders')
        .where('status', isEqualTo: 'delivered')
        .where('deliveredAt', isGreaterThanOrEqualTo: startDate)
        .where('deliveredAt', isLessThanOrEqualTo: endDate)
        .get();

    final Map<DateTime, double> dailyRevenue = {};
    for (final doc in snapshot.docs) {
      final data = doc.data();
      final deliveredAt = (data['deliveredAt'] as Timestamp?)?.toDate();
      if (deliveredAt != null) {
        final day = DateTime(deliveredAt.year, deliveredAt.month, deliveredAt.day);
        dailyRevenue[day] = (dailyRevenue[day] ?? 0) + (data['orderAmount'] ?? 0);
      }
    }
    return dailyRevenue;
  }

  // ---------- Top Products ----------
  Future<List<Map<String, dynamic>>> getTopProducts({int limit = 5}) async {
    final snapshot = await _firestore
        .collection('orders')
        .where('status', isEqualTo: 'delivered')
        .get();

    final Map<String, int> productCount = {};
    final Map<String, double> productRevenue = {};
    final Map<String, String> productName = {};

    for (final doc in snapshot.docs) {
      final data = doc.data();
      final items = data['items'] as List<dynamic>? ?? [];
      for (final item in items) {
        final id = item['productId'] ?? '';
        final name = item['productName'] ?? 'Unknown';
        final qty = item['quantity'] ?? 1;
        final price = (item['unitPrice'] ?? 0).toDouble();

        productName[id] = name;
        productCount[id] = (productCount[id] ?? 0) + (qty as int);
        productRevenue[id] = (productRevenue[id] ?? 0) + (price * qty);
      }
    }

    final result = productCount.keys.map((id) {
      return {
        'id': id,
        'name': productName[id] ?? 'Unknown',
        'totalSold': productCount[id] ?? 0,
        'revenue': productRevenue[id] ?? 0,
      };
    }).toList();

    result.sort((a, b) => (b['totalSold'] as int).compareTo(a['totalSold'] as int));
    return result.take(limit).toList();
  }

  // ---------- Top Influencers ----------
  Future<List<Map<String, dynamic>>> getTopInfluencers({int limit = 5}) async {
    final snapshot = await _firestore
        .collection('orders')
        .where('status', isEqualTo: 'delivered')
        .get();

    final Map<String, double> influencerRevenue = {};
    final Map<String, String> influencerName = {};

    for (final doc in snapshot.docs) {
      final data = doc.data();
      final id = data['influencerId'] ?? '';
      final name = data['influencerName'] ?? 'Unknown';
      final amount = (data['orderAmount'] ?? 0).toDouble();

      influencerName[id] = name;
      influencerRevenue[id] = (influencerRevenue[id] ?? 0) + amount;
    }

    final result = influencerRevenue.keys.map((id) {
      return {
        'id': id,
        'name': influencerName[id] ?? 'Unknown',
        'revenue': influencerRevenue[id] ?? 0,
      };
    }).toList();

    result.sort((a, b) => (b['revenue'] as double).compareTo(a['revenue'] as double));
    return result.take(limit).toList();
  }

  // ---------- Top Vendors ----------
  Future<List<Map<String, dynamic>>> getTopVendors({int limit = 5}) async {
    final snapshot = await _firestore
        .collection('orders')
        .where('status', isEqualTo: 'delivered')
        .get();

    final Map<String, double> vendorRevenue = {};
    final Map<String, String> vendorName = {};

    for (final doc in snapshot.docs) {
      final data = doc.data();
      final id = data['vendorId'] ?? '';
      final name = data['vendorName'] ?? 'Unknown';
      final amount = (data['orderAmount'] ?? 0).toDouble();

      vendorName[id] = name;
      vendorRevenue[id] = (vendorRevenue[id] ?? 0) + amount;
    }

    final result = vendorRevenue.keys.map((id) {
      return {
        'id': id,
        'name': vendorName[id] ?? 'Unknown',
        'revenue': vendorRevenue[id] ?? 0,
      };
    }).toList();

    result.sort((a, b) => (b['revenue'] as double).compareTo(a['revenue'] as double));
    return result.take(limit).toList();
  }

  // ---------- Pending Orders Count ----------
  Future<int> getPendingOrdersCount() async {
    final snapshot = await _firestore
        .collection('orders')
        .where('status', whereIn: ['awaitingVerification', 'verified', 'packed', 'shipped'])
        .get();
    return snapshot.docs.length;
  }

  // ---------- Total Orders Count ----------
  Future<int> getTotalOrdersCount() async {
    final snapshot = await _firestore.collection('orders').get();
    return snapshot.docs.length;
  }
}