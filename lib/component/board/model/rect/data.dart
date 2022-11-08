import 'package:board_front/interface/hash_map_data.dart';
import 'package:flutter/material.dart';

class TextModelData extends HashMapData {
  TextModelData(super.map);
  String get content => map['content'] ?? '';
  set content(String v) => map['content'] = v;
  Color get color => Color(map['color'] ??= Colors.black.value);
  set color(Color v) => map['color'] = v.value;
}

class BorderModelData extends HashMapData {
  BorderModelData(super.map);
  Color get color => Color(map['color'] ??= Colors.black12.value);
  set color(Color v) => map['color'] = v.value;
  double get width => map['width'] ?? 0.0;
  set width(double v) => map['width'] = v;
}

class RectModelData extends HashMapData {
  Color get color => Color(map['color'] ??= Colors.transparent.value);
  set color(Color v) => map['color'] = v.value;
  BorderModelData get border => BorderModelData(map['border'] ??= <String, dynamic>{});
  TextModelData get text => TextModelData(map['text'] ??= <String, dynamic>{});
  RectModelData(super.map);
}
