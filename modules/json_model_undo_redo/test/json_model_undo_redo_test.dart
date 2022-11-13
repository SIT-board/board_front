import 'package:json_model_undo_redo/json_model_undo_redo.dart';
import 'package:test/test.dart';

class MyState {
  final Map map;
  int get counter => map['counter'] ??= 0;
  set counter(int v) => map['counter'] = v;

  MyState(this.map);
}

void main() {
  test('test undo redo', () {
    // 初始状态0 counter = 0
    final state = MyState({})..counter = 0;
    final undoRedo = UndoRedoManager(state.map);
    expect(state.counter, equals(0));
    expect(undoRedo.canUndo, isFalse);
    expect(undoRedo.canRedo, isFalse);

    // 状态1 counter = 4
    state.counter = 4;
    undoRedo.store();

    expect(state.counter, equals(4));
    expect(undoRedo.canUndo, isTrue);
    expect(undoRedo.canRedo, isFalse);

    // 回滚到状态0
    undoRedo.undo();
    expect(state.counter, equals(0));
    expect(undoRedo.canUndo, isFalse);
    expect(undoRedo.canRedo, isTrue);

    // 重做到状态1
    undoRedo.redo();
    expect(state.counter, equals(4));
    expect(undoRedo.canUndo, isTrue);
    expect(undoRedo.canRedo, isFalse);
  });
}
