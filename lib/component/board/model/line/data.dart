import 'package:board_front/interface/hash_map_data.dart';
import 'package:flutter/material.dart';

class LineModelData extends HashMapData {
  double get thickness => map['thickness'] ?? 3.0;
  set thickness(double v) => map['thickness'] = v;
  Color get color => ((e) => e != null ? Color(e) : Colors.black)(map['color']);
  set color(Color v) => map['color'] = v.value;
  LineModelData(super.map);
}
