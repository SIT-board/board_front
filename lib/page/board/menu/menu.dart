import 'package:board_event_bus/board_event_bus.dart';
import 'package:board_front/component/board/board.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:quds_popup_menu/quds_popup_menu.dart';

import '../board_page_event.dart';
import 'add_model.dart';

class BoardMenu extends StatelessWidget {
  final Widget child;
  final BoardViewModel boardViewModel;
  final EventBus<BoardPageEventName> eventBus;
  const BoardMenu({
    Key? key,
    required this.child,
    required this.boardViewModel,
    required this.eventBus,
  }) : super(key: key);

  showBoardMenu(BuildContext context, Offset position) {
    showQudsPopupMenu(
      context: context,
      startOffset: position,
      endOffset: position,
      items: [
        QudsPopupMenuItem(
          title: Text('清空画布'),
          onPressed: () {
            boardViewModel.models.clear();
            eventBus.publish(BoardPageEventName.refreshBoard);
          },
        ),
        buildAddModelMenu(
          boardViewModel: boardViewModel,
          eventBus: eventBus,
          offset: position,
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Listener(
      onPointerDown: (event) {
        // 绑定鼠标右键
        if (event.kind == PointerDeviceKind.mouse && event.buttons == kSecondaryMouseButton) {
          showBoardMenu(context, event.localPosition);
        }
      },
      child: GestureDetector(
        // 绑定长按
        onLongPressStart: (d) => showBoardMenu(context, d.localPosition),
        child: child,
      ),
    );
  }
}
