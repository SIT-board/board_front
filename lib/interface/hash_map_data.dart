import 'dart:convert';

abstract class HashMapData {
  Map<String, dynamic> map;
  HashMapData(this.map);

  String toJsonString() {
    return jsonEncode(map);
  }
}
