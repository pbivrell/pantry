import 'dart:convert';
import 'dart:core';

import 'package:flutter/services.dart';
import 'package:groceryui/models/trip.dart';
import 'package:http/http.dart' as http;

import '../constants.dart';


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

class RecieptItem{

  final DateTime date;
  final DateTime visit;
  final String addr;
  final int id;
  List<Purchase>? purchases;
  int count;
  int total;

  RecieptItem(
      {
        required this.id,
        required this.date,
        required this.addr,
        this.purchases,
        this.count = 0,
        this.total = 0,
        required this.visit,
      });

  factory RecieptItem.fromJson(Map<String, dynamic> json) {

    var list = json["items"] != null ? json["items"] as List : <Purchase>[];
    var x = list.map((i) => Purchase.fromJson(i)).toList();
    return RecieptItem(
      id: json['id'],
      date: DateTime.parse(json['date']),
      visit: DateTime.parse(json['visit']),
      addr: json['addr'],
      count: json['count']??0,
      total: json['total']??0,
      purchases: x,
    );
  }

  static Future<List<RecieptItem>> readJson() {
    return rootBundle.loadString('assets/models/recipts.json').then(
        (String response) {
          final data = json.decode(response) as List;
          final items = data.map((i) => RecieptItem.fromJson(i)).toList();
          return items;
        }
    );
  }

  static Future<RecieptItem?> readOneJson() async {
    var js = await readJson();
    return js.length > 0 ? js[0] : null;

  }

  static Future<List<RecieptItem>> getSummary(String token) {
    return http.get(
        Uri.parse('$ExposerURL/summary'),
        headers: {"cookie": "X-Session-Token=$token"}
    ).then(
        (http.Response response) {
          if (response.statusCode == 200) {
            var list = json.decode(response.body) as List;
            var x = list.map((i) => RecieptItem.fromJson(i)).toList();
            return x;
          }
          return Future.error("unable to load");
        }
    );
  }

  static Future<RecieptItem?> getReciept(String token, int id) {
    return http.get(
        Uri.parse('$ExposerURL/recipt?tid=$id'),
        headers: {"cookie": "X-Session-Token=$token"},
    ).then(
        (http.Response response) {
          print(response.body);
          if (response.statusCode == 200) {
            var item = json.decode(response.body);
            return RecieptItem.fromJson(item);
          }
          return Future.error("unable to load");
        },
    );
  }

  @override
  String toString() {
    return json.encode(this);
  }
}