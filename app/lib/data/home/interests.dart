import 'dart:convert';
import 'dart:core';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:groceryui/models/purchaseItem.dart';

import '../../constants.dart';
import '../../containers/Loader.dart';
import '../../pages/product.dart';

class Interest implements Jsonable<Interest> {

  final String title;
  List<Purchase>? purchases;

  Interest(
      {
        required this.title,
        this.purchases,
      });

  Interest.empty({this.title = ""});

  Interest fromJson(Map<String, dynamic> json) {

    var list = json["items"] != null ? json["items"] as List : <Purchase>[];
    var x = list.map((i) => Purchase.fromJson(i)).toList();
    return Interest(
      title: json['title']??"",
      purchases: x,
    );
  }

  @override
  String toString() {
    return json.encode(this);
  }


  @override
  String get jsonPath => "assets/models/homes.json";

  @override
  String get route => "";

  @override
  Widget build(items) {
    items = items as List<Interest>;
    return Column(
      children: [
        for(int i = 0; i < items.length; i++) Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: EdgeInsets.only(bottom: 20, left: 10, top: 20),
                child: Text(
                  "${items[i].title}",
                  style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: secondary),
                ),
              ),
              productGrid(items[i].purchases ?? []),
            ]),
      ],
    );
  }

  Widget productGrid(List<Purchase> purchases) {
    return SizedBox(
      height: 140,
      child: ListView.builder(
        itemCount: purchases.length,
        scrollDirection: Axis.horizontal,
        itemBuilder: (context, item) {
          final product = purchases[item];
          return Padding(
            padding: const EdgeInsets.only(left: 8.0),
            child: InkWell(
              onTap: () {
                Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => Product(id: 0, token: "")));
              },
              child: Container(
                width: 100,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(17),
                  border: Border.all(color: secondary),
                  image: DecorationImage(
                      fit: BoxFit.cover, image: AssetImage(product.icon)),
                ),
                child: Stack(
                  children: [
                    Positioned(
                      left: 0,
                      child: InkWell(
                        onTap: () {
                          print("Hey");
                        },
                        child: SizedBox(
                          height: 25,
                          child: Icon(
                            Icons.add,
                            color: secondary,
                          ),
                        ),
                      ),
                    ),
                    Positioned(
                      bottom: 1,
                      left: 0,
                      child: SizedBox(
                        height: 30,
                        child: Container(
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(color: primary!),
                          ),
                          padding: const EdgeInsets.all(5),
                          child: Text(
                            "\$${product.price / 100}",
                            textAlign: TextAlign.center,
                            style: TextStyle(color: inPrimaryText),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}