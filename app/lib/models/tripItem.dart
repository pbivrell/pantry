import 'dart:convert';

import 'package:flutter/services.dart';

class ReciptItem{

  final int id;
  final DateTime date;
  final DateTime visit;
  final String addr;
  final int total;
  final int count;

  ReciptItem(
      {
        required this.id,
        required this.date,
        required this.addr,
        required this.total,
        required this.count,
        required this.visit,
      });

  factory ReciptItem.fromJson(Map<String, dynamic> json) {
    return ReciptItem(
      date: DateTime.parse(json['date']),
      visit: DateTime.parse(json['visit']),
      addr: json['addr'],
      total: json['total'],
      count: json['count'],
      id: json['id'],
    );
  }

  @override
  String toString() {
    return json.encode(this);
  }
}