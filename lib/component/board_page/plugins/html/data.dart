import 'package:board_front/interface/hash_map_data.dart';

class HtmlModelData extends HashMapData {
  HtmlModelData(super.map);
  String get html => map['html'];
  set html(String v) => map['html'] = v;
}
