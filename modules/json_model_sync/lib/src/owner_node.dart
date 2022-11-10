import 'message.dart';
import 'node.dart';

class OwnerBoardNode {
  final BoardUserNode node;
  final Map<String, dynamic> model;
  OwnerBoardNode({
    required this.node,
    required this.model,
  }) {
    // owner需要订阅接收模型请求, 非owner则无需订阅该消息
    node.registerForOnReceive(
      topic: 'modelRequest',
      callback: (BaseMessage message) {
        // 其他节点向该节点发起模型数据请求
        sendBoardViewModel(message.publisher);
      },
    );
  }

  void sendBoardViewModel(String targetId) {
    node.sendTo(targetId, 'modelResponse', model);
  }
}
