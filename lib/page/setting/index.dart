import 'package:board_front/global.dart';
import 'package:board_front/storage/server.dart';
import 'package:flutter/material.dart';
import 'package:flutter_settings_screens/flutter_settings_screens.dart';

class SettingPage extends StatelessWidget {
  const SettingPage({Key? key}) : super(key: key);

  ServerStorage get server => GlobalObjects.storage.server;
  @override
  Widget build(BuildContext context) {
    return SettingsScreen(
      title: '白板设置',
      children: [
        SettingsGroup(
          title: '服务器设置',
          children: [
            TextInputSettingsTile(
              title: 'MQTT服务器地址',
              settingKey: ServerStorageKeys.mqttHost,
              initialValue: server.mqttHost,
              onChange: (value) => server.mqttHost = value,
            ),
            TextInputSettingsTile(
              title: 'MQTT服务器端口',
              settingKey: ServerStorageKeys.mqttPort,
              validator: (String? input) {
                String error = 'MQTT服务器端口设置错误(0~65535)';
                if (input == null || input.isEmpty) return error;
                int? port = int.tryParse(input);
                if (port == null) return error;
                if (port <= 0 || port >= 65535) return error;
                return null;
              },
              initialValue: server.mqttPort.toString(),
              onChange: (value) => server.mqttHost = value,
            ),
          ],
        ),
      ],
    );
  }
}
