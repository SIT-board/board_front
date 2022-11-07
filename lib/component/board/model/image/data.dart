import 'package:board_front/interface/hash_map_data.dart';
import 'package:flutter/material.dart';

class ImageModelData extends HashMapData {
  String get url => map['url']!;
  set url(String v) => map['url'] = v;

  /// 图像适应
  BoxFit get fit => BoxFit.values[map['fit'] ??= BoxFit.contain.index];
  set fit(BoxFit v) => map['fit'] = v.index;
  ImageModelData(super.map);
}
