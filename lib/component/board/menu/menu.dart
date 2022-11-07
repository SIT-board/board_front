import 'dart:convert';
import 'dart:math';

import 'package:board_event_bus/board_event_bus.dart';
import 'package:board_front/component/board/board.dart';
import 'package:board_front/util/transform.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:quds_popup_menu/quds_popup_menu.dart';

import '../board_event.dart';
import 'add_model.dart';

class BoardMenu {
  final BuildContext context;
  final ValueGetter<BoardViewModel> boardViewModelGetter;
  final EventBus<BoardEventName> eventBus;

  BoardViewModel get boardViewModel => boardViewModelGetter();

  onBoardMenu(arg) {
    showBoardMenu(context, arg as Offset);
  }

  onModelMenu(arg) {
    final model = arg[0] as Model;
    final pos = arg[1] as Offset;
    showModelMenu(context, pos, model);
  }

  BoardMenu({
    required this.context,
    required this.boardViewModelGetter,
    required this.eventBus,
  }) {
    eventBus.subscribe(BoardEventName.onBoardMenu, onBoardMenu);
    eventBus.subscribe(BoardEventName.onModelMenu, onModelMenu);
  }

  void dispose() {
    eventBus.unsubscribe(BoardEventName.onBoardMenu, onBoardMenu);
    eventBus.unsubscribe(BoardEventName.onModelMenu, onModelMenu);
  }

  QudsPopupMenuItem? buildBoardPasteMenuItem(String? text, Offset position) {
    if (text == null) return null;
    try {
      final model = Model(jsonDecode(text));
      model.id = Random().nextInt(65535);
      model.common.position = Matrix4.inverted(boardViewModel.viewerTransform).transformOffset(position);
      return QudsPopupMenuItem(
        title: Text('粘贴'),
        onPressed: () {
          boardViewModel.addModel(model);
          eventBus.publish(BoardEventName.refreshBoard);
        },
      );
    } catch (e) {
      return null;
    }
  }

  showBoardMenu(BuildContext context, Offset position) async {
    final text = (await Clipboard.getData('text/plain'))?.text;
    final pasteItem = buildBoardPasteMenuItem(text, position);
    showQudsPopupMenu(
      context: context,
      startOffset: position,
      endOffset: position,
      items: [
        QudsPopupMenuItem(
          title: Text('清空画布'),
          onPressed: () {
            boardViewModel.clear();
            eventBus.publish(BoardEventName.refreshBoard);
          },
        ),
        if (pasteItem != null) pasteItem,
        buildAddModelMenu(
          boardViewModel: boardViewModel,
          eventBus: eventBus,
          offset: position,
        ),
      ],
    );
  }

  showModelMenu(BuildContext context, Offset position, Model model) {
    showQudsPopupMenu(
      context: context,
      startOffset: position,
      endOffset: position,
      items: [
        QudsPopupMenuItem(
          title: Text('复制对象'),
          onPressed: () {
            Clipboard.setData(ClipboardData(text: model.toJsonString()));
            EasyLoading.showSuccess('复制成功');
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
}
