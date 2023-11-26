import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:ee_capstone_project/backend.dart';

class StatsData {
  static Future<List<dynamic>> getData(StatType type, int number) async {
    return await Backend.getData(type, number);
  }
}

class StatsWidget extends StatefulWidget {
  const StatsWidget({super.key});

  @override
  createState() => _StatsWidgetState();
}

class _StatsWidgetState extends State<StatsWidget> {
  List<dynamic> _statsData = [];
  StatType _statType = StatType.people; // in backend
  int _statNumber = 5;
  int _graphInterval = 5;

  @override
  void initState() {
    super.initState();
    StatsData.getData(_statType, _statNumber)
        .then((value) => {_statsData = value});
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: OrientationBuilder(builder: (context, orientation) {
        return orientation == Orientation.portrait
            ? Column(
                children: [
                  SegmentedButton<StatType>(
                    segments: const [
                      ButtonSegment<StatType>(
                        value: StatType.people,
                        label: Text('People'),
                        icon: Icon(Icons.people),
                      ),
                      ButtonSegment<StatType>(
                        value: StatType.busArrival,
                        label: Text('Bus Arrival'),
                        icon: Icon(Icons.directions_bus),
                      )
                    ],
                    selected: <StatType>{_statType},
                    onSelectionChanged: (newSelection) {
                      setState(() {
                        _statType = newSelection.first;
                        StatsData.getData(_statType, _statNumber)
                            .then((value) => {_statsData = value});
                      });
                    },
                  ),
                  const SizedBox(height: 24),
                  SegmentedButton<int>(
                    segments: const [
                      ButtonSegment<int>(
                        value: 5,
                        label: Text('5'),
                      ),
                      ButtonSegment<int>(
                        value: 10,
                        label: Text('10'),
                      ),
                      ButtonSegment<int>(
                        value: 50,
                        label: Text('50'),
                      ),
                      ButtonSegment<int>(
                        value: 100,
                        label: Text('100'),
                      ),
                      ButtonSegment<int>(
                        value: 500,
                        label: Text('500'),
                      ),
                    ],
                    selected: <int>{_statNumber},
                    onSelectionChanged: (newSelection) {
                      setState(() {
                        _statNumber = newSelection.first;
                        StatsData.getData(_statType, _statNumber)
                            .then((value) => {_statsData = value});
                      });
                    },
                  ),
                  const SizedBox(height: 24),
                  const Text('Please rotate your phone to see the graph.'),
                ],
              )
            : (_statType == StatType.people
                ? LineChart(
                    _peopleData(),
                    swapAnimationDuration: const Duration(milliseconds: 500),
                    swapAnimationCurve: Curves.linear,
                  )
                : LineChart(
                    _busData(),
                    swapAnimationDuration: const Duration(milliseconds: 500),
                    swapAnimationCurve: Curves.linear,
                  ));
      }),
    );
  }

  LineChartData _peopleData() {
    DateTime minTime = DateTime.parse(_statsData[0]['created_at']);
    DateTime maxTime = minTime;

    late DateTime temp;
    for (var i = 1; i < _statsData.length; i++) {
      temp = DateTime.parse(_statsData[i]['created_at']);
      if (temp.compareTo(minTime) < 0) {
        minTime = temp;
      }
      if (temp.compareTo(maxTime) > 0) {
        maxTime = temp;
      }
    }

    return LineChartData(
      lineTouchData: LineTouchData(
        enabled: true,
        touchTooltipData: LineTouchTooltipData(
            fitInsideVertically: true,
            getTooltipItems: (touchedSpots) {
              return touchedSpots.map((LineBarSpot touchedSpot) {
                final date =
                    DateTime.fromMillisecondsSinceEpoch(touchedSpot.x.toInt());
                final people = touchedSpot.y.toInt();
                return LineTooltipItem(
                    '${date.toString()}\n',
                    const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                    ),
                    children: [
                      TextSpan(
                        text: '$people ${people > 1 ? 'people' : 'person'}',
                        style: TextStyle(
                          color: touchedSpot.bar.color,
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      )
                    ]);
              }).toList();
            }),
      ),
      titlesData: FlTitlesData(
          show: true,
          topTitles: AxisTitles(
              axisNameWidget: const Text('Statistics in graph'),
              sideTitles: SideTitles(
                showTitles: false,
              )),
          bottomTitles: AxisTitles(
            axisNameWidget: const Text('Click on the points for details'),
            sideTitles: SideTitles(
              showTitles: true,
              getTitlesWidget: (data, titleMeta) {
                if (data == minTime.millisecondsSinceEpoch.toDouble() ||
                    data == maxTime.millisecondsSinceEpoch.toDouble()) {
                  return const Text("");
                }
                return SizedBox(
                    width: titleMeta.parentAxisSize / _graphInterval,
                    child: Text(
                      DateTime.fromMillisecondsSinceEpoch(data.toInt())
                          .toString(),
                    ));
              },
              reservedSize: 50,
              interval: (maxTime.millisecondsSinceEpoch.toDouble() -
                      minTime.millisecondsSinceEpoch.toDouble()) /
                  (_graphInterval - 1),
            ),
          ),
          rightTitles: AxisTitles(
              sideTitles: SideTitles(
            showTitles: false,
          ))),
      borderData: FlBorderData(
          show: true, border: Border.all(color: const Color(0x2f37434d))),
      minY: 0,
      lineBarsData: [
        LineChartBarData(
          spots: _statsData[0].length != 0
              ? _statsData
                  .map((d) => FlSpot(
                      DateTime.parse(d['created_at'])
                          .millisecondsSinceEpoch
                          .toDouble(),
                      d['number'].toDouble()))
                  .toList()
              : null,
        )
      ],
      gridData: FlGridData(
        show: true,
        verticalInterval: (maxTime.millisecondsSinceEpoch.toDouble() -
                minTime.millisecondsSinceEpoch.toDouble()) /
            (_graphInterval - 1),
      ),
    );
  }

  LineChartData _busData() {
    return LineChartData(
      lineTouchData: LineTouchData(
        touchTooltipData: LineTouchTooltipData(
            fitInsideVertically: true,
            getTooltipItems: (touchedSpots) {
              return touchedSpots.map((LineBarSpot touchedSpot) {
                final date =
                    DateTime.fromMillisecondsSinceEpoch(touchedSpot.x.toInt());
                final people = touchedSpot.y.toInt();
                return LineTooltipItem(
                  '${date.toString()}\n',
                  const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                  ),
                );
              }).toList();
            }),
      ),
      titlesData: FlTitlesData(
        show: true,
        topTitles: AxisTitles(
            axisNameWidget: const Text('Statistics in graph'),
            sideTitles: SideTitles(
              showTitles: false,
            )),
        bottomTitles: AxisTitles(
          axisNameWidget: const Text('Click on the points for details'),
          sideTitles: SideTitles(
            showTitles: false,
          ),
        ),
        rightTitles: AxisTitles(
          sideTitles: SideTitles(
            showTitles: false,
          ),
        ),
        leftTitles: AxisTitles(
          sideTitles: SideTitles(
            showTitles: false,
          ),
        ),
      ),
      lineBarsData: [
        LineChartBarData(
          spots: _statsData[0].length != 0
              ? _statsData
                  .map((d) => FlSpot(
                      DateTime.parse(d['created_at'])
                          .millisecondsSinceEpoch
                          .toDouble(),
                      (d['is_arrived'] as bool ? 1.0 : 0.0)))
                  .toList()
              : null,
        )
      ],
      gridData: FlGridData(
        show: false,
      ),
    );
  }
}
