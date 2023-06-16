import 'dart:convert';

import 'package:isar/isar.dart';
import 'package:untitled/consts.dart';
import 'package:http/http.dart' as http;

import '../componets/AbsSearchList.dart';

class Meal {
  final int backID;
  final String name;
  final String icon;
  final DateTime date;
  final bool localOnly;

  Meal({
    required this.backID,
    required this.name,
    required this.icon,
    required this.date,
    this.localOnly = false
  });

  factory Meal.fromJson(Map<String, dynamic> json) {
    return Meal(
      backID: json['id'],
      name: json['name'],
      icon: json['icon'],
      date: DateTime.parse(json['date']),
    );
  }

  Meal.localOnly(this.name)
      :
        backID = -1,
        icon = "",
        date = DateTime.now(),
        localOnly = true;

  @override
  bool operator ==(o) => o is Meal && backID == o.backID;

  @override
  int get hashCode => backID;

  @override
  String toString() {
    return name;
  }

  static Future<List<Meal>> Load(String term) {
    final uri = 'http://$apiURL/api/meals/';

    return http.get(Uri.parse(uri),
        headers: {"cookie": "X-Session-Token=alwaysvalid"}).then((response) {
          if (response.statusCode == 200) {
            var list = json.decode(response.body) as List;
            List<Meal> x = list.map((i) => Meal.fromJson(i)).toList();
            return x;
          }
          throw Exception("$response");
    });
  }
}