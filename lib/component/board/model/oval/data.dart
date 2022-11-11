import 'package:board_front/interface/hash_map_data.dart';
import 'package:flutter/material.dart';

class OvalModelData extends HashMapData {
  OvalModelData(super.map);
  Color get color => Color(map['color'] ??= Colors.lightBlueAccent.value);
  set color(Color v) => map['color'] = v.value;
}
