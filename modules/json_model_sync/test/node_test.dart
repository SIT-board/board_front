import 'package:json_model_sync/json_model_sync.dart';
import 'package:test/test.dart';

Future<void> delay(int seconds) => Future.delayed(Duration(seconds: seconds));

void main() {
  test('test_mqtt', () async {
    final node1 = BoardUserNode(
      roomId: 'room1',
      userNodeId: 'user1',
      reportInterval: Duration(seconds: 1),
      onlineListTimeout: Duration(seconds: 5),
    );
    await node1.connect();
    await delay(2);
    print(node1.onlineList); // [1]
    final node2 = BoardUserNode(
      roomId: 'room1',
      userNodeId: 'user2',
      reportInterval: Duration(seconds: 1),
      onlineListTimeout: Duration(seconds: 5),
    );
    await node2.connect();
    await delay(2);
    print(node1.onlineList); // [1,2]
    node2.disconnect();
    await delay(5);
    print(node1.onlineList); // [1]
  });
}
