import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';

import '../models/product_model.dart' as product_models;
import '../models/order_model.dart' as order_models;
import '../models/inventory_movement_model.dart' as inventory_models;

class InventoryEngine {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<Map<String, (bool isAvailable, int availableStock, int requiredQuantity)>> checkStockAvailability(
    order_models.Order order,
  ) async {
    final result = <String, (bool, int, int)>{};
    for (final item in order.items) {
      final product = await _getProduct(item.productId);
      if (product == null) {
        result[item.productId] = (false, 0, item.quantity);
      } else {
        final available = product.currentStock - product.reservedStock;
        result[item.productId] = (available >= item.quantity, available, item.quantity);
      }
    }
    return result;
  }

  Future<ProductStockInfo> getProductStockInfo(String productId) async {
    final product = await _getProduct(productId);
    if (product == null) {
      throw Exception('Product not found');
    }
    return ProductStockInfo(
      productId: product.id,
      currentStock: product.currentStock,
      reservedStock: product.reservedStock,
      availableStock: product.currentStock - product.reservedStock,
      minStockLevel: product.minStockLevel,
      isLowStock: (product.currentStock - product.reservedStock) <= product.minStockLevel,
    );
  }

  Future<int> getTotalReservedStock() async {
    final snapshot = await _firestore.collection('products').get();
    int total = 0;
    for (final doc in snapshot.docs) {
      final data = doc.data();
      total += (data['reservedStock'] as int? ?? 0);
    }
    return total;
  }

  Future<int> getTotalAvailableStock() async {
    final snapshot = await _firestore.collection('products').get();
    int total = 0;
    for (final doc in snapshot.docs) {
      final data = doc.data();
      final current = (data['currentStock'] as int? ?? 0);
      final reserved = (data['reservedStock'] as int? ?? 0);
      total += (current - reserved).clamp(0, double.maxFinite).toInt();
    }
    return total;
  }

  // ---------- Atomic Stock Reservation (Overselling Prevent) ----------
  Future<void> reserveStock(order_models.Order order) async {
    try {
      await _firestore.runTransaction((transaction) async {
        final updates = <String, dynamic>{};
        final movements = <inventory_models.InventoryMovement>[];

        for (final item in order.items) {
          final productRef = _firestore.collection('products').doc(item.productId);
          final snapshot = await transaction.get(productRef);
          if (!snapshot.exists) {
            throw Exception('Product ${item.productId} not found');
          }
          final product = product_models.Product.fromFirestore(snapshot);
          final available = product.currentStock - product.reservedStock;
          if (available < item.quantity) {
            throw Exception('Insufficient available stock for product ${product.name}. '
                'Available: $available, Required: ${item.quantity}');
          }

          final newCurrentStock = product.currentStock - item.quantity;
          final newReservedStock = product.reservedStock + item.quantity;

          updates[productRef.path] = {
            'currentStock': newCurrentStock,
            'reservedStock': newReservedStock,
          };

          movements.add(inventory_models.InventoryMovement(
            movementId: '',
            productId: product.id,
            orderId: order.orderId,
            movementType: inventory_models.MovementType.reserve,
            quantity: -item.quantity,
            previousStock: product.currentStock,
            newStock: newCurrentStock.toInt(),
            userId: order.createdBy,
            remarks: 'Reserved for order ${order.orderNumber}',
            timestamp: DateTime.now(),
          ));
        }

        for (final entry in updates.entries) {
          final ref = _firestore.doc(entry.key);
          transaction.update(ref, entry.value);
        }

        for (final movement in movements) {
          final ref = _firestore.collection('inventory_movements').doc();
          final data = movement.copyWith(movementId: ref.id).toFirestore();
          transaction.set(ref, data);
        }
      });
      debugPrint('Stock reserved for order ${order.orderNumber}');
    } catch (e) {
      debugPrint('InventoryEngine.reserveStock error: $e');
      rethrow;
    }
  }

