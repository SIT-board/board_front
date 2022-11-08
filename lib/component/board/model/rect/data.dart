import 'package:board_front/interface/hash_map_data.dart';
import 'package:flutter/material.dart';

class TextModelData extends HashMapData {
  TextModelData(super.map);
  String get content => map['content'] ??= '文本';
  set content(String v) => map['content'] = v;
  Color get color => Color(map['color'] ??= Colors.black.value);
  set color(Color v) => map['color'] = v.value;
  double get fontSize => map['fontSize'] ??= 14.0;
  set fontSize(double v) => map['fontSize'] = v;
  Alignment get alignment {
    final alignment = map['alignment'] ??= <double>[0.0, 0.0];
    return Alignment(alignment[0], alignment[1]);
  }

  set alignment(Alignment v) => map['alignment'] = [v.x, v.y];

  bool get bold => map['bold'] ??= false;
  set bold(bool v) => map['bold'] = v;

  bool get italic => map['italic'] ??= false;
  set italic(bool v) => map['italic'] = v;

  bool get underline => map['underline'] ??= false;
  set underline(bool v) => map['underline'] = v;
}

class BorderModelData extends HashMapData {
  BorderModelData(super.map);
  Color get color => Color(map['color'] ??= Colors.black12.value);
  set color(Color v) => map['color'] = v.value;
  double get width => map['width'] ?? 0.0;
  set width(double v) => map['width'] = v;
}

class RectModelData extends HashMapData {
  Color get color => Color(map['color'] ??= Colors.lightBlueAccent.value);
  set color(Color v) => map['color'] = v.value;
  BorderModelData get border => BorderModelData(map['border'] ??= <String, dynamic>{});
  TextModelData get text => TextModelData(map['text'] ??= <String, dynamic>{});
  RectModelData(super.map);
}
