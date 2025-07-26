import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class DetailsScreen extends StatelessWidget {
  final Map<String, dynamic> item;
  const DetailsScreen({Key? key, required this.item}) : super(key: key);

  Widget _buildBadge(String text, Color color) {
    return Container(
      margin: const EdgeInsets.only(right: 4),
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: BoxDecoration(
        color: color.withAlpha((0.15 * 255).toInt()),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        text,
        style: TextStyle(
          color: color,
          fontWeight: FontWeight.bold,
          fontSize: 12,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final macros = item['macros'] as Map<String, dynamic>?;
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
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.surface,
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        child: Column(
          children: [
            // รูปภาพ
            Container(
              width: MediaQuery.of(context).size.width,
              height: MediaQuery.of(context).size.width - 40,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(30),
                boxShadow: const [
                  BoxShadow(
                      color: Colors.grey, offset: Offset(3, 3), blurRadius: 5)
                ],
                image: DecorationImage(
                  image: AssetImage(item['picture']),
                  fit: BoxFit.cover,
                ),
              ),
            ),
            const SizedBox(height: 30),
            Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(30),
                boxShadow: const [
                  BoxShadow(
                      color: Colors.grey, offset: Offset(3, 3), blurRadius: 5)
                ],
              ),
              child: Padding(
                padding: const EdgeInsets.all(20.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Badge
                    Row(
                      children: [
                        if (item['isVeg'] == false)
                          _buildBadge('NON-VEG', Colors.red),
                        if (item['isVeg'] == true)
                          _buildBadge('VEGETARIAN', Colors.green),
                        if (item['spicy'] != null)
                          _buildBadge(
                              item['spicy'],
                              item['spicy'] == 'SPICY'
                                  ? Colors.orange
                                  : Colors.green),
                      ],
                    ),
                    const SizedBox(height: 8),
                    // ชื่อสินค้า
                    Text(
                      item['name'],
                      style: const TextStyle(
                          fontSize: 20, fontWeight: FontWeight.bold),
                    ),
                    if (item['description'] != null)
                      Padding(
                        padding: const EdgeInsets.only(top: 4.0),
                        child: Text(
                          item['description'],
                          style:
                              const TextStyle(fontSize: 14, color: Colors.grey),
                        ),
                      ),
                    const SizedBox(height: 12),
                    // ราคา
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        if (discountedPrice != null) ...[
                          Text(
                            '₭${price}',
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
                        ] else ...[
                          Text(
                            '₭${price}',
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              color: Theme.of(context).colorScheme.primary,
                            ),
                          ),
                        ],
                      ],
                    ),
                    const SizedBox(height: 16),
                    // Macros
                    if (macros != null)
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          _MacroWidget(
                              title: "Calories",
                              value: macros['calories'],
                              icon: FontAwesomeIcons.fire),
                          _MacroWidget(
                              title: "Protein",
                              value: macros['proteins'],
                              icon: FontAwesomeIcons.dumbbell),
                          _MacroWidget(
                              title: "Fat",
                              value: macros['fat'],
                              icon: FontAwesomeIcons.oilWell),
                          _MacroWidget(
                              title: "Carbs",
                              value: macros['carbs'],
                              icon: FontAwesomeIcons.breadSlice),
                        ],
                      ),
                    const SizedBox(height: 24),
                    SizedBox(
                      width: double.infinity,
                      height: 50,
                      child: TextButton(
                        onPressed: () async {
                          // 1. สร้าง order map
                          final order = {
                            'item': item,
                            'price': item['price'],
                            'createdAt': DateTime.now().toIso8601String(),
                          };
                          // 2. บันทึกลง Firestore
                          final doc = await FirebaseFirestore.instance
                              .collection('orders')
                              .add(order);
                          // 3. ไปหน้า OrderSummaryScreen
                          // ignore: use_build_context_synchronously
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => OrderSummaryScreen(
                                  order: order, orderId: doc.id),
                            ),
                          );
                        },
                        style: TextButton.styleFrom(
                          elevation: 3.0,
                          backgroundColor: Colors.black,
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                        child: const Text(
                          "Buy Now",
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 20,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _MacroWidget extends StatelessWidget {
  final String title;
  final dynamic value;
  final IconData icon;
  const _MacroWidget(
      {required this.title, required this.value, required this.icon});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Icon(icon, size: 20, color: Colors.red),
        const SizedBox(height: 4),
        Text('$value $title', style: const TextStyle(fontSize: 12)),
      ],
    );
  }
}

class OrderSummaryScreen extends StatelessWidget {
  final Map<String, dynamic> order;
  final String orderId;
  const OrderSummaryScreen(
      {Key? key, required this.order, required this.orderId})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    final item = order['item'] as Map<String, dynamic>;
    return Scaffold(
      appBar: AppBar(title: const Text('รายละเอียดคำสั่งซื้อ')),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('หมายเลขคำสั่งซื้อ: $orderId',
                style: const TextStyle(fontWeight: FontWeight.bold)),
            const SizedBox(height: 12),
            Row(
              children: [
                Container(
                  width: 80,
                  height: 80,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(16),
                    image: DecorationImage(
                      image: AssetImage(item['picture']),
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(item['name'],
                          style: const TextStyle(
                              fontWeight: FontWeight.bold, fontSize: 18)),
                      if (item['description'] != null)
                        Text(item['description'],
                            style: const TextStyle(
                                fontSize: 14, color: Colors.grey)),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Text('ราคา: ₭${order['price']}',
                style: const TextStyle(fontSize: 16)),
            const SizedBox(height: 8),
            Text('เวลาสั่งซื้อ: ${order['createdAt']}',
                style: const TextStyle(fontSize: 14, color: Colors.grey)),
            const SizedBox(height: 24),
            const Text('ขอบคุณที่สั่งซื้อ!',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
          ],
        ),
      ),
    );
  }
}
