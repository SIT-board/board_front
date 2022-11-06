import 'package:flutter/cupertino.dart';
import 'package:flutter/gestures.dart';

enum MenuTriggerType {
  secondaryMouseButton,
  longPress,
}

class MenuEvent {
  MenuTriggerType type;
  Offset localPosition;

  MenuEvent(this.type, this.localPosition);

  @override
  String toString() {
    return 'MenuEvent{type: $type, localPosition: $localPosition}';
  }
}

extension MenuTrigger on Widget {
  Widget bindMenuEvent({
    bool useSecondaryMouseButton = true,
    bool useLongPress = true,
    void Function(MenuEvent event)? onTrigger,
  }) {
    Widget result = this;
    if (useLongPress) {
      result = GestureDetector(
        // 绑定长按
        onLongPressStart: (d) {
          if (onTrigger != null) onTrigger(MenuEvent(MenuTriggerType.longPress, d.localPosition));
        },
        child: result,
      );
    }
    if (useSecondaryMouseButton) {
      return GestureDetector(
        child: Listener(
          onPointerDown: (event) {
            // 绑定鼠标右键
            if (event.kind == PointerDeviceKind.mouse && event.buttons == kSecondaryMouseButton) {
              if (onTrigger != null) onTrigger(MenuEvent(MenuTriggerType.longPress, event.localPosition));
            }
          },
          child: result,
        ),
      );
    }
    return result;
  }
}
