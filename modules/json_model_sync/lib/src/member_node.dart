import 'package:json_diff_patcher/json_diff_patcher.dart';

import 'message.dart';
import 'node.dart';

class MemberBoardNode {
  final BoardUserNode node;
  final void Function(Map<dynamic, dynamic> model)? onModelRefresh;
  final void Function(JsonPatch patch)? onModelChanged;
  JsonDiffPatcher? patcher;

  MemberBoardNode({
    required this.node,
    required this.onModelRefresh,
    this.onModelChanged,
  }) {
    node.registerForOnReceive(
      topic: 'modelResponse',
      callback: (BaseMessage message) {
        final model = message.data;
        onModelRefresh?.call(model);
      },
    );

    node.registerForOnReceive(
      topic: 'syncPatch',
      callback: (BaseMessage message) {
        final patch = JsonPatch.fromJson((message.data as Map).cast<String, dynamic>());
        patcher?.applyPatch(patch);
        onModelChanged?.call(patch);
      },
    );
  }

  // 请求一份BoardModel
  void requestBoardModel() {
    node.broadcast('modelRequest', '');
  }
}
