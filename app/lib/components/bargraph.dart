import 'package:flutter/material.dart';
import 'package:syncfusion_flutter_charts/charts.dart';

import '../constants.dart';
import '../models/barGraph.dart';

class BarGraph extends StatefulWidget {

  final String token;

  const BarGraph({Key? key, required this.token}) : super(key: key);

  @override
  State<BarGraph> createState() => _BarGraphState();
}

class _BarGraphState extends State<BarGraph> {

  Future<List<BarGraphModel>> loadPage() {
    if (DisableHTTP) {
      return BarGraphModel.readJson();
    }
    return BarGraphModel.fromWeb(widget.token);
  }

  late Future<List<BarGraphModel>> _value;

  @override
  void initState() {
    super.initState();
    _value = loadPage();
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<BarGraphModel>>(
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

  Widget Graph(List<BarGraphModel> data) {
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
      series: <ChartSeries<BarGraphModel, String>>[
        ColumnSeries<BarGraphModel, String>(
            dataSource: data,
            xValueMapper: (BarGraphModel data, _) => data.x,
            yValueMapper: (BarGraphModel data, _) => data.y,
            name: 'Gold',
            color: primary)
      ],
    );
  }
}
