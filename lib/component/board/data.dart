import 'package:board_front/interface/hash_map_data.dart';
import 'package:flutter/material.dart';

import 'board.dart';

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
