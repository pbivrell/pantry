import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:groceryui/constants.dart';
import 'package:groceryui/models/cartItem.dart';

class CartPage extends StatefulWidget {
  const CartPage({Key? key}) : super(key: key);

  @override
  State<CartPage> createState() => _CartPageState();
}

class _CartPageState extends State<CartPage> {
  List<CartItem> products = [];
  Set<int> selectedProducts = {};

  void initState() {
    super.initState();
    loadProducts("");
  }

  void loadProducts(String term) async {
    var loadedProducts = await CartItem.readJson();
    //print(loadedProducts);

    setState(() {
      products = loadedProducts;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Expanded(
          child: ListView.builder(
            itemCount: products.length,
            itemBuilder: (context, item) {
              final product = products[item];
              final unitLine = '${product.quantity ?? "" }${product.unit ?? ""}';
              final line = '${product.specific ?? product.name}';
              return CheckboxListTile(
                title: Row(
                  children: [
                    Padding(
                        padding: EdgeInsets.only(right: 15),
                        child: CircleAvatar(
                          radius: 31,
                          backgroundColor: secondary,
                          child: CircleAvatar(
                            radius: 30,
                            backgroundColor: Colors.white,
                            foregroundImage: AssetImage(product.iconPath),
                          ),
                        )),
                    Text(line),
                    Padding(
                      padding: const EdgeInsets.only(left: 4.0),
                      child: Icon(Icons.info_outline_rounded, size: 18),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(4.0),
                      child: Text(unitLine),
                    ),
                  ],
                ),
                onChanged: (bool? value) {
                  selectedProducts.contains(product.id)
                      ? selectedProducts.remove(product.id)
                      : selectedProducts.add(product.id);
                  setState(() {
                    selectedProducts = selectedProducts;
                  });
                },
                value: selectedProducts.contains(product.id),
              );
            },
          ),
        )
      ],
    );
  }
}
