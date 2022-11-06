import 'dart:convert';

abstract class HashMapData {
  final Map<String, dynamic> map;
  HashMapData(this.map);

  String toJsonString() {
    return jsonEncode(map);
  }
}
