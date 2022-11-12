import 'package:json_diff_patcher/json_diff_patcher.dart';

import 'message.dart';
import 'node.dart';

class MemberBoardNode {
  final BoardUserNode node;
  final Map<dynamic, dynamic> model;
  final void Function(BaseMessage)? onModelRefresh;
  final void Function(JsonPatch patch)? onModelChanged;
  JsonDiffPatcher? _patcher;
  final List<JsonPatch> _patchBuffer = [];
  Map<dynamic, dynamic> _lastStore;

  MemberBoardNode({
    required this.node,
    this.model = const {},
    this.onModelRefresh,
    this.onModelChanged,
  }) : _lastStore = copy(model) {
    node.registerForOnReceive(
      topic: 'modelResponse',
      callback: (BaseMessage message) {
        // 收到响应数据后刷新model
        model.clear();
        model.addAll(message.data);

        // 如果缓冲区中存在patch那么全部应用
        _patcher = JsonDiffPatcher(model);
        if (_patchBuffer.isNotEmpty) _patchBuffer.forEach(_patcher!.applyPatch);

        // 快照一份
        _lastStore = copy(model);

        // 通知事件
        onModelRefresh?.call(message);
      },
    );

    node.registerForOnReceive(
      topic: 'syncPatch',
      callback: (BaseMessage message) {
        // 去除自反性，即自身到自身的同步
        if (node.userNodeId == message.publisher) return;
        final patch = JsonPatch.fromJson((message.data as Map).cast<String, dynamic>());

        //  若还未刷新，那么先放至缓冲区
        if (_patcher == null) {
          _patchBuffer.add(patch);
        } else {
          _patcher!.applyPatch(patch);

          // 快照一份
          _lastStore = copy(model);
        }
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

  // 请求一份BoardModel
  void requestBoardModel() {
    node.broadcast('modelRequest', '');
  }
}
