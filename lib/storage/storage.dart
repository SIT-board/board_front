import 'package:board_front/storage/color.dart';
import 'package:shared_preferences/shared_preferences.dart';

class BoardStorage {
  final SharedPreferences prefs;
  late ColorStorage color = ColorStorage(prefs);
  BoardStorage(this.prefs);
}
