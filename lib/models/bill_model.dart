import 'package:cloud_firestore/cloud_firestore.dart';

class BillItem {
  final String name;
  final int quantity;
  final double price;
  final double total;

  BillItem({
    required this.name,
    required this.quantity,
    required this.price,
    required this.total,
  });

  factory BillItem.fromFirestore(Map<String, dynamic> data) {
    return BillItem(
      name: data['name'] ?? '',
      quantity: data['quantity'] ?? 1,
      price: (data['price'] ?? 0).toDouble(),
      total: (data['total'] ?? 0).toDouble(),
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'name': name,
      'quantity': quantity,
      'price': price,
      'total': total,
    };
  }
}

class BillModel {
  final String billNumber;
  final List<BillItem> items;
  final double amount;
  final DateTime date;
  final String status; // generated, sent, paid

  BillModel({
    required this.billNumber,
    required this.items,
    required this.amount,
    required this.date,
    this.status = 'generated',
  });

  factory BillModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    final itemsData = data['items'] as List<dynamic>? ?? [];
    final items = itemsData.map((item) => BillItem.fromFirestore(item)).toList();
    return BillModel(
      billNumber: data['billNumber'] ?? '',
      items: items,
      amount: (data['amount'] ?? 0).toDouble(),
      date: (data['date'] as Timestamp?)?.toDate() ?? DateTime.now(),
      status: data['status'] ?? 'generated',
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'billNumber': billNumber,
      'items': items.map((e) => e.toFirestore()).toList(),
      'amount': amount,
      'date': Timestamp.fromDate(date),
      'status': status,
    };
  }
}