import 'dart:ui';

import 'package:flutter/gestures.dart';

enum ModelType {
  text,
  rect,
  image,
}

abstract class ModelData {}

class ImageModelData implements ModelData {
  final String url;

  ImageModelData(this.url);
}

class TextModelData implements ModelData {
  final String content;
  final Color? color;

  TextModelData({required this.content, this.color});
}

class RectModelData implements ModelData {
  final Color? fillColor;
  final Color? borderColor;
  final double? borderWidth;

  RectModelData({this.fillColor, this.borderColor, this.borderWidth});
}

class Model {
  /// 模型id
  int id;

  /// 模型类型
  ModelType type;

  /// 模型数据
  ModelData data;

  /// 模型角度变换
  double angle = 0;

  /// 模型位置
  Offset position = const Offset(0, 0);

  /// 模型大小
  Size size = const Size(100, 100);

  /// 是否显示
  bool enable = true;

  Model({
    required this.id,
    required this.type,
    required this.data,
  });
}

class CanvasViewModel {
  /// 视口变换
  final Matrix4? viewerTransform;
  final Map<int, Model> models;

  CanvasViewModel({this.viewerTransform, required this.models});
}
