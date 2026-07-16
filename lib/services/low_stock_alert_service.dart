import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import '../models/product_model.dart';
import 'notification_service.dart';

class LowStockAlertService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final NotificationService _notificationService = NotificationService();

  static const int LOW_STOCK_THRESHOLD = 10;

  // Check all products for low stock
  Future<void> checkLowStock() async {
    try {
      final snapshot = await _firestore
          .collection('products')
          .where('isActive', isEqualTo: true)
          .get();

      for (final doc in snapshot.docs) {
        final product = Product.fromFirestore(doc);
        final availableStock = product.currentStock - product.reservedStock;

        if (availableStock <= LOW_STOCK_THRESHOLD) {
          // Send notification to Super Admin
          final superAdmins = await _firestore
              .collection('users')
              .where('role', isEqualTo: 'super_admin')
              .get();

          for (final admin in superAdmins.docs) {
            await _notificationService.sendNotification(
              userId: admin.id,
              title: '⚠️ Low Stock Alert',
              body: '${product.name} has only $availableStock units left!',
              type: 'low_stock',
              productId: product.id,
            );
          }
        }
      }
    } catch (e) {
      debugPrint('LowStockAlertService error: $e');
    }
  }

  // Get all products with low stock
  Future<List<Product>> getLowStockProducts() async {
    final snapshot = await _firestore
        .collection('products')
        .where('isActive', isEqualTo: true)
        .get();

    final List<Product> lowStockProducts = [];
    for (final doc in snapshot.docs) {
      final product = Product.fromFirestore(doc);
      final availableStock = product.currentStock - product.reservedStock;
      if (availableStock <= LOW_STOCK_THRESHOLD) {
        lowStockProducts.add(product);
      }
    }
    return lowStockProducts;
  }

  // Get low stock count
  Future<int> getLowStockCount() async {
    final products = await getLowStockProducts();
    return products.length;
  }
}