import 'package:cloud_firestore/cloud_firestore.dart';

/// Type of inventory movement.
enum MovementType {
  purchase,   // Stock added via purchase/restock
  reserve,    // Stock reserved for an order (when order created)
  sale,       // Stock permanently reduced on delivery
  returned,   // Stock returned by customer
  adjustment, // Manual stock adjustment (admin)
}

/// Model representing a single stock movement audit record.
class InventoryMovement {
  final String movementId;
  final String productId;
  final String? orderId;
  final MovementType movementType;
  final int quantity;          // Positive for addition, negative for reduction
  final int previousStock;
  final int newStock;
  final String userId;
  final String? remarks;
  final DateTime timestamp;

  InventoryMovement({
    required this.movementId,
    required this.productId,
    this.orderId,
    required this.movementType,
    required this.quantity,
    required this.previousStock,
    required this.newStock,
    required this.userId,
    this.remarks,
    required this.timestamp,
  });

  factory InventoryMovement.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return InventoryMovement(
      movementId: doc.id,
      productId: data['productId'] ?? '',
      orderId: data['orderId'],
      movementType: _parseMovementType(data['movementType'] ?? 'purchase'),
      quantity: data['quantity'] ?? 0,
      previousStock: data['previousStock'] ?? 0,
      newStock: data['newStock'] ?? 0,
      userId: data['userId'] ?? '',
      remarks: data['remarks'],
      timestamp: (data['timestamp'] as Timestamp?)?.toDate() ?? DateTime.now(),
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'productId': productId,
      'orderId': orderId,
      'movementType': movementType.name,
      'quantity': quantity,
      'previousStock': previousStock,
      'newStock': newStock,
      'userId': userId,
      'remarks': remarks,
      'timestamp': Timestamp.fromDate(timestamp),
    };
  }

  InventoryMovement copyWith({
    String? movementId,
    String? productId,
    String? orderId,
    MovementType? movementType,
    int? quantity,
    int? previousStock,
    int? newStock,
    String? userId,
    String? remarks,
    DateTime? timestamp,
  }) {
    return InventoryMovement(
      movementId: movementId ?? this.movementId,
      productId: productId ?? this.productId,
      orderId: orderId ?? this.orderId,
      movementType: movementType ?? this.movementType,
      quantity: quantity ?? this.quantity,
      previousStock: previousStock ?? this.previousStock,
      newStock: newStock ?? this.newStock,
      userId: userId ?? this.userId,
      remarks: remarks ?? this.remarks,
      timestamp: timestamp ?? this.timestamp,
    );
  }

  static MovementType _parseMovementType(String value) {
    return MovementType.values.firstWhere(
      (e) => e.name == value,
      orElse: () => MovementType.purchase,
    );
  }
}