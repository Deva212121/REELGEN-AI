import 'package:cloud_firestore/cloud_firestore.dart';

/// Commission type for a product.
enum CommissionType {
  fixed,   // fixed amount per unit sold
  percent, // percentage of product price
}

/// Product model representing a sellable item (e.g., jewellery).
class Product {
  final String id;
  final String vendorId;

  // Identification
  final String designNumber;
  final String productCode;
  final String sku;

  // Basic Info
  final String name;
  final String? description;
  final String category;
  final String? collectionName;
  final String? materialType;
  final String? color;
  final String? size;

  // Pricing
  final double price;
  final String currency; // default 'INR'

  // Stock
  final int currentStock;
  final int reservedStock;
  final int minStockLevel;
  final int stockQty;

  // Commission
  final CommissionType commissionType;
  final double commissionValue;

  // Tax
  final String gstHsnCode;
  final double gstRate;

  // Other
  final String unit;
  final bool isActive;
  final DateTime createdAt;
  final DateTime updatedAt;

  Product({
    required this.id,
    required this.vendorId,
    required this.designNumber,
    required this.productCode,
    required this.sku,
    required this.name,
    this.description,
    required this.category,
    this.collectionName,
    this.materialType,
    this.color,
    this.size,
    required this.price,
    this.currency = 'INR',
    this.currentStock = 0,
    this.reservedStock = 0,
    this.minStockLevel = 0,
    this.stockQty = 0,
    required this.commissionType,
    required this.commissionValue,
    required this.gstHsnCode,
    required this.gstRate,
    this.unit = 'pc',
    this.isActive = true,
    required this.createdAt,
    required this.updatedAt,
  });

  factory Product.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    final typeStr = data['commissionType'] ?? 'percent';
    final type = typeStr == 'fixed' ? CommissionType.fixed : CommissionType.percent;

    return Product(
      id: doc.id,
      vendorId: data['vendorId'] ?? '',
      designNumber: data['designNumber'] ?? '',
      productCode: data['productCode'] ?? '',
      sku: data['sku'] ?? '',
      name: data['name'] ?? '',
      description: data['description'],
      category: data['category'] ?? '',
      collectionName: data['collectionName'],
      materialType: data['materialType'],
      color: data['color'],
      size: data['size'],
      price: (data['price'] ?? 0).toDouble(),
      currency: data['currency'] ?? 'INR',
      currentStock: data['currentStock'] ?? 0,
      reservedStock: data['reservedStock'] ?? 0,
      minStockLevel: data['minStockLevel'] ?? 0,
      stockQty: data['stockQty'] ?? 0,
      commissionType: type,
      commissionValue: (data['commissionValue'] ?? 0).toDouble(),
      gstHsnCode: data['gstHsnCode'] ?? '',
      gstRate: (data['gstRate'] ?? 0).toDouble(),
      unit: data['unit'] ?? 'pc',
      isActive: data['isActive'] ?? true,
      createdAt: (data['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      updatedAt: (data['updatedAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'vendorId': vendorId,
      'designNumber': designNumber,
      'productCode': productCode,
      'sku': sku,
      'name': name,
      'description': description,
      'category': category,
      'collectionName': collectionName,
      'materialType': materialType,
      'color': color,
      'size': size,
      'price': price,
      'currency': currency,
      'currentStock': currentStock,
      'reservedStock': reservedStock,
      'minStockLevel': minStockLevel,
      'stockQty': stockQty,
      'commissionType': commissionType.name,
      'commissionValue': commissionValue,
      'gstHsnCode': gstHsnCode,
      'gstRate': gstRate,
      'unit': unit,
      'isActive': isActive,
      'createdAt': Timestamp.fromDate(createdAt),
      'updatedAt': Timestamp.fromDate(updatedAt),
    };
  }

  Product copyWith({
    String? id,
    String? vendorId,
    String? designNumber,
    String? productCode,
    String? sku,
    String? name,
    String? description,
    String? category,
    String? collectionName,
    String? materialType,
    String? color,
    String? size,
    double? price,
    String? currency,
    int? currentStock,
    int? reservedStock,
    int? minStockLevel,
    int? stockQty,
    CommissionType? commissionType,
    double? commissionValue,
    String? gstHsnCode,
    double? gstRate,
    String? unit,
    bool? isActive,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return Product(
      id: id ?? this.id,
      vendorId: vendorId ?? this.vendorId,
      designNumber: designNumber ?? this.designNumber,
      productCode: productCode ?? this.productCode,
      sku: sku ?? this.sku,
      name: name ?? this.name,
      description: description ?? this.description,
      category: category ?? this.category,
      collectionName: collectionName ?? this.collectionName,
      materialType: materialType ?? this.materialType,
      color: color ?? this.color,
      size: size ?? this.size,
      price: price ?? this.price,
      currency: currency ?? this.currency,
      currentStock: currentStock ?? this.currentStock,
      reservedStock: reservedStock ?? this.reservedStock,
      minStockLevel: minStockLevel ?? this.minStockLevel,
      stockQty: stockQty ?? this.stockQty,
      commissionType: commissionType ?? this.commissionType,
      commissionValue: commissionValue ?? this.commissionValue,
      gstHsnCode: gstHsnCode ?? this.gstHsnCode,
      gstRate: gstRate ?? this.gstRate,
      unit: unit ?? this.unit,
      isActive: isActive ?? this.isActive,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  // Helper: calculate commission for a given quantity
  double calculateCommission(int quantity) {
    if (commissionType == CommissionType.fixed) {
      return commissionValue * quantity;
    } else {
      return (price * commissionValue / 100) * quantity;
    }
  }

  int get availableStock => currentStock - reservedStock;
  bool get isLowStock => availableStock <= minStockLevel;
}