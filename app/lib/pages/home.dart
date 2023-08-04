import 'dart:ffi';

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:groceryui/models/cartItem.dart';
import 'package:groceryui/models/categoryItem.dart';
import 'package:groceryui/pages/demo.dart';
import 'package:groceryui/pages/product.dart';
import 'package:groceryui/pages/search.dart';
import 'dart:convert';
import 'package:syncfusion_flutter_charts/charts.dart';
import 'package:syncfusion_flutter_charts/sparkcharts.dart';

import '../constants.dart';

class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage>
    with SingleTickerProviderStateMixin {
  late List<CartItem> products = <CartItem>[];

  int _selected = 0;
  late TabController _controller = TabController(length: 3, vsync: this);

  List<_ChartData> data = [
    _ChartData('Mar', 12),
    _ChartData('Apr', 15),
    _ChartData('May', 30),
    _ChartData('Jun', 6.4),
    _ChartData('Jul', 14)
  ];

  @override
  void initState() {
    super.initState();
    _controller.addListener(() {
      setState(() {
        _selected = _controller.index;
        print(_selected);
      });
    });
    loadProducts("");
  }

  void loadProducts(String term) async {
    var loadedProducts = await CartItem.readJson();
    setState(() {
      products = loadedProducts;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(
                height: 300,
                child: TabBarView(
                  controller: _controller,
                  children: [
                    graph2(),
                    graph1(),
                    graph3(),
                  ],
                ),
              ),
              SizedBox(
                height: 12,
                child: Align(
                  alignment: Alignment.center,
                  child: TabBar(
                    indicatorColor: Colors.white,
                    isScrollable: true,
                    tabs: [
                      CircleAvatar(
                        backgroundColor: _selected == 0 ? secondary : alternate,
                        radius: _selected == 0 ? 8 : 4,
                      ),
                      CircleAvatar(
                        backgroundColor: _selected == 1 ? secondary : alternate,
                        radius: _selected == 1 ? 8 : 4,
                      ),
                      CircleAvatar(
                        backgroundColor: _selected == 2 ? secondary : alternate,
                        radius: _selected == 2 ? 8 : 4,
                      ),
                    ],
                    controller: _controller,
                  ),
                ),
              ),
              Padding(
                padding: EdgeInsets.only(bottom: 20, left: 10),
                child: Text(
                  "buy again",
                  style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: secondary),
                ),
              ),
              productGrid(),
              Padding(
                padding: EdgeInsets.only(top: 20, bottom: 20, left: 10),
                child: Text(
                  "recently cheap",
                  style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: secondary),
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(bottom: 10),
                child: productGrid(),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget graph1() {
    return SfCartesianChart(
      primaryXAxis: CategoryAxis(
        borderColor: secondary,
      ),
      primaryYAxis: NumericAxis(
        title: AxisTitle(text: "cost"),
      ),
      // Chart title
      // Enable tooltip
      title: ChartTitle(text: "monthly spending", alignment: ChartAlignment.near, textStyle: TextStyle(
          fontSize: 15,
          fontWeight: FontWeight.bold,
          color: secondary),
      ),
    tooltipBehavior: TooltipBehavior(enable: true),
    series: <ChartSeries<_ChartData, String>>[
        ColumnSeries<_ChartData, String>(
            dataSource: data,
            xValueMapper: (_ChartData data, _) => data.x,
            yValueMapper: (_ChartData data, _) => data.y,
            name: 'Gold',
            color: primary)
      ],
    );
  }

  Widget graph2() {
    return SfCircularChart(
        title: ChartTitle(text: "categories (7/3-8/3)", alignment: ChartAlignment.near, textStyle: TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.bold,
            color: secondary),
        ),
        legend: const Legend(
            position: LegendPosition.right,
            isVisible: true,
            title: LegendTitle(
                textStyle: TextStyle(fontWeight: FontWeight.bold))),
        series: <CircularSeries>[
          // Renders radial bar chart
          RadialBarSeries<_ChartData, String>(
              dataSource: data,
              xValueMapper: (_ChartData data, _) => data.x,
              yValueMapper: (_ChartData data, _) => data.y,
              innerRadius: '30%'),
        ]);
  }

  Widget graph3() {
    return SfCartesianChart(
        title: ChartTitle(text: "favorite foods", alignment: ChartAlignment.near, textStyle: TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.bold,
            color: secondary),
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

  Widget productGrid() {
    return SizedBox(
      height: 140,
      child: ListView.builder(
        itemCount: products.length,
        scrollDirection: Axis.horizontal,
        itemBuilder: (context, item) {
          final product = products[item];
          return Padding(
            padding: const EdgeInsets.only(left: 8.0),
            child: InkWell(
              onTap: (){
                Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) =>
                            Product(id: 0, token: "")));
              },
              child: Container(
                width: 100,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(17),
                  border: Border.all(color: secondary),
                  image: DecorationImage(
                      fit: BoxFit.cover, image: AssetImage(product.iconPath)),
                ),
                child: Stack(
                  children: [
                    Positioned(
                      left: 0,
                      child: InkWell(
                        onTap: (){
                          print("Hey");
                        },
                        child: SizedBox(
                          height: 25,
                          child: Icon(
                            Icons.add,
                            color: secondary,
                          ),
                        ),
                      ),
                    ),
                    Positioned(
                      bottom: 1,
                      left: 0,
                      child: SizedBox(
                        height: 30,
                        child: Container(
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(color: primary!),
                          ),
                          padding: const EdgeInsets.all(5),
                          child: Text(
                            "\$${product.price}",
                            textAlign: TextAlign.center,
                            style: TextStyle(color: inPrimaryText),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget search() {
    return TextButton(
        child: Icon(
          Icons.search,
          color: secondary,
        ),
        onPressed: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (context) {
                return SearchPage();
              }),
            ));
  }
}

class _ChartData {
  _ChartData(this.x, this.y);

  final String x;
  final double y;
}
