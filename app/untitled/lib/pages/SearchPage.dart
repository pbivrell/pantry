import 'dart:async';
import 'dart:convert';
import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:untitled/consts.dart';

import '../componets/ProductTile.dart';
import '../models/product.dart';

const url = apiURL;

class SearchPage extends StatefulWidget {
  final void Function(Set<Product>) gatherSelected;

  const SearchPage({
    Key? key,
    required this.gatherSelected,
  }) : super(key: key);

  @override
  State<SearchPage> createState() => _SearchPageState(gatherSelected);
}

class _SearchPageState extends State<SearchPage> {
  final StreamController<List<Product>> productStream =
      StreamController<List<Product>>();
  Set<Product> selectedIngredients = <Product>{};
  var searchTerm = "";

  Function gatherSelected;

  _SearchPageState(this.gatherSelected);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: const BackButton(
          color: Colors.black,
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
      floatingActionButton: selectedIngredients.isEmpty
          ? null
          : FloatingActionButton(
              child: Text("+",
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 25,
                  )),
              onPressed: () {
                gatherSelected(selectedIngredients);
                Navigator.of(context).pop();
              },
            ),
      body: Container(
        child: Column(
          children: [
            Row(
              children: [
                Expanded(
                  child: Padding(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                    child: Container(
                      padding:
                          EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(8),
                        color: Colors.grey[200],
                      ),
                      child: Row(
                        children: [
                          Padding(
                            padding: const EdgeInsets.only(left: 5, right: 10),
                            child: Icon(Icons.search, size: 25),
                          ),
                          Expanded(
                            child: TextFormField(
                              decoration: InputDecoration(
                                hintText: 'Search',
                              ),
                              onChanged: (value) {
                                print(selectedIngredients);
                                setState(() {
                                  searchTerm = value;
                                });
                                loadProducts(value);
                              },
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                Padding(
                  padding: EdgeInsets.only(right: 10),
                  child: Container(
                    padding: EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                    decoration: BoxDecoration(
                      color: Colors.blue[200],
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Icon(
                      Icons.filter_list,
                      size: 25,
                    ),
                  ),
                ),
              ],
            ),
            Expanded(
              child: StreamBuilder<List<Product>>(
                  stream: productStream.stream,
                  builder: (context, snapshot) {
                    if (snapshot.hasData) {
                      final dataLen = snapshot.data?.length;
                      final hasTerm = (searchTerm == "" ||  dataLen == 1 && snapshot.data![0].name == searchTerm) ? 0 : 1;
                      return ListView.builder(
                          itemCount: dataLen != null ? dataLen + hasTerm : hasTerm,
                          padding: EdgeInsets.all(12),
                          itemBuilder: (context, item) {
                            final product = (item == dataLen)
                                ? Product.localOnly(searchTerm)
                                : snapshot.data![item];
                            return Row(
                              children: [
                                Expanded(
                                  child: ProductTile(
                                      product: product,
                                  ),
                                ),
                                Checkbox(
                                  value: selectedIngredients
                                      .contains(product),
                                  onChanged: (value) {
                                    print(selectedIngredients);
                                    setState(() {
                                      var x = {...selectedIngredients};
                                      if (x.contains(product)) {
                                        x.remove(product);
                                      } else {
                                        x.add(product);
                                      }
                                      selectedIngredients = x;
                                      print("${x}");
                                    });
                                  },
                                ),
                              ],
                            );
                          });
                    } else if (snapshot.hasError) {
                      return Text('${snapshot.error}');
                    }
                    return const CircularProgressIndicator();
                  }),
            )
          ],
        ),
      ),
    );
  }

  @override
  void initState() {
    super.initState();
    searchTerm = "";
    loadProducts(searchTerm);
  }

  void loadProducts(term) async {
    final response = await http.get(
        Uri.parse('http://$url/api/products/search/$term'),
        headers: {"cookie": "X-Session-Token=alwaysvalid"}).catchError((err) {
      print(err);
    });

    if (response.statusCode == 200) {
      var list = json.decode(response.body) as List;

      var x = list.map((i) => Product.fromJson(i)).toList();
      productStream.add(x);
    } else {
      print("status: $response.statusCode");
    }
  }
}
