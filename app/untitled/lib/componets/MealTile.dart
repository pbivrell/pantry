import 'package:flutter/material.dart';
import 'package:untitled/componets/WrappedListTile.dart';

import '../models/meal.dart';
import '../models/product.dart';
import '../pages/MealPage.dart';
import '../pages/ProductPage.dart';

class MealTile extends StatelessWidget {
  final Meal meal;

  const MealTile({
    Key? key,
    required this.meal,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return WrappedListTile(
      listTile:  ListTile(
        onTap: () {
          Navigator.push(
              context,
              MaterialPageRoute(
                  builder: (context) =>
                  const MealPage()));
        },
        leading: Icon(
          Icons.local_pizza,
          size: 40,
        ),
        title: Text(meal.name),
        subtitle: Text("${meal.date.month}/${meal.date.day}/${meal.date.year}"),
      )
    );
  }
}
