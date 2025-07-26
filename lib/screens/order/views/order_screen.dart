import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:pizza_repository/pizza_repository.dart';
import 'package:pizza_app/screens/payment/views/payment_screen.dart';
import 'package:intl/intl.dart';

class OrderScreen extends StatefulWidget {
  final List<Pizza> cartItems;
  final Map<String, int> cartQuantities;

  const OrderScreen({
    super.key,
    required this.cartItems,
    required this.cartQuantities,
  });

  @override
  State<OrderScreen> createState() => _OrderScreenState();
}

class _OrderScreenState extends State<OrderScreen> {
  late Map<String, int> quantities;
  late List<Pizza> items;

  // ຂໍ້ມູນທີ່ຢູ່ຈັດສົ່ງ
  final TextEditingController _addressController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _noteController = TextEditingController();

  // ສະຖານະການເລືອກທີ່ຢູ່
  bool _isDeliveryAddressExpanded = false;
  String _selectedDeliveryMethod = 'delivery'; // delivery หรือ pickup

  @override
  void initState() {
    super.initState();
    quantities = Map.from(widget.cartQuantities);
    items = List.from(widget.cartItems);
    _addressController.text = '';
    _phoneController.text = '';
    _noteController.text = '';
  }

  @override
  void dispose() {
    _addressController.dispose();
    _phoneController.dispose();
    _noteController.dispose();
    super.dispose();
  }

  void updateQuantity(String pizzaId, int newQuantity) {
    setState(() {
      if (newQuantity <= 0) {
        quantities.remove(pizzaId);
        items.removeWhere((pizza) => pizza.pizzaId == pizzaId);
      } else {
        quantities[pizzaId] = newQuantity;
      }
    });
  }

  double calculateTotal() {
    double total = 0;
    for (final pizza in items) {
      final quantity = quantities[pizza.pizzaId] ?? 0;
      final price = pizza.price * 673; // ราคาเป็นกีบโดยตรง
      total += price * quantity;
    }
    // ເພີ່ມຄ່າຈັດສົ່ງຖ້າເລືອກ delivery
    if (_selectedDeliveryMethod == 'delivery') {
      total += 20190; // ຄ່າຈັດສົ່ງ 20,190 ກີບ
    }
    return total;
  }

