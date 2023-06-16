import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:untitled/componets/MealTile.dart';
import 'package:untitled/consts.dart';

import '../models/meal.dart';
import '../models/product.dart';
import 'ProductTile.dart';
import 'WrappedListTile.dart';

typedef Responder = Future<List<dynamic>> Function(String);
typedef Adder = Future Function();

class AbsSearchList<K> extends StatefulWidget {
  final bool checkable;
  final bool deletable;
  final bool addable;
  final bool searchable;
  final bool ghostItem;
  final Adder? addFunc;
  final Responder? loadFunc;

  const AbsSearchList({
    Key? key,
    this.checkable = false,
    this.addable = false,
    this.searchable = false,
    this.ghostItem = false,
    this.deletable = false,
    this.addFunc,
    this.loadFunc,
  }) : super(key: key);

  @override
  State<AbsSearchList> createState() => _AbsSearchListState<K>();
}

class _AbsSearchListState<T> extends State<AbsSearchList> {
  final StreamController<List<dynamic>> productStream =
      StreamController<List<dynamic>>();
  var selectedIngredients = <dynamic>{};
  var searchTerm = "";

  @override
  void initState() {
    super.initState();
    searchTerm = "";
    if (widget.loadFunc != null) {
      load(searchTerm);
    }else {
      productStream.add(<T>[]);
    }
  }

  void replace(List<dynamic> x) {
    var res = <dynamic>{...x};
    res.addAll(selectedIngredients);
    productStream.add(res.toList());
  }

  void update(List<dynamic> x) {
    var res = <dynamic>{...x};
    res.addAll(selectedIngredients);
    productStream.add(res.toList());
  }

  void load(term) async {
    print("Loading");
    final loadFunc = widget.loadFunc;
    if (loadFunc != null) {
      List<dynamic> x = await loadFunc(term);
      replace(x);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      child: Column(
        children: [
          if (widget.searchable) ...[
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
                                setState(() {
                                  searchTerm = value;
                                });
                                load(value);
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
          ],
          Expanded(
            child: StreamBuilder<List<dynamic>>(
                stream: productStream.stream,
                builder: (context, snapshot) {
                  if (snapshot.hasData) {
                    final dataLen = snapshot.data == null ? 0 : snapshot.data!.length;
                    final ghost = !(searchTerm == "" ||
                        (dataLen == 1 &&
                                snapshot.data![0].name == searchTerm) ) && widget.ghostItem;
                    final ghostIndex = ghost ? dataLen : dataLen + 10;
                    final addIndex = widget.addable ? ghost ? dataLen + 1 : dataLen : dataLen + 10;
                    final data = snapshot.requireData;
                    return ListView.builder(
                        itemCount: dataLen + ((ghost) ? 1 : 0) + ((widget.addable) ? 1 : 0),
                        padding: EdgeInsets.all(12),
                        itemBuilder: (context, item) {
                          final product = (item >= dataLen )
                              ? (T == Product ? Product.localOnly(searchTerm) : Meal.localOnly(searchTerm))
                              : snapshot.data![item];
                          return (item == addIndex) ? WrappedListTile(
                            listTile: ListTile(
                              title: const Text(
                                "+",
                                textAlign: TextAlign.center,
                                style:
                                TextStyle(fontSize: 30, fontWeight: FontWeight.bold),
                              ),
                              onTap: (){
                                widget.addFunc!().then((vals){
                                  List<dynamic> x = vals.toList() + data;
                                  update(x);
                                });

                                //load(searchTerm);
                              },
                            )
                          ): Row(
                            children: [
                              Expanded(
                                  child: (T == Product ? ProductTile(product: product,) : MealTile(meal: product,)),
                                  ),
                              if (widget.checkable) ...[
                                Checkbox(
                                  value: selectedIngredients.contains(product),
                                  onChanged: (value) {
                                    setState(() {
                                      selectedIngredients.contains(product)
                                          ? selectedIngredients.remove(product)
                                          : selectedIngredients.add(product);
                                    });
                                  },
                                ),
                              ],
                              if (widget.deletable) ...[
                                InkWell(
                                  child: Icon(Icons.close),
                                  onTap: () {
                                    setState(() {
                                      snapshot.data?.remove(product);
                                      //selectedIngredients.remove(product);
                                      //productStream.add(selectedIngredients.toList());
                                    });
                                  },
                                )
                              ]
                            ],
                          );
                        });
                  } else if (snapshot.hasError) {
                    return Text('${snapshot.error}');
                  }
                  return const CircularProgressIndicator();
                }),
          ),
          if (widget.checkable && selectedIngredients.isNotEmpty) ...[
            FloatingActionButton(onPressed: (){
              Navigator.pop(context, selectedIngredients);
            }, child: Icon(Icons.save),)
          ]
        ],
      ),
    );
  }
}
