import 'package:board_front/interface/hash_map_data.dart';
import 'package:flutter/material.dart';

import 'board.dart';

class ModelMap extends HashMapData {
  ModelMap(super.map);

  void addModel(Model model) {
    map[model.id] = model.map;
  }

  Map<String, Model> get models => map.map((key, value) => MapEntry(key, Model(value)));
}

/// 画板的ViewModel
class BoardViewModel extends HashMapData {
  /// 视口变换
  Matrix4? get viewerTransform => ((e) {
        if (e == null || e is! List) return null;
        return Matrix4.fromList((e).map((e) => e as double).toList());
      })(map['viewerTransform']);
  set viewerTransform(Matrix4? v) => map['viewerTransform'] = v?.storage;
  ModelMap get models {
    if (!map.containsKey('models')) map['models'] = <String, dynamic>{};
    return ModelMap(map['models']);
  }

  set models(ModelMap v) => map['models'] = v.map;

  BoardViewModel(super.map);
}
