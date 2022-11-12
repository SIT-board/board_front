import 'package:board_front/storage/storage.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// 全局依赖对象
class GlobalObjects {
  static late SharedPreferences sharedPreferences;
  static late BoardStorage storage;
}
