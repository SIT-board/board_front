import 'dart:async';
import 'dart:convert';

import 'package:board_front/util/log.dart';
import 'package:mqtt_client/mqtt_client.dart';
import 'package:mqtt_client/mqtt_server_client.dart';

class BoardMessage {
  final DateTime ts;
  final String topic;
  final String publisher;
  final String sendTo;
  final dynamic data;
  BoardMessage({
    required this.ts,
    required this.topic,
    required this.publisher,
    required this.sendTo,
    required this.data,
  });
  static BoardMessage fromJson(Map<String, dynamic> json) {
    return BoardMessage(
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
  /// 房间id
  final String roomId;

  /// 当前节点id
  final String nodeId;

  /// 服务器地址
  final String mqttServer;

  /// 上报时间间隔
  /// 定期上报发布广播消息，通知所有人表示自己在线
  final Duration reportInterval;

  /// 在线人数列表超过多长时间的节点需要被清理
  final Duration onlineListTimeout;

  /// 节点接收消息的回调
  final Map<String, void Function(BoardMessage message)> _onReceiveCallbackMap = {};

  /// 维护一个在线清单列表
  final Map<String, DateTime> _onlineList = {};

  /// mqtt客户端
  MqttClient? _client;

  /// 用于上报在线状态的定时器
  Timer? _timer;
  BoardNode({
    this.mqttServer = '192.168.2.118',
    required this.roomId,
    required this.nodeId,
    this.reportInterval = const Duration(seconds: 1),
    this.onlineListTimeout = const Duration(seconds: 5),
  });

  void _subscribe() {
    _client?.subscribe('$roomId/node/$nodeId/#', MqttQos.atLeastOnce);
    _client?.subscribe('$roomId/broadcast/#', MqttQos.atLeastOnce);

    _client?.updates?.listen((messageList) {
      final recMess = messageList[0];
      final pubMess = recMess.payload as MqttPublishMessage;

      final String message = utf8.decode(pubMess.payload.message);
      _onReceiveMessage(BoardMessage.fromJson(jsonDecode(message)));
    });
  }

  void _onReceiveMessage(BoardMessage message) {
    final cb = _onReceiveCallbackMap[message.topic];
    if (cb == null) return;
    cb(message);
  }

  /// 获取在线列表
  Map<String, DateTime> get onlineList {
    return Map.fromEntries(_onlineList.entries.where((e) => DateTime.now().difference(e.value) <= onlineListTimeout));
  }

  /// 注册消息接收回调
  void registerForOnReceive({
    required String topic,
    required void Function(BoardMessage message) callback,
  }) {
    _onReceiveCallbackMap[topic] = callback;
  }

  /// 连接mqtt服务器
  Future<void> connect() async {
    _client = MqttServerClient(mqttServer, nodeId);
    final client = _client!;
    client.setProtocolV311();
    try {
      await client.connect();
    } on Exception catch (e) {
      Log.error('Mqtt Client connect exception - $e');
      client.disconnect();
      return;
    }

    if (client.connectionStatus!.state != MqttConnectionState.connected) {
      Log.error('ERROR Mosquitto client connection failed - disconnecting, state is ${client.connectionStatus!.state}');
      client.disconnect();
      return;
    }
    Log.info('Mosquitto client connected');

    Log.info('RoomId: $roomId , NodeId: $nodeId');
    client.onSubscribed = ((s) => Log.info('Topic订阅成功: $s'));
    _subscribe();

    // 定时上报在线状态
    _timer = Timer.periodic(reportInterval, (timer) => report());
    registerForOnReceive(
        topic: 'report',
        callback: (BoardMessage message) {
          _onlineList[message.publisher] = message.ts;
        });
  }

  void disconnect() {
    _client?.disconnect();
    _timer?.cancel();
    _timer = null;
  }

  /// 发送点对点消息
  void sendTo(String otherNodeId, String topic, dynamic jsonMessage) {
    final builder = MqttClientPayloadBuilder();
    builder.addUTF8String(
      jsonEncode(BoardMessage(
        ts: DateTime.now(),
        publisher: nodeId,
        sendTo: otherNodeId,
        topic: topic,
        data: jsonMessage,
      ).toJson()),
    );
    _client?.publishMessage(
      '$roomId/node/$otherNodeId/$topic',
      MqttQos.atLeastOnce,
      builder.payload!,
    );
  }

  /// 发送广播消息
  void broadcast(String topic, dynamic jsonMessage) {
    final builder = MqttClientPayloadBuilder();

    builder.addUTF8String(
      jsonEncode(BoardMessage(
        ts: DateTime.now(),
        publisher: nodeId,
        sendTo: '+',
        topic: topic,
        data: jsonMessage,
      ).toJson()),
    );
    _client?.publishMessage(
      '$roomId/broadcast/$topic',
      MqttQos.atLeastOnce,
      builder.payload!,
    );
  }

  /// 上报当前节点状态
  void report() {
    broadcast('report', '');
  }
}

class MyBoardNode {
  final BoardNode node;
  MyBoardNode(this.node) {
    node.registerForOnReceive(
        topic: 'requestBoardModel',
        callback: (BoardMessage message) {
          // 其他节点向该节点发起模型数据请求
        });
    node.registerForOnReceive(topic: 'boardModelRefresh', callback: (BoardMessage message) {});
  }
  // 请求一份BoardModel
  void requestBoardModel() {
    node.broadcast('requestBoardModel', '');
  }
}
