import 'message.dart';
import 'node.dart';

class MemberBoardNode {
  final BoardUserNode node;
  final void Function(Map<String, dynamic> model) onModelChanged;
  MemberBoardNode({
    required this.node,
    required this.onModelChanged,
  }) {
    node.registerForOnReceive(
      topic: 'modelResponse',
      callback: (BaseMessage message) {
        onModelChanged((message.data as Map).cast<String, dynamic>());
      },
    );
  }

  // 请求一份BoardModel
  void requestBoardModel() {
    node.broadcast('modelRequest', '');
  }
}
