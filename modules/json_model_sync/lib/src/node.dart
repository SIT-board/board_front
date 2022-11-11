import 'dart:async';
import 'dart:convert';

import 'package:mqtt_client/mqtt_client.dart';
import 'package:mqtt_client/mqtt_server_client.dart';

import 'message.dart';

class BoardUserNode {
  /// 房间id
  final String roomId;

  /// 当前用户节点id
  /// 该id是确定用户的唯一标识
  final String userNodeId;

  /// 当前用户名, 允许后期再动态修改
  String username;

  /// 上报时间间隔
  /// 定期上报发布广播消息，通知所有人表示自己在线
  final Duration reportInterval;

  /// 在线人数列表超过多长时间的节点需要被清理
  final Duration onlineListTimeout;

  /// 节点接收消息的回调
  final Map<String, void Function(BaseMessage message)> _onReceiveCallbackMap = {};

  /// 维护一个在线清单列表
  final Map<String, DateTime> _onlineUserIdMap = {};

  /// 维护一个用户名列表
  final Map<String, String> _onlineUsernameMap = {};

  /// mqtt客户端
  final MqttClient _client;

  /// 用于上报在线状态的定时器
  Timer? _timer;
  BoardUserNode({
    String mqttServer = '127.0.0.1',
    int mqttPort = 1883,
    required this.roomId,
    required this.userNodeId,
    String? username,
    this.reportInterval = const Duration(seconds: 1),
    this.onlineListTimeout = const Duration(seconds: 5),
  })  : username = username ?? '用户$userNodeId',
        _client = MqttServerClient.withPort(mqttServer, userNodeId, mqttPort);

  void _subscribe() {
    _client.subscribe('$roomId/node/$userNodeId/#', MqttQos.atLeastOnce);
    _client.subscribe('$roomId/broadcast/#', MqttQos.atLeastOnce);

    _client.updates?.listen((messageList) {
      final recMess = messageList[0];
      final pubMess = recMess.payload as MqttPublishMessage;

      final String message = utf8.decode(pubMess.payload.message);
      _onReceiveMessage(BaseMessage.fromJson(jsonDecode(message)));
    });
  }

  void _onReceiveMessage(BaseMessage message) {
    final cb = _onReceiveCallbackMap[message.topic];
    if (cb == null) return;
    cb(message);
  }

  /// 获取在线列表
  List<String> get onlineList {
    return _onlineUserIdMap.entries
        .where((e) => DateTime.now().difference(e.value) <= onlineListTimeout)
        .map((e) => e.key)
        .toList();
  }

  String getUsernameByUserId(String userId) {
    return _onlineUsernameMap[userId] ?? '未知用户';
  }

  /// 注册消息接收回调
  void registerForOnReceive({
    required String topic,
    required void Function(BaseMessage message) callback,
  }) {
    _onReceiveCallbackMap[topic] = callback;
  }

  /// 连接mqtt服务器
  Future<void> connect() async {
    _client.setProtocolV311();
    try {
      await _client.connect();
    } on Exception catch (e) {
      print('Mqtt Client connect exception - $e');
      _client.disconnect();
      return;
    }

    if (_client.connectionStatus!.state != MqttConnectionState.connected) {
      print('ERROR Mosquitto client connection failed - disconnecting, state is ${_client.connectionStatus!.state}');
      _client.disconnect();
      return;
    }
    print('Mosquitto client connected');

    print('当前节点信息：RoomId: $roomId , NodeId: $userNodeId');
    _client.onSubscribed = ((s) => print('Topic订阅成功: $s'));
    _subscribe();

    // 定时上报在线状态
    _timer = Timer.periodic(reportInterval, (timer) => report());
    registerForOnReceive(
      topic: 'report',
      callback: (BaseMessage message) {
        _onlineUserIdMap[message.publisher] = message.ts;
        _onlineUsernameMap[message.publisher] = message.data.toString();
      },
    );
  }

  void disconnect() {
    _client.disconnect();
    _timer?.cancel();
    _timer = null;
  }

  /// 发送点对点消息
  void sendTo(String otherNodeId, String topic, dynamic jsonMessage) {
    final builder = MqttClientPayloadBuilder();
    builder.addUTF8String(
      jsonEncode(BaseMessage(
        ts: DateTime.now(),
        publisher: userNodeId,
        sendTo: otherNodeId,
        topic: topic,
        data: jsonMessage,
      ).toJson()),
    );
    _client.publishMessage(
      '$roomId/node/$otherNodeId/$topic',
      MqttQos.atLeastOnce,
      builder.payload!,
    );
  }

  /// 发送广播消息
  void broadcast(String topic, dynamic jsonMessage) {
    final builder = MqttClientPayloadBuilder();

    builder.addUTF8String(
      jsonEncode(BaseMessage(
        ts: DateTime.now(),
        publisher: userNodeId,
        sendTo: '+',
        topic: topic,
        data: jsonMessage,
      ).toJson()),
    );
    _client.publishMessage(
      '$roomId/broadcast/$topic',
      MqttQos.atLeastOnce,
      builder.payload!,
    );
  }

  /// 上报当前节点状态
  void report() {
    broadcast('report', username);
  }
}
