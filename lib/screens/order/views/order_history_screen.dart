import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:pizza_app/screens/order/repositories/order_tracking_repository.dart';
import 'package:pizza_app/screens/order/views/order_tracking_screen.dart';

class OrderHistoryScreen extends StatelessWidget {
  final OrderTrackingRepository _repository = OrderTrackingRepository();

  OrderHistoryScreen({Key? key}) : super(key: key);

  String _getStatusText(String status) {
    switch (status) {
      case 'pending':
        return 'ລໍຖ້າການຢືນຢັນ';
      case 'confirmed':
        return 'ຢືນຢັນແລ້ວ';
      case 'preparing':
        return 'ກຳລັງກະກຽມ';
      case 'ready':
        return 'ພ້ອມສົ່ງ';
      case 'delivering':
        return 'ກຳລັງສົ່ງ';
      case 'delivered':
        return 'ສົ່ງແລ້ວ';
      case 'cancelled':
        return 'ຍົກເລີກ';
      default:
        return 'ລໍຖ້າການຢືນຢັນ';
    }
  }

  Color _getStatusColor(String status) {
    switch (status) {
      case 'pending':
        return Colors.orange;
      case 'confirmed':
        return Colors.blue;
      case 'preparing':
        return Colors.purple;
      case 'ready':
        return Colors.indigo;
      case 'delivering':
        return Colors.deepPurple;
      case 'delivered':
        return Colors.green;
      case 'cancelled':
        return Colors.red;
      default:
        return Colors.orange;
    }
  }

  IconData _getStatusIcon(String status) {
    switch (status) {
      case 'pending':
        return Icons.schedule;
      case 'confirmed':
        return Icons.check_circle;
      case 'preparing':
        return Icons.restaurant;
      case 'ready':
        return Icons.local_shipping;
      case 'delivering':
        return Icons.delivery_dining;
      case 'delivered':
        return Icons.done_all;
      case 'cancelled':
        return Icons.cancel;
      default:
        return Icons.schedule;
    }
  }

  void _showOrderDetails(BuildContext context, Map<String, dynamic> order) {
    final orderId = order['orderId'] ?? order['id'];
    final total = order['total'] ?? 0;
    final status = order['status'] ?? 'pending';
    final items = order['items'] as List<dynamic>? ?? [];
    final deliveryAddress = order['deliveryAddress'] ?? '';
    final phoneNumber = order['phoneNumber'] ?? '';
    final note = order['note'] ?? '';
    final deliveryMethod = order['deliveryMethod'] ?? '';

    // Debug: แสดงข้อมูลใน console
    print('Order Details $orderId - Status: $status');
    print('Order Details data: $order');
    print('Status from order details: ${order['status']}');
    print('Default status details: pending');

    DateTime? createdAt;
    if (order['createdAt'] is Timestamp) {
      createdAt = (order['createdAt'] as Timestamp).toDate();
    } else if (order['createdAt'] is String) {
      createdAt = DateTime.tryParse(order['createdAt']);
    }

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('ລາຍລະອຽດອໍເດີ້ $orderId'),
          content: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                // สถานะ
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: _getStatusColor(status).withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: _getStatusColor(status)),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(_getStatusIcon(status),
                          size: 16, color: _getStatusColor(status)),
                      const SizedBox(width: 4),
                      Text(
                        _getStatusText(status),
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          color: _getStatusColor(status),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 12),

                // วันที่
                if (createdAt != null) ...[
                  Text(
                      'ວັນທີ: ${createdAt.day}/${createdAt.month}/${createdAt.year} ${createdAt.hour}:${createdAt.minute.toString().padLeft(2, '0')}'),
                  const SizedBox(height: 8),
                ],

                // ข้อมูลการจัดส่ง
                if (deliveryMethod == 'delivery') ...[
                  Text('ທີ່ຢູ່ຈັດສົ່ງ: $deliveryAddress'),
                  const SizedBox(height: 4),
                ],
                Text('ເບີໂທລະສັບ: $phoneNumber'),
                if (note.isNotEmpty) ...[
                  const SizedBox(height: 4),
                  Text('ໝາຍເຫດ: $note'),
                ],
                const SizedBox(height: 8),

                // รายการสินค้า
                const Text('ສິນຄ້າ:',
                    style: TextStyle(fontWeight: FontWeight.bold)),
                const SizedBox(height: 4),
                ...items
                    .map((item) => Padding(
                          padding: const EdgeInsets.only(bottom: 4),
                          child: Text('• ${item['name']} x${item['quantity']}'),
                        ))
                    .toList(),
                const SizedBox(height: 8),

