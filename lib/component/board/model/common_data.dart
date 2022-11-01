import 'package:flutter/material.dart';

class CommonModelData {
  /// 模型角度变换
  MyValueNotifier<double> angle = 0;

  /// 模型位置
  MyValueNotifier<Offset> position = const Offset(0, 0);

  /// 模型大小
  MyValueNotifier<Size> size = const Size(100, 100);

  /// 模型层叠关系
  int index = 0;

  /// 模型尺寸约束
  BoxConstraints constraints = const BoxConstraints(maxWidth: double.maxFinite, maxHeight: double.maxFinite);

  /// 是否显示
  bool enable = true;

  /// 是否处于编辑状态
  bool editableState = false;
}
