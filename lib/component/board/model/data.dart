import 'model.dart';

enum ModelType {
  text,
  rect,
  image,
  freeStyle,
}

class Model {
  /// 模型id
  String id;

  /// 模型类型
  ModelType type;

  /// 模型数据
  dynamic data;

  /// 公共模型数据
  CommonModelData common = CommonModelData();
  Model(this.id, this.type);
}
