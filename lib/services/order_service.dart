import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';

import '../models/order_model.dart' as order_models;
import '../models/product_model.dart';
import '../models/tracker_model.dart';
import '../models/audit_log_model.dart';
import 'inventory_engine.dart';
import 'whatsapp_verification_service.dart';
import 'settings_service.dart';

class OrderService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final InventoryEngine _inventoryEngine = InventoryEngine();
  final WhatsAppVerificationService _whatsappService = WhatsAppVerificationService();
  final SettingsService _settingsService = SettingsService();

  // ---------- Create Order ----------
  Future<(String orderId, String confirmationCode)> createOrder(order_models.Order order) async {
    try {
      if (order.mobile.length != 10) {
        throw Exception('Invalid mobile number');
      }
      if (order.pincode.length != 6) {
        throw Exception('Invalid pincode');
      }
      if (order.items.isEmpty) {
        throw Exception('Order must have at least one item');
      }
      if (order.customerName.isEmpty || order.address.isEmpty) {
        throw Exception('Customer name and address are required');
      }

      final existingOrder = await _firestore
          .collection('orders')
          .where('orderNumber', isEqualTo: order.orderNumber)
          .limit(1)
          .get();

      if (existingOrder.docs.isNotEmpty) {
        final existing = order_models.Order.fromFirestore(existingOrder.docs.first);
        debugPrint('⚠️ Duplicate order detected: ${existing.orderNumber}');
        return (existing.orderId, existing.confirmationCode ?? '');
      }

      await _inventoryEngine.validateOrderInventory(order);

      double totalCommission = 0;
      double totalGst = 0;
      double totalOrderAmount = 0;

      for (final item in order.items) {
        final product = await _getProduct(item.productId);
        if (product == null) throw Exception('Product ${item.productId} not found');
        totalCommission += product.calculateCommission(item.quantity);
        totalGst += (item.unitPrice * item.quantity) * (item.gstRate / 100);
        totalOrderAmount += item.unitPrice * item.quantity;
      }

      final platformFee = totalOrderAmount * 0.025;
      final vendorPayableSnapshot = totalOrderAmount - totalCommission - platformFee;

      final orderNumber = await _generateOrderNumber();
      final confirmationCode = _whatsappService.generateConfirmationCode();

      final finalOrder = order.copyWith(
        orderNumber: orderNumber,
        confirmationCode: confirmationCode,
        status: order_models.OrderStatus.awaitingVerification,
        verificationStatus: order_models.VerificationStatus.pending,
        stockReduced: false,
        totalCommission: totalCommission,
        totalGst: totalGst,
        platformFee: platformFee,
        vendorPayableSnapshot: vendorPayableSnapshot,
      );

      final orderRef = _firestore.collection('orders').doc();
      final savedOrder = finalOrder.copyWith(orderId: orderRef.id);
      await orderRef.set(savedOrder.toFirestore());

      await _createAuditLog(
        userId: order.createdBy,
        userName: order.influencerName,
        userRole: 'influencer',
        actionType: ActionType.orderCreated,
        module: Module.order,
        orderId: orderRef.id,
        beforeValue: null,
        afterValue: {'orderNumber': orderNumber, 'status': 'awaitingVerification'},
        remarks: 'Order created with commission snapshot',
      );

      await _updateTrackerNewOrder();
      debugPrint('Order created: ${savedOrder.orderNumber} (${savedOrder.orderId})');
      return (savedOrder.orderId, confirmationCode);
    } catch (e) {
      debugPrint('OrderService.createOrder error: $e');
      rethrow;
    }
  }

  // ---------- Verify Order ----------
  Future<void> verifyOrder(String orderId, String code) async {
    final order = await _getOrder(orderId);
    if (order == null) throw Exception('Order not found');

    if (order.status != order_models.OrderStatus.awaitingVerification) {
      debugPrint('⚠️ Order already verified: ${order.orderNumber}');
      return;
    }

    if (order.confirmationCode == null) {
      throw Exception('No confirmation code found for this order');
    }
    if (code.trim().toUpperCase() != order.confirmationCode!.trim().toUpperCase()) {
      throw Exception('Invalid confirmation code');
    }

    await reserveStock(orderId);

    final totalQuantity = order.items.fold(0, (sum, item) => sum + item.quantity);
    try {
      await _inventoryEngine.reducePartnerStock(
        partnerId: order.vendorId,
        platform: order.platform ?? 'reelgen',
        quantity: totalQuantity,
      );
    } catch (e) {
      debugPrint('Partner stock reduction failed: $e');
    }

    await _updateOrderStatus(orderId, order_models.OrderStatus.verified);

    await _firestore.collection('orders').doc(orderId).update({
      'verificationStatus': order_models.VerificationStatus.confirmed.name,
      'verifiedAt': FieldValue.serverTimestamp(),
    });

    await _createAuditLog(
      userId: order.createdBy,
      userName: order.influencerName,
      userRole: 'influencer',
      actionType: ActionType.orderUpdated,
      module: Module.order,
      orderId: orderId,
      beforeValue: {'status': 'awaitingVerification'},
      afterValue: {'status': 'verified'},
      remarks: 'Order verified via WhatsApp code. Stock reduced.',
    );
    debugPrint('Order verified and stock reduced: $orderId');
  }

  // ---------- Update Order Status ----------
  Future<void> updateOrderStatus(String orderId, order_models.OrderStatus newStatus) async {
    final order = await _getOrder(orderId);
    if (order == null) throw Exception('Order not found');
    if (order.status == newStatus) return;
    if (!_isValidTransition(order.status, newStatus)) {
      throw Exception('Invalid status transition from ${order.status.name} to ${newStatus.name}');
    }
    await _updateOrderStatus(orderId, newStatus);
  }

  Future<void> _updateOrderStatus(String orderId, order_models.OrderStatus newStatus) async {
    final order = await _getOrder(orderId);
    if (order == null) throw Exception('Order not found');
    final timestampField = _getTimestampField(newStatus);
    await _firestore.collection('orders').doc(orderId).update({
      'status': newStatus.name,
      timestampField: FieldValue.serverTimestamp(),
    });
    await _createAuditLog(
      userId: order.createdBy,
      userName: order.influencerName,
      userRole: 'influencer',
      actionType: _getActionTypeForStatus(newStatus),
      module: Module.order,
      orderId: orderId,
      beforeValue: {'status': order.status.name},
      afterValue: {'status': newStatus.name},
      remarks: 'Order status updated to ${newStatus.name}',
    );
    if (newStatus == order_models.OrderStatus.delivered) {
      await _updateTrackerDelivered();
    } else if (newStatus == order_models.OrderStatus.cancelled || newStatus == order_models.OrderStatus.returned) {
      await _updateTrackerCancelledReturned();
    }
    debugPrint('Order $orderId status updated to ${newStatus.name}');
  }

  // ---------- Stock Reservation ----------
  Future<void> reserveStock(String orderId) async {
    final order = await _getOrder(orderId);
    if (order == null) throw Exception('Order not found');
    if (order.status != order_models.OrderStatus.awaitingVerification) {
      throw Exception('Order must be pending verification to reserve stock');
    }
    await _inventoryEngine.reserveStock(order);
    await _firestore.collection('orders').doc(orderId).update({
      'stockReduced': true,
    });
    await _createAuditLog(
      userId: order.createdBy,
      userName: order.influencerName,
      userRole: 'influencer',
      actionType: ActionType.stockReduced,
      module: Module.stock,
      orderId: orderId,
      remarks: 'Stock reserved for order ${order.orderNumber}',
    );
    debugPrint('Stock reserved for order: $orderId');
  }

  // ---------- WhatsApp Verification ----------
  Future<(String deepLink, String confirmationCode)> getVerificationLink(String orderId) async {
    final order = await _getOrder(orderId);
    if (order == null) throw Exception('Order not found');
    final code = order.confirmationCode ?? _whatsappService.generateConfirmationCode();
    final (link, _) = _whatsappService.generateVerificationLink(order, phoneNumber: order.mobile);
    return (link, code);
  }

  Future<void> markVerificationSent(String orderId) async {
    await _firestore.collection('orders').doc(orderId).update({
      'verificationStatus': order_models.VerificationStatus.sent.name,
      'whatsappMessageSentAt': FieldValue.serverTimestamp(),
    });
  }

  // ---------- Mark Delivered ----------
  Future<void> markDelivered(String orderId) async {
    final order = await _getOrder(orderId);
    if (order == null) throw Exception('Order not found');

    final now = DateTime.now();
    final releaseDays = await _settingsService.getCommissionReleaseDays();
    final paymentReleaseDate = now.add(Duration(days: releaseDays));

    await _firestore.collection('orders').doc(orderId).update({
      'status': order_models.OrderStatus.delivered.name,
      'deliveredAt': Timestamp.fromDate(now),
      'paymentReleaseDate': Timestamp.fromDate(paymentReleaseDate),
      'paymentReleaseStatus': 'processing',
    });

    await _createAuditLog(
      userId: order.createdBy,
      userName: order.influencerName,
      userRole: 'influencer',
      actionType: ActionType.orderUpdated,
      module: Module.order,
      orderId: orderId,
      beforeValue: {'status': order.status.name},
      afterValue: {'status': 'delivered'},
      remarks: 'Order delivered. Payment will be released in $releaseDays days.',
    );

    debugPrint('Order delivered: $orderId. Payment release on: $paymentReleaseDate');
  }

  // ---------- Cancel Order ----------
  Future<void> cancelOrder(String orderId) async {
    final order = await _getOrder(orderId);
    if (order == null) throw Exception('Order not found');

    if (order.status != order_models.OrderStatus.awaitingVerification &&
        order.status != order_models.OrderStatus.verified) {
      throw Exception('Order can only be cancelled before packing');
    }

    await _updateOrderStatus(orderId, order_models.OrderStatus.cancelled);
    await _createAuditLog(
      userId: order.createdBy,
      userName: order.influencerName,
      userRole: 'influencer',
      actionType: ActionType.orderCancelled,
      module: Module.order,
      orderId: orderId,
      beforeValue: {'status': order.status.name},
      afterValue: {'status': 'cancelled'},
      remarks: 'Order cancelled',
    );

    if (order.stockReduced) {
      await _inventoryEngine.releaseReservedStock(order);
    }
  }

  // ---------- Return ----------
  Future<void> requestReturn(String orderId, String reason) async {
    final order = await _getOrder(orderId);
    if (order == null) throw Exception('Order not found');

    if (order.status != order_models.OrderStatus.delivered) {
      throw Exception('Only delivered orders can be returned');
    }

    await _firestore.collection('orders').doc(orderId).update({
      'returnReason': reason,
      'returnStatus': 'pending',
      'returnRequestedAt': FieldValue.serverTimestamp(),
    });

    await _createAuditLog(
      userId: order.createdBy,
      userName: order.influencerName,
      userRole: 'influencer',
      actionType: ActionType.orderUpdated,
      module: Module.order,
      orderId: orderId,
      remarks: 'Return requested: $reason',
    );
  }

  Future<void> approveReturn(String orderId) async {
    final order = await _getOrder(orderId);
    if (order == null) throw Exception('Order not found');

    await _firestore.collection('orders').doc(orderId).update({
      'returnStatus': 'approved',
      'returnApprovedAt': FieldValue.serverTimestamp(),
      'refundAmount': order.orderAmount,
    });

    await _inventoryEngine.returnStock(order);

    await _createAuditLog(
      userId: order.createdBy,
      userName: order.influencerName,
      userRole: 'influencer',
      actionType: ActionType.orderUpdated,
      module: Module.order,
      orderId: orderId,
      remarks: 'Return approved',
    );
  }

  Future<void> rejectReturn(String orderId) async {
    final order = await _getOrder(orderId);
    if (order == null) throw Exception('Order not found');

    await _firestore.collection('orders').doc(orderId).update({
      'returnStatus': 'rejected',
    });

    await _createAuditLog(
      userId: order.createdBy,
      userName: order.influencerName,
      userRole: 'influencer',
      actionType: ActionType.orderUpdated,
      module: Module.order,
      orderId: orderId,
      remarks: 'Return rejected',
    );
  }

  Future<void> processRefund(String orderId) async {
    final order = await _getOrder(orderId);
    if (order == null) throw Exception('Order not found');

    if (order.returnStatus != 'approved') {
      throw Exception('Return must be approved before refund');
    }

    await _firestore.collection('orders').doc(orderId).update({
      'status': order_models.OrderStatus.refunded.name,
      'refundedAt': FieldValue.serverTimestamp(),
      'paymentReleaseStatus': 'refunded',
    });

    await _createAuditLog(
      userId: order.createdBy,
      userName: order.influencerName,
      userRole: 'influencer',
      actionType: ActionType.refund,
      module: Module.payment,
      orderId: orderId,
      remarks: 'Refund processed',
    );
  }

  // ---------- Helper Methods ----------
  Future<order_models.Order?> _getOrder(String orderId) async {
    final doc = await _firestore.collection('orders').doc(orderId).get();
    if (!doc.exists) return null;
    return order_models.Order.fromFirestore(doc);
  }

  Future<Product?> _getProduct(String productId) async {
    final doc = await _firestore.collection('products').doc(productId).get();
    if (!doc.exists) return null;
    return Product.fromFirestore(doc);
  }

  Future<String> _generateOrderNumber() async {
    final counterRef = _firestore.collection('counters').doc('orderCounter');
    final snapshot = await counterRef.get();
    int counter = 1;
    if (snapshot.exists) {
      counter = (snapshot.data()?['value'] ?? 0) + 1;
    }
    await counterRef.set({'value': counter}, SetOptions(merge: true));
    final year = DateTime.now().year;
    final random = DateTime.now().millisecondsSinceEpoch.toString().substring(10, 13);
    return 'RGAI-$year-${counter.toString().padLeft(6, '0')}-$random';
  }

  bool _isValidTransition(order_models.OrderStatus from, order_models.OrderStatus to) {
    switch (from) {
      case order_models.OrderStatus.awaitingVerification:
        return to == order_models.OrderStatus.verified || to == order_models.OrderStatus.cancelled;
      case order_models.OrderStatus.verified:
        return to == order_models.OrderStatus.packed || to == order_models.OrderStatus.cancelled;
      case order_models.OrderStatus.packed:
        return to == order_models.OrderStatus.shipped || to == order_models.OrderStatus.cancelled;
      case order_models.OrderStatus.shipped:
        return to == order_models.OrderStatus.delivered || to == order_models.OrderStatus.cancelled;
      case order_models.OrderStatus.delivered:
        return to == order_models.OrderStatus.returned;
      case order_models.OrderStatus.returned:
        return to == order_models.OrderStatus.refunded;
      default:
        return false;
    }
  }

  String _getTimestampField(order_models.OrderStatus status) {
    switch (status) {
      case order_models.OrderStatus.verified: return 'verifiedAt';
      case order_models.OrderStatus.packed: return 'packedAt';
      case order_models.OrderStatus.shipped: return 'shippedAt';
      case order_models.OrderStatus.delivered: return 'deliveredAt';
      case order_models.OrderStatus.returned: return 'returnedAt';
      case order_models.OrderStatus.cancelled: return 'cancelledAt';
      case order_models.OrderStatus.refunded: return 'refundedAt';
      default: return 'updatedAt';
    }
  }

  ActionType _getActionTypeForStatus(order_models.OrderStatus status) {
    switch (status) {
      case order_models.OrderStatus.verified: return ActionType.orderUpdated;
      case order_models.OrderStatus.packed: return ActionType.orderUpdated;
      case order_models.OrderStatus.shipped: return ActionType.orderUpdated;
      case order_models.OrderStatus.delivered: return ActionType.orderUpdated;
      case order_models.OrderStatus.returned: return ActionType.orderUpdated;
      case order_models.OrderStatus.cancelled: return ActionType.orderCancelled;
      case order_models.OrderStatus.refunded: return ActionType.refund;
      default: return ActionType.orderUpdated;
    }
  }

  Future<void> _createAuditLog({
    required String userId,
    required String userName,
    required String userRole,
    required ActionType actionType,
    required Module module,
    String? orderId,
    Map<String, dynamic>? beforeValue,
    Map<String, dynamic>? afterValue,
    String? remarks,
  }) async {
    try {
      final log = AuditLog(
        id: '',
        userId: userId,
        userName: userName,
        userRole: userRole,
        actionType: actionType,
        module: module,
        beforeValue: beforeValue,
        afterValue: afterValue,
        timestamp: DateTime.now(),
        deviceType: 'backend',
        orderId: orderId,
        remarks: remarks,
        success: true,
        priority: PriorityLevel.medium,
      );
      final ref = _firestore.collection('audit_logs').doc();
      await ref.set(log.copyWith(id: ref.id).toFirestore());
    } catch (e) {
      debugPrint('Audit log creation failed: $e');
    }
  }

  Future<void> _updateTrackerNewOrder() async {
    try {
      final trackerRef = _firestore.doc('system/trackerState');
      await trackerRef.update({
        'newOrdersCount': FieldValue.increment(1),
        'updatedAt': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      debugPrint('Tracker update failed: $e');
    }
  }

  Future<void> _updateTrackerDelivered() async {
    try {
      final trackerRef = _firestore.doc('system/trackerState');
      await trackerRef.update({
        'deliveredOrdersCount': FieldValue.increment(1),
        'updatedAt': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      debugPrint('Tracker update failed: $e');
    }
  }

  Future<void> _updateTrackerCancelledReturned() async {
    try {
      final trackerRef = _firestore.doc('system/trackerState');
      await trackerRef.update({
        'cancelledReturnedOrdersCount': FieldValue.increment(1),
        'updatedAt': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      debugPrint('Tracker update failed: $e');
    }
  }
}