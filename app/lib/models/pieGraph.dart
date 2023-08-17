import 'dart:convert';
import 'dart:core';

import 'package:flutter/services.dart';
import 'package:groceryui/models/purchaseItem.dart';
import 'package:http/http.dart' as http;

import '../constants.dart';

class PieGraphModel{

  final String x;
  final int y;

  PieGraphModel(
      {
        required this.x,
        required this.y,
      });

  factory PieGraphModel.fromJson(Map<String, dynamic> json) {

    return PieGraphModel(
      x: json['x'],
      y: json['y'],
    );
  }

  static Future<List<PieGraphModel>> readJson() {
    return rootBundle.loadString('assets/models/graph_pie.json').then(
            (String response) {
          final data = json.decode(response) as List;
          final items = data.map((i) => PieGraphModel.fromJson(i)).toList();
          return items;
        }
    );
  }

  static Future<List<PieGraphModel>> fromWeb(String token) {
    return http.get(
        Uri.parse('$ExposerURL/home'),
        headers: {"cookie": "X-Session-Token=$token"}
    ).then(
            (http.Response response) {
          if (response.statusCode == 200) {
            var list = json.decode(response.body) as List;
            var x = list.map((i) => PieGraphModel.fromJson(i)).toList();
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
