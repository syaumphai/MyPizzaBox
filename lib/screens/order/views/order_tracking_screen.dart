import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:pizza_app/screens/order/blocs/order_tracking_bloc.dart';
import 'package:pizza_app/screens/order/repositories/order_tracking_repository.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class OrderTrackingScreen extends StatefulWidget {
  final String orderId;
  final double total;
  final String deliveryAddress;
  final String deliveryMethod;
  final bool showStatusTimeline;
  const OrderTrackingScreen({
    super.key,
    required this.orderId,
    required this.total,
    required this.deliveryAddress,
    required this.deliveryMethod,
    this.showStatusTimeline = true,
  });

  @override
  State<OrderTrackingScreen> createState() => _OrderTrackingScreenState();
}

class _OrderTrackingScreenState extends State<OrderTrackingScreen> {
  @override
  void initState() {
    super.initState();
    // ใช้ real-time listener แทนการ load ครั้งเดียว
    _setupRealTimeListener();
  }

  void _setupRealTimeListener() {
    final repository = OrderTrackingRepository();
    repository.getOrderTrackingStream(widget.orderId).listen((orderData) {
      print('Received real-time update: $orderData');
      if (orderData != null) {
        final status = _stringToOrderStatus(orderData['status'] ?? 'pending');
        final statusHistory = (orderData['statusHistory'] as List<dynamic>?)
                ?.map((s) => _stringToOrderStatus(s.toString()))
                .toList() ??
            [OrderStatus.pending];

        final estimatedDeliveryTime = orderData['estimatedDeliveryTime'] != null
            ? (orderData['estimatedDeliveryTime'] as Timestamp).toDate()
            : DateTime.now().add(const Duration(minutes: 45));

        print('Current status: $status');
        print('Status history: $statusHistory');

        setState(() {
          // อัพเดท state โดยตรง
          _currentOrderData = {
            'orderId': orderData['orderId'],
            'currentStatus': status,
            'statusHistory': statusHistory,
            'estimatedDeliveryTime': estimatedDeliveryTime,
            'driverName': orderData['driverName'],
            'driverPhone': orderData['driverPhone'],
            'driverLatitude': orderData['driverLatitude']?.toDouble(),
            'driverLongitude': orderData['driverLongitude']?.toDouble(),
            'items': orderData['items'] as List<dynamic>?,
          };
        });
      }
    });
  }

  OrderStatus _stringToOrderStatus(String status) {
    switch (status.toLowerCase()) {
      case 'pending':
        return OrderStatus.pending;
      case 'confirmed':
        return OrderStatus.confirmed;
      case 'preparing':
        return OrderStatus.preparing;
      case 'ready':
        return OrderStatus.ready;
      case 'delivering':
        return OrderStatus.delivering;
      case 'delivered':
        return OrderStatus.delivered;
      case 'cancelled':
        return OrderStatus.cancelled;
      default:
        return OrderStatus.pending;
    }
  }

  // เพิ่มตัวแปรสำหรับเก็บข้อมูล real-time
  Map<String, dynamic>? _currentOrderData;

  String _getStatusText(OrderStatus status) {
    switch (status) {
      case OrderStatus.pending:
        return 'ລໍການຢືນຢັນ';
      case OrderStatus.confirmed:
        return 'ຢືນຢັນແລ້ວ';
      case OrderStatus.preparing:
        return 'ກຳລັງກຽມອາຫານ';
      case OrderStatus.ready:
        return 'ພ້ອມສົ່ງ';
      case OrderStatus.delivering:
        return 'ກຳລັງຈັດສົ່ງ';
      case OrderStatus.delivered:
        return 'ຈັດສົ່ງແລ້ວ';
      case OrderStatus.cancelled:
        return 'ຍົກເລີກ';
    }
  }

