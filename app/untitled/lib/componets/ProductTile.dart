import 'package:flutter/material.dart';
import 'package:untitled/componets/WrappedListTile.dart';

import '../models/product.dart';
import '../pages/ProductPage.dart';

class ProductTile extends StatelessWidget {
  final Product product;

  const ProductTile({
    Key? key,
    required this.product,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return WrappedListTile(
      listTile: ListTile(
        onTap: () {
          Navigator.push(context,
              MaterialPageRoute(builder: (context) => ProductPage(product: product)));
        },
        leading: Icon(
          Icons.apple,
          size: 40,
        ),
        title: Text(product.name),
        trailing: SizedBox(
          width: 110,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: <Widget>[
              if (product.inPantry) ...[
                Padding(
                  padding: EdgeInsets.only(right: 15),
                  child: Icon(
                    Icons.home,
                    size: 15,
                  ),
                ),
              ],
              if (!product.localOnly) ...[
              Container(
                padding: const EdgeInsets.all(3.0),
                decoration: BoxDecoration(
                  color: Colors.green[200],
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  product.priceText,
                  style: TextStyle(
                    fontSize: 12,
                  ),
                ),
              )
              ],
            ],
          ),
        ),
      ),
    );
  }
}
