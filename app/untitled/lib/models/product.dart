import 'package:isar/isar.dart';

part 'product.g.dart';



@collection
class Product {
  Id id = Isar.autoIncrement;
  final int price;
  final String name;
  final String icon;
  final bool inPantry;
  String priceText = "";
  final int backId;
  bool localOnly;

  Product({
    required this.price,
    required this.name,
    required this.icon,
    required this.inPantry,
    required this.backId,
    this.localOnly = false
  }) {
    double p = price / 100;
    priceText = "\$$p";
  }

  factory Product.fromJson(Map<String, dynamic> json) {
    return Product(
      price: json['price'],
      name: json['name'],
      backId: json['id'],
      inPantry: json['inPantry'],
      icon: json['icon'],
    );
  }

  Product.localOnly(this.name): price = 0, icon = "", inPantry = false, backId = -1, localOnly = true;

  @override
  bool operator ==(o) => o is Product && backId == o.backId;

  @override
  int get hashCode => backId;

  @override
  String toString() {
    return name;
  }
}