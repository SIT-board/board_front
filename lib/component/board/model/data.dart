import 'package:board_front/interface/hash_map_data.dart';

import 'model.dart';

enum ModelType {
  text,
  rect,
  image,
  freeStyle,
}

class Model extends HashMapData {
  /// 模型id
  String get id => map['id'];
  set id(String v) => map['id'] = v;

  /// 模型类型
  ModelType get type => ModelType.values[map['type']];
  set type(ModelType v) => map['type'] = v.index;

  /// 模型数据
  HashMapData get data {
    return {
      ModelType.text: (m) => TextModelData(m),
      ModelType.image: (m) => ImageModelData(m),
      ModelType.rect: (m) => RectModelData(m),
      ModelType.freeStyle: (m) => FreeStyleModelData(m),
    }[type]!(map['data']);
  }

  set data(HashMapData v) => map['data'] = v.map;

  /// 公共模型数据
  CommonModelData get common => CommonModelData(map['common']);
  set common(CommonModelData v) => map['common'] = v.map;

  Model(super.map);
}
