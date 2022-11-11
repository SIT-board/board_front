import 'package:shared_preferences/shared_preferences.dart';

import 'color.dart';
import 'recently_used.dart';
import 'window.dart';

class BoardStorage {
  final SharedPreferences prefs;
  late final color = ColorStorage(prefs);
  late final window = WindowStorage(prefs);
  late final recentlyUsed = RecentlyUsedListStorage(prefs);
  BoardStorage(this.prefs);
}
