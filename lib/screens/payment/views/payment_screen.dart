import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:pizza_repository/pizza_repository.dart';
import 'package:pizza_app/screens/order/blocs/order_tracking_bloc.dart';
import 'package:pizza_app/screens/order/repositories/order_tracking_repository.dart';
import 'package:pizza_app/screens/order/views/order_tracking_screen.dart';
import 'package:intl/intl.dart';

class PaymentScreen extends StatefulWidget {
  final List<Pizza> items;
  final Map<String, int> quantities;
  final double total;
  final String deliveryAddress;
  final String phoneNumber;
  final String note;
  final String deliveryMethod;
  final VoidCallback? onPaymentSuccess;

  const PaymentScreen({
    super.key,
    required this.items,
    required this.quantities,
    required this.total,
    required this.deliveryAddress,
    required this.phoneNumber,
    required this.note,
    required this.deliveryMethod,
    this.onPaymentSuccess,
  });

  @override
  State<PaymentScreen> createState() => _PaymentScreenState();
}

class _PaymentScreenState extends State<PaymentScreen> {
  String _selectedPaymentMethod = 'cash';
  final TextEditingController _cardNumberController = TextEditingController();
  final TextEditingController _cardNameController = TextEditingController();
  final TextEditingController _expiryController = TextEditingController();
  final TextEditingController _cvvController = TextEditingController();

  // Controllers สำหรับข้อมูลการจัดส่ง
  final TextEditingController _deliveryAddressController =
      TextEditingController();
  final TextEditingController _phoneNumberController = TextEditingController();
  final TextEditingController _noteController = TextEditingController();

  bool _isProcessing = false;
  bool _isEditingDelivery = false;

  @override
  void initState() {
    super.initState();
    _cardNumberController.text = '';
    _cardNameController.text = '';
    _expiryController.text = '';
    _cvvController.text = '';

    // ตั้งค่าเริ่มต้นสำหรับข้อมูลการจัดส่ง
    _deliveryAddressController.text = widget.deliveryAddress;
    _phoneNumberController.text = widget.phoneNumber;
    _noteController.text = widget.note;
  }

  @override
  void dispose() {
    _cardNumberController.dispose();
    _cardNameController.dispose();
    _expiryController.dispose();
    _cvvController.dispose();
    _deliveryAddressController.dispose();
    _phoneNumberController.dispose();
    _noteController.dispose();
    super.dispose();
  }

