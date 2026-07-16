import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/order_model.dart' as order_models;

/// Service for revenue analytics.
class RevenueAnalyticsService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  Future<List<order_models.Order>> getUserOrders({String? role}) async {
    final user = _auth.currentUser;
    if (user == null) return [];
    try {
      Query query = _firestore
          .collection('orders')
          .where('influencerId', isEqualTo: user.uid)
          .orderBy('createdAt', descending: true);
      if (role != null) {
        query = query.where('influencerRole', isEqualTo: role);
      }
      final snapshot = await query.get();
      return snapshot.docs.map((doc) => order_models.Order.fromFirestore(doc)).toList();
    } catch (e) {
      return [];
    }
  }

  Future<double> getTotalRevenue({String? role}) async {
    final orders = await getUserOrders(role: role);
    double total = 0.0;
    for (final order in orders) {
      total += order.orderAmount;
    }
    return total;
  }

  Future<Map<String, double>> getRevenueByMonth({String? role}) async {
    final orders = await getUserOrders(role: role);
    final Map<String, double> monthlyRevenue = {};
    for (final o in orders) {
      final monthKey = '${o.createdAt.year}-${o.createdAt.month.toString().padLeft(2, '0')}';
      monthlyRevenue[monthKey] = (monthlyRevenue[monthKey] ?? 0) + o.orderAmount;
    }
    return monthlyRevenue;
  }

  Future<Map<DateTime, double>> getRevenueLast30Days({String? role}) async {
    final endDate = DateTime.now();
    final startDate = endDate.subtract(const Duration(days: 30));
    final orders = await getUserOrders(role: role);
    final Map<DateTime, double> dailyRevenue = {};
    for (final o in orders) {
      if (o.createdAt.isAfter(startDate) && o.createdAt.isBefore(endDate)) {
        final day = DateTime(o.createdAt.year, o.createdAt.month, o.createdAt.day);
        dailyRevenue[day] = (dailyRevenue[day] ?? 0) + o.orderAmount;
      }
    }
    return dailyRevenue;
  }
}