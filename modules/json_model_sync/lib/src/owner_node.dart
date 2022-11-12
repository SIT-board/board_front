import 'package:json_diff_patcher/json_diff_patcher.dart';

import 'message.dart';
import 'node.dart';

class OwnerBoardNode {
  final BoardUserNode node;
  final Map<dynamic, dynamic> model;
  final JsonDiffPatcher _patcher;
  Map<dynamic, dynamic> _lastStore;
  final void Function(JsonPatch patch)? onModelChanged;

  OwnerBoardNode({
    required this.node,
    required this.model,
    this.onModelChanged,
  })  : _patcher = JsonDiffPatcher(model),
        _lastStore = copy(model) {
    // owner需要订阅接收模型请求, 非owner则无需订阅该消息
    node.registerForOnReceive(
      topic: 'modelRequest',
      callback: (BaseMessage message) {
        // 其他节点向该节点发起模型数据请求
        sendBoardViewModel(message.publisher);
      },
    );
    node.registerForOnReceive(
      topic: 'syncPatch',
      callback: (BaseMessage message) {
        if (node.userNodeId == message.publisher) return; // 去除自反性
        final patch = JsonPatch.fromJson((message.data as Map).cast<String, dynamic>());
        _patcher.applyPatch(patch);
        _lastStore = copy(model);
        onModelChanged?.call(patch);
      },
    );
  }

  void broadcastSyncPatch() {
    // 监听发生的修改
    final patch = JsonDiffPatcher(_lastStore).diff(model);
    if (patch.isEmpty()) return;
    // 发送修改
    node.broadcast('syncPatch', patch);
    _lastStore = copy(model);
  }

  void sendBoardViewModel(String targetId) {
    node.sendTo(targetId, 'modelResponse', model);
  }
}
