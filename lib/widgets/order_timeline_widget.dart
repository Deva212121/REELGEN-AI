import 'package:flutter/material.dart';
import '../models/order_model.dart' as order_models;

class OrderTimelineWidget extends StatelessWidget {
  final order_models.Order order;

  const OrderTimelineWidget({super.key, required this.order});

  @override
  Widget build(BuildContext context) {
    final events = [
      _TimelineEvent('Order Created', order.createdAt, Icons.check_circle, Colors.blue),
      if (order.verifiedAt != null)
        _TimelineEvent('Verified', order.verifiedAt!, Icons.check_circle, Colors.green),
      if (order.packedAt != null)
        _TimelineEvent('Packed', order.packedAt!, Icons.inventory, Colors.orange),
      if (order.shippedAt != null)
        _TimelineEvent('Shipped', order.shippedAt!, Icons.local_shipping, Colors.purple),
      if (order.deliveredAt != null)
        _TimelineEvent('Delivered', order.deliveredAt!, Icons.delivery_dining, Colors.teal),
      if (order.returnRequestedAt != null)
        _TimelineEvent('Return Requested', order.returnRequestedAt!, Icons.undo, Colors.orange),
      if (order.returnApprovedAt != null)
        _TimelineEvent('Return Approved', order.returnApprovedAt!, Icons.check_circle, Colors.green),
      if (order.refundedAt != null)
        _TimelineEvent('Refunded', order.refundedAt!, Icons.money_off, Colors.purple),
      if (order.cancelledAt != null)
        _TimelineEvent('Cancelled', order.cancelledAt!, Icons.cancel, Colors.red),
    ];

    if (events.length == 1) {
      return const SizedBox.shrink();
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          '📋 Activity Timeline',
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
        ),
        const SizedBox(height: 8),
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: Colors.grey[900],
            borderRadius: BorderRadius.circular(8),
          ),
          child: Column(
            children: events.map((event) {
              return Padding(
                padding: const EdgeInsets.symmetric(vertical: 2),
                child: Row(
                  children: [
                    Icon(event.icon, color: event.color, size: 14),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        event.label,
                        style: const TextStyle(fontSize: 12),
                      ),
                    ),
                    Text(
                      '${event.time.day}/${event.time.month}/${event.time.year} ${event.time.hour.toString().padLeft(2, '0')}:${event.time.minute.toString().padLeft(2, '0')}',
                      style: const TextStyle(fontSize: 10, color: Color(0xFF938F99)),
                    ),
                  ],
                ),
              );
            }).toList(),
          ),
        ),
      ],
    );
  }
}

class _TimelineEvent {
  final String label;
  final DateTime time;
  final IconData icon;
  final Color color;

  _TimelineEvent(this.label, this.time, this.icon, this.color);
}