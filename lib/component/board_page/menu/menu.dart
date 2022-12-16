import 'dart:convert';
import 'dart:math';

import 'package:board_event_bus/board_event_bus.dart';
import 'package:board_front/component/board/board.dart';
import 'package:board_front/component/board/board_event.dart';
import 'package:board_front/util/transform.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:quds_popup_menu/quds_popup_menu.dart';
import 'package:universal_platform/universal_platform.dart';

import '../plugins/model_plugin_manager.dart';
import 'add_model.dart';

class BoardMenu {
  final BuildContext context;
  final ValueGetter<BoardViewModel> boardViewModelGetter;
  final EventBus<BoardEventName> eventBus;
  final BoardModelPluginManager pluginManager;

  BoardViewModel get boardViewModel => boardViewModelGetter();

  BoardMenu({
    required this.context,
    required this.boardViewModelGetter,
    required this.eventBus,
    required this.pluginManager,
  });

  QudsPopupMenuItem? buildBoardPasteMenuItem(String? text, Offset position) {
    if (text == null) return null;
    try {
      final model = Model(jsonDecode(text));
      model.id = Random().nextInt(65535);
      model.common.position = Matrix4.inverted(boardViewModel.viewerTransform).transformOffset(position);
      return QudsPopupMenuItem(
        title: const Text('粘贴'),
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
    QudsPopupMenuItem? pasteItem;
    if (!UniversalPlatform.isWeb) {
      final text = (await Clipboard.getData('text/plain'))?.text;
      pasteItem = buildBoardPasteMenuItem(text, position);
    }
    showQudsPopupMenu(
      context: context,
      startOffset: position,
      endOffset: position,
      items: [
        QudsPopupMenuItem(
          title: const Text('清空画布'),
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
          pluginManager: pluginManager,
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
          title: const Text('复制对象'),
          onPressed: () {
            Clipboard.setData(ClipboardData(text: model.toJsonString()));
            EasyLoading.showSuccess('复制成功');
          },
        ),
        buildAddModelMenu(
          boardViewModel: boardViewModel,
          eventBus: eventBus,
          offset: position,
          pluginManager: pluginManager,
        ),
      ],
    );
  }
}
