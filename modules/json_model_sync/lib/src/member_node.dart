import 'package:json_diff_patcher/json_diff_patcher.dart';

import 'message.dart';
import 'node.dart';

class MemberBoardNode {
  final BoardUserNode node;
  final void Function(Map<dynamic, dynamic> model)? onModelRefresh;
  final void Function(JsonPatch patch)? onModelChanged;
  JsonDiffPatcher? _patcher;
  final List<JsonPatch> _patchBuffer = [];
  MemberBoardNode({
    required this.node,
    this.onModelRefresh,
    this.onModelChanged,
  }) {
    node.registerForOnReceive(
      topic: 'modelResponse',
      callback: (BaseMessage message) {
        final model = message.data;
        _patcher = JsonDiffPatcher(model);
        if (_patchBuffer.isNotEmpty) {
          _patchBuffer.forEach(_patcher!.applyPatch);
        }
        onModelRefresh?.call(model!);
      },
    );

    node.registerForOnReceive(
      topic: 'syncPatch',
      callback: (BaseMessage message) {
        final patch = JsonPatch.fromJson((message.data as Map).cast<String, dynamic>());
        if (_patcher == null) {
          _patchBuffer.add(patch);
        } else {
          _patcher!.applyPatch(patch);
        }
        onModelChanged?.call(patch);
      },
    );
  }

  // 请求一份BoardModel
  void requestBoardModel() {
    node.broadcast('modelRequest', '');
  }
}
