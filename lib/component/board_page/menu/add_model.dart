import 'package:board_event_bus/board_event_bus.dart';
import 'package:board_front/component/board/board.dart';
import 'package:board_front/component/board/board_event.dart';
import 'package:board_front/component/board/plugins/plugins.dart';
import 'package:board_front/util/transform.dart';
import 'package:flutter/material.dart';
import 'package:quds_popup_menu/quds_popup_menu.dart';

QudsPopupMenuBase buildAddModelMenu({
  required EventBus<BoardEventName> eventBus,
  required BoardViewModel boardViewModel,
  required Offset offset,
}) {
  void saveState() => eventBus.publish(BoardEventName.saveState);
  void refresh() {
    eventBus.publish(BoardEventName.refreshBoard);
    eventBus.publish(BoardEventName.saveState);
  }

  Offset position = Matrix4.inverted(boardViewModel.viewerTransform).transformOffset(offset);
  return QudsPopupMenuSection(
    titleText: '添加模型',
    subItems: defaultModelPlugins.getPluginNameList().map((modelTypeName) {
      final plugin = defaultModelPlugins.getPluginByModelType(modelTypeName);
      return QudsPopupMenuItem(
          title: Text(plugin.inMenuName),
          onPressed: () {
            boardViewModel.addModel(plugin.buildDefaultAddModel(
              modelId: boardViewModel.getNextModelId(),
              position: position,
            ));
            refresh();
          });
    }).toList(),
  );
}
