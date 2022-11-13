import 'dart:convert';
import 'dart:math';

import 'package:board_front/interface/hash_map_data.dart';
import 'package:flutter/material.dart';

class FreeStylePathModelData extends HashMapData {
  FreeStylePathModelData(super.map);

  int get id => map['id'];
  set id(int v) => map['id'] = v;

  List<Offset> get points =>
      ((e) => e == null ? <Offset>[] : (e as List).map((e) => Offset(e[0], e[1])).toList())(map['points']);
  set points(List<Offset> v) => map['points'] = v.map((e) => [e.dx, e.dy]).toList();

  FreeStylePaintStyleModelData get paint =>
      FreeStylePaintStyleModelData(map['paint'] ??= FreeStylePaintStyleModelData.createDefault());
  set paint(FreeStylePaintStyleModelData v) => map['paint'] = v.map;
}

class FreeStylePaintStyleModelData extends HashMapData {
  FreeStylePaintStyleModelData(super.map);

  /// 画笔颜色
  Color get color => Color(map['color'] ??= Colors.black.value);
  set color(Color v) => map['color'] = v.value;

  /// 画笔线宽
  double get strokeWidth => map['strokeWidth'] ??= 5.0;
  set strokeWidth(double v) => map['strokeWidth'] = v;

  /// 抗锯齿
  bool get isAntiAlias => map['isAntiAlias'] ??= true;
  set isAntiAlias(bool v) => map['isAntiAlias'] = v;

  factory FreeStylePaintStyleModelData.createDefault() => FreeStylePaintStyleModelData({});

  /// 复制一份
  FreeStylePaintStyleModelData copy() {
    return FreeStylePaintStyleModelData(jsonDecode(toJsonString()));
  }
}

class FreeStyleModelData extends HashMapData {
  List<int> get pathIdList => ((map['pathIdList'] ??= <int>[]) as List).cast<int>();

  set pathIdList(List<int> v) => map['pathIdList'] = v;

  int getNextModelId() {
    if (pathIdList.isEmpty) return 0;
    return pathIdList.reduce(max) + 1;
  }

  FreeStylePathModelData getPathById(int pathId) {
    return FreeStylePathModelData((map['pathMap'] as Map<String, dynamic>)[pathId.toString()]);
  }

  int get pathListSize => pathIdList.length;

  void addPath(FreeStylePathModelData p) {
    ((map['pathMap'] ??= <String, dynamic>{}) as Map)[p.id.toString()] = p.map;
    pathIdList = [...pathIdList, p.id];
  }

  /// 背景颜色
  Color get backgroundColor => Color(map['backgroundColor'] ??= Colors.yellow.value);
  set backgroundColor(Color v) => map['backgroundColor'] = v.value;

  /// 当前画笔样式
  FreeStylePaintStyleModelData get paint =>
      FreeStylePaintStyleModelData(map['paint'] ??= FreeStylePaintStyleModelData.createDefault().map);
  set paint(FreeStylePaintStyleModelData v) => map['paint'] = v.map;
  FreeStyleModelData(super.map);
}
