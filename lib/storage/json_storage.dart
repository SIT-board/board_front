import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

class JsonStorage {
  final SharedPreferences prefs;

  JsonStorage(this.prefs);

  void setModel<T>(
    String key,
    T? model,
    Map<String, dynamic> Function(T e) toJson,
  ) {
    if (model == null) {
      prefs.remove(key);
      return;
    }
    prefs.setString(key, jsonEncode(toJson(model)));
  }

  T? getModel<T>(String key, T Function(Map<String, dynamic>) fromJson) {
    String? json = prefs.getString(key);
    if (json == null) return null;
    return fromJson(jsonDecode(json));
  }

  List<T>? getModelList<T>(
    String key,
    T Function(Map<String, dynamic>) fromJson,
  ) {
    String? json = prefs.getString(key);
    if (json == null) return null;
    List<dynamic> list = jsonDecode(json);
    return list.map((e) => fromJson(e)).toList();
  }

  void setModelList<T>(
    String key,
    List<T>? foo,
    Map<String, dynamic> Function(T e) toJson,
  ) {
    if (foo == null) {
      prefs.remove(key);
      return;
    }
    // 不为空时
    List<Map<String, dynamic>> list = foo.map((e) => toJson(e)).toList();
    String json = jsonEncode(list);
    prefs.setString(key, json);
  }
}
