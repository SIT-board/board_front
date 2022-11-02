import 'dart:convert';
import 'dart:ui';

import 'package:shared_preferences/shared_preferences.dart';

class ColorStorageKeys {
  static const _namespace = '/color';
  static const recentColorList = '$_namespace/recentColorList';
}

class ColorStorage {
  final SharedPreferences prefs;
  ColorStorage(this.prefs);

  List<Color> get recentColorList {
    List<dynamic> list = jsonDecode(prefs.getString(ColorStorageKeys.recentColorList) ?? '[]');
    return list.map((e) => Color(e)).toList();
  }

  set recentColorList(List<Color> v) {
    String json = jsonEncode(v.map((e) => e.value).toList());
    prefs.setString(ColorStorageKeys.recentColorList, json);
  }
}
