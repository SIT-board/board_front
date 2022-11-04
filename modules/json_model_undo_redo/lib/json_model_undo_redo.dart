library json_model_undo_redo;

import 'dart:convert';

import 'package:json_diff_patcher/json_diff_patcher.dart';

dynamic copy(dynamic json) {
  return jsonDecode(jsonEncode(json));
}

class UndoRedoManager {
  Map<dynamic, dynamic> lastStore;
  Map<dynamic, dynamic> model;
  UndoRedoManager(this.model) : lastStore = copy(model);

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
  void store() {
    if (canRedo) history.removeRange(currentPtr + 1, history.length);

    // 计算 patch = model - lastStore
    final patch = JsonDiffPatcher(lastStore).diff(model);
    if (patch.isEmpty()) return;

    history.add(patch);
    lastStore = copy(model);
    currentPtr = history.length - 1;
  }

  bool get canRedo => currentPtr < history.length - 1;

  bool get canUndo => currentPtr >= 0;

  void redo() {
    if (!canRedo) return;
    currentPtr++;
    JsonDiffPatcher(model).applyPatch(history[currentPtr]);
  }

  void undo() {
    if (!canUndo) return;
    print(history[currentPtr].inverse());
    print(lastStore);
    JsonDiffPatcher(model).applyPatch(history[currentPtr].inverse());
    currentPtr--;
  }

  @override
  String toString() {
    return 'UndoRedoManager{lastStore: $lastStore, model: $model, history: $history, currentPtr: $currentPtr, canRedo: $canRedo, canUndo: $canUndo}';
  }
}
