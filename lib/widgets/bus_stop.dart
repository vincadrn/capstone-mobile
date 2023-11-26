import 'dart:convert';
import 'package:flutter/material.dart';
import '../models/current_wifi_count.dart';
import 'package:http/http.dart' as http;
import '../backend.dart';

class BusStopWidget extends StatefulWidget {
  const BusStopWidget({super.key});

  @override
  createState() => _BusStopWidgetState();
}

class _BusStopWidgetState extends State<BusStopWidget> {
  final GlobalKey<RefreshIndicatorState> _refreshIndicatorKey =
      GlobalKey<RefreshIndicatorState>();
  late Future<CurrentWifiCount> _futureCurrentWifiCount;

  @override
  void initState() {
    super.initState();
    _futureCurrentWifiCount = _fetchCurrentWifiCount();
  }

  @override
  Widget build(BuildContext context) {
    return RefreshIndicator(
      key: _refreshIndicatorKey,
      onRefresh: _refreshFetch,
      child: ListView(
        children: [
          Center(
            child: _currentWifiCountBuilder(_futureCurrentWifiCount),
          ),
        ],
      ),
    );
  }

  Future<void> _refreshFetch() async {
    setState(() {
      _futureCurrentWifiCount = _fetchCurrentWifiCount();
    });
  }

  Widget _currentWifiCountBuilder(Future<CurrentWifiCount> future) {
    return FutureBuilder<CurrentWifiCount>(
      future: future,
      builder: (_, snapshot) {
        if (snapshot.hasData) {
          return Column(
            children: [
              Text(
                  "There ${snapshot.data!.message == "1" ? "is" : "are"}"
              ),
              Container(
                padding: const EdgeInsets.all(20),
                child: Text(
                  "${snapshot.data!.message == "" ? 0 : snapshot.data!.message}",
                  style: const TextStyle(
                    fontSize: 60,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
              Text(
                "${snapshot.data!.message == "1" ? "person" : "people"} detected in the vicinity of the bus stop."
              )
            ],
          );
        } else if (snapshot.hasError) {
          return Text('${snapshot.error}');
        }
        return const CircularProgressIndicator();
      },
    );
  }

  Future<CurrentWifiCount> _fetchCurrentWifiCount() async {
    final res =
        await http.get(Uri.parse('${Backend.getHost()}/api/people'));

    if (res.statusCode == 200) {
      return CurrentWifiCount.fromJson(jsonDecode(res.body));
    } else {
      throw Exception("Failed to load data!");
    }
  }
}
