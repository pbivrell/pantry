import 'dart:async';

import 'package:flutter/material.dart';
import 'package:isar/isar.dart';
import 'package:untitled/componets/AbsSearchList.dart';
import 'package:untitled/componets/WrappedListTile.dart';

import '../models/product.dart';
import '../pages/SearchPage.dart';
import '../componets/ProductTile.dart';
import '../componets/DB.dart';

class IngredientSelector extends StatefulWidget {
  final bool store;
  final String cartIndex;

  const IngredientSelector({
    Key? key,
    this.store = false,
    this.cartIndex = "default",
  }) : super(key: key);

  @override
  State<IngredientSelector> createState() => _IngredientSelectorState();
}

class _IngredientSelectorState extends State<IngredientSelector> {
  final Isar isar = DB().isar;

  var selectedIngredients = <Product>{};

  getIngredients() {
    if (widget.store) {
      isar.txnSync(() {
        var vals = isar.products.where().findAllSync();
        setState(() {
          selectedIngredients = {...vals};
        });
      });
    }
  }

  saveIngredients() {
    if (widget.store) {
      isar.writeTxnSync(() {
        isar.products.clearSync();
        isar.products.putAllSync(selectedIngredients.toList());
      });
    }
  }

  @override
  initState() {
    super.initState();
    getIngredients();
  }

  @override
  dispose() {
    saveIngredients();
    super.dispose();
  }

  Future<List<Product>> getProducts(String term) {
    print("Getting Product");
    var completer = Completer<List<Product>>();
    completer.complete(selectedIngredients.toList());
    return completer.future;
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
        onWillPop: () async {
          print("Poping");
          saveIngredients();
          return true;
        },
        child: Expanded(
          child: AbsSearchList<Product>(
            loadFunc: getProducts,
            addable: true,
            deletable: true,
            addFunc: () {
              return Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (context) => Scaffold(
                        appBar: AppBar(
                          backgroundColor: Colors.transparent,
                          elevation: 0,
                          leading: const BackButton(
                            color: Colors.black,
                          ),
                        ),
                        body: AbsSearchList<Product>(
                          loadFunc: Product.Load,
                          checkable: true,
                        ))),
              );
            },
          ),
        ));

    /* ListView.builder(
            itemCount: selectedIngredients.length + 1,
            padding: EdgeInsets.all(12),
            itemBuilder: (context, item) {
              return item == selectedIngredients.length
                  ? WrappedListTile(
                      listTile: ListTile(
                      title: Text(
                        "+",
                        textAlign: TextAlign.center,
                        style:
                            TextStyle(fontSize: 30, fontWeight: FontWeight.bold),
                      ),
                      onTap: () {
                        Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) =>
                                    SearchPage(gatherSelected: (val) {
                                      setState(() {
                                        selectedIngredients.addAll(val);
                                        selectedIngredients = selectedIngredients;
                                        //isar.carts.putByIndex(widget.cartIndex, Cart(selectedIngredients.toList()));
                                        //isar.carts.filter().
                                      });
                                    })));
                      },
                    ))
                  : Row(
                      children: [
                        Expanded(
                            child: ProductTile(
                                product: selectedIngredients.toList()[item])),
                        InkWell(
                          child: Icon(Icons.close),
                          onTap: () {
                            var deleteItem = selectedIngredients.toList()[item];
                            setState(() {
                              selectedIngredients.remove(deleteItem);
                            });
                          },
                        )
                      ],
                    );
            }),
      ),
    );*/
  }
}
