import 'package:board_front/interface/hash_map_data.dart';
import 'package:flutter/material.dart';

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

  /// 是否处于编辑状态
  bool get editableState => map['editableState'] ?? false;
  set editableState(bool v) => map['editableState'] = v;
  CommonModelData(super.map);
}
