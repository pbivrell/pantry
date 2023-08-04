import 'dart:convert';

import 'package:flutter/services.dart';

class Trip{

  final int id;
  final DateTime date;
  final DateTime visit;
  final String addr;
  final int total;
  final int count;

  Trip(
      {
        required this.id,
        required this.date,
        required this.addr,
        required this.total,
        required this.count,
        required this.visit,
      });

  factory Trip.fromJson(Map<String, dynamic> json) {
    return Trip(
      date: DateTime.parse(json['date']),
      visit: DateTime.parse(json['visit']),
      addr: json['addr'],
      total: json['total']??0,
      count: json['count']??0,
      id: json['id'],
    );
  }

  static Future<List<Trip>> readJson() async {
    final String response = await rootBundle.loadString('assets/models/trip.json');
    final data = await json.decode(response) as List;
    final items = data.map((i) => Trip.fromJson(i)).toList();
    return items;
  }

  @override
  String toString() {
    return json.encode(this);
  }

  static fromNet(String? token) {}
}