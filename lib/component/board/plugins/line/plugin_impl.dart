import 'package:board_event_bus/board_event_bus.dart';
import 'package:board_front/component/board/board.dart';
import 'package:board_front/component/board/board_event.dart';
import 'package:board_front/component/board/model/data.dart';
import 'package:board_front/component/board/model/model_plugin_interface.dart';
import 'package:flutter/material.dart';

import 'data.dart';
import 'editor.dart';
import 'widget.dart';

class LineModelPlugin extends BoardModelPluginInterface {
  @override
  Widget buildModelEditor(Model model, EventBus<BoardEventName> eventBus) {
    return LineModelEditor(model: model, eventBus: eventBus);
  }

  @override
  Widget buildModelView(Model model, EventBus<BoardEventName> eventBus) {
    return LineModelWidget(data: LineModelData(model.data));
  }

  @override
  String get modelTypeName => 'line';

  @override
  Model buildDefaultAddModel({
    required int modelId,
    required Offset position,
  }) {
    return Model({})
      ..id = modelId
      ..common = (CommonModelData({})
        ..position = position
        ..constraints = const BoxConstraints(
          minWidth: 0,
          maxWidth: double.maxFinite,
          minHeight: 60,
          maxHeight: 60,
        )
        ..size = const Size(100, 60))
      ..type = modelTypeName;
  }

  @override
  String get inMenuName => '直线/虚线';
}
