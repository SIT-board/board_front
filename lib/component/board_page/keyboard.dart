import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class BoardKeyMapping extends StatefulWidget {
  final FocusNode focusNode;
  final Widget child;
  final void Function(
    LogicalKeyboardKey key,
    Set<LogicalKeyboardKey> keyPressedSet,
  )? onKeyDown;
  final void Function(
    LogicalKeyboardKey key,
    Set<LogicalKeyboardKey> keyPressedSet,
  )? onKeyUp;
  const BoardKeyMapping({
    Key? key,
    required this.child,
    required this.focusNode,
    this.onKeyDown,
    this.onKeyUp,
  }) : super(key: key);

  @override
  State<BoardKeyMapping> createState() => _BoardKeyMappingState();
}

class _BoardKeyMappingState extends State<BoardKeyMapping> {
  Set<LogicalKeyboardKey> keyPressedSet = {};
  @override
  Widget build(BuildContext context) {
    return KeyboardListener(
      onKeyEvent: (key) {
        if (key is KeyDownEvent) {
          keyPressedSet.add(key.logicalKey);
          widget.onKeyDown?.call(key.logicalKey, keyPressedSet);
        }
        if (key is KeyUpEvent) {
          keyPressedSet.remove(key.logicalKey);
          widget.onKeyUp?.call(key.logicalKey, keyPressedSet);
        }
      },
      autofocus: true,
      focusNode: widget.focusNode,
      child: widget.child,
    );
  }
}
