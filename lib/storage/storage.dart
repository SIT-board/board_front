import 'package:board_front/storage/color.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'window.dart';

class BoardStorage {
  final SharedPreferences prefs;
  late final color = ColorStorage(prefs);
  late final window = WindowStorage(prefs);
  BoardStorage(this.prefs);
}
