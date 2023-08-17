import 'package:flutter/material.dart';
import 'package:syncfusion_flutter_charts/charts.dart';

import '../constants.dart';
import '../models/pieGraph.dart';

class PieGraph extends StatefulWidget {

  final String token;

  const PieGraph({Key? key, required this.token}) : super(key: key);

  @override
  State<PieGraph> createState() => _PieGraphState();
}

class _PieGraphState extends State<PieGraph> {

  Future<List<PieGraphModel>> loadPage() {
    if (DisableHTTP) {
      return PieGraphModel.readJson();
    }
    return PieGraphModel.fromWeb(widget.token);
  }

  late Future<List<PieGraphModel>> _value;

  @override
  void initState() {
    super.initState();
    _value = loadPage();
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<PieGraphModel>>(
      future: _value,
      builder: (BuildContext context, AsyncSnapshot<dynamic> snapshot) {
        if (!snapshot.hasData) {
          return Center(child: CircularProgressIndicator());
        }
        if (snapshot.hasError || (snapshot.hasData && snapshot.data == null)) {
          return Text("Failed to load data");
        }
        return Graph(snapshot.data);
      },
    );
  }

  Widget Graph(List<PieGraphModel> data) {
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
          RadialBarSeries<PieGraphModel, String>(
              dataSource: data,
              xValueMapper: (PieGraphModel data, _) => data.x,
              yValueMapper: (PieGraphModel data, _) => data.y,
              innerRadius: '30%'),
        ]);
  }
}
