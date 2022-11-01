import 'package:flutter/material.dart';

enum ModelType {
  text,
  rect,
  image,
  freeStyle,
}

abstract class HashMapData {
  final Map<String, dynamic> map;
  HashMapData(this.map);
}

class FreeStylePathModelData extends HashMapData {
  FreeStylePathModelData(super.map);

  List<Offset> get points =>
      ((e) => e == null ? <Offset>[] : (e as List).map((e) => Offset(e[0], e[1])).toList())(map['points']);
  set points(List<Offset> v) => map['points'] = v.map((e) => [e.dx, e.dy]).toList();

  Color get color => ((e) => e != null ? Color(e) : Colors.red)(map['color']);
  set color(Color v) => map['color'] = v;
}

class FreeStyleModelData extends HashMapData {
  List<FreeStylePathModelData> get pathList => (map['pathList'] as List).map((e) => FreeStylePathModelData(e)).toList();
  set pathList(List<FreeStylePathModelData> v) => map['pathList'] = v.map((e) => e.map).toList();
  FreeStyleModelData(super.map);
}

class ImageModelData extends HashMapData {
  String get url => map['url']!;
  set url(String v) => map['url'] = v;
  ImageModelData(super.map);
}

class TextModelData extends HashMapData {
  String get content => map['content'];
  set content(String v) => map['content'] = v;
  Color? get color => ((e) => e == null ? null : Color(e))(map['color']);
  set color(Color? v) => map['color'] = v?.value;
  TextModelData(super.map);
}

class RectModelData extends HashMapData {
  Color? get fillColor => ((e) => e == null ? null : Color(e))(map['fillColor']);
  set fillColor(Color? v) => map['fillColor'] = v?.value;
  Color? get borderColor => ((e) => e == null ? null : Color(e))(map['borderColor']);
  set borderColor(Color? v) => map['borderColor'] = v?.value;
  double? get borderWidth => map['borderWidth'];
  set borderWidth(double? v) => map['borderWidth'] = v;
  RectModelData(super.map);
}

class CommonModelData extends HashMapData {
  /// 模型角度变换
  double get angle => map['angle'] ?? 0;
  set angle(double v) => map['angle'] = v;

  /// 模型位置
  Offset get position => ((e) => e == null ? null : Offset(e[0], e[1]))(map['position']) ?? const Offset(0, 0);
  set position(Offset v) => map['position'] = [v.dx, v.dy];

  /// 模型大小
  Size get size => ((e) => e == null ? null : Size(e[0], e[1]))(map['size']) ?? const Size(100, 100);
  set size(Size v) => map['size'] = [v.width, v.height];

  /// 模型层叠关系
  int get index => map['index'] ?? 0;
  set index(int v) => map['index'] = v;

  /// 模型尺寸约束
  BoxConstraints get constraints {
    final list = map['constraints'];
    if (list == null) return const BoxConstraints(maxWidth: double.maxFinite, maxHeight: double.maxFinite);
    return BoxConstraints(
      minWidth: list[0],
      maxWidth: list[1],
      minHeight: list[2],
      maxHeight: list[3],
    );
  }

  set constraints(BoxConstraints v) => map['constraints'] = [v.minWidth, v.maxWidth, v.minHeight, v.maxHeight];

  /// 是否显示
  bool get enable => map['enable'] ?? true;
  set enable(bool v) => map['enable'] = v;

  CommonModelData(super.map);
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

/// 画板的ViewModel
class BoardViewModel extends HashMapData {
  /// 视口变换
  Matrix4? get viewerTransform => ((e) {
        if (e == null || e is! List) return null;
        return Matrix4.fromList((e).map((e) => e as double).toList());
      })(map['viewerTransform']);
  set viewerTransform(Matrix4? v) => map['viewerTransform'] = v?.storage;
  Map<String, Model> get models =>
      (map['models'] as Map<String, dynamic>).map((key, value) => MapEntry(key, Model(value)));

  set models(Map<String, Model> v) => map['models'] = v.map((key, value) => MapEntry(key, value.map));

  BoardViewModel(super.map);
}
