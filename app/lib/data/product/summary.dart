import 'dart:convert';
import 'dart:core';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:groceryui/containers/Loader.dart';
import 'package:groceryui/models/purchaseItem.dart';
import 'package:http/http.dart' as http;

import '../../constants.dart';

class StoreLink {

  final int id;
  final String iconPath;

  StoreLink(
  {
    required this.id,
    required this.iconPath,
  });

  factory StoreLink.fromJson(Map<String, dynamic> json) {

    return StoreLink(
      id: json['id'],
      iconPath: json['iconPath'],
    );
  }
}

class Summary implements Jsonable<Summary> {

  final String name;
  final int price;
  final String iconPath;
  final Map<String, dynamic>? stats;
  final List<StoreLink>? stores;

  Summary(
      {
        required this.name,
        required this.price,
        required this.iconPath,
        required this.stats,
        required this.stores,

      });

  Summary.empty({this.name = "", this.iconPath = "", this.price = 0, this.stats, this.stores});

  Summary fromJson(Map<String, dynamic> json) {

    var list = json["stores"] != null ? json["stores"] as List : <StoreLink>[];
    var x = list.map((i) => StoreLink.fromJson(i)).toList();
    return Summary(
      name: json['name'],
      price: json['price'],
      iconPath: json['iconPath'],
      stats: json['stats'],
      stores: x,
    );
  }

  @override
  String get jsonPath => "assets/models/product_summary.json";

  @override
  String get route => "";

  @override
  Widget build(dynamic item) {
    item = item as Summary;
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 18.0, right: 10),
          child: Container(
            width: 150,
            height: 200,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(17),
              border: Border.all(color: secondary),
              image: DecorationImage(
                fit: BoxFit.cover,
                image: AssetImage(item.iconPath),
              ),
            ),
          ),
        ),
        Flexible(
          fit: FlexFit.tight,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.only(bottom: 12.0),
                child: Text(
                  item.name,
                  style: TextStyle(
                    fontSize: 30,
                    color: secondary,
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(bottom: 8.0),
                child: Text("Stores",
                    style:
                    TextStyle(fontWeight: FontWeight.bold, color: primary)),
              ),
              SizedBox(
                height: 30,
                child: ListView.builder(
                    itemCount: item.stores?.length,
                    scrollDirection: Axis.horizontal,
                    itemBuilder: (ctx, idx) {
                      return Padding(
                        padding: const EdgeInsets.only(right: 8.0),
                        child: CircleAvatar(
                          foregroundImage: AssetImage(
                            item.stores[idx].iconPath,
                          ),
                        ),
                      );
                    }),
              ),
              Padding(
                padding: const EdgeInsets.only(bottom: 8.0, top: 16),
                child: Text("Stats",
                    style:
                    TextStyle(fontWeight: FontWeight.bold, color: primary)),
              ),
              SizedBox(
                height: 50,
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  itemCount: item.stats?.length,
                  itemBuilder: (BuildContext context, int index) {
                    var key = item.stats.keys.toList()[index];
                    var value = item.stats.values.toList()[index];
                    return Padding(
                      padding: const EdgeInsets.only(right: 20),
                      child: Column(
                        children: [
                          Text(
                            key,
                            style: TextStyle(color: Colors.grey),
                          ),
                          Padding(
                            padding: const EdgeInsets.only(top: 8.0),
                            child: Text(value.toString()),
                          ),
                        ],
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        )
      ],
    );
  }

  @override
  String toString() {
    return json.encode(this);
  }
}