  Future<void> releaseReservedStock(order_models.Order order) async {
    try {
      await _firestore.runTransaction((transaction) async {
        final updates = <String, dynamic>{};
        final movements = <inventory_models.InventoryMovement>[];

        for (final item in order.items) {
          final productRef = _firestore.collection('products').doc(item.productId);
          final snapshot = await transaction.get(productRef);
          if (!snapshot.exists) {
            throw Exception('Product ${item.productId} not found');
          }
          final product = product_models.Product.fromFirestore(snapshot);
          if (product.reservedStock < item.quantity) {
            debugPrint('Warning: reservedStock (${product.reservedStock}) < quantity (${item.quantity}) for ${product.id}');
          }

          final newReservedStock = (product.reservedStock - item.quantity).clamp(0, double.maxFinite).toInt();
          final newCurrentStock = product.currentStock + item.quantity;

          updates[productRef.path] = {
            'reservedStock': newReservedStock,
            'currentStock': newCurrentStock,
          };

          movements.add(inventory_models.InventoryMovement(
            movementId: '',
            productId: product.id,
            orderId: order.orderId,
            movementType: inventory_models.MovementType.returned,
            quantity: item.quantity,
            previousStock: product.currentStock,
            newStock: newCurrentStock.toInt(),
            userId: order.createdBy,
            remarks: 'Released reserved stock for order ${order.orderNumber}',
            timestamp: DateTime.now(),
          ));
        }

        for (final entry in updates.entries) {
          final ref = _firestore.doc(entry.key);
          transaction.update(ref, entry.value);
        }

        for (final movement in movements) {
          final ref = _firestore.collection('inventory_movements').doc();
          final data = movement.copyWith(movementId: ref.id).toFirestore();
          transaction.set(ref, data);
        }
      });
      debugPrint('Reserved stock released for order ${order.orderNumber}');
    } catch (e) {
      debugPrint('InventoryEngine.releaseReservedStock error: $e');
      rethrow;
    }
  }

  Future<void> reduceStockOnDelivery(order_models.Order order) async {
    try {
      await _firestore.runTransaction((transaction) async {
        final updates = <String, dynamic>{};
        final movements = <inventory_models.InventoryMovement>[];

        for (final item in order.items) {
          final productRef = _firestore.collection('products').doc(item.productId);
          final snapshot = await transaction.get(productRef);
          if (!snapshot.exists) {
            throw Exception('Product ${item.productId} not found');
          }
          final product = product_models.Product.fromFirestore(snapshot);
          final newReservedStock = (product.reservedStock - item.quantity).clamp(0, double.maxFinite).toInt();

          updates[productRef.path] = {
            'reservedStock': newReservedStock,
          };

          movements.add(inventory_models.InventoryMovement(
            movementId: '',
            productId: product.id,
            orderId: order.orderId,
            movementType: inventory_models.MovementType.sale,
            quantity: -item.quantity,
            previousStock: product.currentStock,
            newStock: product.currentStock.toInt(),
            userId: order.createdBy,
            remarks: 'Order ${order.orderNumber} delivered, reserved stock finalised',
            timestamp: DateTime.now(),
          ));
        }

        for (final entry in updates.entries) {
          final ref = _firestore.doc(entry.key);
          transaction.update(ref, entry.value);
        }

        for (final movement in movements) {
          final ref = _firestore.collection('inventory_movements').doc();
          final data = movement.copyWith(movementId: ref.id).toFirestore();
          transaction.set(ref, data);
        }
      });
      debugPrint('Stock reduced on delivery for order ${order.orderNumber}');
    } catch (e) {
      debugPrint('InventoryEngine.reduceStockOnDelivery error: $e');
      rethrow;
    }
  }

  Future<void> returnStock(order_models.Order order) async {
    try {
      await _firestore.runTransaction((transaction) async {
        final updates = <String, dynamic>{};
        final movements = <inventory_models.InventoryMovement>[];

        for (final item in order.items) {
          final productRef = _firestore.collection('products').doc(item.productId);
          final snapshot = await transaction.get(productRef);
          if (!snapshot.exists) {
            throw Exception('Product ${item.productId} not found');
          }
          final product = product_models.Product.fromFirestore(snapshot);
          final newCurrentStock = product.currentStock + item.quantity;

          updates[productRef.path] = {
            'currentStock': newCurrentStock,
          };

          movements.add(inventory_models.InventoryMovement(
            movementId: '',
            productId: product.id,
            orderId: order.orderId,
            movementType: inventory_models.MovementType.returned,
            quantity: item.quantity,
            previousStock: product.currentStock,
            newStock: newCurrentStock.toInt(),
            userId: order.createdBy,
            remarks: 'Order ${order.orderNumber} returned, stock increased',
            timestamp: DateTime.now(),
          ));
        }

        for (final entry in updates.entries) {
          final ref = _firestore.doc(entry.key);
          transaction.update(ref, entry.value);
        }

        for (final movement in movements) {
          final ref = _firestore.collection('inventory_movements').doc();
          final data = movement.copyWith(movementId: ref.id).toFirestore();
          transaction.set(ref, data);
        }
      });
      debugPrint('Stock returned for order ${order.orderNumber}');
    } catch (e) {
      debugPrint('InventoryEngine.returnStock error: $e');
      rethrow;
    }
  }

