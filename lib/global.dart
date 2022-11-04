import 'package:board_event_bus/board_event_bus.dart';
import 'package:board_front/storage/storage.dart';
import 'package:shared_preferences/shared_preferences.dart';

enum EventBusEventName {
  refreshRedoUndo,
}

/// 全局依赖对象
class GlobalObjects {
  static late SharedPreferences sharedPreferences;
  static late BoardStorage storage;
  static late EventBus<EventBusEventName> eventBus;
}
