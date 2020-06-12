import 'dart:collection';
import 'package:DartVika/database.dart';

class DonationLib {
  /// Method fot loading list of donators
  static Future<LinkedHashMap> loadList() async {
    final List<Map<String, dynamic>> data =
        await MongoDB().loadAllData('donations');
    final Map<String, double> donators = {};
    for (var element in data) {
      if (donators[element['name']] == null) {
        donators[element['name']] = element['sum'];
      } else {
        donators[element['name']] += element['sum'];
      }
    }
    var sortedKeys = donators.keys.toList(growable: false)
      ..sort((k1, k2) => donators[k2].compareTo(donators[k1]));
    LinkedHashMap sortedMap = new LinkedHashMap.fromIterable(sortedKeys,
        key: (k) => k, value: (k) => donators[k]);

    return sortedMap;
  }
}
