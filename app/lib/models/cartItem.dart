import 'dart:convert';

import 'package:flutter/services.dart';

class CartItem{

  final String name;
  final String iconPath;
  final int id;
  final double price;
  double? quantity;
  String? unit;
  String? specific;


  CartItem({required this.name, required this.iconPath, required this.id, required this.price, this.unit, this.quantity, this.specific });

  factory CartItem.fromJson(Map<String, dynamic> json) {
    return CartItem(
      name: json['name'],
      id: json['id'],
      iconPath: json['icon'],
      price: json['price'],
      quantity: json['quantity'],
    );
  }

  static Future<List<CartItem>> readJson() async {
    final String response = await rootBundle.loadString('assets/models/products.json');
    final data = await json.decode(response) as List;
    final items = data.map((i) => CartItem.fromJson(i)).toList();
    return items;
  }

  @override
  String toString() {
    return json.encode(this);
  }
}