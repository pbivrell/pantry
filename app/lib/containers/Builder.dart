import 'package:flutter/material.dart';
import 'package:groceryui/containers/Loader.dart';
import 'package:groceryui/pages/product.dart';
import 'package:intl/intl.dart';

import '../constants.dart';
import '../data/home/interests.dart';
import '../data/product/history.dart';
import '../models/purchaseItem.dart';

class ListBuilder extends StatefulWidget {
  final String token;
  final Loader loader;

  const ListBuilder({Key? key, required this.token, required this.loader}) : super(key: key);

  @override
  _ListBuilderState createState() => _ListBuilderState();
}

class _ListBuilderState extends State<ListBuilder> {

  late Future<dynamic> _value;

  Future<dynamic> loadPage() {

    if (DisableHTTP) {
      return widget.loader.readJson();
    }
    return widget.loader.getHome(widget.token);
  }

  @override
  void initState() {
    super.initState();
    _value = loadPage();
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<dynamic>(
        future: _value,
        builder: (context, snapshot) {
          if (snapshot.hasError ||
              (snapshot.data == null && snapshot.hasData)) {
            print(snapshot.error);
            return const Center(child: Text("Failed to load. Try again"));
          }
          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.requireData is List) {
            return snapshot.requireData[0].build(snapshot.requireData);
          } else {
            return (snapshot.requireData as Jsonable).build(snapshot.requireData);
          }
        });
  }

  Widget buildItem(List<History> item) {
    return Expanded(
      child: ListView.builder(
          itemCount: item.length,
          scrollDirection: Axis.vertical,
          itemBuilder: (context, idx) {
            return ListTile(
              leading: CircleAvatar(
                radius: 21,
                backgroundColor: secondary,
                child: CircleAvatar(
                  radius: 20,
                  foregroundImage: AssetImage(
                    item[idx].iconPath,
                  ),
                ),
              ),
              title: Text(
                  "${item[idx].addr} - ${DateFormat('MM/dd/yy').format(item[idx].date ?? DateTime.now())}" ),
              trailing: Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: primary!),
                ),
                padding: EdgeInsets.all(5),
                child: Text(
                  "\$${item[idx].price/100}",
                  textAlign: TextAlign.center,
                  style: TextStyle(color: inPrimaryText),
                ),
              ),
            );
          }),
    );

  }
}
