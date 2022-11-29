import 'package:board_front/interface/hash_map_data.dart';
import 'package:flutter/material.dart';

class SvgModelData extends HashMapData {
  String get data => map['data'] ?? '';
  set data(String v) => map['data'] = v;

  /// 图像适应
  BoxFit get fit => BoxFit.values[map['fit'] ??= BoxFit.contain.index];
  set fit(BoxFit v) => map['fit'] = v.index;

  /// 背景颜色
  Color? get color => ((e) => e == null ? null : Color(e))(map['color']);
  set color(Color? v) => map['color'] = v?.value;

  SvgModelData(super.map);
}
