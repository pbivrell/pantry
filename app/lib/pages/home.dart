import 'dart:ffi';

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:groceryui/components/piegraph.dart';
import 'package:groceryui/models/cartItem.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:syncfusion_flutter_charts/charts.dart';

import '../components/bargraph.dart';
import '../components/plotgraph.dart';
import '../constants.dart';
import '../containers/Builder.dart';
import '../containers/Loader.dart';
import '../containers/SwipeWrapper.dart';
import '../data/home/interests.dart';
import '../models/pieGraph.dart';

class HomePage extends StatefulWidget {

  const HomePage({Key? key}) : super(key: key);

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {

  void DoIt(){
    print("Hello");
  }

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.only(bottom: 8.0),
              child: SwipeWrapper(
                widgets: [
                  PieGraph(token: ""),
                  BarGraph(token: ""),
                  PlotGraph(token: ""),
                ],
                funcs: [
                  DoIt,
                  DoIt,
                  DoIt,
                ],
              ),
            ),
            Expanded(
              child: Padding(
                padding: EdgeInsets.only(bottom: 14.0),
                child: SingleChildScrollView(
                  child: ListBuilder(token: "", loader: ListLoader<Interest>(inst: Interest.empty())),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

}