  void navigateToPayment() {
    // ກວດສອບຂໍ້ມູນທີ່ຈຳເປັນ
    if (_selectedDeliveryMethod == 'delivery' &&
        (_addressController.text.isEmpty)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('ກະລຸນາໃສ່ທີ່ຢູ່ຈັດສົ່ງ'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }
    if (_phoneController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('ກະລຸນາໃສ່ເບີໂທລະສັບ'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    // Debug print
    print('DEBUG: items = ' + items.toString());
    print('DEBUG: quantities = ' + quantities.toString());
    print('DEBUG: total = ' + calculateTotal().toString());
    print('DEBUG: deliveryAddress = ' + _addressController.text);
    print('DEBUG: phoneNumber = ' + _phoneController.text);
    print('DEBUG: note = ' + _noteController.text);
    print('DEBUG: deliveryMethod = ' + _selectedDeliveryMethod);

    // ນຳທາງໄປຍັງໜ້າຊຳລະເງິນ
    Navigator.push(
      context,
      MaterialPageRoute<void>(
        builder: (BuildContext context) => PaymentScreen(
          items: items,
          quantities: quantities,
          total: calculateTotal(),
          deliveryAddress: _addressController.text,
          phoneNumber: _phoneController.text,
          note: _noteController.text,
          deliveryMethod: _selectedDeliveryMethod,
        ),
      ),
    );
  }

  Widget _buildDeliverySection() {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
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
        children: [
          ListTile(
            title: const Text(
              'ຂໍ້ມູນການຈັດສົ່ງ',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            trailing: IconButton(
              onPressed: () {
                setState(() {
                  _isDeliveryAddressExpanded = !_isDeliveryAddressExpanded;
                });
              },
              icon: Icon(
                _isDeliveryAddressExpanded
                    ? Icons.keyboard_arrow_up
                    : Icons.keyboard_arrow_down,
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              children: [
                Expanded(
                  child: RadioListTile<String>(
                    title: const Text('ຈັດສົ່ງ'),
                    value: 'delivery',
                    groupValue: _selectedDeliveryMethod,
                    onChanged: (value) {
                      setState(() {
                        _selectedDeliveryMethod = value!;
                      });
                    },
                  ),
                ),
                Expanded(
                  child: RadioListTile<String>(
                    title: const Text('ຮັບທີ່ຮ້ານ'),
                    value: 'pickup',
                    groupValue: _selectedDeliveryMethod,
                    onChanged: (value) {
                      setState(() {
                        _selectedDeliveryMethod = value!;
                      });
                    },
                  ),
                ),
              ],
            ),
          ),
          if (_isDeliveryAddressExpanded)
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  TextField(
                    controller: _addressController,
                    decoration: const InputDecoration(
                      labelText: 'ທີ່ຢູ່ຈັດສົ່ງ',
                      border: OutlineInputBorder(),
                      prefixIcon: Icon(Icons.location_on),
                    ),
                    maxLines: 3,
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    controller: _phoneController,
                    decoration: const InputDecoration(
                      labelText: 'ເບີໂທລະສັບ',
                      border: OutlineInputBorder(),
                      prefixIcon: Icon(Icons.phone),
                    ),
                    keyboardType: TextInputType.phone,
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    controller: _noteController,
                    decoration: const InputDecoration(
                      labelText: 'ບັນທຶກເພີ່ມເຕີມ (ບໍ່ບັງຄັບ)',
                      border: OutlineInputBorder(),
                      prefixIcon: Icon(Icons.note),
                    ),
                    maxLines: 2,
                  ),
                  const SizedBox(height: 16),
                  Container(
                    height: 200,
                    decoration: BoxDecoration(
                      color: Colors.grey[200],
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.map,
                            size: 50,
                            color: Colors.grey,
                          ),
                          SizedBox(height: 8),
                          Text(
                            'ແຜນທີ່ການຈັດສົ່ງ',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: Colors.grey,
                            ),
                          ),
                          SizedBox(height: 4),
                          Text(
                            'ກົດເພື່ອເບິ່ງແຜນທີ່',
                            style: TextStyle(
                              color: Colors.grey,
                            ),
                          ),
                        ],
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

  @override
  Widget build(BuildContext context) {
    final NumberFormat kipFormat = NumberFormat('#,##0', 'en_US');
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.surface,
        title: const Text(
          'ກະຕ່າສິນຄ້າ',
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
      body: items.isEmpty
          ? const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    CupertinoIcons.cart,
                    size: 80,
                    color: Colors.grey,
                  ),
                  SizedBox(height: 16),
                  Text(
                    'ກະຕ່າສິນຄ້າວ່າງ',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Colors.grey,
                    ),
                  ),
                  SizedBox(height: 8),
                  Text(
                    'ເພີ່ມພິດຊ່າລົງໃນກະຕ່າເພື່ອເລີ່ມສັ່ງຊື້',
                    style: TextStyle(
                      color: Colors.grey,
                    ),
                  ),
                ],
              ),
            )
          : Column(
              children: [
                Expanded(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      children: [
                        _buildDeliverySection(),
                        ...items.map((pizza) {
                          final quantity = quantities[pizza.pizzaId] ?? 0;
                          final price = pizza.price * 673;
                          return Container(
                            margin: const EdgeInsets.only(bottom: 16),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(16),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.grey.withOpacity(0.1),
                                  spreadRadius: 1,
                                  blurRadius: 5,
                                  offset: const Offset(0, 2),
                                ),
                              ],
                            ),
                            child: Padding(
                              padding: const EdgeInsets.all(16),
                              child: Row(
                                children: [
                                  Container(
                                    width: 80,
                                    height: 80,
                                    decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(12),
                                      image: DecorationImage(
                                        image: pizza.picture
                                                .toLowerCase()
                                                .startsWith('assets/')
                                            ? AssetImage(pizza.picture)
                                            : NetworkImage(pizza.picture)
                                                as ImageProvider,
                                        fit: BoxFit.cover,
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: 16),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          pizza.name,
                                          style: const TextStyle(
                                            fontSize: 18,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                        const SizedBox(height: 4),
                                        Text(
                                          pizza.description,
                                          style: TextStyle(
                                            fontSize: 14,
                                            color: Colors.grey[600],
                                          ),
                                          maxLines: 2,
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                        const SizedBox(height: 8),
                                        Row(
                                          children: [
                                            Flexible(
                                              child: Text(
                                                '₭${kipFormat.format(price)}',
                                                style: TextStyle(
                                                  fontSize: 16,
                                                  fontWeight: FontWeight.bold,
                                                  color: Theme.of(context)
                                                      .colorScheme
                                                      .primary,
                                                ),
                                                maxLines: 1,
                                                overflow: TextOverflow.ellipsis,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ],
                                    ),
                                  ),
                                  Column(
                                    children: [
                                      Row(
                                        children: [
                                          IconButton(
                                            onPressed: () => updateQuantity(
                                              pizza.pizzaId,
                                              quantity - 1,
                                            ),
                                            icon: const Icon(
                                              CupertinoIcons.minus_circle,
                                              size: 24,
                                            ),
                                          ),
                                          Container(
                                            padding: const EdgeInsets.symmetric(
                                              horizontal: 12,
                                              vertical: 4,
                                            ),
                                            decoration: BoxDecoration(
                                              color: Colors.grey[100],
                                              borderRadius:
                                                  BorderRadius.circular(8),
                                            ),
                                            child: Text(
                                              '$quantity',
                                              style: const TextStyle(
                                                fontSize: 16,
                                                fontWeight: FontWeight.bold,
                                              ),
                                            ),
                                          ),
                                          IconButton(
                                            onPressed: () => updateQuantity(
                                              pizza.pizzaId,
                                              quantity + 1,
                                            ),
                                            icon: const Icon(
                                              CupertinoIcons.plus_circle,
                                              size: 24,
                                            ),
                                          ),
                                        ],
                                      ),
                                      Text(
                                        '₭${kipFormat.format(price * quantity)}',
                                        style: const TextStyle(
                                          fontSize: 14,
                                          fontWeight: FontWeight.bold,
                                        ),
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          );
                        }).toList(),
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
                            'ຈຳນວນລາຍການ:',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          Text(
                            '${items.length} ລາຍການ',
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      if (_selectedDeliveryMethod == 'delivery')
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text(
                              'ຄ່າຈັດສົ່ງ:',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            Text(
                              '₭${kipFormat.format(20190)}',
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      const SizedBox(height: 8),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text(
                            'ລາຄາລວມ:',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Flexible(
                            child: Text(
                              '₭${kipFormat.format(calculateTotal())}',
                              style: TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                                color: Theme.of(context).colorScheme.primary,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 20),
                      SizedBox(
                        width: double.infinity,
                        height: 50,
                        child: ElevatedButton(
                          onPressed: items.isEmpty ? null : navigateToPayment,
                          style: ElevatedButton.styleFrom(
                            backgroundColor:
                                Theme.of(context).colorScheme.primary,
                            foregroundColor: Colors.white,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          child: const Text(
                            'ດຳເນີນການສັ່ງຊື້',
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
