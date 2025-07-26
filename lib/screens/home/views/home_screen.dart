import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:pizza_app/screens/auth/blocs/sign_in_bloc/sign_in_bloc.dart';
import 'package:pizza_app/screens/order/views/order_screen.dart';
import 'package:pizza_app/screens/order/views/order_history_screen.dart';
import 'package:pizza_repository/pizza_repository.dart';
import 'package:intl/intl.dart';
import 'package:pizza_app/screens/home/views/details_screen.dart';
import 'package:pizza_app/screens/order/views/cart_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  String selectedCategory = 'All';
  List<String> categories = [
    'All',
    'Pizza',
    'Chicken',
    'BBQ',
    'Appetizers',
    'French Fries',
    'Beverages',
    'Desserts'
  ];

  List<Map<String, dynamic>> cart = [];

  // กำหนดข้อมูลสินค้าในโค้ด (ไม่ใช้ json)
  final List<Map<String, dynamic>> assetMenuItems = [
    {
      "name": "BBQ Chicken Wings",
      "category": "Chicken",
      "price": 75000,
      "picture": "assets/BBQ_Chicken.jpeg",
      "isVeg": false,
      "spicy": "SPICY",
      "description": "Crispy wings with BBQ sauce",
      "macros": {"calories": 220, "proteins": 20, "fat": 7, "carbs": 28}
    },
    {
      "name": "Grilled Chicken Breast",
      "category": "Chicken",
      "price": 80000,
      "picture": "assets/chicken_grilled.jpeg",
      "isVeg": false,
      "spicy": "BLAND",
      "description": "Juicy grilled chicken with herbs",
      "macros": {"calories": 220, "proteins": 20, "fat": 7, "carbs": 28}
    },
    {
      "name": "Pizza Hawaiian ",
      "category": "Pizza",
      "price": 250000,
      "picture": "assets/pizza_hawaiian.png",
      "isVeg": true,
      "spicy": "BLAND",
      "description": "Juicy pizza with pineapple and ham",
      "macros": {"calories": 250, "proteins": 22, "fat": 10, "carbs": 30}
    },
    {
      "name": "Pizza Margherita ",
      "category": "Pizza",
      "price": 220000,
      "picture": "assets/pizza_margherita.png",
      "isVeg": true,
      "spicy": "BLAND",
      "description": "Juicy pizza with tomato and cheese",
      "macros": {"calories": 250, "proteins": 22, "fat": 10, "carbs": 30}
    },
    {
      "name": "Pizza Pepperoni ",
      "category": "Pizza",
      "price": 230000,
      "picture": "assets/pizza_pepperoni.png",
      "isVeg": true,
      "spicy": "BLAND",
      "description": "Juicy pizza with pepperoni and cheese",
      "macros": {"calories": 250, "proteins": 22, "fat": 10, "carbs": 30}
    },
    {
      "name": "Orange Juice ",
      "category": "Beverages",
      "price": 3000,
      "picture": "assets/Orange_Juice.jpeg",
      "isVeg": false,
      "spicy": "BLAND",
      "description": "Fresh orange juice",
      "macros": {"calories": 120, "proteins": 6, "fat": 0, "carbs": 0}
    },
    {
      "name": "Coca Cola ",
      "category": "Beverages",
      "price": 5000,
      "picture": "assets/Coca_Cola.jpeg",
      "isVeg": false,
      "spicy": "BLAND",
      "description": "Coca Cola",
      "macros": {"calories": 120, "proteins": 6, "fat": 0, "carbs": 0}
    },
    {
      "name": "BBQ Chicken ",
      "category": "Chicken",
      "price": 80000,
      "picture": "assets/BBQ_Chicken.jpeg",
      "isVeg": false,
      "spicy": "BLAND",
      "description": "BBQ Chicken",
      "macros": {"calories": 200, "proteins": 20, "fat": 6, "carbs": 8}
    },
    {
      "name": "BBQ Ribs ",
      "category": "BBQ",
      "price": 80000,
      "picture": "assets/BBQ_Ribs.jpeg",
      "isVeg": true,
      "spicy": "BLAND",
      "description": "BBQ Ribs",
      "macros": {"calories": 200, "proteins": 20, "fat": 6, "carbs": 8}
    },
    {
      "name": "Buffalo Wings ",
      "category": "BBQ",
      "price": 90000,
      "picture": "assets/Buffalo_Wings.jpeg",
      "isVeg": true,
      "spicy": "BLAND",
      "description": "Buffalo Wings",
      "macros": {"calories": 200, "proteins": 20, "fat": 6, "carbs": 8}
    },
    {
      "name": "Cheese Stick ",
      "category": "French Fries",
      "price": 15000,
      "picture": "assets/Cheese_Sticks.jpeg",
      "isVeg": true,
      "spicy": "BLAND",
      "description": "Cheese Stick",
      "macros": {"calories": 130, "proteins": 12, "fat": 10, "carbs": 12}
    },
    {
      "name": "Chocolate Cake ",
      "category": "Desserts",
      "price": 10000,
      "picture": "assets/Chocolate_Cake.jpeg",
      "isVeg": false,
      "spicy": "BLAND",
      "description": "Chocolate Cake",
      "macros": {"calories": 100, "proteins": 6, "fat": 0, "carbs": 0}
    },
    {
      "name": "Classic Fries ",
      "category": "French Fries",
      "price": 17000,
      "picture": "assets/Classic_Fries.jpeg",
      "isVeg": true,
      "spicy": "BLAND",
      "description": "Classic Fries",
      "macros": {"calories": 130, "proteins": 20, "fat": 10, "carbs": 12}
    },
    {
      "name": "Ice Cream ",
      "category": "Desserts",
      "price": 10000,
      "picture": "assets/Ice_Cream.jpeg",
      "isVeg": false,
      "spicy": "BLAND",
      "description": "Ice Cream",
      "macros": {"calories": 100, "proteins": 6, "fat": 2, "carbs": 0}
    },
    {
      "name": "Loaded Fries ",
      "category": "French Fries",
      "price": 15000,
      "picture": "assets/Loaded_Fries.jpeg",
      "isVeg": true,
      "spicy": "BLAND",
      "description": "Loaded Fries",
      "macros": {"calories": 130, "proteins": 20, "fat": 10, "carbs": 12}
    },
    {
      "name": "Shrimp Salad ",
      "category": "Appetizers",
      "price": 25000,
      "picture": "assets/Shrimp_Salad.jpg",
      "isVeg": false,
      "spicy": "BLAND",
      "description": "Shrimp Salad",
      "macros": {"calories": 120, "proteins": 8, "fat": 2, "carbs": 0}
    },
    {
      "name": "Onion Rings ",
      "category": "Appetizers",
      "price": 20000,
      "picture": "assets/Onion_Rings.webp",
      "isVeg": true,
      "spicy": "BLAND",
      "description": "Onion Rings",
      "macros": {"calories": 120, "proteins": 8, "fat": 6, "carbs": 8}
    },
    {
      "name": "Pizza Marinara ",
      "category": "Pizza",
      "price": 80000,
      "picture": "assets/Pizza_Marinara.webp",
      "isVeg": true,
      "spicy": "BLAND",
      "description": "Pizza Marinara",
      "macros": {"calories": 250, "proteins": 22, "fat": 10, "carbs": 30}
    },
    {
      "name": "Cheesy Garlic breadsticks Cheese Dip ",
      "category": "Appetizers",
      "price": 30000,
      "picture": "assets/Cheesy Garlic Breadsticks_Cheese Dip.webp",
      "isVeg": true,
      "spicy": "BLAND",
      "description": "Cheesy Garlic Breadsticks Cheese Dip",
      "macros": {"calories": 120, "proteins": 8, "fat": 6, "carbs": 8}
    },
    {
      "name": "Pizza Veggie ",
      "category": "Pizza",
      "price": 85000,
      "picture": "assets/Veggie_pizza.jpg",
      "isVeg": true,
      "spicy": "BLAND",
      "description": "Veggie Pizza",
      "macros": {"calories": 250, "proteins": 22, "fat": 10, "carbs": 30}
    },
    {
      "name": "Pizza Truffle ",
      "category": "Pizza",
      "price": 87000,
      "picture": "assets/truffle_pizza.webp",
      "isVeg": true,
      "spicy": "BLAND",
      "description": "Truffle Pizza",
      "macros": {"calories": 250, "proteins": 22, "fat": 10, "carbs": 30}
    },
    {
      "name": "Pizza Salami ",
      "category": "Pizza",
      "price": 89000,
      "picture": "assets/pizza_Salami.webp",
      "isVeg": true,
      "spicy": "BLAND",
      "description": "Pizza Salami",
      "macros": {"calories": 250, "proteins": 22, "fat": 10, "carbs": 30}
    },
    {
      "name": "Sprite ",
      "category": "Beverages",
      "price": 50000,
      "picture": "assets/Sprite.jpg",
      "isVeg": false,
      "spicy": "BLAND",
      "description": "Sprite",
      "macros": {"calories": 100, "proteins": 6, "fat": 2, "carbs": 0}
    },
    {
      "name": "Lemon Tea ",
      "category": "Beverages",
      "price": 5000,
      "picture": "assets/Lemon_Tea.jpg",
      "isVeg": false,
      "spicy": "BLAND",
      "description": "Lemon Tea",
      "macros": {"calories": 100, "proteins": 6, "fat": 2, "carbs": 0}
    },
    {
      "name": "Seven Up ",
      "category": "Beverages",
      "price": 5000,
      "picture": "assets/7_up.png",
      "isVeg": false,
      "spicy": "BLAND",
      "description": "Seven Up",
      "macros": {"calories": 100, "proteins": 6, "fat": 2, "carbs": 0}
    },

    // ... เพิ่มสินค้าอื่นๆ ตามต้องการ ...
  ];

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
  void initState() {
    super.initState();
  }

  void showCart(BuildContext context) {
    if (cart.isEmpty) {
      showModalBottomSheet(
        context: context,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        builder: (context) => const SizedBox(
          height: 200,
          child: Center(child: Text('ກະຕ່າຫວ່າງເປົ່າ')),
        ),
      );
      return;
    }

    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        // Combine Firestore and asset items for cart
        return FutureBuilder<List<Map<String, dynamic>>>(
          future: _getAllMenuItems(),
          builder: (context, snapshot) {
            if (!snapshot.hasData) {
              return const Center(child: CircularProgressIndicator());
            }
            final items = snapshot.data!;
            final cartMap = <String, int>{};
            for (final item in cart) {
              final id = item['itemId'];
              cartMap[id] = (cartMap[id] ?? 0) + 1;
            }
            final cartItems = items
                .where((item) => cartMap.containsKey(item['itemId']))
                .toList();

            // Calculate total
            double total = 0;
            for (final item in cartItems) {
              final count = cartMap[item['itemId']]!;
              final price = ((item['price'] as num)).toInt();
              total += price * count;
            }

            final NumberFormat kipFormat = NumberFormat('#,##0', 'en_US');

            return Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text('ກະຕ່າຂອງທ່ານ',
                      style:
                          TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 16),
                  Flexible(
                    child: ListView.builder(
                      shrinkWrap: true,
                      itemCount: cartItems.length,
                      itemBuilder: (context, index) {
                        final item = cartItems[index];
                        final count = cartMap[item['itemId']]!;
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
                        return ListTile(
                          leading: item['picture']
                                  .toString()
                                  .toLowerCase()
                                  .startsWith('assets/')
                              ? Image.asset(
                                  item['picture'],
                                  width: 40,
                                  height: 40,
                                  errorBuilder: (context, error, stackTrace) =>
                                      const Icon(Icons.broken_image),
                                )
                              : Image.network(
                                  item['picture'],
                                  width: 40,
                                  height: 40,
                                  errorBuilder: (context, error, stackTrace) =>
                                      const Icon(Icons.broken_image),
                                ),
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
                            onPressed: () {
                              setState(() {
                                cart.removeWhere((id) => id == item['itemId']);
                              });
                              Navigator.pop(context);
                              showCart(context);
                            },
                          ),
                        );
                      },
                    ),
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Divider(),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text('ລາຍການສິນຄ້າທັງໝົດ:',
                              style: TextStyle(fontWeight: FontWeight.bold)),
                          Text('${cartItems.length} ລາຍການ'),
                        ],
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text('ຈຳນວນທັງໝົດ:',
                              style: TextStyle(fontWeight: FontWeight.bold)),
                          Text(
                              '${cart.fold<int>(0, (acc, id) => acc + 1)} ຊິ້ນ'),
                        ],
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text('ລາຄາລວມທັງໝົດ:',
                              style: TextStyle(fontWeight: FontWeight.bold)),
                          Text('₭${kipFormat.format(total)}',
                              style:
                                  const TextStyle(fontWeight: FontWeight.bold)),
                        ],
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () {
                        Navigator.pop(context);
                        // แปลง cartItems เป็น List<Pizza> ก่อนส่ง
                        final pizzaList = cartItems
                            .map((item) => Pizza(
                                  pizzaId: item['itemId'],
                                  picture: item['picture'],
                                  isVeg: (item['isVeg'] ?? false),
                                  spicy: item['spicy'],
                                  name: item['name'],
                                  description: item['description'],
                                  price: (item['price'] as num).toInt(),
                                  discount: item['discount'],
                                  macros: Macros.fromDocument({
                                    ...?item['macros'],
                                    'calories':
                                        (item['macros']?['calories'] ?? 0),
                                    'proteins':
                                        (item['macros']?['proteins'] ?? 0),
                                    'fat': (item['macros']?['fat'] ?? 0),
                                    'carbs': (item['macros']?['carbs'] ?? 0),
                                  }),
                                ))
                            .toList();
                        Navigator.push(
                          context,
                          MaterialPageRoute<void>(
                            builder: (BuildContext context) => OrderScreen(
                              cartItems: pizzaList,
                              cartQuantities: cartMap,
                            ),
                          ),
                        );
                      },
                      child: const Text('ຊຳລະເງິນ'),
                    ),
                  )
                ],
              ),
            );
          },
        );
      },
    );
  }

  Future<List<Map<String, dynamic>>> _getAllMenuItems() async {
    // Load Firestore items
    final QuerySnapshot snapshot =
        await FirebaseFirestore.instance.collection('menu').get();
    final List<Map<String, dynamic>> firestoreItems = snapshot.docs.map((doc) {
      final data = doc.data() as Map<String, dynamic>;
      return {
        'id': doc.id,
        ...data,
      };
    }).toList();

    // Load asset items (already loaded in assetMenuItems)
    return [...firestoreItems, ...assetMenuItems];
  }

  @override
  Widget build(BuildContext context) {
    final NumberFormat kipFormat = NumberFormat('#,##0', 'en_US');
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.surface,
        title: const Row(
          children: [
            Icon(Icons.local_pizza, size: 30, color: Colors.red),
            SizedBox(width: 8),
            Text(
              'PIZZA',
              style: TextStyle(fontWeight: FontWeight.w900, fontSize: 30),
            )
          ],
        ),
        actions: [
          Stack(
            children: [
              IconButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => CartScreen(
                          cartItems: cart,
                          onClearCart: () => setState(() {
                                cart.clear();
                              })),
                    ),
                  );
                },
                icon: const Icon(CupertinoIcons.cart),
              ),
              if (cart.isNotEmpty)
                Positioned(
                  right: 8,
                  top: 8,
                  child: Container(
                    padding: const EdgeInsets.all(4),
                    decoration: BoxDecoration(
                      color: Colors.red,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    constraints:
                        const BoxConstraints(minWidth: 20, minHeight: 20),
                    child: Text(
                      '${cart.length}',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                ),
            ],
          ),
          IconButton(
            icon: const Icon(Icons.cloud_upload),
            onPressed: () {
              // ໄປຍັງໜ້າ Order History
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => OrderHistoryScreen(),
                ),
              );
            },
            tooltip: 'Sync assets to Firestore',
          ),
          IconButton(
            onPressed: () {
              // ໄປຍັງໜ້າ Order History
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => OrderHistoryScreen(),
                ),
              );
            },
            icon: const Icon(Icons.history),
          ),
          IconButton(
              onPressed: () {
                context.read<SignInBloc>().add(SignOutRequired());
              },
              icon: const Icon(CupertinoIcons.arrow_right_to_line)),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            // Category Filter
            SizedBox(
              height: 50,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                itemCount: categories.length,
                itemBuilder: (context, index) {
                  final category = categories[index];
                  final isSelected = selectedCategory == category;
                  return Padding(
                    padding: const EdgeInsets.only(right: 12),
                    child: GestureDetector(
                      onTap: () {
                        setState(() {
                          selectedCategory = category;
                        });
                      },
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 16, vertical: 8),
                        decoration: BoxDecoration(
                          color: isSelected ? Colors.black : Colors.grey[200],
                          borderRadius: BorderRadius.circular(25),
                        ),
                        child: Text(
                          category,
                          style: TextStyle(
                            color: isSelected ? Colors.white : Colors.black,
                            fontWeight: isSelected
                                ? FontWeight.bold
                                : FontWeight.normal,
                          ),
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
            const SizedBox(height: 16),
            // Menu Items
            Expanded(
              child: Builder(
                builder: (context) {
                  final filteredItems = assetMenuItems
                      .where((item) =>
                          selectedCategory == 'All' ||
                          item['category'] == selectedCategory)
                      .toList();
                  return GridView.builder(
                    gridDelegate:
                        const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      crossAxisSpacing: 12,
                      mainAxisSpacing: 12,
                      childAspectRatio: 0.7,
                    ),
                    itemCount: filteredItems.length,
                    itemBuilder: (context, index) {
                      final item = filteredItems[index];
                      final name = item['name'];
                      final price = item['price'];
                      final picture = item['picture'];
                      final discount = item['discount'];

                      // คำนวณราคาหลังหักส่วนลด ถ้ามี discount
                      double? discountedPrice;
                      if (discount != null && discount is num && discount > 0) {
                        discountedPrice = price - (price * (discount / 100));
                      }

                      return Card(
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(20),
                        ),
                        elevation: 3,
                        child: InkWell(
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => DetailsScreen(item: item),
                              ),
                            );
                          },
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Expanded(
                                child: ClipRRect(
                                  borderRadius: const BorderRadius.vertical(
                                      top: Radius.circular(20)),
                                  child: Image.asset(
                                    picture,
                                    fit: BoxFit.cover,
                                    width: double.infinity,
                                    errorBuilder:
                                        (context, error, stackTrace) =>
                                            Container(
                                      color: Colors.grey[200],
                                      child: const Center(
                                          child: Icon(Icons.broken_image)),
                                    ),
                                  ),
                                ),
                              ),
                              Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Row(
                                      children: [
                                        if (item['isVeg'] == false)
                                          _buildBadge('NON-VEG', Colors.red),
                                        if (item['isVeg'] == true)
                                          _buildBadge(
                                              'VEGETARIAN', Colors.green),
                                        if (item['spicy'] != null)
                                          _buildBadge(
                                              item['spicy'],
                                              item['spicy'] == 'SPICY'
                                                  ? Colors.orange
                                                  : Colors.green),
                                      ],
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      name,
                                      style: const TextStyle(
                                          fontWeight: FontWeight.bold,
                                          fontSize: 14),
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                    if (item['description'] != null)
                                      Text(
                                        item['description'],
                                        style: const TextStyle(
                                            fontSize: 13, color: Colors.grey),
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    const SizedBox(height: 8),
                                    Row(
                                      children: [
                                        Expanded(
                                          child: Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              if (discountedPrice != null)
                                                Row(
                                                  children: [
                                                    Expanded(
                                                      child: Text(
                                                        '₭${NumberFormat('#,##0', 'en_US').format(price)}',
                                                        style: const TextStyle(
                                                          fontSize: 12,
                                                          color: Colors.grey,
                                                          decoration:
                                                              TextDecoration
                                                                  .lineThrough,
                                                        ),
                                                        overflow: TextOverflow
                                                            .ellipsis,
                                                      ),
                                                    ),
                                                    const SizedBox(width: 4),
                                                    Expanded(
                                                      child: Text(
                                                        '₭${NumberFormat('#,##0', 'en_US').format(discountedPrice)}',
                                                        style: TextStyle(
                                                          fontSize: 14,
                                                          fontWeight:
                                                              FontWeight.bold,
                                                          color:
                                                              Theme.of(context)
                                                                  .colorScheme
                                                                  .primary,
                                                        ),
                                                        overflow: TextOverflow
                                                            .ellipsis,
                                                      ),
                                                    ),
                                                    const SizedBox(width: 4),
                                                    Text(
                                                      '-${discount.toString()}%',
                                                      style: const TextStyle(
                                                        color: Colors.red,
                                                        fontWeight:
                                                            FontWeight.bold,
                                                        fontSize: 12,
                                                      ),
                                                    ),
                                                  ],
                                                )
                                              else
                                                Text(
                                                  '₭${NumberFormat('#,##0', 'en_US').format(price)}',
                                                  style: TextStyle(
                                                    fontSize: 14,
                                                    fontWeight: FontWeight.bold,
                                                    color: Theme.of(context)
                                                        .colorScheme
                                                        .primary,
                                                  ),
                                                  overflow:
                                                      TextOverflow.ellipsis,
                                                ),
                                            ],
                                          ),
                                        ),
                                        CircleAvatar(
                                          backgroundColor: Colors.black,
                                          child: IconButton(
                                            icon: const Icon(Icons.add,
                                                color: Colors.white),
                                            onPressed: () {
                                              setState(() {
                                                cart.add(item);
                                              });
                                              ScaffoldMessenger.of(context)
                                                  .showSnackBar(
                                                SnackBar(
                                                  content: Text(
                                                      'เพิ่ม $name ลงในตะกร้าแล้ว'),
                                                  backgroundColor: Colors.green,
                                                ),
                                              );
                                            },
                                          ),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
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
      ),
    );
  }
}
