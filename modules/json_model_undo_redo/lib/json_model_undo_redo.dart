library json_model_undo_redo;

import 'dart:convert';

import 'package:json_diff_patcher/json_diff_patcher.dart';

dynamic copy(dynamic json) {
  return jsonDecode(jsonEncode(json));
}

class UndoRedoManager {
  Map<dynamic, dynamic> lastStore;
  Map<dynamic, dynamic> model;

  /// 需要排除undo redo diff的路径
  Set<String> excludePath;
  UndoRedoManager(this.model, {this.excludePath = const {}}) : lastStore = copy(model);

  List<JsonPatch> history = [];
  int currentPtr = -1; // 指向某个补丁对应的快照指针

  /// 恢复到上一次的store
  void restoreLast() {
    final patcher = JsonDiffPatcher(model);
    // patch = lastStore - model;
    final patch = patcher.diff(lastStore);
    // model = lastStore + (-patch)
    patcher.applyPatch(patch);
  }

  /// 快照捕获
  JsonPatch store() {
    // 不产生分支，直接覆盖后续redo内容
    if (canRedo) history.removeRange(currentPtr + 1, history.length);

    // 计算 patch = model - lastStore
    final patch = JsonDiffPatcher(lastStore).diff(model);
    if (patch.isEmpty()) return patch;
    patch.add.removeWhere((key, value) => excludePath.contains(key));
    patch.remove.removeWhere((key, value) => excludePath.contains(key));
    patch.update.removeWhere((key, value) => excludePath.contains(key));
    history.add(patch);
    lastStore = copy(model);
    currentPtr = history.length - 1;
    return patch;
  }

  bool get canRedo => currentPtr < history.length - 1;

  bool get canUndo => currentPtr >= 0;

  JsonPatch? redo() {
    if (!canRedo) return null;
    currentPtr++;
    final patch = history[currentPtr];
    JsonDiffPatcher(model).applyPatch(patch);
    lastStore = copy(model);
    return patch;
  }

  JsonPatch? undo() {
    if (!canUndo) return null;
    final patch = history[currentPtr].inverse();
    JsonDiffPatcher(model).applyPatch(patch);
    currentPtr--;
    lastStore = copy(model);
    return patch;
  }

  @override
  String toString() {
    return 'UndoRedoManager{lastStore: $lastStore, model: $model, history: $history, currentPtr: $currentPtr, canRedo: $canRedo, canUndo: $canUndo}';
  }
}
