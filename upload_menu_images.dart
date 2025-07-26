import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'dart:io';

Future<void> main() async {
  // 1. Initialize Firebase
  await Firebase.initializeApp();

  final menuItems = [
    {'file': 'assets/chicken_wings.png', 'menuId': 'chicken_2'},
    {'file': 'assets/grilled_chicken.png', 'menuId': 'chicken_1'},
    {'file': 'assets/bbq_ribs.png', 'menuId': 'bbq_1'},
    {'file': 'assets/bbq_chicken.png', 'menuId': 'bbq_2'},
    {'file': 'assets/cheese_sticks.png', 'menuId': 'app_1'},
    {'file': 'assets/buffalo_wings.png', 'menuId': 'app_2'},
    {'file': 'assets/fries_classic.png', 'menuId': 'fries_1'},
    {'file': 'assets/fries_loaded.png', 'menuId': 'fries_2'},
    {'file': 'assets/coca_cola.png', 'menuId': 'bev_1'},
    {'file': 'assets/orange_juice.png', 'menuId': 'bev_2'},
    {'file': 'assets/chocolate_cake.png', 'menuId': 'dessert_1'},
    {'file': 'assets/ice_cream.png', 'menuId': 'dessert_2'},
  ];

  for (final item in menuItems) {
    final file = File(item['file']!);
    final fileName = file.uri.pathSegments.last;
    final storageRef =
        FirebaseStorage.instance.ref().child('menu_images/ [200~$fileName');
    // 3. Upload image to Firebase Storage
    await storageRef.putFile(file);
    final downloadUrl = await storageRef.getDownloadURL();

    // 4. Update Firestore
    await FirebaseFirestore.instance
        .collection('menu')
        .doc(item['menuId']!)
        .update({
      'picture': downloadUrl,
    });
    print('Uploaded and updated Firestore for ${item['menuId']}');
  }
}
