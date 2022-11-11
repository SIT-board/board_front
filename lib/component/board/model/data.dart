import 'package:board_front/interface/hash_map_data.dart';

import 'model.dart';

class Model extends HashMapData {
  /// 模型id
  int get id => map['id'];
  set id(int v) => map['id'] = v;

  /// 模型类型
  String get type => map['type'];
  set type(String v) => map['type'] = v;

  /// 模型数据
  Map<String, dynamic> get data => map['data'] ??= <String, dynamic>{};

  set data(Map<String, dynamic> v) => map['data'] = v;

  /// 公共模型数据
  CommonModelData get common => CommonModelData(map['common']);
  set common(CommonModelData v) => map['common'] = v.map;

  Model(super.map);
}
