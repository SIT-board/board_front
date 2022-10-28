import 'dart:convert';

import 'package:board_front/component/board/model.dart';
import 'package:board_front/util/log.dart';
import 'package:flutter/cupertino.dart';
import 'package:mqtt_client/mqtt_client.dart';
import 'package:mqtt_client/mqtt_server_client.dart';

class BoardNode {
  final String roomId;
  final String nodeId;
  final String server;

  final ValueSetter<Map> onModelChanged;

  late final client = MqttServerClient(server, nodeId);

  BoardNode({
    this.server = '192.168.2.118',
    required this.roomId,
    required this.nodeId,
    required this.onModelChanged,
  });

  Future<void> connect() async {
    client.setProtocolV311();
    try {
      await client.connect();
    } on Exception catch (e) {
      Log.error('Mqtt Client connect exception - $e');
      client.disconnect();
    }

    if (client.connectionStatus!.state != MqttConnectionState.connected) {
      Log.error('ERROR Mosquitto client connection failed - disconnecting, state is ${client.connectionStatus!.state}');
      client.disconnect();
    }
    Log.info('Mosquitto client connected');

    client.onSubscribed = ((s) {
      print('topic订阅成功: $s');
    });
    // client.subscribe('$roomId/broadcast/board', MqttQos.atLeastOnce);
    client.subscribe('$roomId/node/$nodeId/board', MqttQos.atLeastOnce);
    print('订阅消息');
    client.updates!.listen((messageList) {
      final recMess = messageList[0];
      final pubMess = recMess.payload as MqttPublishMessage;

      final pt = MqttPublishPayload.bytesToStringAsString(pubMess.payload.message);
      onModelChanged(jsonDecode(pt) as Map<dynamic, dynamic>);
    });
  }

  void sendTo(String otherId, String topic, String message) {
    final builder = MqttClientPayloadBuilder();
    builder.addString(message);
    client.publishMessage('$roomId/node/$otherId/$topic', MqttQos.atLeastOnce, builder.payload!);
  }

  void broadcast(String topic, String message) {
    final builder = MqttClientPayloadBuilder();
    builder.addString(message);
    client.publishMessage('$roomId/broadcast/$topic', MqttQos.atLeastOnce, builder.payload!);
  }

  void broadcastBoard(BoardViewModel vm) {
    broadcast('board', jsonEncode(vm.map));
  }

  void sendToBoard(String otherId, BoardViewModel vm) {
    sendTo(otherId, 'board', jsonEncode(vm.map));
  }
}
