import 'package:board_front/interface/hash_map_data.dart';
import 'package:flutter/material.dart';

import 'board.dart';

class ModelMap extends HashMapData {
  ModelMap(super.map);

  void addModel(Model model) {
    map[model.id] = model.map;
  }

  void clear() {
    map.clear();
  }

  Map<String, Model> get models => map.map((key, value) => MapEntry(key, Model(value)));
}

/// 画板的ViewModel
class BoardViewModel extends HashMapData {
  /// 视口变换
  Matrix4 get viewerTransform {
    map['viewerTransform'] ??= Matrix4.identity().storage;
    return Matrix4.fromList(map['viewerTransform']);
  }

  set viewerTransform(Matrix4 v) => map['viewerTransform'] = v.storage;
  ModelMap get models {
    map['models'] ??= <String, dynamic>{};
    return ModelMap(map['models']);
  }

  BoardViewModel(super.map);
}
