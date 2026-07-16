import 'package:flutter/material.dart';
import 'package:razorpay_flutter/razorpay_flutter.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/audit_log_model.dart';

/// A service class to handle Razorpay payment integration.
class RazorpayService {
  late Razorpay _razorpay;

  // Callback functions
  VoidCallback? onSuccess;
  VoidCallback? onFailure;
  VoidCallback? onExternalWallet;

  // User context for audit logging
  String? _userId;
  String? _userName;
  String? _userRole;
  String? _orderId;

  RazorpayService() {
    _razorpay = Razorpay();
    _razorpay.on(Razorpay.EVENT_PAYMENT_SUCCESS, _handlePaymentSuccess);
    _razorpay.on(Razorpay.EVENT_PAYMENT_ERROR, _handlePaymentError);
    _razorpay.on(Razorpay.EVENT_EXTERNAL_WALLET, _handleExternalWallet);
  }

  /// Sets user context for audit logging.
  void setUserContext({String? userId, String? userName, String? userRole, String? orderId}) {
    _userId = userId;
    _userName = userName;
    _userRole = userRole;
    _orderId = orderId;
  }

  /// Opens the Razorpay checkout with the provided order details.
  void openCheckout({
    required int amount,
    required String productName,
    required String customerName,
    required String customerEmail,
    required String customerContact,
    String? orderId,
    Map<String, String>? prefill,
    Map<String, String>? notes,
  }) {
    final options = {
      'key': 'rzp_test_SlJ6tQPqMFP8zm', // <-- API Key set
      'amount': amount,
      'name': productName,
      'description': 'Payment for $productName',
      'prefill': prefill ?? {
        'contact': customerContact,
        'email': customerEmail,
        'name': customerName,
      },
      'notes': notes ?? {
        'customer_name': customerName,
        'customer_email': customerEmail,
      },
      'theme': {
        'color': '#D0BCFF',
      },
    };

    if (orderId != null && orderId.isNotEmpty) {
      options['order_id'] = orderId;
    }

    try {
      _razorpay.open(options);
    } catch (e) {
      debugPrint('Razorpay open error: $e');
      if (onFailure != null) onFailure!();
    }
  }

  void _handlePaymentSuccess(PaymentSuccessResponse response) {
    debugPrint('Payment Success: ${response.paymentId}');
    _logAudit(ActionType.paymentSuccess, 'Payment successful: ${response.paymentId}');
    if (onSuccess != null) onSuccess!();
  }

  void _handlePaymentError(PaymentFailureResponse response) {
    debugPrint('Payment Error: ${response.code} - ${response.message}');
    _logAudit(ActionType.paymentFailed, 'Payment failed: ${response.message}');
    if (onFailure != null) onFailure!();
  }

  void _handleExternalWallet(ExternalWalletResponse response) {
    debugPrint('External Wallet: ${response.walletName}');
    _logAudit(ActionType.paymentFailed, 'External wallet selected: ${response.walletName}');
    if (onExternalWallet != null) onExternalWallet!();
  }

  void dispose() {
    _razorpay.clear();
  }

  // ---------- Audit Log Helper ----------
  void _logAudit(ActionType actionType, String remarks) {
    try {
      if (_userId == null) return;
      final log = AuditLog(
        id: '',
        userId: _userId!,
        userName: _userName ?? 'Unknown',
        userRole: _userRole ?? 'customer',
        actionType: actionType,
        module: Module.payment,
        beforeValue: null,
        afterValue: null,
        timestamp: DateTime.now(),
        deviceType: 'mobile',
        orderId: _orderId,
        remarks: remarks,
        success: actionType == ActionType.paymentSuccess,
        priority: PriorityLevel.medium,
      );
      final ref = FirebaseFirestore.instance.collection('audit_logs').doc();
      ref.set(log.copyWith(id: ref.id).toFirestore());
    } catch (e) {
      debugPrint('Razorpay audit log failed: $e');
    }
  }
}