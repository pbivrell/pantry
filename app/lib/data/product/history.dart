import 'dart:convert';
import 'dart:core';

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../constants.dart';
import '../../containers/Loader.dart';

class History implements Jsonable<History> {
  final String addr;
  final int price;
  final String iconPath;
  final DateTime? date;

  History.empty(
      {this.addr = "", this.price = 0, this.iconPath = "", this.date});

  History({
    required this.price,
    required this.iconPath,
    required this.addr,
    required this.date,
  });

  History fromJson(Map<String, dynamic> json) {
    return History(
        price: json["price"],
        iconPath: json["iconPath"],
        addr: json["addr"],
        date: DateTime.parse(json["date"]));
  }

  @override
  String toString() {
    return json.encode(this);
  }

  @override
  String get jsonPath => "assets/models/product_history.json";

  @override
  String get route => "";

  @override
  Widget build(dynamic item) {
    item = item as List<History>;
    return Expanded(
      child: ListView.builder(
          itemCount: item.length,
          scrollDirection: Axis.vertical,
          itemBuilder: (context, idx) {
            return ListTile(
              leading: CircleAvatar(
                radius: 21,
                backgroundColor: secondary,
                child: CircleAvatar(
                  radius: 20,
                  foregroundImage: AssetImage(
                    item[idx].iconPath,
                  ),
                ),
              ),
              title: Text(
                  "${item[idx].addr} - ${DateFormat('MM/dd/yy').format(item[idx].date ?? DateTime.now())}"),
              trailing: Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: primary!),
                ),
                padding: EdgeInsets.all(5),
                child: Text(
                  "\$${item[idx].price / 100}",
                  textAlign: TextAlign.center,
                  style: TextStyle(color: inPrimaryText),
                ),
              ),
            );
          }),
    );
  }
}
