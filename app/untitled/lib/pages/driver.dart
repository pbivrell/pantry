import 'package:easy_search_bar/easy_search_bar.dart';
import 'package:flutter/material.dart';
import 'package:isar/isar.dart';
import 'package:untitled/componets/IngredientSelector.dart';
import 'package:untitled/componets/SearchList.dart';
import 'package:untitled/pages/NewMealPage.dart';
import 'package:untitled/pages/ProductPage.dart';
import 'package:untitled/pages/ReceiptPage.dart';

import 'package:untitled/pages/SearchPage.dart';
import '../componets/AbsSearchList.dart';
import '../componets/DB.dart';
import '../componets/ProductTile.dart';
import '../models/meal.dart';
import '../models/product.dart';
import 'MealPage.dart';

class DriverPage extends StatelessWidget {
  const DriverPage({super.key});

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 3,
      child: Scaffold(
        appBar: AppBar(
          bottom: const TabBar(
            tabs: [
              Tab(icon: Icon(Icons.apple)),
              Tab(icon: Icon(Icons.fastfood_sharp)),
              Tab(icon: Icon(Icons.shopping_cart)),
            ],
          ),
          title: const Text('Inventory'),
        ),
        body: TabBarView(
          children: [
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 8),
              child: AbsSearchList<Product>(checkable: true, deletable: true, ghostItem: true, searchable: true, loadFunc: Product.Load,),
            ),
            Column(children: [
              Expanded(
                child: AbsSearchList<Meal>(addable: true, addFunc: (){
                  return Navigator.push(
                    context,
                    MaterialPageRoute(
                    builder: (context) =>
                      const NewMealPage()));
                  },
                  loadFunc: Meal.Load,
                ),


  /*Scaffold(
                  body: ListView.builder(
                    itemCount: 2,
                    padding: EdgeInsets.all(12),
                    itemBuilder: (context, item) {
                      return Padding(
                        padding: const EdgeInsets.all(12.0),
                        child: Container(
                            decoration: BoxDecoration(
                              color: Colors.grey[200],
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: item == 1
                            ? ListTile(
                                title: Text(
                                  "+",
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                      fontSize: 30,
                                      fontWeight: FontWeight.bold),
                                ),
                                onTap: () {
                              )
                            : ListTile(
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
                                title: Text("Pizza"),
                                subtitle: Text("9/13/2022"),
                              )
                        ),
                      );
                    },
                  ),
                ),*/
              ),
            ]),
            Column(
              children: [
                IngredientSelector(store: true),
              ],
            )
          ],
        ),
      ),
    );
  }
}
