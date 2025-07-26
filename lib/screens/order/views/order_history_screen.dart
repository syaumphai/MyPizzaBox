import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:pizza_app/screens/order/repositories/order_tracking_repository.dart';
import 'package:pizza_app/screens/order/views/order_tracking_screen.dart';

class OrderHistoryScreen extends StatelessWidget {
  final OrderTrackingRepository _repository = OrderTrackingRepository();

  OrderHistoryScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('ประวัติการสั่งซื้อ')),
      body: StreamBuilder<List<Map<String, dynamic>>>(
        stream: _repository.getOrdersStream(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(child: Text('ยังไม่มีประวัติการสั่งซื้อ'));
          }
          final orders = snapshot.data!;
          return ListView.builder(
            itemCount: orders.length,
            itemBuilder: (context, index) {
              final order = orders[index];
              final orderId = order['orderId'] ?? order['id'];
              final total = order['total'] ?? 0;
              DateTime? createdAt;
              if (order['createdAt'] is Timestamp) {
                createdAt = (order['createdAt'] as Timestamp).toDate();
              } else if (order['createdAt'] is String) {
                createdAt = DateTime.tryParse(order['createdAt']);
              } else {
                createdAt = null;
              }
              final items = order['items'] as List<dynamic>? ?? [];
              return Card(
                margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: ListTile(
                  title: Text('Order #$orderId',
                      style: const TextStyle(fontWeight: FontWeight.bold)),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      if (createdAt != null)
                        Text(
                          'วันที่: ${createdAt.day}/${createdAt.month}/${createdAt.year} ${createdAt.hour}:${createdAt.minute.toString().padLeft(2, '0')}',
                          style:
                              const TextStyle(fontSize: 12, color: Colors.grey),
                        ),
                      Text('จำนวนสินค้า: ${items.length}'),
                      Text('ยอดรวม: ₭${total.toStringAsFixed(0)}'),
                    ],
                  ),
                  trailing: const Icon(Icons.arrow_forward_ios,
                      size: 16, color: Colors.grey),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => OrderTrackingScreen(
                          orderId: orderId,
                          total: total is num ? total.toDouble() : 0.0,
                          deliveryAddress: order['deliveryAddress'] ?? '',
                          deliveryMethod: order['deliveryMethod'] ?? '',
                          showStatusTimeline: false, // ซ่อนสถานะ
                        ),
                      ),
                    );
                  },
                ),
              );
            },
          );
        },
      ),
    );
  }
}
