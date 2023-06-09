import 'dart:convert';

import 'package:isar/isar.dart';
import 'package:untitled/consts.dart';
import 'package:http/http.dart' as http;

import '../componets/AbsSearchList.dart';

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

  Product.localOnly(this.name)
      : price = 0,
        icon = "",
        inPantry = false,
        backId = -1,
        localOnly = true;

  @override
  bool operator ==(o) => o is Product && backId == o.backId;

  @override
  int get hashCode => backId;

  @override
  String toString() {
    return name;
  }

  static Future<List<Product>> Load(String term) {
      final uri = 'http://$apiURL/api/products/search/$term';

      return http.get(Uri.parse(uri),
          headers: {"cookie": "X-Session-Token=alwaysvalid"}).then(
              (response) {
                if (response.statusCode == 200) {
                  var list = json.decode(response.body) as List;
                  List<Product> x = list.map((i) => Product.fromJson(i)).toList();
                  return x;
                }
                throw Exception("$response");
      });
    }
}