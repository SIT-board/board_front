import 'package:board_front/interface/hash_map_data.dart';
import 'package:flutter/material.dart';

class TextModelData extends HashMapData {
  String get content => map['content'];
  set content(String v) => map['content'] = v;
  Color? get color => ((e) => e == null ? null : Color(e))(map['color']);
  set color(Color? v) => map['color'] = v?.value;
  TextModelData(super.map);
}
