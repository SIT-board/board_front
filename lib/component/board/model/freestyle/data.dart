import 'package:board_front/interface/hash_map_data.dart';
import 'package:flutter/material.dart';

class FreeStylePathModelData extends HashMapData {
  FreeStylePathModelData(super.map);

  List<Offset> get points =>
      ((e) => e == null ? <Offset>[] : (e as List).map((e) => Offset(e[0], e[1])).toList())(map['points']);
  set points(List<Offset> v) => map['points'] = v.map((e) => [e.dx, e.dy]).toList();

  Color get color => ((e) => e != null ? Color(e) : Colors.red)(map['color']);
  set color(Color v) => map['color'] = v;
}

class FreeStyleModelData extends HashMapData {
  List<FreeStylePathModelData> get pathList {
    if (!map.containsKey('pathList')) map['pathList'] = [];
    return (map['pathList'] as List).map((e) => FreeStylePathModelData(e)).toList();
  }

  set pathList(List<FreeStylePathModelData> v) => map['pathList'] = v.map((e) => e.map).toList();
  Color get backgroundColor => ((e) => e == null ? Colors.yellow : Color(e))(map['backgroundColor']);
  set backgroundColor(Color v) => map['backgroundColor'] = v.value;
  FreeStyleModelData(super.map);
}
