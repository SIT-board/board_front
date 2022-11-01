import 'package:flutter/material.dart';

import 'board.dart';

/// 画板的ViewModel
class BoardViewModel {
  /// 视口变换
  Matrix4 viewerTransform = Matrix4.identity();
  Map<String, Model> models = {};
}
