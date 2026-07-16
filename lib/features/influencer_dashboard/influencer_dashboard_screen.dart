import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../models/order_model.dart' as order_models;

class InfluencerDashboardScreen extends StatefulWidget {
  const InfluencerDashboardScreen({super.key});

  @override
  State<InfluencerDashboardScreen> createState() => _InfluencerDashboardScreenState();
}

class _InfluencerDashboardScreenState extends State<InfluencerDashboardScreen> {
  String? _influencerId;
  List<order_models.Order> _orders = [];
  double _totalCommission = 0.0;
  int _pendingCount = 0;
  int _paidCount = 0;
  int _processingCount = 0;

  @override
  void initState() {
    super.initState();
    _loadInfluencerData();
  }

  Future<void> _loadInfluencerData() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;
    setState(() {
      _influencerId = user.uid;
    });
    _fetchOrders();
    _checkPayments();
  }

  void _fetchOrders() {
    if (_influencerId == null) return;

    FirebaseFirestore.instance
        .collection('orders')
        .where('influencerId', isEqualTo: _influencerId)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .listen((snapshot) {
      final orders = snapshot.docs.map((doc) => order_models.Order.fromFirestore(doc)).toList();
      double total = 0.0;
      int pending = 0;
      int paid = 0;
      int processing = 0;

      for (final order in orders) {
        total += order.influencerCommission;
        if (order.paymentReleaseStatus == 'paid') {
          paid++;
        } else if (order.paymentReleaseStatus == 'processing') {
          processing++;
        } else {
          pending++;
        }
      }

      setState(() {
        _orders = orders;
        _totalCommission = total;
        _pendingCount = pending;
        _paidCount = paid;
        _processingCount = processing;
      });
    });
  }

  Future<void> _checkPayments() async {
    if (_influencerId == null) return;
    final orders = await FirebaseFirestore.instance
        .collection('orders')
        .where('influencerId', isEqualTo: _influencerId)
        .where('paymentReleaseStatus', isEqualTo: 'processing')
        .get();

    for (final doc in orders.docs) {
      final order = order_models.Order.fromFirestore(doc);
      if (order.paymentReleaseDate != null &&
          DateTime.now().isAfter(order.paymentReleaseDate!)) {
        await doc.reference.update({
          'paymentReleaseStatus': 'paid',
          'commissionStatus': order_models.CommissionStatus.paid.name,
        });
        debugPrint('✅ Payment released for order: ${order.orderNumber}');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Influencer Dashboard'),
        backgroundColor: const Color(0xFF130F26),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            // ---------- Summary Cards ----------
            Row(
              children: [
                _buildSummaryCard('Total Orders', _orders.length.toString(), Colors.blue),
                _buildSummaryCard('Pending', _pendingCount.toString(), Colors.red),
                _buildSummaryCard('Processing', _processingCount.toString(), Colors.orange),
                _buildSummaryCard('Paid', _paidCount.toString(), Colors.green),
                _buildSummaryCard('Total Commission', '₹${_totalCommission.toStringAsFixed(2)}', const Color(0xFFC4FF62)),
              ],
            ),
            const SizedBox(height: 16),

            // ---------- Ledger Table ----------
            const Text(
              'Commission Ledger',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Expanded(
              child: _orders.isEmpty
                  ? const Center(child: Text('No orders yet'))
                  : SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: DataTable(
                        columnSpacing: 16,
                        columns: const [
                          DataColumn(label: Text('Order No')),
                          DataColumn(label: Text('Commission')),
                          DataColumn(label: Text('Status')),
                          DataColumn(label: Text('Release Date')),
                        ],
                        rows: _orders.map((order) {
                          return DataRow(cells: [
                            DataCell(Text(order.orderNumber)),
                            DataCell(Text('₹${order.influencerCommission.toStringAsFixed(2)}')),
                            DataCell(_buildPaymentStatusChip(order.paymentReleaseStatus)),
                            DataCell(Text(order.paymentReleaseDate != null
                                ? '${order.paymentReleaseDate!.day}/${order.paymentReleaseDate!.month}/${order.paymentReleaseDate!.year}'
                                : '—')),
                          ]);
                        }).toList(),
                      ),
                    ),
            ),
            const SizedBox(height: 8),
            // ---------- Total Tally ----------
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.grey[900],
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    '💰 Total Commission',
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                  ),
                  Text(
                    '₹${_totalCommission.toStringAsFixed(2)}',
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                      color: Color(0xFFC4FF62),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSummaryCard(String label, String value, Color color) {
    return Expanded(
      child: Card(
        child: Padding(
          padding: const EdgeInsets.all(8),
          child: Column(
            children: [
              Text(label, style: const TextStyle(color: Color(0xFF938F99), fontSize: 10)),
              const SizedBox(height: 2),
              Text(value, style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: color)),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPaymentStatusChip(String status) {
    Color color;
    String label;

    switch (status) {
      case 'paid':
        color = Colors.green;
        label = '✅ Paid';
        break;
      case 'processing':
        color = Colors.orange;
        label = '⏳ Processing';
        break;
      default:
        color = Colors.red;
        label = '❌ Pending';
    }

    return Chip(
      label: Text(label),
      backgroundColor: color.withAlpha(30),
      labelStyle: TextStyle(color: color, fontWeight: FontWeight.bold),
      side: BorderSide(color: color),
    );
  }
}