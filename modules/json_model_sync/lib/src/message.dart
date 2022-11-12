import 'dart:convert';

/// 通信的基本消息实体
dynamic copy(dynamic json) {
  return jsonDecode(jsonEncode(json));
}

class BaseMessage {
  final DateTime ts;
  final String topic;
  final String publisher;
  final String sendTo;
  final dynamic data;
  BaseMessage({
    required this.ts,
    required this.topic,
    required this.publisher,
    required this.sendTo,
    required this.data,
  });

  static BaseMessage fromJson(Map<String, dynamic> json) {
    return BaseMessage(
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