  IconData _getStatusIcon(OrderStatus status) {
    switch (status) {
      case OrderStatus.pending:
        return Icons.schedule;
      case OrderStatus.confirmed:
        return Icons.check_circle;
      case OrderStatus.preparing:
        return Icons.restaurant;
      case OrderStatus.ready:
        return Icons.local_shipping;
      case OrderStatus.delivering:
        return Icons.delivery_dining;
      case OrderStatus.delivered:
        return Icons.done_all;
      case OrderStatus.cancelled:
        return Icons.cancel;
    }
  }

  Color _getStatusColor(OrderStatus status) {
    switch (status) {
      case OrderStatus.pending:
        return Colors.orange;
      case OrderStatus.confirmed:
        return Colors.blue;
      case OrderStatus.preparing:
        return Colors.purple;
      case OrderStatus.ready:
        return Colors.indigo;
      case OrderStatus.delivering:
        return Colors.green;
      case OrderStatus.delivered:
        return Colors.green;
      case OrderStatus.cancelled:
        return Colors.red;
    }
  }

  Widget _buildStatusTimeline() {
    final currentStatus = _currentOrderData!['currentStatus'] as OrderStatus;
    final statusHistory =
        _currentOrderData!['statusHistory'] as List<OrderStatus>;

    print('Current status: $currentStatus');
    print('Status history: $statusHistory');

    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            spreadRadius: 1,
            blurRadius: 5,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'ສະຖານະການສັ່ງຊື້',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          ...OrderStatus.values.map((status) {
            final isCompleted = statusHistory.contains(status);
            final isCurrent = currentStatus == status;
            final isConfirmedCurrent =
                status == OrderStatus.confirmed && isCurrent;
            final isConfirmedInHistory = status == OrderStatus.confirmed &&
                statusHistory.contains(status);
            final isCancelled = status == OrderStatus.cancelled;

            print(
                'Status: $status, isCompleted: $isCompleted, isCurrent: $isCurrent, isConfirmedCurrent: $isConfirmedCurrent, isConfirmedInHistory: $isConfirmedInHistory, isCancelled: $isCancelled');

            return Padding(
              padding: const EdgeInsets.only(bottom: 16),
              child: Row(
                children: [
                  Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: (isCompleted ||
                              isCurrent ||
                              isConfirmedCurrent ||
                              isConfirmedInHistory ||
                              isCancelled)
                          ? _getStatusColor(status)
                          : Colors.grey.shade300,
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      _getStatusIcon(status),
                      color: (isCompleted ||
                              isCurrent ||
                              isConfirmedCurrent ||
                              isConfirmedInHistory ||
                              isCancelled)
                          ? Colors.white
                          : Colors.grey,
                      size: 20,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          _getStatusText(status),
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: (isCurrent ||
                                    isConfirmedCurrent ||
                                    isConfirmedInHistory ||
                                    isCancelled)
                                ? _getStatusColor(status)
                                : Colors.black,
                            fontSize: (isCurrent ||
                                    isConfirmedCurrent ||
                                    isConfirmedInHistory ||
                                    isCancelled)
                                ? 16
                                : 14,
                          ),
                        ),
                        if (isCurrent) ...[
                          const SizedBox(height: 4),
                          Text(
                            'ກຳລັງດຳເນີນການ...',
                            style: TextStyle(
                              color: Colors.grey[600],
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                  if (isCompleted)
                    const Icon(
                      Icons.check_circle,
                      color: Colors.green,
                      size: 20,
                    ),
                  if (isCurrent && status == OrderStatus.pending)
                    ElevatedButton(
                      onPressed: () => _updateStatus(status),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: _getStatusColor(status),
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(
                            horizontal: 12, vertical: 6),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      child: const Text(
                        'ຍືນຢັນ',
                        style: TextStyle(fontSize: 12),
                      ),
                    ),
                  if (isCurrent && status == OrderStatus.confirmed)
                    ElevatedButton(
                      onPressed: () => _updateStatus(status),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: _getStatusColor(status),
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(
                            horizontal: 12, vertical: 6),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      child: const Text(
                        'ຍືນຢັນ',
                        style: TextStyle(fontSize: 12),
                      ),
                    ),
                  if (isCurrent && status == OrderStatus.preparing)
                    ElevatedButton(
                      onPressed: () => _updateStatus(status),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: _getStatusColor(status),
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(
                            horizontal: 12, vertical: 6),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      child: const Text(
                        'ຍືນຢັນ',
                        style: TextStyle(fontSize: 12),
                      ),
                    ),
                  if (isCurrent && status == OrderStatus.ready)
                    ElevatedButton(
                      onPressed: () => _updateStatus(status),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: _getStatusColor(status),
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(
                            horizontal: 12, vertical: 6),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      child: const Text(
                        'ຍືນຢັນ',
                        style: TextStyle(fontSize: 12),
                      ),
                    ),
                  if (isCurrent && status == OrderStatus.delivering)
                    ElevatedButton(
                      onPressed: () => _updateStatus(status),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: _getStatusColor(status),
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(
                            horizontal: 12, vertical: 6),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      child: const Text(
                        'ຍືນຢັນ',
                        style: TextStyle(fontSize: 12),
                      ),
                    ),
                  if (isCurrent && status == OrderStatus.delivered)
                    ElevatedButton(
                      onPressed: () => _updateStatus(status),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: _getStatusColor(status),
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(
                            horizontal: 12, vertical: 6),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      child: const Text(
                        'ຍືນຢັນ',
                        style: TextStyle(fontSize: 12),
                      ),
                    ),
                ],
              ),
            );
          }).toList(),
        ],
      ),
    );
  }

  void _updateStatus(OrderStatus currentStatus) async {
    try {
      final repository = OrderTrackingRepository();
      String nextStatusString;

      // กำหนดสถานะถัดไปตามลำดับ
      switch (currentStatus) {
        case OrderStatus.pending:
          // หลังจาก pending แล้วไป confirmed
          nextStatusString = 'confirmed';
          break;
        case OrderStatus.confirmed:
          // หลังจาก confirmed แล้วไป preparing เลย
          nextStatusString = 'preparing';
          break;
        case OrderStatus.preparing:
          nextStatusString = 'ready';
          break;
        case OrderStatus.ready:
          nextStatusString = 'delivering';
          break;
        case OrderStatus.delivering:
          nextStatusString = 'delivered';
          break;
        case OrderStatus.delivered:
          // ถ้าสถานะสุดท้ายแล้ว ไม่ต้องอัพเดท
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('ອໍເດີ້ສຳເລັດແລ້ວ'),
              backgroundColor: Colors.green,
            ),
          );
          return;
        case OrderStatus.cancelled:
          // ถ้าญกเลิกแล้ว ไม่ต้องอัพเดท
          return;
      }

      print(
          'Updating status from ${currentStatus.toString()} to $nextStatusString');
      await repository.updateOrderStatus(widget.orderId, nextStatusString);
      print('Status updated successfully');

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('ອັບເດດສະຖານະສຳເລັດ'),
          backgroundColor: Colors.green,
        ),
      );

      // ไม่ต้อง refresh เพราะใช้ real-time listener แล้ว
    } catch (e) {
      print('Error updating status: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('ບໍ່ສາມາດອັບເດດສະຖານະໄດ້: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Widget _buildOrderInfo() {
    final items = _currentOrderData?['items'] as List<dynamic>? ?? [];
    // คำนวณราคารวม
    num total = 0;
    for (final item in items) {
      final price = item['price'] is num
          ? item['price']
          : int.tryParse(item['price'].toString()) ?? 0;
      final quantity = item['quantity'] is num
          ? item['quantity']
          : int.tryParse(item['quantity'].toString()) ?? 1;
      total += price * quantity;
    }
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            spreadRadius: 1,
            blurRadius: 5,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'ໃບບິນລາຍການສິນຄ້າ',
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Icon(Icons.receipt, color: Colors.grey[600]),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  'ເລກອໍເດີ້:  ${_currentOrderData!['orderId']}',
                  style: const TextStyle(fontSize: 16),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Icon(Icons.location_on, color: Colors.grey[600]),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  widget.deliveryMethod == 'delivery'
                      ? widget.deliveryAddress
                      : 'ຮັບທີ່ຮ້ານ',
                  style: const TextStyle(fontSize: 16),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Icon(Icons.access_time, color: Colors.grey[600]),
              const SizedBox(width: 8),
              Text(
                'ເວລາທີ່ຄາດວ່າຈະໄດ້ຮັບ: ${_formatTime(_currentOrderData!['estimatedDeliveryTime'])}',
                style: const TextStyle(fontSize: 16),
              ),
            ],
          ),
          const SizedBox(height: 16),
          if (items.isNotEmpty) ...[
            Container(
              margin: const EdgeInsets.symmetric(vertical: 8),
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.grey[50],
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.grey.shade300),
              ),
              child: Column(
                children: [
                  Row(
                    children: const [
                      Expanded(
                          child: Text('ຊື່ສິນຄ້າ',
                              style: TextStyle(fontWeight: FontWeight.bold))),
                      SizedBox(width: 8),
                      Text('จำนวน',
                          style: TextStyle(fontWeight: FontWeight.bold)),
                      SizedBox(width: 8),
                      Text('ລາຄາ',
                          style: TextStyle(fontWeight: FontWeight.bold)),
                    ],
                  ),
                  const Divider(),
                  ...items.map((item) {
                    final name = item['name'] ?? '';
                    final quantity = item['quantity'] is num
                        ? item['quantity']
                        : int.tryParse(item['quantity'].toString()) ?? 1;
                    final price = item['price'] is num
                        ? item['price']
                        : int.tryParse(item['price'].toString()) ?? 0;
                    final discount = item['discount'] is num
                        ? item['discount']
                        : int.tryParse(item['discount'].toString()) ?? 0;
                    double? discountedPrice;
                    if (discount > 0) {
                      discountedPrice = price - (price * (discount / 100));
                    }
                    final subtotal = (discountedPrice ?? price) * quantity;
                    return Padding(
                      padding: const EdgeInsets.symmetric(vertical: 2),
                      child: Row(
                        children: [
                          Expanded(child: Text(name)),
                          SizedBox(width: 8),
                          if (discountedPrice != null) ...[
                            Text(
                              '₭${price}',
                              style: const TextStyle(
                                color: Colors.grey,
                                decoration: TextDecoration.lineThrough,
                              ),
                            ),
                            const SizedBox(width: 4),
                            Text(
                              '₭${discountedPrice.toStringAsFixed(0)}',
                              style: const TextStyle(
                                color: Colors.green,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(width: 4),
                            Text(
                              '-${discount.toString()}%',
                              style: const TextStyle(
                                color: Colors.red,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ] else
                            Text('₭${price}'),
                          SizedBox(width: 8),
                          Text('x$quantity'),
                          SizedBox(width: 8),
                          Text('₭${subtotal.toStringAsFixed(0)}'),
                        ],
                      ),
                    );
                  }).toList(),
                  const Divider(),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      const Text('ລວມທັງໝົດ: ',
                          style: TextStyle(fontWeight: FontWeight.bold)),
                      Text('₭${total.toStringAsFixed(0)}',
                          style: const TextStyle(fontWeight: FontWeight.bold)),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildDriverInfo() {
    if (_currentOrderData == null ||
        _currentOrderData!['currentStatus'] != OrderStatus.delivering ||
        _currentOrderData!['driverName'] == null) {
      return const SizedBox.shrink();
    }

    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            spreadRadius: 1,
            blurRadius: 5,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'ຂໍ້ມູນຄົນຂັບ',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              CircleAvatar(
                radius: 25,
                backgroundColor: Colors.blue.shade100,
                child: const Icon(
                  Icons.person,
                  color: Colors.blue,
                  size: 30,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      _currentOrderData!['driverName']?.toString() ??
                          'ບໍ່ມີຂໍ້ມູນ',
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      'ຄົນຂັບລົດ',
                      style: TextStyle(
                        color: Colors.grey[600],
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
              ),
              IconButton(
                onPressed: () {
                  // ຈຳລອງການໂທຫາ
                  showDialog(
                    context: context,
                    builder: (context) => AlertDialog(
                      title: const Text('ໂທຫາ'),
                      content: Text(
                          'ໂທຫາ ${_currentOrderData!['driverName']?.toString() ?? 'ບໍ່ມີຂໍ້ມູນ'} ທີ່ ${_currentOrderData!['driverPhone']?.toString() ?? 'ບໍ່ມີຂໍ້ມູນ'}?'),
                      actions: [
                        TextButton(
                          onPressed: () => Navigator.pop(context),
                          child: const Text('ຍົກເລີກ'),
                        ),
                        ElevatedButton(
                          onPressed: () {
                            Navigator.pop(context);
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(content: Text('ກຳລັງໂທຫາ...')),
                            );
                          },
                          child: const Text('ໂທ'),
                        ),
                      ],
                    ),
                  );
                },
                icon: const Icon(Icons.phone, color: Colors.green),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildMap() {
    if (_currentOrderData == null ||
        _currentOrderData!['currentStatus'] != OrderStatus.delivering) {
      return const SizedBox.shrink();
    }

    return Container(
      margin: const EdgeInsets.all(16),
      height: 200,
      decoration: BoxDecoration(
        color: Colors.grey.shade200,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Stack(
        children: [
          Container(
            width: double.infinity,
            height: double.infinity,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12),
              color: Colors.blue.shade50,
            ),
            child: const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.map,
                    size: 50,
                    color: Colors.blue,
                  ),
                  SizedBox(height: 8),
                  Text(
                    'ແຜນທີ່ການຈັດສົ່ງ',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    'ຕຳແໜ່ງຄົນຂັບຈະສະແດງທີ່ນີ້',
                    style: TextStyle(
                      color: Colors.grey,
                    ),
                  ),
                ],
              ),
            ),
          ),
          Positioned(
            top: 16,
            right: 16,
            child: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(8),
                boxShadow: [
                  BoxShadow(
                    color: Colors.grey.withOpacity(0.3),
                    spreadRadius: 1,
                    blurRadius: 3,
                    offset: const Offset(0, 1),
                  ),
                ],
              ),
              child: const Icon(Icons.my_location, color: Colors.blue),
            ),
          ),
        ],
      ),
    );
  }

  String _formatTime(DateTime time) {
    return '${time.hour.toString().padLeft(2, '0')}:${time.minute.toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.surface,
        title: const Text(
          'ຕິດຕາມອໍເດີ້',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 24,
          ),
        ),
        leading: IconButton(
          onPressed: () => Navigator.of(context).pop(),
          icon: const Icon(CupertinoIcons.back),
        ),
        actions: [
          IconButton(
            onPressed: () {
              _setupRealTimeListener(); // refresh data
            },
            icon: const Icon(Icons.refresh),
          ),
        ],
      ),
      body: _currentOrderData == null
          ? const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CircularProgressIndicator(),
                  SizedBox(height: 16),
                  Text('ກຳລັງໂຫຼດຂໍ້ມູນການຕິດຕາມ...'),
                ],
              ),
            )
          : SingleChildScrollView(
              child: Column(
                children: [
                  _buildOrderInfo(),
                  if (widget.showStatusTimeline) _buildStatusTimeline(),
                  _buildDriverInfo(),
                  _buildMap(),
                  const SizedBox(height: 20),
                ],
              ),
            ),
    );
  }
}
