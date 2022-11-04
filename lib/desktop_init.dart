import 'dart:ui';

import 'package:window_manager/window_manager.dart';

class DesktopInit {
  static bool resizing = false;

  /// The default window size is small enough for any modern desktop device.
  static const Size defaultSize = Size(500, 800);

  /// If the window was resized to too small accidentally, this will keep a minimum function area.
  static const Size minSize = Size(300, 400);

  static Future<void> init() async {
    // 必须加上这一行。
    await windowManager.ensureInitialized();
    windowManager.waitUntilReadyToShow().then((_) async {
      // Hide window title bar
      await windowManager.setTitle('协作画板');
      await windowManager.setSize(defaultSize);
      // Center the window.
      await windowManager.center();
      await windowManager.setMinimumSize(minSize);
      await windowManager.show();
    });
  }
}
