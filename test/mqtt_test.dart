import 'package:board_front/mqtt.dart';
import 'package:board_front/util/log.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mqtt_client/mqtt_client.dart';

void main() {
  test('test_mqtt', () async {
    final node1 = BoardNode(roomId: 'room1', nodeId: '1');
    await node1.connect();
    await MqttUtilities.asyncSleep(2);
    Log.info(node1.onlineList); // [1]
    final node2 = BoardNode(roomId: 'room1', nodeId: '2');
    await node2.connect();
    await MqttUtilities.asyncSleep(2);
    Log.info(node1.onlineList); // [1,2]
    node2.disconnect();
    await MqttUtilities.asyncSleep(6);
    Log.info(node1.onlineList); // [1]
  });
}
