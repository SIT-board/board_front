import 'package:board_front/interface/hash_map_data.dart';

class ImageModelData extends HashMapData {
  String get url => map['url']!;
  set url(String v) => map['url'] = v;

  /// 图像适应
  int get fit => map['fit'] ??= 0;
  set fit(int v) => map['fit'] = v;
  ImageModelData(super.map);
}