  // ---------- Partner Stock ----------
  Future<void> reducePartnerStock({
    required String partnerId,
    required String platform,
    required int quantity,
  }) async {
    try {
      final snapshot = await _firestore
          .collection('partner_stock')
          .where('partnerId', isEqualTo: partnerId)
          .orderBy('createdAt', descending: true)
          .limit(1)
          .get();

      if (snapshot.docs.isEmpty) {
        throw Exception('No stock found for partner: $partnerId');
      }

      final doc = snapshot.docs.first;
      final data = doc.data() as Map<String, dynamic>;
      final platformStock = Map<String, double>.from(data['platformStock'] ?? {});
      final currentPlatformStock = platformStock[platform] ?? 0;

      if (currentPlatformStock < quantity) {
        throw Exception('Insufficient stock for platform: $platform. '
            'Available: $currentPlatformStock, Required: $quantity');
      }

      platformStock[platform] = currentPlatformStock - quantity;
      final remainingStock = (data['remainingStock'] ?? 0) - quantity;

      await doc.reference.update({
        'platformStock': platformStock,
        'remainingStock': remainingStock,
      });

      debugPrint('Partner stock reduced: $partnerId, $platform, -$quantity');
    } catch (e) {
      debugPrint('InventoryEngine.reducePartnerStock error: $e');
      rethrow;
    }
  }

  Future<Map<String, double>> getPartnerStock(String partnerId) async {
    final snapshot = await _firestore
        .collection('partner_stock')
        .where('partnerId', isEqualTo: partnerId)
        .orderBy('createdAt', descending: true)
        .limit(1)
        .get();

    if (snapshot.docs.isEmpty) {
      return {};
    }

    final data = snapshot.docs.first.data();
    return Map<String, double>.from(data['platformStock'] ?? {});
  }

  // ---------- Low Stock ----------
  Future<List<product_models.Product>> getLowStockProducts() async {
    final snapshot = await _firestore.collection('products').where('isActive', isEqualTo: true).get();
    final lowStock = <product_models.Product>[];
    for (final doc in snapshot.docs) {
      final product = product_models.Product.fromFirestore(doc);
      if (product.availableStock <= product.minStockLevel) {
        lowStock.add(product);
      }
    }
    return lowStock;
  }

  Future<Map<String, String>> getStockAlerts() async {
    final snapshot = await _firestore.collection('products').where('isActive', isEqualTo: true).get();
    final alerts = <String, String>{};
    for (final doc in snapshot.docs) {
      final product = product_models.Product.fromFirestore(doc);
      final available = product.availableStock;
      if (available <= 0) {
        alerts[product.id] = 'out';
      } else if (available <= product.minStockLevel) {
        alerts[product.id] = 'low';
      }
    }
    return alerts;
  }

  // ---------- Validation ----------
  Future<void> validateOrderInventory(order_models.Order order) async {
    for (final item in order.items) {
      final product = await _getProduct(item.productId);
      if (product == null) {
        throw Exception('Product ${item.productId} not found');
      }
      final available = product.currentStock - product.reservedStock;
      if (available < item.quantity) {
        throw Exception('Insufficient stock for product ${product.name}. '
            'Available: $available, Required: ${item.quantity}');
      }
    }
  }

  Future<product_models.Product?> _getProduct(String productId) async {
    final doc = await _firestore.collection('products').doc(productId).get();
    if (!doc.exists) return null;
    return product_models.Product.fromFirestore(doc);
  }
}

class ProductStockInfo {
  final String productId;
  final int currentStock;
  final int reservedStock;
  final int availableStock;
  final int minStockLevel;
  final bool isLowStock;

  ProductStockInfo({
    required this.productId,
    required this.currentStock,
    required this.reservedStock,
    required this.availableStock,
    required this.minStockLevel,
    required this.isLowStock,
  });
}