import 'package:board_front/interface/hash_map_data.dart';

class AttachmentModelData extends HashMapData {
  String get url => map['url'] ??= '';
  set url(String v) => map['url'] = v;
  String get name => map['name'] ??= '未修改名称';
  set name(String v) => map['name'] = v;
  AttachmentModelData(super.map);
}
