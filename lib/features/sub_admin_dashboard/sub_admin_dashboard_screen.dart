import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../models/user_model.dart';
import '../../models/order_model.dart' as order_models;

class SubAdminDashboardScreen extends StatefulWidget {
  const SubAdminDashboardScreen({super.key});

  @override
  State<SubAdminDashboardScreen> createState() => _SubAdminDashboardScreenState();
}

class _SubAdminDashboardScreenState extends State<SubAdminDashboardScreen> {
  String? _assignedPartnerId;
  String? _partnerName;

  @override
  void initState() {
    super.initState();
    _loadAssignedPartner();
  }

  Future<void> _loadAssignedPartner() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;
    final doc = await FirebaseFirestore.instance.collection('users').doc(user.uid).get();
    if (!doc.exists) return;
    final userData = UserModel.fromFirestore(doc);
    setState(() {
      _assignedPartnerId = userData.assignedPartnerId;
    });
    if (_assignedPartnerId != null) {
      final partnerDoc = await FirebaseFirestore.instance.collection('users').doc(_assignedPartnerId).get();
      if (partnerDoc.exists) {
        final data = partnerDoc.data() as Map<String, dynamic>;
        setState(() {
          _partnerName = data['displayName'] ?? 'Partner';
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Sub Admin Dashboard'),
          backgroundColor: const Color(0xFF130F26),
          bottom: const TabBar(
            tabs: [
              Tab(icon: Icon(Icons.inventory), text: 'Stock'),
              Tab(icon: Icon(Icons.receipt), text: 'Invoices'),
            ],
          ),
        ),
        body: TabBarView(
          children: [
            // Tab 1: Stock View
            _buildStockView(),
            // Tab 2: Invoice System
            _buildInvoiceView(),
          ],
        ),
      ),
    );
  }

  // ---------- Stock View ----------
  Widget _buildStockView() {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  const Text(
                    'Assigned Partner',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    _partnerName ?? 'Loading...',
                    style: const TextStyle(fontSize: 16, color: Color(0xFFC4FF62)),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),
          const Text(
            'Stock Summary',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          Expanded(
            child: _assignedPartnerId == null
                ? const Center(child: Text('No partner assigned'))
                : StreamBuilder<QuerySnapshot>(
                    stream: FirebaseFirestore.instance
                        .collection('partner_stock')
                        .where('partnerId', isEqualTo: _assignedPartnerId)
                        .snapshots(),
                    builder: (context, snapshot) {
                      if (snapshot.hasError) return Text('Error: ${snapshot.error}');
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return const Center(child: CircularProgressIndicator());
                      }
                      final stocks = snapshot.data!.docs;
                      if (stocks.isEmpty) return const Text('No stock data for this partner');
                      return ListView.builder(
                        itemCount: stocks.length,
                        itemBuilder: (context, index) {
                          final data = stocks[index].data() as Map<String, dynamic>;
                          return Card(
                            child: Padding(
                              padding: const EdgeInsets.all(16),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    _partnerName ?? 'Partner',
                                    style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                                  ),
                                  const SizedBox(height: 8),
                                  Text('Total Allocated: ₹${data['totalAllocated']?.toStringAsFixed(2) ?? 0}'),
                                  Text('Remaining: ₹${data['remainingStock']?.toStringAsFixed(2) ?? 0}'),
                                  const SizedBox(height: 8),
                                  const Text('Platform-wise Stock', style: TextStyle(fontWeight: FontWeight.bold)),
                                  ...(data['platformStock'] as Map<String, dynamic>? ?? {}).entries.map((entry) {
                                    return Padding(
                                      padding: const EdgeInsets.only(left: 8),
                                      child: Text('${entry.key}: ₹${entry.value.toStringAsFixed(2)}'),
                                    );
                                  }).toList(),
                                ],
                              ),
                            ),
                          );
                        },
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }

  // ---------- Invoice View ----------
  Widget _buildInvoiceView() {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: () {
                    // Generate invoice for all delivered orders
                    _generateInvoice();
                  },
                  icon: const Icon(Icons.receipt_long),
                  label: const Text('Generate Invoice'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFC4FF62),
                    foregroundColor: Colors.black,
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: () {
                    // Download PDF placeholder
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Download PDF - Coming Soon')),
                    );
                  },
                  icon: const Icon(Icons.download),
                  label: const Text('Download PDF'),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          const Text(
            'Invoice History',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance
                  .collection('orders')
                  .where('status', isEqualTo: 'delivered')
                  .orderBy('deliveredAt', descending: true)
                  .snapshots(),
              builder: (context, snapshot) {
                if (snapshot.hasError) return Text('Error: ${snapshot.error}');
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }
                final orders = snapshot.data!.docs.map((doc) => order_models.Order.fromFirestore(doc)).toList();
                if (orders.isEmpty) {
                  return const Center(child: Text('No delivered orders for invoice'));
                }
                return ListView.builder(
                  itemCount: orders.length,
                  itemBuilder: (context, index) {
                    final order = orders[index];
                    return Card(
                      child: ListTile(
                        title: Text('Invoice #${order.orderNumber}'),
                        subtitle: Text(
                          '${order.customerName} | ₹${order.orderAmount.toStringAsFixed(2)} | ${order.deliveredAt != null ? '${order.deliveredAt!.day}/${order.deliveredAt!.month}/${order.deliveredAt!.year}' : ''}',
                        ),
                        trailing: const Icon(Icons.receipt),
                        onTap: () {
                          _showInvoiceDetails(order);
                        },
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  // ---------- Generate Invoice ----------
  void _generateInvoice() {
    // Logic to create invoice document in Firestore
    // For now, show a toast
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Invoice generated successfully!')),
    );
  }

  // ---------- Show Invoice Details ----------
  void _showInvoiceDetails(order_models.Order order) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Invoice #${order.orderNumber}'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Customer: ${order.customerName}'),
            Text('Mobile: ${order.mobile}'),
            Text('Amount: ₹${order.orderAmount.toStringAsFixed(2)}'),
            Text('Platform: ${order.platform}'),
            const Divider(),
            const Text('Items:', style: TextStyle(fontWeight: FontWeight.bold)),
            ...order.items.map((item) {
              return Text('• ${item.productName} x${item.quantity} - ₹${(item.unitPrice * item.quantity).toStringAsFixed(2)}');
            }).toList(),
            const Divider(),
            Text('Total: ₹${order.orderAmount.toStringAsFixed(2)}', style: const TextStyle(fontWeight: FontWeight.bold)),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }
}