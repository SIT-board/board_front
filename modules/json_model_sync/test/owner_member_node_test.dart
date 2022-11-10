import 'package:json_model_sync/json_model_sync.dart';
import 'package:test/scaffolding.dart';

Future<void> delay(int seconds) => Future.delayed(Duration(seconds: seconds));
final model = {
  'm1': 1,
  'm2': 2,
  'm3': '234',
  'm4': {'m5': 666},
  'm5': [1, 2, 3],
};
void main() {
  test('owner and member', () async {
    final ownerRawNode = BoardUserNode(
      roomId: 'room1',
      userNodeId: 'ownerNode',
      reportInterval: Duration(seconds: 3),
      onlineListTimeout: Duration(seconds: 5),
    );
    final memberRawNode = BoardUserNode(
      roomId: 'room1',
      userNodeId: 'memberNode',
      reportInterval: Duration(seconds: 3),
      onlineListTimeout: Duration(seconds: 5),
    );
    await ownerRawNode.connect();
    await memberRawNode.connect();

    final ownerNode = OwnerBoardNode(node: ownerRawNode, model: model);
    ownerNode.sendBoardViewModel('targetId');
    model['m1'] = 2;
    model['m5'] = [2, 3, 4];
    ownerNode.broadcastSyncPatch();
    (model['m4'] as Map)['m5'] = 456;
    ownerNode.broadcastSyncPatch();

    final memberNode = MemberBoardNode(
      node: memberRawNode,
      onModelChanged: (patch) {
        print('model被修改：$patch');
      },
      onModelRefresh: (model) {
        print('model被刷新: $model');
      },
    );
    memberNode.requestBoardModel();
    await Future.delayed(Duration(seconds: 60));
  });
}
