import 'dart:ui';

import 'package:board_front/global.dart';
import 'package:universal_platform/universal_platform.dart';
import 'package:window_manager/window_manager.dart';

class MyWindowListener extends WindowListener {
  @override
  void onWindowMoved() async {
    GlobalObjects.storage.window.position = await windowManager.getPosition();
  }

  @override
  void onWindowResized() async {
    GlobalObjects.storage.window.size = await windowManager.getSize();
  }
}

class DesktopInit {
  static bool resizing = false;

  /// The default window size is small enough for any modern desktop device.
  static const Size defaultSize = Size(500, 800);

  /// If the window was resized to too small accidentally, this will keep a minimum function area.
  static const Size minSize = Size(300, 400);

  static Size get windowSize => GlobalObjects.storage.window.size ?? defaultSize;
  static Offset? get windowPosition => GlobalObjects.storage.window.position;

  static Future<void> init() async {
    // 非桌面端直接跳过
    if (!UniversalPlatform.isDesktop) return;
    // 必须加上这一行。
    await windowManager.ensureInitialized();
    windowManager.addListener(MyWindowListener());
    windowManager.waitUntilReadyToShow().then((_) async {
      // Hide window title bar
      await windowManager.setTitle('协作画板');
      await windowManager.setSize(windowSize);
      // Center the window.
      if (windowPosition == null) {
        await windowManager.center();
      } else {
        await windowManager.setPosition(windowPosition!);
      }
      await windowManager.setMinimumSize(minSize);
      await windowManager.show();
    });
  }
}
