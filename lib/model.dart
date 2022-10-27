import 'dart:ui';

import 'package:flutter/cupertino.dart';

enum ModelType {
  text,
  rect,
  image,
}

class ImageModelData {
  final String url;

  ImageModelData(this.url);

  static ImageModelData fromJson(Map<String, dynamic> json) {
    return ImageModelData(json['url']);
  }

  Map<String, dynamic> toJson() {
    return {'url': url};
  }
}

class TextModelData {
  final String content;
  final Color? color;

  TextModelData({required this.content, this.color});

  static TextModelData fromJson(Map<String, dynamic> json) {
    return TextModelData(
      content: json['content'],
      color: json['color'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'content': content,
      'color': color,
    };
  }
}

class RectModelData {
  final Color? fillColor;
  final Color? borderColor;
  final double? borderWidth;

  RectModelData({this.fillColor, this.borderColor, this.borderWidth});

  static RectModelData fromJson(Map<String, dynamic> json) {
    return RectModelData(
      fillColor: json['fillColor'],
      borderColor: json['borderColor'],
      borderWidth: json['borderWidth'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'fillColor': fillColor,
      'borderColor': borderColor,
      'borderWidth': borderWidth,
    };
  }
}

class CommonModelData {
  /// 模型角度变换
  double angle = 0;

  /// 模型位置
  Offset position = const Offset(0, 0);

  /// 模型大小
  Size size = const Size(100, 100);

  /// 是否显示
  bool enable = true;

  static CommonModelData fromJson(Map<String, dynamic> json) {
    final data = CommonModelData();
    data.angle = json['angle'] ?? 0;
    data.enable = json['enable'] ?? true;
    final jsonPosition = json['position'];
    if (jsonPosition != null) data.position = Offset(jsonPosition[0], jsonPosition[1]);
    final jsonSize = json['size'];
    if (jsonSize != null) data.size = Size(jsonSize[0], jsonSize[1]);
    return data;
  }

  Map<String, dynamic> toJson() {
    return {
      'enable': enable,
      'angle': angle,
      'position': [position.dx, position.dy],
      'size': [size.width, size.height],
    };
  }
}

class Model {
  /// 模型id
  int id;

  /// 模型类型
  ModelType type;

  /// 模型数据
  dynamic data;

  /// 公共模型数据
  CommonModelData common;

  Model({
    required this.id,
    required this.type,
    required this.data,
    required this.common,
  });

  static Model fromJson(Map<String, dynamic> json) {
    final type = Map.fromEntries(ModelType.values.map((e) => MapEntry(e.name, e)))[json['type']]!;
    final data = {
      ModelType.image: (m) => ImageModelData.fromJson(m),
      ModelType.text: (m) => TextModelData.fromJson(m),
      ModelType.rect: (m) => RectModelData.fromJson(m),
    }[type]!(json['data']);
    return Model(
      id: json['id'],
      type: type,
      data: data,
      common: CommonModelData.fromJson(
        json['common'],
      ),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'type': type.name,
      'data': {
        ModelType.image: () => (data as ImageModelData).toJson(),
        ModelType.text: () => (data as TextModelData).toJson(),
        ModelType.rect: () => (data as RectModelData).toJson(),
      }[type]!(),
      'common': common.toJson(),
    };
  }
}

class CanvasViewModel {
  /// 视口变换
  final Matrix4? viewerTransform;
  final Map<int, Model> models;

  CanvasViewModel({this.viewerTransform, required this.models});
}
