import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:groceryui/models/reciptItem.dart';
import 'package:groceryui/models/trip.dart';
import 'package:groceryui/pages/product.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';

import '../constants.dart';

class SingleReceipt extends StatefulWidget {
  final String token;
  final int id;

  const SingleReceipt({Key? key, required this.token, required this.id})
      : super(key: key);

  @override
  State<SingleReceipt> createState() => _SingleReceiptState();
}

class _SingleReceiptState extends State<SingleReceipt> {

  late Future<RecieptItem?> _value;

  Future<RecieptItem?> loadPage(bool disabled) {
    if (disabled) {
      return RecieptItem.readOneJson();
    }
    return RecieptItem.getReciept(widget.token, widget.id);
  }

  @override
  void initState(){
    super.initState();
    _value = loadPage(DisableHTTP);
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<RecieptItem?>(
      future: _value,
      builder: (context, snapshot) {
        var receipt = snapshot.data;
        if (snapshot.hasError || (snapshot.data == null && snapshot.hasData)) {
          print(snapshot.error);
          return Scaffold(
            appBar: AppBar(),
            body: const Center(child:Text("Failed to load. Try again")),
          );
        }
        if (!snapshot.hasData) {
            return Scaffold(
              appBar: AppBar(),
              body: const Center(child:CircularProgressIndicator()),
            );
        }

        return Scaffold(
          appBar: AppBar(
            title: Row(
              children: [
                Column(
                    children: [
                      Padding(
                        padding: const EdgeInsets.only(bottom: 6.0),
                        child: Text("${DateFormat('MM/dd/yy HH:mm').format(
                            receipt!.visit)}"),
                      ),
                      Text("${receipt!.addr}", style: const TextStyle(
                        fontSize: 10,
                      ),)
                    ]),
                Spacer(),
                Padding(
                  padding: const EdgeInsets.only(top: 8.0),
                  child: CircleAvatar(
                    radius: 31,
                    backgroundColor: secondary,
                    child: CircleAvatar(
                      radius: 29,
                      foregroundImage: AssetImage(
                        receipt.iconPath,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          body: SafeArea(
            child: Column(
              children: [
                Expanded(
                  child: ListView.builder(
                    itemCount: receipt.purchases?.length ?? 0,
                    itemBuilder: (context, item) {
                      final product = receipt!.purchases?[item];
                      return InkWell(
                        onTap: () {
                          Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (context) =>
                                      Product(token: "", id: 0)));
                        },
                        child: ListTile(
                          leading: Padding(
                            padding: EdgeInsets.only(right: 15),
                            child: CircleAvatar(
                              radius: 31,
                              backgroundColor: secondary,
                              child: CircleAvatar(
                                radius: 30,
                                backgroundColor: Colors.white,
                                foregroundImage:
                                AssetImage("assets/images/products/pear.jpeg"),
                              ),
                            ),
                          ),
                          subtitle: Text(product!.name),
                          trailing: Text(
                              (product.price / 100).toStringAsFixed(2)),
                        ),
                      );
                    },
                  ),
                )
              ],
            ),
          ),
        );
      }
    );
  }
}
