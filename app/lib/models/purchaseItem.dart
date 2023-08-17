import 'dart:convert';

class Purchase {
  final String name;
  final int price;
  final String icon;

  Purchase(
      {
        required this.name,
        required this.price,
        required this.icon,
      });

  factory Purchase.fromJson(Map<String, dynamic> json) {
    return Purchase(
      name: json['name'],
      price: json['price'],
      icon: json['icon'] ?? "",
    );
  }

  @override
  String toString() {
    return json.encode(this);
  }
}
