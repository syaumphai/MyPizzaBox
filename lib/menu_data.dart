import 'dart:convert';
import 'package:flutter/services.dart' show rootBundle;

class MenuItem {
  final String name;
  final int price;
  final String image;

  MenuItem({required this.name, required this.price, required this.image});

  factory MenuItem.fromJson(Map<String, dynamic> json) {
    return MenuItem(
      name: json['name'],
      price: json['price'],
      image: json['image'],
    );
  }
}

Future<List<MenuItem>> loadMenu() async {
  final data = await rootBundle.loadString('assets/menu.json');
  final List<dynamic> jsonResult = json.decode(data);
  return jsonResult.map((e) => MenuItem.fromJson(e)).toList();
}
