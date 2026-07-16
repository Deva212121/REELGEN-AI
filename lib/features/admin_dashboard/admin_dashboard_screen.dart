import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import '../../models/order_model.dart' as order_models;
import '../../services/order_service.dart';
import '../../widgets/order_timeline_widget.dart';

class AdminDashboardScreen extends StatefulWidget {
  const AdminDashboardScreen({super.key});

  @override
  State<AdminDashboardScreen> createState() => _AdminDashboardScreenState();
}

class _AdminDashboardScreenState extends State<AdminDashboardScreen> {
  final OrderService _orderService = OrderService();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Admin Dashboard'),
        backgroundColor: const Color(0xFF130F26),
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('orders')
            .orderBy('createdAt', descending: true)
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          final orders = snapshot.data!.docs.map((doc) => order_models.Order.fromFirestore(doc)).toList();
          if (orders.isEmpty) {
            return const Center(child: Text('No orders found'));
          }
          return ListView.builder(
            itemCount: orders.length,
            itemBuilder: (context, index) {
              final order = orders[index];
              return Card(
                margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                child: ExpansionTile(
                  title: Text('${order.orderNumber} - ${order.customerName}'),
                  subtitle: Text(
                    'Status: ${order.status.name} | ₹${order.orderAmount.toStringAsFixed(2)}',
                  ),
                  children: [
                    Padding(
                      padding: const EdgeInsets.all(12),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Order ID: ${order.orderId}'),
                          Text('Customer: ${order.customerName} (${order.mobile})'),
                          Text('Address: ${order.address}'),
                          Text('Items: ${order.items.length}'),
                          const SizedBox(height: 8),
                          // Status Actions
                          Wrap(
                            spacing: 8,
                            runSpacing: 8,
                            children: [
                              if (order.status == order_models.OrderStatus.awaitingVerification)
                                ElevatedButton.icon(
                                  onPressed: () => _verifyOrder(order),
                                  icon: const Icon(Icons.verified, size: 16),
                                  label: const Text('Verify'),
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: Colors.green,
                                    foregroundColor: Colors.white,
                                  ),
                                ),
                              if (order.status == order_models.OrderStatus.verified)
                                ElevatedButton.icon(
                                  onPressed: () => _updateStatus(order, order_models.OrderStatus.packed),
                                  icon: const Icon(Icons.inventory, size: 16),
                                  label: const Text('Packed'),
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: Colors.blue,
                                    foregroundColor: Colors.white,
                                  ),
                                ),
                              if (order.status == order_models.OrderStatus.packed)
                                ElevatedButton.icon(
                                  onPressed: () => _updateStatus(order, order_models.OrderStatus.shipped),
                                  icon: const Icon(Icons.local_shipping, size: 16),
                                  label: const Text('Shipped'),
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: Colors.purple,
                                    foregroundColor: Colors.white,
                                  ),
                                ),
                              if (order.status == order_models.OrderStatus.shipped)
                                ElevatedButton.icon(
                                  onPressed: () => _updateStatus(order, order_models.OrderStatus.delivered),
                                  icon: const Icon(Icons.delivery_dining, size: 16),
                                  label: const Text('Delivered'),
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: Colors.teal,
                                    foregroundColor: Colors.white,
                                  ),
                                ),
                              // Cancel (only before packing)
                              if (order.status == order_models.OrderStatus.awaitingVerification ||
                                  order.status == order_models.OrderStatus.verified)
                                OutlinedButton.icon(
                                  onPressed: () => _cancelOrder(order),
                                  icon: const Icon(Icons.cancel, size: 16),
                                  label: const Text('Cancel'),
                                  style: OutlinedButton.styleFrom(
                                    foregroundColor: Colors.red,
                                    side: const BorderSide(color: Colors.red),
                                  ),
                                ),
                              // Return/Refund
                              if (order.status == order_models.OrderStatus.delivered &&
                                  order.returnStatus == null)
                                OutlinedButton.icon(
                                  onPressed: () => _showReturnDialog(order),
                                  icon: const Icon(Icons.undo, size: 16),
                                  label: const Text('Return'),
                                  style: OutlinedButton.styleFrom(
                                    foregroundColor: Colors.orange,
                                    side: const BorderSide(color: Colors.orange),
                                  ),
                                ),
                              if (order.returnStatus == 'pending')
                                Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    OutlinedButton.icon(
                                      onPressed: () => _approveReturn(order),
                                      icon: const Icon(Icons.check_circle, size: 16),
                                      label: const Text('Approve'),
                                      style: OutlinedButton.styleFrom(
                                        foregroundColor: Colors.green,
                                        side: const BorderSide(color: Colors.green),
                                      ),
                                    ),
                                    const SizedBox(width: 8),
                                    OutlinedButton.icon(
                                      onPressed: () => _rejectReturn(order),
                                      icon: const Icon(Icons.cancel, size: 16),
                                      label: const Text('Reject'),
                                      style: OutlinedButton.styleFrom(
                                        foregroundColor: Colors.red,
                                        side: const BorderSide(color: Colors.red),
                                      ),
                                    ),
                                  ],
                                ),
                              if (order.returnStatus == 'approved')
                                OutlinedButton.icon(
                                  onPressed: () => _processRefund(order),
                                  icon: const Icon(Icons.money_off, size: 16),
                                  label: const Text('Refund'),
                                  style: OutlinedButton.styleFrom(
                                    foregroundColor: Colors.purple,
                                    side: const BorderSide(color: Colors.purple),
                                  ),
                                ),
                            ],
                          ),
                          const SizedBox(height: 16),
                          OrderTimelineWidget(order: order),
                        ],
                      ),
                    ),
                  ],
                ),
              );
            },
          );
        },
      ),
    );
  }

  // ---------- Actions ----------
  Future<void> _verifyOrder(order_models.Order order) async {
    try {
      await _orderService.verifyOrder(order.orderId, order.confirmationCode ?? '');
      Fluttertoast.showToast(msg: 'Order verified successfully');
      setState(() {});
    } catch (e) {
      Fluttertoast.showToast(msg: 'Error: $e');
    }
  }

  Future<void> _updateStatus(order_models.Order order, order_models.OrderStatus newStatus) async {
    try {
      await _orderService.updateOrderStatus(order.orderId, newStatus);
      Fluttertoast.showToast(msg: 'Order ${newStatus.name} successfully');
      setState(() {});
    } catch (e) {
      Fluttertoast.showToast(msg: 'Error: $e');
    }
  }

  Future<void> _cancelOrder(order_models.Order order) async {
    try {
      await _orderService.cancelOrder(order.orderId);
      Fluttertoast.showToast(msg: 'Order cancelled');
      setState(() {});
    } catch (e) {
      Fluttertoast.showToast(msg: 'Error: $e');
    }
  }

  Future<void> _showReturnDialog(order_models.Order order) async {
    final controller = TextEditingController();
    await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Return Request'),
        content: TextField(
          controller: controller,
          decoration: const InputDecoration(labelText: 'Return Reason'),
          maxLines: 3,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              if (controller.text.isNotEmpty) {
                await _orderService.requestReturn(order.orderId, controller.text);
                Fluttertoast.showToast(msg: 'Return requested');
                Navigator.pop(context);
                setState(() {});
              }
            },
            child: const Text('Submit'),
          ),
        ],
      ),
    );
  }

  Future<void> _approveReturn(order_models.Order order) async {
    try {
      await _orderService.approveReturn(order.orderId);
      Fluttertoast.showToast(msg: 'Return approved');
      setState(() {});
    } catch (e) {
      Fluttertoast.showToast(msg: 'Error: $e');
    }
  }

  Future<void> _rejectReturn(order_models.Order order) async {
    try {
      await _orderService.rejectReturn(order.orderId);
      Fluttertoast.showToast(msg: 'Return rejected');
      setState(() {});
    } catch (e) {
      Fluttertoast.showToast(msg: 'Error: $e');
    }
  }

  Future<void> _processRefund(order_models.Order order) async {
    try {
      await _orderService.processRefund(order.orderId);
      Fluttertoast.showToast(msg: 'Refund processed');
      setState(() {});
    } catch (e) {
      Fluttertoast.showToast(msg: 'Error: $e');
    }
  }
}