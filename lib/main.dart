import 'package:board_front/page/board/simple_board.dart';
import 'package:board_front/page/home.dart';
import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:flutter_settings_screens/flutter_settings_screens.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:universal_platform/universal_platform.dart';

import 'api/api.dart';
import 'desktop_init.dart';
import 'global.dart';
import 'storage/storage.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  // 初始化 SharedPreferences 存储
  GlobalObjects.sharedPreferences = await SharedPreferences.getInstance();
  GlobalObjects.storage = BoardStorage(GlobalObjects.sharedPreferences);
  GlobalObjects.api = Api();
  await DesktopInit.init();
  await Settings.init();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'SIT-board',
      theme: ThemeData(primarySwatch: Colors.blue),
      home: UniversalPlatform.isWeb ? const SimpleBoardPage() : const HomePage(),
      builder: EasyLoading.init(),
    );
  }
}
