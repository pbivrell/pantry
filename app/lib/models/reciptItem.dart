import 'dart:convert';

import 'package:flutter/services.dart';

class Purchase {
  final String name;
  final int price;

  Purchase(
      {
        required this.name,
        required this.price,
      });

  factory Purchase.fromJson(Map<String, dynamic> json) {
    return Purchase(
      name: json['name'],
      price: json['price'],
    );
  }

  @override
  String toString() {
    return json.encode(this);
  }
}

class ReciptItem{

  final DateTime date;
  final DateTime visit;
  final String addr;
  final List<Purchase> purchases;

  ReciptItem(
      {
        required this.date,
        required this.addr,
        required this.purchases,
        required this.visit,
      });

  factory ReciptItem.fromJson(Map<String, dynamic> json) {

    var list = json["items"] as List;

    var x = list.map((i) => Purchase.fromJson(i)).toList();

    return ReciptItem(
      date: DateTime.parse(json['date']),
      visit: DateTime.parse(json['visit']),
      addr: json['addr'],
      purchases: x,
    );
  }

  @override
  String toString() {
    return json.encode(this);
  }
}