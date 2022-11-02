import 'package:board_front/page/home.dart';
import 'package:board_front/storage/storage.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'global.dart';

void main() async {
  // 初始化 SharedPreferences 存储
  GlobalObjects.sharedPreferences = await SharedPreferences.getInstance();
  GlobalObjects.storage = BoardStorage(GlobalObjects.sharedPreferences);
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'SIT-board',
      theme: ThemeData(primarySwatch: Colors.blue),
      home: const HomePage(),
    );
  }
}
