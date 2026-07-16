import 'dart:math';
import 'package:flutter/foundation.dart';
import '../models/order_model.dart' as order_models;

/// Utility service for WhatsApp order verification (V1 – deep link).
class WhatsAppVerificationService {
  static const int confirmationCodeLength = 6;
  static const String defaultCountryCode = '91';

  String generateConfirmationCode() {
    const chars = 'ABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789';
    final random = _getRandom();
    return String.fromCharCodes(
      Iterable.generate(confirmationCodeLength, (_) {
        return chars.codeUnitAt(random.nextInt(chars.length));
      }),
    );
  }

  Random _getRandom() {
    try {
      return Random.secure();
    } catch (_) {
      return Random();
    }
  }

  String buildVerificationMessage(order_models.Order order, String code) {
    final items = order.items.map((item) {
      return '• ${item.productName} (Design: ${item.designNumber}, Qty: ${item.quantity}, ₹${item.unitPrice})';
    }).join('\n');

    return 
      '✅ *Order Confirmation – REELGEN AI*\n\n'
      'Dear ${order.customerName},\n'
      'Thank you for your order!\n\n'
      '📦 Order Details\n'
      '─────────────────\n'
      'Order ID: ${order.orderNumber}\n'
      'Influencer: ${order.influencerName} (Code: ${order.referralCode})\n'
      'Items:\n$items\n'
      'Total: ₹${order.orderAmount.toStringAsFixed(2)}\n'
      '─────────────────\n'
      '🔐 Confirmation Code: *$code*\n\n'
      'Please reply with:\n'
      '`CONFIRM ${order.orderNumber} $code`\n'
      'to verify your order.\n\n'
      'Regards,\n'
      'REELGEN AI Team';
  }

  (String deepLink, String code) generateVerificationLink(order_models.Order order, {String? phoneNumber}) {
    final code = generateConfirmationCode();
    final message = buildVerificationMessage(order, code);
    final encoded = Uri.encodeComponent(message);
    final number = phoneNumber ?? order.mobile;
    final cleaned = number.replaceAll(RegExp(r'\D'), '');
    final fullNumber = cleaned.startsWith(defaultCountryCode) ? cleaned : '$defaultCountryCode$cleaned';
    final deepLink = 'https://wa.me/$fullNumber?text=$encoded';
    return (deepLink, code);
  }

  Future<bool> verifyOrder({
    required order_models.Order order,
    required String providedCode,
    required String expectedCode,
    required Future<void> Function(order_models.Order order) onVerified,
    required void Function(String error) onError,
  }) async {
    try {
      if (order.status != order_models.OrderStatus.awaitingVerification) {
        final msg = 'Order is not pending verification (current status: ${order.status.name})';
        onError(msg);
        return false;
      }
      if (providedCode.trim().toUpperCase() != expectedCode.trim().toUpperCase()) {
        const msg = 'Invalid confirmation code. Please check and try again.';
        onError(msg);
        return false;
      }
      await onVerified(order);
      return true;
    } catch (e) {
      onError(e.toString());
      return false;
    }
  }

  static String orderSummary(order_models.Order order) {
    final items = order.items.map((e) => '${e.productName} x${e.quantity}').join(', ');
    return 'Order #${order.orderNumber} | ${order.customerName} | ₹${order.orderAmount} | $items';
  }
}