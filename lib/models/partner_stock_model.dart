import 'package:cloud_firestore/cloud_firestore.dart';

class PartnerStock {
  final String id;
  final String partnerId;
  final String partnerName;
  final double totalAllocated;
  final double rentDeducted;
  final Map<String, double> platformStock; // meesho, flipkart, amazon, reelgen
  final double remainingStock;
  final DateTime createdAt;
  final DateTime updatedAt;

  PartnerStock({
    required this.id,
    required this.partnerId,
    required this.partnerName,
    required this.totalAllocated,
    required this.rentDeducted,
    required this.platformStock,
    required this.remainingStock,
    required this.createdAt,
    required this.updatedAt,
  });

  factory PartnerStock.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return PartnerStock(
      id: doc.id,
      partnerId: data['partnerId'] ?? '',
      partnerName: data['partnerName'] ?? '',
      totalAllocated: (data['totalAllocated'] ?? 0).toDouble(),
      rentDeducted: (data['rentDeducted'] ?? 0).toDouble(),
      platformStock: Map<String, double>.from(data['platformStock'] ?? {}),
      remainingStock: (data['remainingStock'] ?? 0).toDouble(),
      createdAt: (data['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      updatedAt: (data['updatedAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'partnerId': partnerId,
      'partnerName': partnerName,
      'totalAllocated': totalAllocated,
      'rentDeducted': rentDeducted,
      'platformStock': platformStock,
      'remainingStock': remainingStock,
      'createdAt': Timestamp.fromDate(createdAt),
      'updatedAt': Timestamp.fromDate(updatedAt),
    };
  }

  PartnerStock copyWith({
    String? id,
    String? partnerId,
    String? partnerName,
    double? totalAllocated,
    double? rentDeducted,
    Map<String, double>? platformStock,
    double? remainingStock,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return PartnerStock(
      id: id ?? this.id,
      partnerId: partnerId ?? this.partnerId,
      partnerName: partnerName ?? this.partnerName,
      totalAllocated: totalAllocated ?? this.totalAllocated,
      rentDeducted: rentDeducted ?? this.rentDeducted,
      platformStock: platformStock ?? this.platformStock,
      remainingStock: remainingStock ?? this.remainingStock,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}