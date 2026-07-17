import 'package:cloud_firestore/cloud_firestore.dart';

import 'product_model.dart';

enum InfluencerProductStatus {
  active,
  inactive,
}

class InfluencerProductAssignment {
  final String assignmentId;
  final String influencerId;
  final String vendorId;
  final String productId;
  final String productName;
  final String? imageUrl;
  final double sellingPrice;
  final CommissionType commissionType;
  final double commissionValue;
  final InfluencerProductStatus status;
  final DateTime activatedAt;
  final DateTime updatedAt;
  final DateTime? deactivatedAt;
  final String referralCode;
  final String? referralLink;
  final int clicks;
  final int orders;
  final int deliveredOrders;
  final double salesAmount;
  final double commissionEarned;

  const InfluencerProductAssignment({
    required this.assignmentId,
    required this.influencerId,
    required this.vendorId,
    required this.productId,
    required this.productName,
    this.imageUrl,
    required this.sellingPrice,
    required this.commissionType,
    required this.commissionValue,
    required this.status,
    required this.activatedAt,
    required this.updatedAt,
    this.deactivatedAt,
    required this.referralCode,
    this.referralLink,
    this.clicks = 0,
    this.orders = 0,
    this.deliveredOrders = 0,
    this.salesAmount = 0,
    this.commissionEarned = 0,
  });

  factory InfluencerProductAssignment.fromFirestore(DocumentSnapshot document) {
    final data =
        document.data() as Map<String, dynamic>? ?? <String, dynamic>{};
    final statusName =
        data['status'] as String? ?? InfluencerProductStatus.inactive.name;
    final commissionTypeName =
        data['commissionType'] as String? ?? CommissionType.percent.name;

    return InfluencerProductAssignment(
      assignmentId: data['assignmentId'] as String? ?? document.id,
      influencerId: data['influencerId'] as String? ?? '',
      vendorId: data['vendorId'] as String? ?? '',
      productId: data['productId'] as String? ?? '',
      productName: data['productName'] as String? ?? '',
      imageUrl: data['imageUrl'] as String?,
      sellingPrice: (data['sellingPrice'] as num?)?.toDouble() ?? 0,
      commissionType: commissionTypeName == CommissionType.fixed.name
          ? CommissionType.fixed
          : CommissionType.percent,
      commissionValue: (data['commissionValue'] as num?)?.toDouble() ?? 0,
      status: statusName == InfluencerProductStatus.active.name
          ? InfluencerProductStatus.active
          : InfluencerProductStatus.inactive,
      activatedAt: _dateFromFirestore(data['activatedAt']) ?? DateTime.now(),
      updatedAt: _dateFromFirestore(data['updatedAt']) ?? DateTime.now(),
      deactivatedAt: _dateFromFirestore(data['deactivatedAt']),
      referralCode: data['referralCode'] as String? ?? '',
      referralLink: data['referralLink'] as String?,
      clicks: (data['clicks'] as num?)?.toInt() ?? 0,
      orders: (data['orders'] as num?)?.toInt() ?? 0,
      deliveredOrders: (data['deliveredOrders'] as num?)?.toInt() ?? 0,
      salesAmount: (data['salesAmount'] as num?)?.toDouble() ?? 0,
      commissionEarned: (data['commissionEarned'] as num?)?.toDouble() ?? 0,
    );
  }

  Map<String, dynamic> toFirestore() {
    return <String, dynamic>{
      'assignmentId': assignmentId,
      'influencerId': influencerId,
      'vendorId': vendorId,
      'productId': productId,
      'productName': productName,
      'imageUrl': imageUrl,
      'sellingPrice': sellingPrice,
      'commissionType': commissionType.name,
      'commissionValue': commissionValue,
      'status': status.name,
      'activatedAt': Timestamp.fromDate(activatedAt),
      'updatedAt': Timestamp.fromDate(updatedAt),
      'deactivatedAt':
          deactivatedAt == null ? null : Timestamp.fromDate(deactivatedAt!),
      'referralCode': referralCode,
      'referralLink': referralLink,
      'clicks': clicks,
      'orders': orders,
      'deliveredOrders': deliveredOrders,
      'salesAmount': salesAmount,
      'commissionEarned': commissionEarned,
    };
  }

  InfluencerProductAssignment copyWith({
    String? assignmentId,
    String? influencerId,
    String? vendorId,
    String? productId,
    String? productName,
    String? imageUrl,
    double? sellingPrice,
    CommissionType? commissionType,
    double? commissionValue,
    InfluencerProductStatus? status,
    DateTime? activatedAt,
    DateTime? updatedAt,
    DateTime? deactivatedAt,
    bool clearDeactivatedAt = false,
    String? referralCode,
    String? referralLink,
    int? clicks,
    int? orders,
    int? deliveredOrders,
    double? salesAmount,
    double? commissionEarned,
  }) {
    return InfluencerProductAssignment(
      assignmentId: assignmentId ?? this.assignmentId,
      influencerId: influencerId ?? this.influencerId,
      vendorId: vendorId ?? this.vendorId,
      productId: productId ?? this.productId,
      productName: productName ?? this.productName,
      imageUrl: imageUrl ?? this.imageUrl,
      sellingPrice: sellingPrice ?? this.sellingPrice,
      commissionType: commissionType ?? this.commissionType,
      commissionValue: commissionValue ?? this.commissionValue,
      status: status ?? this.status,
      activatedAt: activatedAt ?? this.activatedAt,
      updatedAt: updatedAt ?? this.updatedAt,
      deactivatedAt:
          clearDeactivatedAt ? null : deactivatedAt ?? this.deactivatedAt,
      referralCode: referralCode ?? this.referralCode,
      referralLink: referralLink ?? this.referralLink,
      clicks: clicks ?? this.clicks,
      orders: orders ?? this.orders,
      deliveredOrders: deliveredOrders ?? this.deliveredOrders,
      salesAmount: salesAmount ?? this.salesAmount,
      commissionEarned: commissionEarned ?? this.commissionEarned,
    );
  }

  bool get isActive => status == InfluencerProductStatus.active;

  static DateTime? _dateFromFirestore(Object? value) {
    if (value is Timestamp) return value.toDate();
    if (value is DateTime) return value;
    if (value is String) return DateTime.tryParse(value);
    return null;
  }
}
