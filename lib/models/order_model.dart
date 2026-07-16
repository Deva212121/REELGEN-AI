import 'package:cloud_firestore/cloud_firestore.dart';

enum OrderStatus {
  awaitingVerification,
  verified,
  packed,
  shipped,
  delivered,
  returned,
  cancelled,
  refunded,
}

enum VerificationStatus {
  pending,
  sent,
  confirmed,
  failed,
}

enum CommissionStatus {
  pending,
  paid,
  rejected,
}

enum PaymentStatus {
  pending,
  success,
  failed,
  refunded,
}

class OrderItem {
  final String productId;
  final String productName;
  final String designNumber;
  final String productCode;
  final String sku;
  final int quantity;
  final double unitPrice;
  final double gstRate;
  final String hsnCode;
  final double commissionEarned;

  OrderItem({
    required this.productId,
    required this.productName,
    required this.designNumber,
    required this.productCode,
    required this.sku,
    required this.quantity,
    required this.unitPrice,
    required this.gstRate,
    required this.hsnCode,
    required this.commissionEarned,
  });

  factory OrderItem.fromFirestore(Map<String, dynamic> data) {
    return OrderItem(
      productId: data['productId'] ?? '',
      productName: data['productName'] ?? '',
      designNumber: data['designNumber'] ?? '',
      productCode: data['productCode'] ?? '',
      sku: data['sku'] ?? '',
      quantity: data['quantity'] ?? 1,
      unitPrice: (data['unitPrice'] ?? 0).toDouble(),
      gstRate: (data['gstRate'] ?? 0).toDouble(),
      hsnCode: data['hsnCode'] ?? '',
      commissionEarned: (data['commissionEarned'] ?? 0).toDouble(),
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'productId': productId,
      'productName': productName,
      'designNumber': designNumber,
      'productCode': productCode,
      'sku': sku,
      'quantity': quantity,
      'unitPrice': unitPrice,
      'gstRate': gstRate,
      'hsnCode': hsnCode,
      'commissionEarned': commissionEarned,
    };
  }

  OrderItem copyWith({
    String? productId,
    String? productName,
    String? designNumber,
    String? productCode,
    String? sku,
    int? quantity,
    double? unitPrice,
    double? gstRate,
    String? hsnCode,
    double? commissionEarned,
  }) {
    return OrderItem(
      productId: productId ?? this.productId,
      productName: productName ?? this.productName,
      designNumber: designNumber ?? this.designNumber,
      productCode: productCode ?? this.productCode,
      sku: sku ?? this.sku,
      quantity: quantity ?? this.quantity,
      unitPrice: unitPrice ?? this.unitPrice,
      gstRate: gstRate ?? this.gstRate,
      hsnCode: hsnCode ?? this.hsnCode,
      commissionEarned: commissionEarned ?? this.commissionEarned,
    );
  }
}

class Order {
  final String orderId;
  final String orderNumber;
  final String? invoiceNumber;
  final String customerId;
  final String customerName;
  final String mobile;
  final String address;
  final String city;
  final String state;
  final String pincode;
  final String? landmark;
  final String vendorId;
  final String vendorName;
  final String influencerId;
  final String influencerName;
  final String referralCode;
  final List<OrderItem> items;
  final bool stockReduced;
  final double orderAmount;
  final double vendorPayable;
  final double influencerCommission;
  final double platformProfit;
  final String paymentGateway;
  final PaymentStatus paymentStatus;
  final String? paymentId;
  final String? transactionId;
  final String? courierName;
  final String? trackingNumber;
  final OrderStatus status;
  final DateTime createdAt;
  final DateTime? updatedAt;
  final DateTime? verifiedAt;
  final DateTime? packedAt;
  final DateTime? shippedAt;
  final DateTime? deliveredAt;
  final DateTime? returnedAt;
  final DateTime? cancelledAt;
  final DateTime? refundedAt;
  final String platform;
  final VerificationStatus verificationStatus;
  final String? confirmationCode;
  final DateTime? whatsappMessageSentAt;
  final DateTime? verifiedAtOtp;
  final CommissionStatus commissionStatus;
  final CommissionStatus payoutStatus;
  final String createdBy;
  final double totalCommission;
  final double totalGst;
  final double platformFee;
  final double vendorPayableSnapshot;
  final DateTime? paymentReleaseDate;
  final String paymentReleaseStatus;
  final String? returnReason;
  final String? returnStatus;
  final DateTime? returnRequestedAt;
  final DateTime? returnApprovedAt;
  final double? refundAmount;
  final bool isDeleted;
  final DateTime? deletedAt;
  final String? deletedBy;

