import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:groceryui/models/productItem.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:syncfusion_flutter_charts/charts.dart';

import '../constants.dart';

class Product extends StatefulWidget {
  final String token;
  final int id;

  const Product({Key? key, required this.token, required this.id})
      : super(key: key);

  @override
  State<Product> createState() => _ProductState();
}

class _ProductState extends State<Product> {
  ProductItem? product;
  var fetching = true;

  List<_ChartData> data = [
    _ChartData('Mar', 12),
    _ChartData('Apr', 15),
    _ChartData('May', 30),
    _ChartData('Jun', 6.4),
    _ChartData('Jul', 14)
  ];

  void loadPage() async {
    /*final response = await http.get(
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
    setState((){
      product = ProductItem(

      );
    });*/
  }

  @override
  void initState() {
    super.initState();
    loadPage();
  }

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
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Padding(
                      padding: const EdgeInsets.only(left: 18.0, right: 10),
                      child: Container(
                        width: 150,
                        height: 200,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(17),
                          border: Border.all(color: secondary),
                          image: const DecorationImage(
                              fit: BoxFit.cover,
                              image: AssetImage(
                                  "assets/images/products/pear.jpeg")),
                        ),
                      ),
                    ),
                    Flexible(
                      fit: FlexFit.tight,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Padding(
                            padding: const EdgeInsets.only(bottom: 12.0),
                            child: Text(
                              "pear",
                              style: TextStyle(
                                fontSize: 30,
                                color: secondary,
                              ),
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.only(bottom: 8.0),
                            child: Text("Stores",
                                style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    color: primary)),
                          ),
                          SizedBox(
                            height: 30,
                            child: ListView.builder(
                                itemCount: 8,
                                scrollDirection: Axis.horizontal,
                                itemBuilder: (ctx, item) {
                                  return Padding(
                                    padding: const EdgeInsets.only(right: 8.0),
                                    child: CircleAvatar(
                                      foregroundImage: AssetImage(
                                        "assets/images/stores/kingsoopers.png",
                                      ),
                                    ),
                                  );
                                }),
                          ),
                          Padding(
                            padding:
                                const EdgeInsets.only(bottom: 8.0, top: 16),
                            child: Text("Stats",
                                style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    color: primary)),
                          ),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                            children: <Widget>[
                              Expanded(
                                child: Column(
                                  children: [
                                    Text(
                                      "Paid",
                                      style: TextStyle(color: Colors.grey),
                                    ),
                                    Padding(
                                      padding: const EdgeInsets.only(top: 8.0),
                                      child: Text("\$3.59"),
                                    ),
                                  ],
                                ),
                              ),
                              Expanded(
                                  child: Column(
                                children: [
                                  Text(
                                    "Bought",
                                    style: TextStyle(color: Colors.grey),
                                  ),
                                  Padding(
                                    padding: const EdgeInsets.only(top: 8.0),
                                    child: Text('7'),
                                  ),
                                ],
                              )),
                              Expanded(
                                child: Column(
                                  children: [
                                    Text(
                                      "Recent",
                                      style: TextStyle(color: Colors.grey),
                                    ),
                                    Padding(
                                      padding: const EdgeInsets.only(top: 8.0),
                                      child: Text('3/2/1997'),
                                    ),
                                  ],
                                ),
                              )
                            ],
                          ),
                        ],
                      ),
                    )
                  ],
                ),
                SizedBox(height: 200, child: graph3()),
                Padding(
                  padding: const EdgeInsets.only(left: 12.0, top: 10, bottom: 10),
                  child: Text("purchase history", style: TextStyle(fontSize: 17, fontWeight: FontWeight.bold, color: secondary),  textAlign: TextAlign.start,),
                ),
                  Expanded(
                    child: ListView.builder(
                      itemCount: 32,
                      scrollDirection: Axis.vertical,
                      itemBuilder: (context, item) {
                        return ListTile(
                          leading: CircleAvatar(
                            radius: 21,
                            backgroundColor: secondary,
                            child: CircleAvatar(
                              radius: 20,
                              foregroundImage: AssetImage(
                                "assets/images/stores/kingsoopers.png",
                              ),
                            ),
                          ),
                          title: Text(
                              "Boulder - 7/21/21"),
                          trailing: Container(
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(20),
                              border: Border.all(color: primary!),
                            ),
                            padding: EdgeInsets.all(5),
                            child: Text(
                              "\$5.31",
                              textAlign: TextAlign.center,
                              style: TextStyle(color: inPrimaryText),
                            ),
                          ),
                        );
                      }),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget graph3() {
    return SfCartesianChart(
        title: ChartTitle(
          text: "favorite foods",
          alignment: ChartAlignment.near,
          textStyle: TextStyle(
              fontSize: 15, fontWeight: FontWeight.bold, color: secondary),
        ),
        primaryXAxis: CategoryAxis(),
        primaryYAxis: NumericAxis(
            minimum: 0,
            maximum: 40,
            interval: 10,
            title: AxisTitle(text: "frequency")),
        series: <ChartSeries<_ChartData, String>>[
          BubbleSeries<_ChartData, String>(
              dataSource: data,
              xValueMapper: (_ChartData data, _) => data.x,
              yValueMapper: (_ChartData data, _) => data.y,
              name: 'Gold',
              color: Color.fromRGBO(8, 142, 255, 1))
        ]);
  }
}

class _ChartData {
  _ChartData(this.x, this.y);

  final String x;
  final double y;
}
