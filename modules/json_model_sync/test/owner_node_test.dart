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
  test('owner', () async {
    final node1 = BoardUserNode(
      roomId: 'room1',
      userNodeId: 'user1',
      reportInterval: Duration(seconds: 3),
      onlineListTimeout: Duration(seconds: 5),
    );
    await node1.connect();

    final ownerNode = OwnerBoardNode(
      node: node1,
      model: model,
    );
    ownerNode.sendBoardViewModel('targetId');
    model['m1'] = 2;
    model['m5'] = [2, 3, 4];
    ownerNode.broadcastSyncPatch();
    (model['m4'] as Map)['m5'] = 456;
    ownerNode.broadcastSyncPatch();
    await Future.delayed(Duration(seconds: 60));
  });
}