  Order({
    required this.orderId,
    required this.orderNumber,
    this.invoiceNumber,
    required this.customerId,
    required this.customerName,
    required this.mobile,
    required this.address,
    required this.city,
    required this.state,
    required this.pincode,
    this.landmark,
    required this.vendorId,
    required this.vendorName,
    required this.influencerId,
    required this.influencerName,
    required this.referralCode,
    required this.items,
    this.stockReduced = false,
    required this.orderAmount,
    required this.vendorPayable,
    required this.influencerCommission,
    required this.platformProfit,
    required this.paymentGateway,
    required this.paymentStatus,
    this.paymentId,
    this.transactionId,
    this.courierName,
    this.trackingNumber,
    required this.status,
    required this.createdAt,
    this.updatedAt,
    this.verifiedAt,
    this.packedAt,
    this.shippedAt,
    this.deliveredAt,
    this.returnedAt,
    this.cancelledAt,
    this.refundedAt,
    required this.platform,
    this.verificationStatus = VerificationStatus.pending,
    this.confirmationCode,
    this.whatsappMessageSentAt,
    this.verifiedAtOtp,
    this.commissionStatus = CommissionStatus.pending,
    this.payoutStatus = CommissionStatus.pending,
    required this.createdBy,
    required this.totalCommission,
    required this.totalGst,
    required this.platformFee,
    required this.vendorPayableSnapshot,
    this.paymentReleaseDate,
    this.paymentReleaseStatus = 'pending',
    this.returnReason,
    this.returnStatus,
    this.returnRequestedAt,
    this.returnApprovedAt,
    this.refundAmount,
    this.isDeleted = false,
    this.deletedAt,
    this.deletedBy,
  });

  factory Order.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    final itemsData = data['items'] as List<dynamic>? ?? [];
    final items = itemsData.map((item) => OrderItem.fromFirestore(item)).toList();

