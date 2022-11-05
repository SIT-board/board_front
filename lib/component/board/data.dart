import 'package:board_front/interface/hash_map_data.dart';
import 'package:flutter/material.dart';

import 'board.dart';

/// 画板的ViewModel
class BoardViewModel extends HashMapData {
  /// 视口变换
  Matrix4 get viewerTransform {
    map['viewerTransform'] ??= Matrix4.identity().storage;
    return Matrix4.fromList((map['viewerTransform'] as List).cast<double>());
  }

  set viewerTransform(Matrix4 v) => map['viewerTransform'] = v.storage;

  void addModel(Model model) {
    map['modelMap'][model.id] = model.map;
    modelIdList = [...modelIdList, model.id];
  }

  void clear() {
    map['modelMap'].clear();
  }

  List<String> get modelIdList {
    map['modelIdList'] ??= <String>[];
    return (map['modelIdList'] as List).cast<String>();
  }

  set modelIdList(List<String> v) => map['modelIdList'] = v;

  List<Model> get models {
    map['modelMap'] ??= <String, dynamic>{};
    final mm = (map['modelMap'] as Map<String, dynamic>).map((key, value) => MapEntry(key, Model(value)));
    return modelIdList.map((e) => mm[e]!).toList();
  }

  BoardViewModel(super.map);
}
