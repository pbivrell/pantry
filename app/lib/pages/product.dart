import 'package:flutter/material.dart';
import 'package:groceryui/data/product/history.dart';
import 'package:groceryui/data/product/summary.dart';

import '../constants.dart';
import '../containers/Builder.dart';
import '../containers/Loader.dart';
import '../data/product/plot.dart';

class Product extends StatelessWidget {
  final String token;
  final int id;

  const Product({Key? key, required this.token, required this.id})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(),
      body: SafeArea(
        child: SizedBox.expand(
          child: Padding(
            padding: const EdgeInsets.only(top: 18.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                ListBuilder(token: "", loader: SingleLoader<Summary>(inst: Summary.empty())),
                SizedBox(height: 200,
                  child: ListBuilder(token: "", loader: SingleLoader<Plot>(inst: Plot.empty())),
                ),
                Padding(
                  padding: const EdgeInsets.only(left: 12.0, top: 10, bottom: 10),
                  child: Text("purchase history", style: TextStyle(fontSize: 17, fontWeight: FontWeight.bold, color: secondary),  textAlign: TextAlign.start,),
                ),
                ListBuilder(token: "", loader: ListLoader<History>(inst: History.empty())),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
