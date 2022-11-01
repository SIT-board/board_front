import 'package:board_front/interface/hash_map_data.dart';

class ImageModelData extends HashMapData {
  String get url => map['url']!;
  set url(String v) => map['url'] = v;
  ImageModelData(super.map);
}
