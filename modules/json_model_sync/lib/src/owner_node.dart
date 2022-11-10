import 'dart:convert';

import 'package:json_diff_patcher/json_diff_patcher.dart';

import 'message.dart';
import 'node.dart';

dynamic copy(dynamic json) {
  return jsonDecode(jsonEncode(json));
}

class OwnerBoardNode {
  final BoardUserNode node;
  final Map<dynamic, dynamic> model;
  final JsonDiffPatcher patcher;
  Map<dynamic, dynamic> lastStore;

  OwnerBoardNode({
    required this.node,
    required this.model,
  })  : patcher = JsonDiffPatcher(model),
        lastStore = copy(model) {
    // owner需要订阅接收模型请求, 非owner则无需订阅该消息
    node.registerForOnReceive(
      topic: 'modelRequest',
      callback: (BaseMessage message) {
        // 其他节点向该节点发起模型数据请求
        sendBoardViewModel(message.publisher);
      },
    );
  }

  void broadcastSyncPatch() {
    // 监听发生的修改
    final patch = JsonDiffPatcher(lastStore).diff(model);
    if (patch.isEmpty()) return;
    // 发送修改
    node.broadcast('syncPatch', patch);
    lastStore = copy(model);
  }

  void sendBoardViewModel(String targetId) {
    node.sendTo(targetId, 'modelResponse', model);
  }
}
