import 'package:flutter/material.dart';

import '../models/product.dart';

class ProductPage extends StatelessWidget {
  final Product product;

  const ProductPage({
    Key? key,
    required this.product,
  }) : super(key: key);

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
              Expanded(child: Icon(Icons.apple, size: 90)),
              Column(
                children: [
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: 40),
                    child: Text(
                      product.name,
                      style: TextStyle(
                        fontSize: 18,
                      ),
                    ),
                  ),
                  Row(
                    children: [
                      Padding(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 8.0, vertical: 4),
                        child: Container(
                          decoration: BoxDecoration(
                            color: Colors.blue[200],
                            borderRadius: BorderRadius.circular(2),
                          ),
                          child: const Text("Tag"),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 8.0, vertical: 4),
                        child: Container(
                          decoration: BoxDecoration(
                            color: Colors.blue[200],
                            borderRadius: BorderRadius.circular(2),
                          ),
                          child: const Text("Tag"),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 8.0, vertical: 4),
                        child: Container(
                          decoration: BoxDecoration(
                            color: Colors.blue[200],
                            borderRadius: BorderRadius.circular(2),
                          ),
                          child: const Text("Tag"),
                        ),
                      )
                    ],
                  ),
                ],
              ),
            ],
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              children: [
                Flexible(
                  child: Container(
                        child: ListTile(
                          title: Text("${product.priceText}", textAlign: TextAlign.center,),
                          subtitle: Text("Avg Price", textAlign: TextAlign.center,),
                        ),
                      ),
                    ),
                    Flexible(
                      child: Container(
                        child: ListTile(
                          title: Text("14",textAlign: TextAlign.center),
                          subtitle: Text("Purchases",textAlign: TextAlign.center),
                        ),
                      ),
                    ),
                    Flexible(
                      child: Container(
                        child: ListTile(
                          title: Text("4/3/2023",textAlign: TextAlign.center),
                          subtitle: Text("Last Purchased",textAlign: TextAlign.center),
                        ),
                      ),
                ),
              ],
            ),
          ),
          Container(
            child: Text(
                "Purchase History",
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.left,
            ),
          ),
          Expanded(
            child: ListView.builder(
              itemCount: 9,
              padding: EdgeInsets.all(12),
              itemBuilder: (context, item) {
                return Padding(
                  padding: EdgeInsets.all(12),
                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.grey[200],
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: ListTile(
                      onTap: () {
                      },
                      leading: Text("2/3/2023"),
                      title: Text("Store"),
                      subtitle: Text("757 Owl Ct Louisville CO"),
                      trailing: Text("\$5.83"),
                    ),
                  )
                );
              }
            ),
          ),
        ],
      ),
    );
  }
}
