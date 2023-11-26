import 'package:flutter/material.dart';

import 'widgets/bus_stop.dart';
import 'widgets/stats.dart';
import 'messaging.dart';

import 'package:shared_preferences/shared_preferences.dart';

class HomeWidget extends StatefulWidget {
  const HomeWidget({super.key});

  @override
  createState() => _HomeWidgetState();
}

class _HomeWidgetState extends State<HomeWidget> {
  int _currentIndex = 0;
  final List<Widget> _listOfWidgets = [
    const BusStopWidget(),
    const StatsWidget(),
  ];
  bool _userWillBeNotified = false;

  Future<void> _loadWillBeNotified() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _userWillBeNotified = (prefs.getBool('notified') ?? false);
    });
  }

  Future<void> _toggleWillBeNotified() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _userWillBeNotified = !_userWillBeNotified;
      prefs.setBool('notified', _userWillBeNotified);
      ClientFCM.setupToken();
    });
  }

  @override
  void initState() {
    super.initState();
    ClientFCM.setupToken();
    ClientFCM.initFCM();
    _loadWillBeNotified();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Capstone Project',
          style: TextStyle(
            color: Colors.black,
          ),
        ),
        centerTitle: true,
        backgroundColor: Colors.white,
        elevation: 0.5,
      ),
      body: Container(
        padding: const EdgeInsets.all(30),
        child: IndexedStack(
          index: _currentIndex,
          children: _listOfWidgets,
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          setState(() {
            _toggleWillBeNotified();
          });
          final snackBar = SnackBar(
            content: !_userWillBeNotified
                ? const Text('You will be notified when the bus has arrived')
                : const Text('Notification off'),
            duration: !_userWillBeNotified
                ? const Duration(seconds: 3)
                : const Duration(seconds: 1),
          );
          ScaffoldMessenger.of(context).showSnackBar(snackBar);
        },
        child: !_userWillBeNotified
            ? const Icon(Icons.notifications_none)
            : const Icon(Icons.notifications_active),
      ),
      bottomNavigationBar: NavigationBar(
          onDestinationSelected: (int index) {
            setState(() {
              _currentIndex = index;
            });
          },
          selectedIndex: _currentIndex,
          destinations: const <Widget>[
            NavigationDestination(
                selectedIcon: Icon(Icons.directions_bus_filled),
                icon: Icon(Icons.directions_bus_filled_outlined),
                label: 'Bus Stop'),
            NavigationDestination(
                selectedIcon: Icon(Icons.query_stats),
                icon: Icon(Icons.query_stats_outlined),
                label: 'Statistics'),
          ]),
    );
  }
}
