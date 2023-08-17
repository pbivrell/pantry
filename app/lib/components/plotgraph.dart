import 'package:flutter/material.dart';
import 'package:syncfusion_flutter_charts/charts.dart';

import '../constants.dart';
import '../models/pieGraph.dart';
import '../models/plotGraph.dart';

class PlotGraph extends StatefulWidget {

  final String token;

  const PlotGraph({Key? key, required this.token}) : super(key: key);

  @override
  State<PlotGraph> createState() => _PlotGraphState();
}

class _PlotGraphState extends State<PlotGraph> {

  Future<List<PlotGraphModel>> loadPage() {
    if (DisableHTTP) {
      return PlotGraphModel.readJson();
    }
    return PlotGraphModel.fromWeb(widget.token);
  }

  late Future<List<PlotGraphModel>> _value;

  @override
  void initState() {
    super.initState();
    _value = loadPage();
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<PlotGraphModel>>(
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

  Widget Graph(List<PlotGraphModel> data) {
    print("Hey");
    print(data);
    return SfCartesianChart(
        title: ChartTitle(text: "favorite foods", alignment: ChartAlignment.near, textStyle: TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.bold,
            color: secondary),
        ),
        primaryXAxis: DateTimeAxis(),
        primaryYAxis: NumericAxis(
            minimum: 0,
            maximum: 40,
            interval: 10,
            title: AxisTitle(text: "frequency")),
        series: <ChartSeries<PlotGraphModel, DateTime>>[
          BubbleSeries<PlotGraphModel, DateTime>(
              dataSource: data,
              xValueMapper: (PlotGraphModel data, _) => data.x,
              yValueMapper: (PlotGraphModel data, _) => data.y,
              sizeValueMapper: (PlotGraphModel data, _) => data.z,
              name: 'Gold',
              color: Color.fromRGBO(8, 142, 255, 1))
        ]);
  }
}
