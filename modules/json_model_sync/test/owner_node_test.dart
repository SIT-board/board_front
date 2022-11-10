import 'package:json_model_sync/json_model_sync.dart';
import 'package:test/scaffolding.dart';

Future<void> delay(int seconds) => Future.delayed(Duration(seconds: seconds));

void main() {
  test('owner', () async {
    final node1 = BoardUserNode(
      roomId: 'room1',
      userNodeId: 'user1',
      reportInterval: Duration(seconds: 1),
      onlineListTimeout: Duration(seconds: 5),
    );
    await node1.connect();
  });
}
