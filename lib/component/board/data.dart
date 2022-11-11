import 'dart:math';

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
    map['modelMap'][model.id.toString()] = model.map;
    modelIdList = [...modelIdList, model.id];
  }

  void clear() {
    map['modelMap'].clear();
  }

  void removeModel(int id) {
    (map['modelMap'] as Map).remove(id);
    modelIdList = modelIdList.where((e) => e != id).toList();
  }

  List<int> get modelIdList {
    map['modelIdList'] ??= <int>[];
    return (map['modelIdList'] as List).cast<int>();
  }

  set modelIdList(List<int> v) => map['modelIdList'] = v;

  /// 获取下一个待添加模型的模型id
  int getNextModelId() {
    if (modelIdList.isEmpty) return 0;
    return modelIdList.reduce(max) + 1;
  }

  Model getModelById(int modelId) => Model((map['modelMap'] as Map<String, dynamic>)[modelId.toString()]);

  List<Model> get models {
    map['modelMap'] ??= <String, dynamic>{};
    final mm = (map['modelMap'] as Map<String, dynamic>).map((key, value) => MapEntry(key, Model(value)));
    return modelIdList.map((e) => mm[e.toString()]!).toList();
  }

  BoardViewModel(super.map);
}
