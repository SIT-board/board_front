import 'package:board_front/interface/hash_map_data.dart';

class MarkdownModelData extends HashMapData {
  MarkdownModelData(super.map);
  String get markdown => map['markdown'];
  set markdown(String v) => map['markdown'] = v;
}
