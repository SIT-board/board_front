import 'package:board_front/mqtt.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mqtt_client/mqtt_client.dart';

void main() {
  test('test_mqtt', () async {
    final node = BoardNode(
      roomId: 'roomId',
      nodeId: 'nodeId',
    );
    await node.connect();
    node.broadcast('test', 'message');
    await MqttUtilities.asyncSleep(60);
  });
}
