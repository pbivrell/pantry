import 'package:flutter/material.dart';
import 'package:untitled/componets/IngredientSelector.dart';
import 'package:untitled/models/product.dart';

import 'dart:async';
import 'dart:convert';

import 'package:http/http.dart' as http;
import '../pages/SearchPage.dart';
import '../componets/ProductTile.dart';
import '../componets/SearchList.dart';
import 'ProductPage.dart';

class NewMealPage extends StatefulWidget {
  const NewMealPage({Key? key}) : super(key: key);

  @override
  State<NewMealPage> createState() => _NewMealPageState();
}

class _NewMealPageState extends State<NewMealPage> {
  String mealName = "";
  var selectedIngredients = <Product>{};

  final StreamController<List<Product>> productStream =
      StreamController<List<Product>>();

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: const BackButton(color: Colors.black),
      ),
      body: Column(
        children: [
          Row(
            children: [
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Icon(Icons.filter_9_plus_outlined, size: 90),
              ),
              Expanded(
                child: TextFormField(
                  decoration: InputDecoration(
                    hintText: 'Meal Name',
                  ),
                  onChanged: (value) {},
                ),
              ),
            ],
          ),
          Container(
            child: Text(
              "Ingredients",
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.left,
            ),
          ),
          IngredientSelector(),
          // Expanded(child: SearchList())
          //SearchList(),
          //SearchList2(),
        ],
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
      floatingActionButton: FloatingActionButton(
        onPressed: () => {},
        child: Container(
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Icon(Icons.save),
          ),
          padding: EdgeInsets.symmetric(horizontal: 10),
        ),
      ),
    );
  }
}
