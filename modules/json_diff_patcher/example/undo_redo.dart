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

  /// 快照捕获
  void store() {
    if (canRedo) history.removeRange(currentPtr + 1, history.length);

    // 计算 model - lastStore = patch
    final patch = JsonDiffPatcher(lastStore).diff(model);
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
    JsonDiffPatcher(model).applyPatch(history[currentPtr].inverse());
    currentPtr--;
  }

  @override
  String toString() {
    return 'UndoRedoManager{lastStore: $lastStore, model: $model, history: $history, currentPtr: $currentPtr, canRedo: $canRedo, canUndo: $canUndo}';
  }
}

final sourceMap = {'a': 123};

void main() {
  final urm = UndoRedoManager(sourceMap);
  // 修改前123
  print(sourceMap);

  // 修改过程
  sourceMap['a'] = 234;

  // 存储快照
  urm.store();

  // 修改后234
  print(sourceMap);

  // 撤销123
  urm.undo();
  print(sourceMap);

  // 重做234
  urm.redo();
  print(sourceMap);
}
