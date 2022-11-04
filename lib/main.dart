import 'package:board_front/page/home.dart';
import 'package:board_front/storage/storage.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'desktop_init.dart';
import 'global.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  // 初始化 SharedPreferences 存储
  GlobalObjects.sharedPreferences = await SharedPreferences.getInstance();
  GlobalObjects.storage = BoardStorage(GlobalObjects.sharedPreferences);
  await DesktopInit.init();
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
      home: const HomePage(),
    );
  }
}