    return Order(
      orderId: doc.id,
      orderNumber: data['orderNumber'] ?? '',
      invoiceNumber: data['invoiceNumber'],
      customerId: data['customerId'] ?? '',
      customerName: data['customerName'] ?? '',
      mobile: data['mobile'] ?? '',
      address: data['address'] ?? '',
      city: data['city'] ?? '',
      state: data['state'] ?? '',
      pincode: data['pincode'] ?? '',
      landmark: data['landmark'],
      vendorId: data['vendorId'] ?? '',
      vendorName: data['vendorName'] ?? '',
      influencerId: data['influencerId'] ?? '',
      influencerName: data['influencerName'] ?? '',
      referralCode: data['referralCode'] ?? '',
      items: items,
      stockReduced: data['stockReduced'] ?? false,
      orderAmount: (data['orderAmount'] ?? 0).toDouble(),
      vendorPayable: (data['vendorPayable'] ?? 0).toDouble(),
      influencerCommission: (data['influencerCommission'] ?? 0).toDouble(),
      platformProfit: (data['platformProfit'] ?? 0).toDouble(),
      paymentGateway: data['paymentGateway'] ?? '',
      paymentStatus: _parsePaymentStatus(data['paymentStatus'] ?? 'pending'),
      paymentId: data['paymentId'],
      transactionId: data['transactionId'],
      courierName: data['courierName'],
      trackingNumber: data['trackingNumber'],
      status: _parseOrderStatus(data['status'] ?? 'awaitingVerification'),
      createdAt: (data['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      updatedAt: (data['updatedAt'] as Timestamp?)?.toDate(),
      verifiedAt: (data['verifiedAt'] as Timestamp?)?.toDate(),
      packedAt: (data['packedAt'] as Timestamp?)?.toDate(),
      shippedAt: (data['shippedAt'] as Timestamp?)?.toDate(),
      deliveredAt: (data['deliveredAt'] as Timestamp?)?.toDate(),
      returnedAt: (data['returnedAt'] as Timestamp?)?.toDate(),
      cancelledAt: (data['cancelledAt'] as Timestamp?)?.toDate(),
      refundedAt: (data['refundedAt'] as Timestamp?)?.toDate(),
      platform: data['platform'] ?? 'reelgen',
      verificationStatus: _parseVerificationStatus(data['verificationStatus'] ?? 'pending'),
      confirmationCode: data['confirmationCode'],
      whatsappMessageSentAt: (data['whatsappMessageSentAt'] as Timestamp?)?.toDate(),
      verifiedAtOtp: (data['verifiedAtOtp'] as Timestamp?)?.toDate(),
      commissionStatus: _parseCommissionStatus(data['commissionStatus'] ?? 'pending'),
      payoutStatus: _parseCommissionStatus(data['payoutStatus'] ?? 'pending'),
      createdBy: data['createdBy'] ?? '',
      totalCommission: (data['totalCommission'] ?? 0).toDouble(),
      totalGst: (data['totalGst'] ?? 0).toDouble(),
      platformFee: (data['platformFee'] ?? 0).toDouble(),
      vendorPayableSnapshot: (data['vendorPayableSnapshot'] ?? 0).toDouble(),
      paymentReleaseDate: (data['paymentReleaseDate'] as Timestamp?)?.toDate(),
      paymentReleaseStatus: data['paymentReleaseStatus'] ?? 'pending',
      returnReason: data['returnReason'],
      returnStatus: data['returnStatus'],
      returnRequestedAt: (data['returnRequestedAt'] as Timestamp?)?.toDate(),
      returnApprovedAt: (data['returnApprovedAt'] as Timestamp?)?.toDate(),
      refundAmount: (data['refundAmount'] as double?)?.toDouble(),
      isDeleted: data['isDeleted'] ?? false,
      deletedAt: (data['deletedAt'] as Timestamp?)?.toDate(),
      deletedBy: data['deletedBy'],
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'orderNumber': orderNumber,
      'invoiceNumber': invoiceNumber,
      'customerId': customerId,
      'customerName': customerName,
      'mobile': mobile,
      'address': address,
      'city': city,
      'state': state,
      'pincode': pincode,
      'landmark': landmark,
      'vendorId': vendorId,
      'vendorName': vendorName,
      'influencerId': influencerId,
      'influencerName': influencerName,
      'referralCode': referralCode,
      'items': items.map((e) => e.toFirestore()).toList(),
      'stockReduced': stockReduced,
      'orderAmount': orderAmount,
      'vendorPayable': vendorPayable,
      'influencerCommission': influencerCommission,
      'platformProfit': platformProfit,
      'paymentGateway': paymentGateway,
      'paymentStatus': paymentStatus.name,
      'paymentId': paymentId,
      'transactionId': transactionId,
      'courierName': courierName,
      'trackingNumber': trackingNumber,
      'status': status.name,
      'createdAt': Timestamp.fromDate(createdAt),
      'updatedAt': updatedAt != null ? Timestamp.fromDate(updatedAt!) : null,
      'verifiedAt': verifiedAt != null ? Timestamp.fromDate(verifiedAt!) : null,
      'packedAt': packedAt != null ? Timestamp.fromDate(packedAt!) : null,
      'shippedAt': shippedAt != null ? Timestamp.fromDate(shippedAt!) : null,
      'deliveredAt': deliveredAt != null ? Timestamp.fromDate(deliveredAt!) : null,
      'returnedAt': returnedAt != null ? Timestamp.fromDate(returnedAt!) : null,
      'cancelledAt': cancelledAt != null ? Timestamp.fromDate(cancelledAt!) : null,
      'refundedAt': refundedAt != null ? Timestamp.fromDate(refundedAt!) : null,
      'platform': platform,
      'verificationStatus': verificationStatus.name,
      'confirmationCode': confirmationCode,
      'whatsappMessageSentAt': whatsappMessageSentAt != null ? Timestamp.fromDate(whatsappMessageSentAt!) : null,
      'verifiedAtOtp': verifiedAtOtp != null ? Timestamp.fromDate(verifiedAtOtp!) : null,
      'commissionStatus': commissionStatus.name,
      'payoutStatus': payoutStatus.name,
      'createdBy': createdBy,
      'totalCommission': totalCommission,
      'totalGst': totalGst,
      'platformFee': platformFee,
      'vendorPayableSnapshot': vendorPayableSnapshot,
      'paymentReleaseDate': paymentReleaseDate != null ? Timestamp.fromDate(paymentReleaseDate!) : null,
      'paymentReleaseStatus': paymentReleaseStatus,
      'returnReason': returnReason,
      'returnStatus': returnStatus,
      'returnRequestedAt': returnRequestedAt != null ? Timestamp.fromDate(returnRequestedAt!) : null,
      'returnApprovedAt': returnApprovedAt != null ? Timestamp.fromDate(returnApprovedAt!) : null,
      'refundAmount': refundAmount,
      'isDeleted': isDeleted,
      'deletedAt': deletedAt != null ? Timestamp.fromDate(deletedAt!) : null,
      'deletedBy': deletedBy,
    };
  }

  Order copyWith({
    String? orderId,
    String? orderNumber,
    String? invoiceNumber,
    String? customerId,
    String? customerName,
    String? mobile,
    String? address,
    String? city,
    String? state,
    String? pincode,
    String? landmark,
    String? vendorId,
    String? vendorName,
    String? influencerId,
    String? influencerName,
    String? referralCode,
    List<OrderItem>? items,
    bool? stockReduced,
    double? orderAmount,
    double? vendorPayable,
    double? influencerCommission,
    double? platformProfit,
    String? paymentGateway,
    PaymentStatus? paymentStatus,
    String? paymentId,
    String? transactionId,
    String? courierName,
    String? trackingNumber,
    OrderStatus? status,
    DateTime? createdAt,
    DateTime? updatedAt,
    DateTime? verifiedAt,
    DateTime? packedAt,
    DateTime? shippedAt,
    DateTime? deliveredAt,
    DateTime? returnedAt,
    DateTime? cancelledAt,
    DateTime? refundedAt,
    String? platform,
    VerificationStatus? verificationStatus,
    String? confirmationCode,
    DateTime? whatsappMessageSentAt,
    DateTime? verifiedAtOtp,
    CommissionStatus? commissionStatus,
    CommissionStatus? payoutStatus,
    String? createdBy,
    double? totalCommission,
    double? totalGst,
    double? platformFee,
    double? vendorPayableSnapshot,
    DateTime? paymentReleaseDate,
    String? paymentReleaseStatus,
    String? returnReason,
    String? returnStatus,
    DateTime? returnRequestedAt,
    DateTime? returnApprovedAt,
    double? refundAmount,
    bool? isDeleted,
    DateTime? deletedAt,
    String? deletedBy,
  }) {
    return Order(
      orderId: orderId ?? this.orderId,
      orderNumber: orderNumber ?? this.orderNumber,
      invoiceNumber: invoiceNumber ?? this.invoiceNumber,
      customerId: customerId ?? this.customerId,
      customerName: customerName ?? this.customerName,
      mobile: mobile ?? this.mobile,
      address: address ?? this.address,
      city: city ?? this.city,
      state: state ?? this.state,
      pincode: pincode ?? this.pincode,
      landmark: landmark ?? this.landmark,
      vendorId: vendorId ?? this.vendorId,
      vendorName: vendorName ?? this.vendorName,
      influencerId: influencerId ?? this.influencerId,
      influencerName: influencerName ?? this.influencerName,
      referralCode: referralCode ?? this.referralCode,
      items: items ?? this.items,
      stockReduced: stockReduced ?? this.stockReduced,
      orderAmount: orderAmount ?? this.orderAmount,
      vendorPayable: vendorPayable ?? this.vendorPayable,
      influencerCommission: influencerCommission ?? this.influencerCommission,
      platformProfit: platformProfit ?? this.platformProfit,
      paymentGateway: paymentGateway ?? this.paymentGateway,
      paymentStatus: paymentStatus ?? this.paymentStatus,
      paymentId: paymentId ?? this.paymentId,
      transactionId: transactionId ?? this.transactionId,
      courierName: courierName ?? this.courierName,
      trackingNumber: trackingNumber ?? this.trackingNumber,
      status: status ?? this.status,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      verifiedAt: verifiedAt ?? this.verifiedAt,
      packedAt: packedAt ?? this.packedAt,
      shippedAt: shippedAt ?? this.shippedAt,
      deliveredAt: deliveredAt ?? this.deliveredAt,
      returnedAt: returnedAt ?? this.returnedAt,
      cancelledAt: cancelledAt ?? this.cancelledAt,
      refundedAt: refundedAt ?? this.refundedAt,
      platform: platform ?? this.platform,
      verificationStatus: verificationStatus ?? this.verificationStatus,
      confirmationCode: confirmationCode ?? this.confirmationCode,
      whatsappMessageSentAt: whatsappMessageSentAt ?? this.whatsappMessageSentAt,
      verifiedAtOtp: verifiedAtOtp ?? this.verifiedAtOtp,
      commissionStatus: commissionStatus ?? this.commissionStatus,
      payoutStatus: payoutStatus ?? this.payoutStatus,
      createdBy: createdBy ?? this.createdBy,
      totalCommission: totalCommission ?? this.totalCommission,
      totalGst: totalGst ?? this.totalGst,
      platformFee: platformFee ?? this.platformFee,
      vendorPayableSnapshot: vendorPayableSnapshot ?? this.vendorPayableSnapshot,
      paymentReleaseDate: paymentReleaseDate ?? this.paymentReleaseDate,
      paymentReleaseStatus: paymentReleaseStatus ?? this.paymentReleaseStatus,
      returnReason: returnReason ?? this.returnReason,
      returnStatus: returnStatus ?? this.returnStatus,
      returnRequestedAt: returnRequestedAt ?? this.returnRequestedAt,
      returnApprovedAt: returnApprovedAt ?? this.returnApprovedAt,
      refundAmount: refundAmount ?? this.refundAmount,
      isDeleted: isDeleted ?? this.isDeleted,
      deletedAt: deletedAt ?? this.deletedAt,
      deletedBy: deletedBy ?? this.deletedBy,
    );
  }

  static OrderStatus _parseOrderStatus(String value) {
    return OrderStatus.values.firstWhere(
      (e) => e.name == value,
      orElse: () => OrderStatus.awaitingVerification,
    );
  }

  static PaymentStatus _parsePaymentStatus(String value) {
    return PaymentStatus.values.firstWhere(
      (e) => e.name == value,
      orElse: () => PaymentStatus.pending,
    );
  }

  static CommissionStatus _parseCommissionStatus(String value) {
    return CommissionStatus.values.firstWhere(
      (e) => e.name == value,
      orElse: () => CommissionStatus.pending,
    );
  }

  static VerificationStatus _parseVerificationStatus(String value) {
    return VerificationStatus.values.firstWhere(
      (e) => e.name == value,
      orElse: () => VerificationStatus.pending,
    );
  }
}