import 'package:shared_preferences/shared_preferences.dart';

class ServerStorageKeys {
  static const _namespace = '/server';
  static const mqttHost = '$_namespace/mqtt/host';
  static const mqttPort = '$_namespace/mqtt/port';
  static const fileUpload = '$_namespace/fileUpload';
}

class ServerStorage {
  static const String defaultMqttHost = 'board.jimyag.com';
  static const int defaultMqttPort = 1883;
  static const String defaultFileUploadService = 'http://board.jimyag.cn:8080/file/upload';

  final SharedPreferences prefs;
  ServerStorage(this.prefs);

  void clear() {
    prefs.getKeys().where((e) => e.startsWith(ServerStorageKeys._namespace)).forEach(prefs.remove);
  }

  String get mqttHost => prefs.getString(ServerStorageKeys.mqttHost) ?? defaultMqttHost;
  set mqttHost(String v) => prefs.setString(ServerStorageKeys.mqttHost, v);

  int get mqttPort =>
      int.tryParse(prefs.getString(ServerStorageKeys.mqttPort) ?? defaultMqttPort.toString()) ?? defaultMqttPort;
  set mqttPort(int v) => prefs.setString(ServerStorageKeys.mqttPort, v.toString());

  String get fileUpload => prefs.getString(ServerStorageKeys.fileUpload) ?? defaultFileUploadService;
  set fileUpload(String v) => prefs.setString(ServerStorageKeys.fileUpload, v);
}