                // ยอดรวม
                Text('ຍອດລວມ: ₭${total.toStringAsFixed(0)}',
                    style: const TextStyle(
                        fontWeight: FontWeight.bold, fontSize: 16)),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('ປິດ'),
            ),
          ],
        );
      },
    );
  }

  Future<void> _clearAllOrders(BuildContext context) async {
    final bool? confirm = await showDialog<bool>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('ຢືນຢັນການລ້າງຂໍ້ມູນ'),
          content: const Text(
              'ທ່ານຕ້ອງການລ້າງຂໍ້ມູນປະຫວັດການສັ່ງຊື້ທັງໝົດຫຼືບໍ່?\n\nການດຳເນີນການນີ້ບໍ່ສາມາດຍົກເລີກໄດ້'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: const Text('ຍົກເລີກ'),
            ),
            ElevatedButton(
              onPressed: () => Navigator.of(context).pop(true),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
                foregroundColor: Colors.white,
              ),
              child: const Text('ລ້າງຂໍ້ມູນ'),
            ),
          ],
        );
      },
    );

    if (confirm == true) {
      try {
        showDialog(
          context: context,
          barrierDismissible: false,
          builder: (BuildContext context) {
            return const AlertDialog(
              content: Row(
                children: [
                  CircularProgressIndicator(),
                  SizedBox(width: 16),
                  Text('ກຳລັງລ້າງຂໍ້ມູນ...'),
                ],
              ),
            );
          },
        );

        await _repository.clearAllOrders();

        Navigator.of(context).pop();

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('ລ້າງຂໍ້ມູນປະຫວັດການສັ່ງຊື້ຮຽບຮ້ອຍແລ້ວ'),
            backgroundColor: Colors.green,
          ),
        );
      } catch (e) {
        Navigator.of(context).pop();

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('ເກີດຂໍ້ຜິດພາດ: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF06402B),
      appBar: AppBar(
        backgroundColor: const Color(0xFF06402B),
        title: const Text('ປະຫວັດການສັ່ງຊື້'),
        actions: [
          IconButton(
            onPressed: () => _clearAllOrders(context),
            icon: const Icon(Icons.delete_sweep),
            tooltip: 'ລ້າງຂໍ້ມູນທັງໝົດ',
          ),
        ],
      ),
      body: StreamBuilder<List<Map<String, dynamic>>>(
        stream: _repository.getOrdersStream(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(child: Text('ຍັງບໍ່ມີປະຫວັດການສັ່ງຊື້'));
          }
          final orders = snapshot.data!;
          return ListView.builder(
            itemCount: orders.length,
            itemBuilder: (context, index) {
              final order = orders[index];
              final orderId = order['orderId'] ?? order['id'];
              final total = order['total'] ?? 0;
              final status = order['status'] ?? 'pending';
              final items = order['items'] as List<dynamic>? ?? [];

              // Debug: แสดงข้อมูลใน console
              print('Order $orderId - Status: $status');
              print('Order data: $order');
              print('Status from order: ${order['status']}');
              print('Default status: pending');

              DateTime? createdAt;
              if (order['createdAt'] is Timestamp) {
                createdAt = (order['createdAt'] as Timestamp).toDate();
              } else if (order['createdAt'] is String) {
                createdAt = DateTime.tryParse(order['createdAt']);
              } else {
                createdAt = null;
              }

              return Card(
                margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                elevation: 2,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded(
                            child: Text(
                              '$orderId',
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                              ),
                            ),
                          ),
                          // แสดงสถานะเสมอ
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 4,
                            ),
                            decoration: BoxDecoration(
                              color: _getStatusColor(status).withOpacity(0.1),
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(
                                color: _getStatusColor(status),
                                width: 1,
                              ),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(
                                  _getStatusIcon(status),
                                  size: 16,
                                  color: _getStatusColor(status),
                                ),
                                const SizedBox(width: 4),
                                Text(
                                  _getStatusText(status),
                                  style: TextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.bold,
                                    color: _getStatusColor(status),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      if (createdAt != null)
                        Text(
                          'ວັນທີ: ${createdAt.day}/${createdAt.month}/${createdAt.year} ${createdAt.hour}:${createdAt.minute.toString().padLeft(2, '0')}',
                          style: const TextStyle(
                            fontSize: 12,
                            color: Colors.grey,
                          ),
                        ),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          Icon(Icons.shopping_bag,
                              size: 16, color: Colors.grey[600]),
                          const SizedBox(width: 4),
                          Text(
                            'ຈຳນວນສິນຄ້າ: ${items.length}',
                            style: TextStyle(
                              fontSize: 14,
                              color: Colors.grey[600],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          Icon(Icons.payments,
                              size: 16, color: Colors.grey[600]),
                          const SizedBox(width: 4),
                          Text(
                            'ຍອດລວມ: ₭${total.toStringAsFixed(0)}',
                            style: TextStyle(
                              fontSize: 14,
                              color: Colors.grey[600],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      Row(
                        children: [
                          Expanded(
                            child: ElevatedButton.icon(
                              onPressed: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => OrderTrackingScreen(
                                      orderId: orderId,
                                      total:
                                          total is num ? total.toDouble() : 0.0,
                                      deliveryAddress:
                                          order['deliveryAddress'] ?? '',
                                      deliveryMethod:
                                          order['deliveryMethod'] ?? '',
                                      showStatusTimeline: false,
                                    ),
                                  ),
                                );
                              },
                              icon: const Icon(Icons.track_changes, size: 16),
                              label: const Text('ຕິດຕາມອໍເດີ້'),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.blue,
                                foregroundColor: Colors.white,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(8),
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: ElevatedButton.icon(
                              onPressed: () {
                                _showOrderDetails(context, order);
                              },
                              icon: const Icon(Icons.info, size: 16),
                              label: const Text('ລາຍລະອຽດ'),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.grey[200],
                                foregroundColor: Colors.grey[700],
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(8),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
