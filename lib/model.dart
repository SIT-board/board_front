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
  final int id;

  /// 模型类型
  final ModelType type;

  /// 模型数据
  final ModelData data;

  /// 模型变换
  final Matrix4? transform;

  /// 模型大小
  final Size? size;

  Model({required this.id, required this.type, required this.data, this.size, this.transform});
}

class CanvasViewModel {
  /// 视口变换
  final Matrix4? viewerTransform;
  final List<Model> models;

  CanvasViewModel({this.viewerTransform, required this.models});
}
