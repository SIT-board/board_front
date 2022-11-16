import 'package:board_front/global.dart';
import 'package:board_front/storage/server.dart';
import 'package:flutter/material.dart';
import 'package:flutter_settings_screens/flutter_settings_screens.dart';

class SettingPage extends StatelessWidget {
  const SettingPage({Key? key}) : super(key: key);
  ServerStorage get server => GlobalObjects.storage.server;

  Widget buildBody(BuildContext context) {
    return ListView(
      children: [
        SettingsGroup(
          title: 'MQTT服务器设置',
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
        SettingsGroup(
          title: '其他服务',
          children: [
            TextInputSettingsTile(
              title: '文件上传服务',
              settingKey: ServerStorageKeys.fileUpload,
              initialValue: server.fileUpload,
            ),
            TextInputSettingsTile(
              title: 'PlantUML渲染服务',
              settingKey: ServerStorageKeys.plantuml,
              initialValue: server.plantuml,
            ),
          ],
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('白板设置'),
        actions: [
          IconButton(
            onPressed: () {
              showDialog(
                  context: context,
                  builder: (context) {
                    return Dialog(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text('还原默认设置？', style: Theme.of(context).textTheme.headline5),
                          ElevatedButton(
                            onPressed: () {
                              server.clear();
                              Navigator.of(context).pop();
                              Navigator.of(context).pop();
                            },
                            child: const Text('还原'),
                          ),
                          TextButton(
                            onPressed: () {
                              Navigator.of(context).pop();
                            },
                            child: const Text('取消'),
                          ),
                        ],
                      ),
                    );
                  });
            },
            icon: const Icon(Icons.undo),
          ),
        ],
      ),
      body: buildBody(context),
    );
  }
}
