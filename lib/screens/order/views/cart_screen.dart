import 'package:flutter/material.dart';
import 'package:pizza_app/screens/payment/views/payment_screen.dart';
import 'package:pizza_repository/pizza_repository.dart';

class CartScreen extends StatefulWidget {
  final List<Map<String, dynamic>> cartItems;
  final VoidCallback onClearCart;
  const CartScreen(
      {Key? key, required this.cartItems, required this.onClearCart})
      : super(key: key);

  @override
  State<CartScreen> createState() => _CartScreenState();
}

class _CartScreenState extends State<CartScreen> {
  late List<Map<String, dynamic>> _cartItems;

  @override
  void initState() {
    super.initState();
    _cartItems = List.from(widget.cartItems);
  }

  void _removeItem(int index) {
    setState(() {
      _cartItems.removeAt(index);
    });
  }

  int parseInt(dynamic value) {
    if (value == null) return 0;
    if (value is int) return value;
    if (value is double) return value.toInt();
    if (value is String) return int.tryParse(value) ?? 0;
    return 0;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF06402B),
      appBar: AppBar(
        backgroundColor: const Color(0xFF06402B),
        title: const Text('ກະຕ່າສິນຄ້າ'),
      ),
      body: _cartItems.isEmpty
          ? const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.shopping_cart, size: 80, color: Colors.grey),
                  SizedBox(height: 16),
                  Text('ກະຕ່າສິນຄ້າວ່າງ',
                      style: TextStyle(fontWeight: FontWeight.bold)),
                  SizedBox(height: 8),
                  Text('ເພີ່ມສິນຄ້າໃນກະຕ່າເພື່ອເລີ່ມສັ່ງຊື້',
                      style: TextStyle(color: Colors.grey)),
                ],
              ),
            )
          : ListView.builder(
              itemCount: _cartItems.length,
              itemBuilder: (context, index) {
                final item = _cartItems[index];
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
                final name = item['name']?.toString() ?? '';
                final count = _cartItems
                    .where((e) => e['name']?.toString() == name)
                    .length;
                return ListTile(
                  leading: Image.asset(item['picture'], width: 40, height: 40),
                  title: Text(item['name']),
                  subtitle: discountedPrice != null
                      ? Row(
                          children: [
                            Text(
                              '₭$price',
                              style: const TextStyle(
                                color: Colors.grey,
                                decoration: TextDecoration.lineThrough,
                              ),
                            ),
                            const SizedBox(width: 6),
                            Text(
                              '₭${discountedPrice.toStringAsFixed(0)}',
                              style: const TextStyle(
                                color: Colors.green,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(width: 6),
                            Text(
                              '-${discount.toString()}%',
                              style: const TextStyle(
                                color: Colors.red,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            Text(' x$count'),
                          ],
                        )
                      : Text('₭$price x$count'),
                  trailing: IconButton(
                    icon: const Icon(Icons.delete, color: Colors.red),
                    onPressed: () => _removeItem(index),
                  ),
                );
              },
            ),
      bottomNavigationBar: _cartItems.isNotEmpty
          ? Padding(
              padding: const EdgeInsets.all(16.0),
              child: ElevatedButton(
                onPressed: () {
                  print('DEBUG: _cartItems = $_cartItems');
                  final pizzaList = _cartItems.map((item) {
                    final macrosMap = {
                      'calories': parseInt(item['macros']?['calories']),
                      'proteins': parseInt(item['macros']?['proteins']),
                      'fat': parseInt(item['macros']?['fat']),
                      'carbs': parseInt(item['macros']?['carbs']),
                    };
                    return Pizza(
                      pizzaId: item['name']?.toString() ?? '',
                      picture: item['picture']?.toString() ?? '',
                      isVeg: (item['isVeg'] ?? false),
                      spicy: parseInt(item['spicy']),
                      name: item['name']?.toString() ?? '',
                      description: item['description']?.toString() ?? '',
                      price: parseInt(item['price']),
                      discount: parseInt(item['discount']),
                      macros: Macros.fromDocument(macrosMap),
                    );
                  }).toList();
                  final Map<String, int> quantities = {};
                  for (final item in _cartItems) {
                    final id = item['name']?.toString() ?? '';
                    quantities[id] = (quantities[id] ?? 0) + 1;
                  }
                  double total = 0;
                  for (final pizza in pizzaList) {
                    final discount = pizza.discount;
                    double? discountedPrice;
                    if (discount > 0) {
                      discountedPrice =
                          pizza.price - (pizza.price * (discount / 100));
                    }
                    final quantity = _cartItems
                        .where((e) => e['name']?.toString() == pizza.pizzaId)
                        .length;
                    final priceToUse = discountedPrice ?? pizza.price;
                    total += priceToUse * quantity;
                  }
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => PaymentScreen(
                        items: pizzaList,
                        quantities: quantities,
                        total: total,
                        deliveryAddress: '',
                        phoneNumber: '',
                        note: '',
                        deliveryMethod: '',
                        onPaymentSuccess: () {
                          setState(() {
                            _cartItems.clear();
                          });
                          widget.onClearCart();
                        },
                      ),
                    ),
                  );
                },
                child: const Text('ຊຳລະເງິນ'),
              ),
            )
          : null,
    );
  }
}
