import 'dart:convert';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/bill_model.dart';

class BillGenerationService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<BillModel> generateBillFromAnalysis(String analysisResult) async {
    final items = _extractItems(analysisResult);
    final totalAmount = items.fold(0.0, (sum, item) => sum + (item.price * item.quantity));
    final billNumber = await _generateBillNumber();

    final bill = BillModel(
      billNumber: billNumber,
      items: items,
      amount: totalAmount,
      date: DateTime.now(),
      status: 'generated',
    );

    // Save to Firestore
    final ref = _firestore.collection('bills').doc();
    await ref.set(bill.toFirestore());

    return bill;
  }

  List<BillItem> _extractItems(String text) {
    final items = <BillItem>[];
    final lines = text.split('\n');

    // Simple extraction logic (can be improved)
    for (final line in lines) {
      final regex = RegExp(r'(\d+)\s*[xX]\s*(\d+\.?\d*)\s*=\s*(\d+\.?\d*)');
      final match = regex.firstMatch(line);
      if (match != null) {
        final quantity = int.parse(match.group(1)!);
        final price = double.parse(match.group(2)!);
        final total = double.parse(match.group(3)!);
        items.add(BillItem(
          name: 'Product ${items.length + 1}',
          quantity: quantity,
          price: price,
          total: total,
        ));
      }
    }

    if (items.isEmpty) {
      // Default item if extraction fails
      items.add(BillItem(
        name: 'Product',
        quantity: 1,
        price: 100,
        total: 100,
      ));
    }

    return items;
  }

  Future<String> _generateBillNumber() async {
    final counterRef = _firestore.collection('counters').doc('billCounter');
    final snapshot = await counterRef.get();
    int counter = 1;
    if (snapshot.exists) {
      counter = (snapshot.data()?['value'] ?? 0) + 1;
    }
    await counterRef.set({'value': counter}, SetOptions(merge: true));
    final year = DateTime.now().year;
    final month = DateTime.now().month.toString().padLeft(2, '0');
    return 'BILL-$year-$month-${counter.toString().padLeft(4, '0')}';
  }
}