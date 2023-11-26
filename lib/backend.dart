import 'package:http/http.dart' as http;
import 'dart:convert';

enum StatType { people, busArrival }

class Backend {
  static String getHost() {
    // return 'http://10.0.2.2:5000'; // to localhost
    return 'https://vincadrn.alwaysdata.net'; // to actual server
  }

  static Future<List<dynamic>> getData(StatType type, int number) async {
    String apiType = '';
    switch (type) {
      case StatType.people:
        apiType = 'people';
        break;
      case StatType.busArrival:
        apiType = 'bus';
        break;
      default:
        break;
    }

    String url = '${Backend.getHost()}/api/data/$apiType/$number';
    final res = await http.get(Uri.parse(url));
    return res.body == 'null' ? jsonDecode('[{}]') : jsonDecode(res.body) as List<dynamic>;
  }

  // static Future<List<dynamic>> getSomePeople(int numberOfPeople) async {
  //   String url = '${Backend.getHost()}/api/data/people/$numberOfPeople';
  //
  //   final res = await http.get(Uri.parse(url));
  //
  //   return jsonDecode(res.body) as List<dynamic>;
  // }
  //
  // static Future<List<dynamic>> getSomeBusArrival(int numberOfArrival) async {
  //   String url = '${Backend.getHost()}/api/data/bus/$numberOfArrival';
  //
  //   final res = await http.get(Uri.parse(url));
  //
  //   return jsonDecode(res.body) as List<dynamic>;
  // }
}