import 'dart:convert';

import 'package:flutter/services.dart';

class CategoryItem{

  final String name;
  final String iconPath;
  final int id;

  CategoryItem({required this.name, required this.iconPath, required this.id});

  factory CategoryItem.fromJson(Map<String, dynamic> json) {
    return CategoryItem(
      name: json['name'],
      id: json['id'],
      iconPath: json['icon'],
    );
  }

  static Future<List<CategoryItem>> readJson() async {
    final String response = await rootBundle.loadString('assets/models/categories.json');
    final data = await json.decode(response) as List;
    final categories = data.map((i) => CategoryItem.fromJson(i)).toList();
    return categories;
  }
}