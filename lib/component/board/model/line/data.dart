import 'package:board_front/interface/hash_map_data.dart';
import 'package:flutter/material.dart';

class LineModelData extends HashMapData {
  double get thickness => map['thickness'] ??= 1.0;
  set thickness(double v) => map['thickness'] = v;
  Color get color => Color(map['color'] ??= Colors.black.value);
  set color(Color v) => map['color'] = v.value;
  double get dashLength => map['dashLength'] ??= 4.0;
  set dashLength(double v) => map['dashLength'] = v;
  double get dashGapLength => map['dashGapLength'] ??= 0.0;
  set dashGapLength(double v) => map['dashGapLength'] = v;
  LineModelData(super.map);
}
