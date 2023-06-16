import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:groceryui/models/cartItem.dart';
import 'package:groceryui/models/categoryItem.dart';
import 'dart:convert';

import '../constants.dart';

class FoodPage extends StatefulWidget {
  const FoodPage({Key? key}) : super(key: key);

  @override
  State<FoodPage> createState() => _FoodPageState();
}

class _FoodPageState extends State<FoodPage> {
  late List<CategoryItem> categories = <CategoryItem>[];
  late List<CartItem> products = <CartItem>[];

  @override
  void initState() {
    super.initState();
    loadCategories();
    loadProducts("");
  }

  void loadCategories() async {
    var loadedCategories = await CategoryItem.readJson();
    setState(() {
      categories = loadedCategories;
    });
  }

  void loadProducts(String term) async {
    var loadedProducts = await CartItem.readJson();
    setState(() {
      products = loadedProducts;
    });
  }

  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(height: 50),
        search(),
        Padding(
          padding: const EdgeInsets.only(right: 8, bottom: 4),
          child: Container(
            alignment: Alignment.centerRight,
            child: Text(
              "see all",
              style: TextStyle(
                  fontSize: 15,
                  color: secondary,
                  decoration: TextDecoration.underline),
            ),
          ),
        ),
        sort(),
        Padding(
          padding: EdgeInsets.only(top: 20, left: 10),
          child: Text(
            "products",
            style: TextStyle(
                fontSize: 20, fontWeight: FontWeight.bold, color: secondary),
          ),
        ),
        Expanded(child: productGrid()),
      ],
    );
  }

  Widget productGrid() {
    return GridView.builder(
      itemCount: products.length,
      shrinkWrap: true,
      scrollDirection: Axis.vertical,
      padding: const EdgeInsets.all(16),
      itemBuilder: (context, item) {
        final product = products[item];
        return Stack(
          children: [
            Container(
              child: Container(
                width: 100,
                height: 110,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(17),
                  border: Border.all(color: secondary),
                  image: DecorationImage(fit: BoxFit.cover, image: AssetImage(product.iconPath)),
                ),
              ),
              width: 120,
              height: 130,
            ),
            Positioned(
              top: 1,
              left: 0,
              child: SizedBox(
                height: 25,
                child: Icon(
                  Icons.add,
                  color: secondary,
                ),
              ),
            ),
            Positioned(
              bottom: 0,
              left: 1,
              child: SizedBox(
                height: 30,
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: primary!),
                  ),
                  padding: EdgeInsets.all(5),
                  child: Text(
                    "\$${product.price}",
                    textAlign: TextAlign.center,
                    style: TextStyle(color: inPrimaryText),
                  ),
                ),
              ),
            ),
          ],
        );
      },
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        mainAxisSpacing: 8,
        crossAxisSpacing: 8,
        mainAxisExtent: 130,
      ),
    );
  }

  Widget sort() {
    return Padding(
      //padding: const EdgeInsets.only(left: 70),
      padding: const EdgeInsets.only(),
      child: Container(
        /*decoration: BoxDecoration(
          color: primary,
          /*borderRadius: BorderRadius.horizontal(
            left: Radius.circular(26),
            right: Radius.circular(26),
          ),*/
          border: Border.all(
            color: secondary,
          ),
          //boxShadow: [BoxShadow( color: Colors.purpleAccent.withOpacity(0.5), spreadRadius: 5, offset: const Offset(0,3), blurRadius: 2), ],
        ),*/
        height: 100,
        child: ListView.builder(
            itemCount: categories.length,
            scrollDirection: Axis.horizontal,
            itemBuilder: (context, item) {
              return Padding(
                padding: const EdgeInsets.only(top: 10, left: 5),
                child: Container(
                  padding: EdgeInsets.symmetric(horizontal: 10),
                  child: Column(
                    children: [
                      CircleAvatar(
                        radius: 31,
                        child: CircleAvatar(
                          radius: 30,
                          backgroundColor: Colors.white,
                          child: SizedBox(
                            height: 38,
                            width: 80,
                            child: ClipOval(
                                child: Image.asset(categories[item].iconPath)),
                          ),
                        ),
                      ),
                      SizedBox(height: 5),
                      Text(
                        categories[item].name,
                        style: TextStyle(
                          fontSize: 12,
                          color: secondary,
                        ),
                      ),
                    ],
                  ),
                ),
              );
            }),
      ),
    );
  }

  Widget search() {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 10),
      child: Container(
        margin: EdgeInsets.symmetric(vertical: 20),
        decoration: BoxDecoration(
            color: Colors.white,
            border: Border.all(color: secondary),
            borderRadius: BorderRadius.circular(160)),
        child: TextField(
          decoration: InputDecoration(
            border: InputBorder.none,
            prefixIcon: Icon(Icons.search, color: secondary),
            hintText: 'search products',
            hintStyle: TextStyle(color: inPrimaryText),
          ),
          style: TextStyle(
            color: secondary,
          ),
        ),
      ),
    );
  }
}
