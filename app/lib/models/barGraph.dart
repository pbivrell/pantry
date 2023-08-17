import 'dart:convert';
import 'dart:core';

import 'package:flutter/services.dart';
import 'package:groceryui/models/purchaseItem.dart';
import 'package:http/http.dart' as http;

import '../constants.dart';

class BarGraphModel{

  final String x;
  final int y;

  BarGraphModel(
      {
        required this.x,
        required this.y,
      });

  factory BarGraphModel.fromJson(Map<String, dynamic> json) {

    return BarGraphModel(
      x: json['x'],
      y: json['y'],
    );
  }

  static Future<List<BarGraphModel>> readJson() {
    return rootBundle.loadString('assets/models/graph_bar.json').then(
            (String response) {
          final data = json.decode(response) as List;
          final items = data.map((i) => BarGraphModel.fromJson(i)).toList();
          return items;
        }
    );
  }

  static Future<List<BarGraphModel>> fromWeb(String token) {
    return http.get(
        Uri.parse('$ExposerURL/home'),
        headers: {"cookie": "X-Session-Token=$token"}
    ).then(
            (http.Response response) {
          if (response.statusCode == 200) {
            var list = json.decode(response.body) as List;
            var x = list.map((i) => BarGraphModel.fromJson(i)).toList();
            return x;
          }
          return Future.error("unable to load");
        }
    );
  }

  @override
  String toString() {
    return json.encode(this);
  }
}
