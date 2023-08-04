import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:groceryui/constants.dart';
import 'package:groceryui/models/cartItem.dart';
import 'package:groceryui/pages/product.dart';
import 'package:groceryui/pages/search.dart';

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
    return Padding(
      padding: const EdgeInsets.only(top: 10.0),
      child: Column(
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
                          child: InkWell(
                            onTap: (){
                              Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                      builder: (context) =>
                                          Product(token: "", id: 0)));
                            },
                            child: CircleAvatar(
                              radius: 31,
                              backgroundColor: secondary,
                              child: CircleAvatar(
                                radius: 30,
                                backgroundColor: Colors.white,
                                foregroundImage: AssetImage(product.iconPath),
                              ),
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
          ),
          Padding(
            padding: const EdgeInsets.only(bottom: 8.0),
            child: Container(
                width: double.infinity,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(20),
                  color: Colors.white.withOpacity(0),
                  border: Border.all(color: primary!),
                ),
                child: TextButton(
                  child: Icon(Icons.search),
                  onPressed: () {
                    var output = Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) =>
                                SearchPage())
                    );
                    }
                )
            ),
          )
        ],
      ),
    );
  }
}
