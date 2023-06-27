import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:groceryui/models/reciptItem.dart';
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
  ReciptItem? recipt = null;
  var fetching = true;

  void loadPage() async {
    print("Atetmpting page load");
    final response = await http.get(
        Uri.parse('$ExposerURL/recipt?tid=${widget.id}'),
        headers: {"cookie": "X-Session-Token=${widget.token}"});

    setState(() {
      fetching = false;
    });
    print("Done");
    if (response.statusCode == 200) {
      var item = json.decode(response.body);
      print(item);

      setState(() {
        recipt = ReciptItem.fromJson(item);
      });
    } else {
      print("status: $response.statusCode");
    }
  }

  @override
  void initState(){
    super.initState();
    loadPage();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: [

            Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.only(bottom: 6.0),
                    child: Text("${DateFormat('MM/dd/yy HH:mm').format(recipt!.visit)}"),
                  ),
                  Text("${recipt!.addr}", style: const TextStyle(
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
                          "assets/images/stores/kingsoopers.png",
                        ),
                      ),
                    ),
                  ),
          ],
        ),
      ),
      body: SafeArea(
        child: fetching
            ? Center(child: CircularProgressIndicator())
            : recipt == null
            ? Center(child: Text("unable to load receipt"))
            :Column(
                children: [
                  Expanded(
                    child: ListView.builder(
                      itemCount: recipt?.purchases.length,
                      itemBuilder: (context, item) {
                        final product = recipt?.purchases[item];
                        return ListTile(
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
                          trailing: Text((product.price / 100).toStringAsFixed(2)),
                        );
                      },
                    ),
                  )
                ],
              ),
      ),
    );
  }
}
