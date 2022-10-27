import 'package:mqtt_client/mqtt_client.dart';
import 'package:mqtt_client/mqtt_server_client.dart';

class BoardNode {
  final String roomId;
  final String nodeId;
  final String server;

  late final client = MqttServerClient(server, nodeId);

  BoardNode({
    this.server = '192.168.2.118',
    required this.roomId,
    required this.nodeId,
  });

  Future<void> connect() async {
    client.setProtocolV311();
    client.onSubscribed = onSubscribed;
    try {
      await client.connect();
    } on Exception catch (e) {
      print('EXAMPLE::client exception - $e');
      client.disconnect();
    }

    /// Check we are connected
    if (client.connectionStatus!.state == MqttConnectionState.connected) {
      print('EXAMPLE::Mosquitto client connected');
    } else {
      print(
          'EXAMPLE::ERROR Mosquitto client connection failed - disconnecting, state is ${client.connectionStatus!.state}');
      client.disconnect();
    }

    client.subscribe('$roomId/broadcast/#', MqttQos.atLeastOnce);
  }

  void onSubscribed(String topic) {}

  void sendTo(String nodeId, String topic, String message) {
    final builder = MqttClientPayloadBuilder();
    builder.addString(message);
    client.publishMessage('$roomId/node/$nodeId/$topic', MqttQos.atLeastOnce, builder.payload!);
  }

  void broadcast(String topic, String message) {
    final builder = MqttClientPayloadBuilder();
    builder.addString(message);
    client.publishMessage('$roomId/broadcast/$topic', MqttQos.atLeastOnce, builder.payload!);
  }
}
