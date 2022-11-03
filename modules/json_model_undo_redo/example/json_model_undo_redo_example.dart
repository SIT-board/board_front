import 'package:json_model_undo_redo/json_model_undo_redo.dart';

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