  void _processPayment() async {
    setState(() {
      _isProcessing = true;
    });

    try {
      // ສ້າງ Order ID
      final orderId = '#${DateTime.now().millisecondsSinceEpoch}';

      // ແປງຂໍ້ມູນສິນຄ້າເປັນ List<Map>
      final items = widget.items
          .map((pizza) => {
                'pizzaId': pizza.pizzaId,
                'name': pizza.name,
                'price': pizza.price,
                'discount': pizza.discount,
                'quantity': widget.quantities[pizza.pizzaId] ?? 0,
              })
          .toList();

      // ບັນທຶກອອເດີລົງ Firebase
      final repository = OrderTrackingRepository();
      await repository.createOrder(
        orderId: orderId,
        total: widget.total,
        deliveryAddress: _deliveryAddressController.text,
        deliveryMethod: widget.deliveryMethod,
        phoneNumber: _phoneNumberController.text,
        note: _noteController.text,
        items: items,
      );

      setState(() {
        _isProcessing = false;
      });

      // ສະແດງຜົນການຊຳລະເງິນ
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (BuildContext context) {
          return AlertDialog(
            title: const Text('ຊຳລະເງິນສຳເລັດ'),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(
                  Icons.check_circle,
                  color: Colors.green,
                  size: 50,
                ),
                const SizedBox(height: 8),
                const Text('ການຊຳລະເງິນຂອງທ່ານສຳເລັດແລ້ວ'),
                const SizedBox(height: 8),
                Text('ເລກອໍເດີ້: $orderId'),
                const SizedBox(height: 8),
                Text('ຈຳນວນເງິນ: ₭${(widget.total).toStringAsFixed(0)}'),
              ],
            ),
            actions: [
              ElevatedButton(
                onPressed: () {
                  Navigator.of(context).pop();
                  // ນຳໄປຍັງໜ້າ Order Tracking
                  Navigator.of(context).pushReplacement(
                    MaterialPageRoute(
                      builder: (context) => BlocProvider(
                        create: (context) => OrderTrackingBloc(),
                        child: OrderTrackingScreen(
                          orderId: orderId,
                          total: widget.total,
                          deliveryAddress: _deliveryAddressController.text,
                          deliveryMethod: widget.deliveryMethod,
                        ),
                      ),
                    ),
                  );
                },
                child: const Text('ຕິດຕາມອໍເດີ້'),
              ),
            ],
          );
        },
      );

      widget.onPaymentSuccess?.call();
    } catch (e) {
      setState(() {
        _isProcessing = false;
      });

      // ສະແດງ error dialog
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('ເກີດຂໍ້ຜິດພາດ'),
          content: Text('ບໍ່ສາມາດບັນທຶກອອເດີໄດ້: $e'),
          actions: [
            ElevatedButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('ຕົກລົງ'),
            ),
          ],
        ),
      );
    }
  }

  Widget _buildPaymentMethodCard(
      String method, String title, String subtitle, IconData icon) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: _selectedPaymentMethod == method
            ? Colors.blue.shade50
            : Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: _selectedPaymentMethod == method
              ? Colors.blue
              : Colors.grey.shade300,
          width: 2,
        ),
      ),
      child: RadioListTile<String>(
        title: Row(
          children: [
            Icon(icon,
                color: _selectedPaymentMethod == method
                    ? Colors.blue
                    : Colors.grey),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: _selectedPaymentMethod == method
                          ? Colors.blue
                          : Colors.black,
                    ),
                  ),
                  Text(
                    subtitle,
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey[600],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        value: method,
        groupValue: _selectedPaymentMethod,
        onChanged: (value) {
          setState(() {
            _selectedPaymentMethod = value!;
          });
        },
      ),
    );
  }

  Widget _buildCardDetailsForm() {
    if (_selectedPaymentMethod != 'card') return const SizedBox.shrink();

    return Container(
      margin: const EdgeInsets.only(top: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey.shade50,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'ຂໍ້ມູນບັດເຄຣດິດ',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          TextField(
            controller: _cardNumberController,
            decoration: const InputDecoration(
              labelText: 'ເລກບັດ',
              border: OutlineInputBorder(),
              prefixIcon: Icon(Icons.credit_card),
            ),
            keyboardType: TextInputType.number,
          ),
          const SizedBox(height: 12),
          TextField(
            controller: _cardNameController,
            decoration: const InputDecoration(
              labelText: 'ຊື່ບົນບັດ',
              border: OutlineInputBorder(),
              prefixIcon: Icon(Icons.person),
            ),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _expiryController,
                  decoration: const InputDecoration(
                    labelText: 'ວັນໝົດອາຍຸ (MM/YY)',
                    border: OutlineInputBorder(),
                    prefixIcon: Icon(Icons.calendar_today),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: TextField(
                  controller: _cvvController,
                  decoration: const InputDecoration(
                    labelText: 'CVV',
                    border: OutlineInputBorder(),
                    prefixIcon: Icon(Icons.security),
                  ),
                  keyboardType: TextInputType.number,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildOrderSummary() {
    final NumberFormat kipFormat = NumberFormat('#,##0', 'en_US');
    int totalItemsPrice = 0;
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
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
            'ສະຫຼຸບການສັ່ງຊື້',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          const Row(
            children: [
              Expanded(
                  flex: 2,
                  child: Text('ຊື່ສິນຄ້າ',
                      style: TextStyle(fontWeight: FontWeight.bold))),
              Expanded(
                  child: Text('ຈຳນວນ',
                      style: TextStyle(fontWeight: FontWeight.bold))),
              Expanded(
                  child: Text('ລາຄາ',
                      style: TextStyle(fontWeight: FontWeight.bold))),
            ],
          ),
          const Divider(),
          ...widget.items.map((pizza) {
            final quantity = widget.quantities[pizza.pizzaId] ?? 0;
            final price = pizza.price;
            final subtotal = price * quantity;
            totalItemsPrice += subtotal;
            return Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: Row(
                children: [
                  Expanded(flex: 2, child: Text(pizza.name)),
                  Expanded(child: Center(child: Text('$quantity'))),
                  Expanded(child: Text('₭${kipFormat.format(price)}')),
                ],
              ),
            );
          }).toList(),
          const Divider(),
          // Row(
          //   mainAxisAlignment: MainAxisAlignment.spaceBetween,
          //   children: [
          //     const Text('ລາຄາລວມສິນຄ້າ:'),
          //     Text('₭${kipFormat.format(totalItemsPrice)}'),
          //   ],
          // ),
          if (widget.deliveryMethod == 'delivery') ...[
            const SizedBox(height: 4),
            const Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('ຄ່າຈັດສົ່ງ:'),
                Text('₭20,190'),
              ],
            ),
          ],
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'ລວມທັງໝົດ:',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
              Text(
                '₭${kipFormat.format(widget.total)}',
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildDeliveryInfo() {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
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
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'ຂໍ້ມູນການຈັດສົ່ງ',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              IconButton(
                onPressed: () {
                  setState(() {
                    _isEditingDelivery = !_isEditingDelivery;
                  });
                },
                icon: Icon(
                  _isEditingDelivery ? Icons.save : Icons.edit,
                  color: Colors.blue,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          if (_isEditingDelivery) ...[
            // แบบฟอร์มแก้ไข
            TextFormField(
              controller: _deliveryAddressController,
              decoration: const InputDecoration(
                labelText: 'ທີ່ຢູ່ຈັດສົ່ງ',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.location_on),
              ),
              maxLines: 2,
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: _phoneNumberController,
              decoration: const InputDecoration(
                labelText: 'ເບີໂທລະສັບ',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.phone),
              ),
              keyboardType: TextInputType.phone,
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: _noteController,
              decoration: const InputDecoration(
                labelText: 'ໝາຍເຫດ (ທົດແທນ)',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.note),
              ),
              maxLines: 2,
            ),
          ] else ...[
            // แสดงข้อมูลแบบ read-only
            Row(
              children: [
                Icon(Icons.location_on, color: Colors.grey[600]),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    widget.deliveryMethod == 'delivery'
                        ? _deliveryAddressController.text
                        : 'ຮັບທີ່ຮ້ານ',
                    style: const TextStyle(fontSize: 16),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Icon(Icons.phone, color: Colors.grey[600]),
                const SizedBox(width: 8),
                Text(
                  _phoneNumberController.text,
                  style: const TextStyle(fontSize: 16),
                ),
              ],
            ),
            if (_noteController.text.isNotEmpty) ...[
              const SizedBox(height: 8),
              Row(
                children: [
                  Icon(Icons.note, color: Colors.grey[600]),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      _noteController.text,
                      style: const TextStyle(fontSize: 16),
                    ),
                  ),
                ],
              ),
            ],
          ],
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final NumberFormat kipFormat = NumberFormat('#,##0', 'en_US');
    return Scaffold(
      backgroundColor: const Color(0xFF06402B),
      appBar: AppBar(
        backgroundColor: const Color(0xFF06402B),
        title: const Text(
          'ຊຳລະເງິນ',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 24,
          ),
        ),
        leading: IconButton(
          onPressed: () => Navigator.of(context).pop(),
          icon: const Icon(CupertinoIcons.back),
        ),
      ),
      body: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildOrderSummary(),
                  _buildDeliveryInfo(),
                  const Text(
                    'ເລືອກວິທີຊຳລະເງິນ',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 16),
                  _buildPaymentMethodCard(
                    'cash',
                    'ເງິນສົດ',
                    'ຊຳລະເງິນສົດເມື່ອໄດ້ຮັບສິນຄ້າ',
                    Icons.money,
                  ),
                  _buildPaymentMethodCard(
                    'card',
                    'ບັດເຄຣດິດ/ເດບິດ',
                    'ຊຳລະເງິນດ້ວຍບັດ',
                    Icons.credit_card,
                  ),
                  _buildPaymentMethodCard(
                    'transfer',
                    'ໂອນເງິນ',
                    'ໂອນເງິນຜ່ານທະນາຄານ',
                    Icons.account_balance,
                  ),
                  _buildCardDetailsForm(),
                ],
              ),
            ),
          ),
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: const BorderRadius.vertical(
                top: Radius.circular(20),
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.grey.withOpacity(0.1),
                  spreadRadius: 1,
                  blurRadius: 5,
                  offset: const Offset(0, -2),
                ),
              ],
            ),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'ຈຳນວນເງິນທີ່ຕ້ອງຊຳລະ:',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    Text(
                      '₭${kipFormat.format(widget.total)}',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Theme.of(context).colorScheme.primary,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                SizedBox(
                  width: double.infinity,
                  height: 50,
                  child: ElevatedButton(
                    onPressed: _isProcessing ? null : _processPayment,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Theme.of(context).colorScheme.primary,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: _isProcessing
                        ? const Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              SizedBox(
                                width: 20,
                                height: 20,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  valueColor: AlwaysStoppedAnimation<Color>(
                                      Colors.white),
                                ),
                              ),
                              SizedBox(width: 12),
                              Text('ກຳລັງປະມວນຜົນ...'),
                            ],
                          )
                        : const Text(
                            'ຢືນຢັນການຊຳລະເງິນ',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
