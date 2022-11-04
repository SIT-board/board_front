import 'dart:ui';

import 'json_storage.dart';

class WindowStorageKeys {
  static const _namespace = '/window';
  static const size = '$_namespace/size';
  static const position = '$_namespace/position';
}

class WindowStorage extends JsonStorage {
  WindowStorage(super.prefs);

  Size? get size => getModel<Size>(WindowStorageKeys.size, (s) => Size(s['width'], s['height']));
  set size(Size? v) => setModel(WindowStorageKeys.size, v, (e) => {'width': e.width, 'height': e.height});

  Offset? get position => getModel<Offset>(WindowStorageKeys.position, (s) => Offset(s['x'], s['y']));
  set position(Offset? v) => setModel(WindowStorageKeys.position, v, (e) => {'x': e.dx, 'y': e.dy});
}
