import 'dart:convert';

import 'package:board_front/util/log.dart';
import 'package:mqtt_client/mqtt_client.dart';
import 'package:mqtt_client/mqtt_server_client.dart';

class _JsonMessage {
  final DateTime ts;
  final String topic;
  final String publisher;
  final String sendTo;
  final Map<String, dynamic> data;
  _JsonMessage({
    required this.ts,
    required this.topic,
    required this.publisher,
    required this.sendTo,
    required this.data,
  });
  static _JsonMessage fromJson(Map<String, dynamic> json) {
    return _JsonMessage(
      ts: DateTime.fromMillisecondsSinceEpoch(json['ts']),
      topic: json['topic'],
      publisher: json['publisher'],
      sendTo: json['sendTo'],
      data: json['data'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'ts': ts.millisecondsSinceEpoch,
      'topic': topic,
      'publisher': publisher,
      'sendTo': sendTo,
      'data': data,
    };
  }
}

class BoardNode {
  final String roomId;
  final String nodeId;
  final String server;

  final Map<String, void Function(dynamic message)> _onReceiveCallbackMap = {};

  late final client = MqttServerClient(server, nodeId);

  BoardNode({
    this.server = '192.168.2.118',
    required this.roomId,
    required this.nodeId,
  });

  void _subscribe() {
    client.subscribe('$roomId/$nodeId/#', MqttQos.atLeastOnce);

    client.updates!.listen((messageList) {
      final recMess = messageList[0];
      final pubMess = recMess.payload as MqttPublishMessage;
      final String message = MqttPublishPayload.bytesToStringAsString(pubMess.payload.message);
      final jsonMessage = _JsonMessage.fromJson(jsonDecode(message));
      _onReceiveMessage(jsonMessage.topic, jsonMessage.data);
    });
  }

  void _onReceiveMessage(String topic, dynamic jsonMessage) {
    final cb = _onReceiveCallbackMap[topic];
    if (cb == null) return;
    cb(jsonMessage);
  }

  void registerForOnReceive({required String topic, required void Function(dynamic message) callback}) {
    _onReceiveCallbackMap[topic] = callback;
  }

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

    client.onSubscribed = ((s) => Log.info('Topic订阅成功: $s'));
    _subscribe();
  }

  /// 发送点对点消息
  void sendTo(String otherNodeId, String topic, dynamic jsonMessage) {
    final builder = MqttClientPayloadBuilder();

    builder.addString(
      jsonEncode(_JsonMessage(
        ts: DateTime.now(),
        publisher: nodeId,
        sendTo: otherNodeId,
        topic: topic,
        data: jsonMessage,
      ).toJson()),
    );
    client.publishMessage(
      '$roomId/$otherNodeId/$topic',
      MqttQos.atLeastOnce,
      builder.payload!,
    );
  }

  /// 发送广播消息
  void broadcast(String topic, Map<String, dynamic> jsonMessage) {
    sendTo('+', topic, jsonMessage);
  }
}
