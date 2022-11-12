import 'package:shared_preferences/shared_preferences.dart';

class ServerStorageKeys {
  static const _namespace = '/server';
  static const mqttHost = '$_namespace/mqtt/host';
  static const mqttPort = '$_namespace/mqtt/port';
  static const image = '$_namespace/image';
  static const attachment = '$_namespace/attachment';
}

class ServerStorage {
  static const String defaultMqttHost = 'board.jimyag.com';
  static const int defaultMqttPort = 1883;
  static const String defaultImageServer = '';
  static const String defaultAttachmentServer = '';

  final SharedPreferences prefs;
  ServerStorage(this.prefs);

  String get mqttHost => prefs.getString(ServerStorageKeys.mqttHost) ?? defaultMqttHost;
  set mqttHost(String v) => prefs.setString(ServerStorageKeys.mqttHost, v);

  int get mqttPort =>
      int.tryParse(prefs.getString(ServerStorageKeys.mqttPort) ?? defaultMqttPort.toString()) ?? defaultMqttPort;
  set mqttPort(int v) => prefs.setString(ServerStorageKeys.mqttPort, v.toString());

  String get image => prefs.getString(ServerStorageKeys.image) ?? defaultImageServer;
  set image(String v) => prefs.setString(ServerStorageKeys.image, v);

  String get attachment => prefs.getString(ServerStorageKeys.attachment) ?? defaultAttachmentServer;
  set attachment(String v) => prefs.setString(ServerStorageKeys.attachment, v);
}
