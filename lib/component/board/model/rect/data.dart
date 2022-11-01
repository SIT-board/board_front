import 'package:board_front/interface/hash_map_data.dart';
import 'package:flutter/material.dart';

class RectModelData extends HashMapData {
  Color? get fillColor => ((e) => e == null ? null : Color(e))(map['fillColor']);
  set fillColor(Color? v) => map['fillColor'] = v?.value;
  Color? get borderColor => ((e) => e == null ? null : Color(e))(map['borderColor']);
  set borderColor(Color? v) => map['borderColor'] = v?.value;
  double? get borderWidth => map['borderWidth'];
  set borderWidth(double? v) => map['borderWidth'] = v;
  RectModelData(super.map);
}
