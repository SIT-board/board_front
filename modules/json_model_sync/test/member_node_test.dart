import 'package:json_model_sync/json_model_sync.dart';
import 'package:test/scaffolding.dart';

Future<void> delay(int seconds) => Future.delayed(Duration(seconds: seconds));

void main() {
  test('member', () async {
    final node1 = BoardUserNode(
      roomId: 'room1',
      userNodeId: 'user1',
      reportInterval: Duration(seconds: 3),
      onlineListTimeout: Duration(seconds: 5),
    );
    await node1.connect();

    final model = {};
    final memberNode = MemberBoardNode(
      node: node1,
      model: model,
      onModelChanged: (patch) {
        print('model被修改：$patch');
      },
      onModelRefresh: (message) {
        print('model被刷新: $model');
      },
    );
    memberNode.requestBoardModel();
    await Future.delayed(Duration(seconds: 60));
  });
}
