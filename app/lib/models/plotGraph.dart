import 'dart:convert';
import 'dart:core';

import 'package:flutter/services.dart';
import 'package:groceryui/models/purchaseItem.dart';
import 'package:http/http.dart' as http;

import '../constants.dart';

class PlotGraphModel{

  final DateTime x;
  final int y;
  final int z;

  PlotGraphModel(
      {
        required this.x,
        required this.y,
        required this.z,
      });

  factory PlotGraphModel.fromJson(Map<String, dynamic> json) {

    return PlotGraphModel(
      x: DateTime.parse(json['x']),
      y: json['y'],
      z: json['z'],
    );
  }

  static Future<List<PlotGraphModel>> readJson() {
    return rootBundle.loadString('assets/models/graph_plot.json').then(
            (String response) {
          final data = json.decode(response) as List;
          final items = data.map((i) => PlotGraphModel.fromJson(i)).toList();
          print("Test");
          print(items);
          return items;
        }
    );
  }

  static Future<List<PlotGraphModel>> fromWeb(String token) {
    return http.get(
        Uri.parse('$ExposerURL/home'),
        headers: {"cookie": "X-Session-Token=$token"}
    ).then(
            (http.Response response) {
          if (response.statusCode == 200) {
            var list = json.decode(response.body) as List;
            var x = list.map((i) => PlotGraphModel.fromJson(i)).toList();
            return x;
          }
          return Future.error("unable to load");
        }
    );
  }

}
