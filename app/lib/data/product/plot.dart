import 'dart:convert';
import 'dart:core';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:groceryui/containers/Loader.dart';
import 'package:syncfusion_flutter_charts/charts.dart';

import '../../constants.dart';
import '../common/Point2D.dart';

class Plot implements Jsonable<Plot> {

  final Map<String, dynamic>? lines;

  Plot(
      {
        required this.lines,
      });

  Plot.empty({this.lines});

  @override
  Plot fromJson(Map<String, dynamic> json) {
    return Plot(
        lines: json.map((k, v) {
          v = v as List;
          var l = v.map((i) => Point2D.fromJson(i)).toList();
          return MapEntry(k, l);
        }),
    );
  }

  @override
  String get jsonPath => "assets/models/product_graph.json";

  @override
  String get route => "";

  @override
  Widget build(dynamic item) {
    item = item as Plot;
    return SfCartesianChart(
          title: ChartTitle(
            text: "pricing",
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
          series: <StackedLineSeries<Point2D, String>>[
            for(int i = 0; i < item.lines!.length; i++) StackedLineSeries<Point2D, String>(
              dataSource: item.lines?.values.toList()[i],
              xValueMapper: (Point2D data, _) => data.x,
              yValueMapper: (Point2D data, _) => data.y,

            )

          ]);

/*          <ChartSeries<Point2D, String>>[
            BubbleSeries<Point2D, String>(
                dataSource: ite,
                xValueMapper: (Point2D data, _) => data.x,
                yValueMapper: (Point2D data, _) => data.y,
                name: 'Gold',
                color: Color.fromRGBO(8, 142, 255, 1))
          ]);*/
  }

  @override
  String toString() {
    return json.encode(this);
  }
}