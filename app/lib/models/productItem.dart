import 'dart:convert';

class ProductItem {

  final String name;
  final String iconPath;
  final int id;
  final double price;
  double? quantity;
  String? unit;
  String? specific;


  ProductItem({required this.name, required this.iconPath, required this.id, required this.price, this.unit, this.quantity, this.specific });

  factory ProductItem.fromJson(Map<String, dynamic> json) {
    return ProductItem(
      name: json['name'],
      id: json['id'],
      iconPath: json['icon'],
      price: json['price'],
      quantity: json['quantity'],
    );
  }

  @override
  String toString() {
    return json.encode(this);
  }
}