import 'package:board_event_bus/board_event_bus.dart';
import 'package:board_front/component/board/board.dart';
import 'package:flutter/material.dart';
import 'package:quds_popup_menu/quds_popup_menu.dart';

import '../board_page_event.dart';
import 'add_model.dart';

class LongPressedMenu extends StatelessWidget {
  final Widget child;
  final BoardViewModel boardViewModel;
  final EventBus<BoardPageEventName> eventBus;
  const LongPressedMenu({
    Key? key,
    required this.child,
    required this.boardViewModel,
    required this.eventBus,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onLongPressStart: (d) {
        showQudsPopupMenu(
          context: context,
          startOffset: d.localPosition,
          endOffset: d.localPosition,
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
              offset: d.localPosition,
            ),
          ],
        );
      },
      child: child,
    );
  }
}
