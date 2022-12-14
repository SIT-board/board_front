import 'package:shared_preferences/shared_preferences.dart';

import 'color.dart';
import 'image.dart';
import 'recently_used.dart';
import 'server.dart';
import 'window.dart';

class BoardStorage {
  final SharedPreferences prefs;
  late final color = ColorStorage(prefs);
  late final window = WindowStorage(prefs);
  late final recentlyUsed = RecentlyUsedListStorage(prefs);
  late final server = ServerStorage(prefs);
  late final image = ImageListStorage(prefs);
  BoardStorage(this.prefs);
}
