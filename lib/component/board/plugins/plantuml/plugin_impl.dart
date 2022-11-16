import 'package:board_event_bus/board_event_bus.dart';
import 'package:board_front/component/board/board.dart';
import 'package:board_front/component/board/board_event.dart';
import 'package:board_front/component/board/model/data.dart';
import 'package:board_front/component/board/model/model_plugin_interface.dart';
import 'package:flutter/material.dart';

import 'data.dart';
import 'editor.dart';
import 'widget.dart';

class PlantUMLModelPlugin extends BoardModelPluginInterface {
  @override
  Widget buildModelEditor(Model model, EventBus<BoardEventName> eventBus) {
    return PlantUMLModelEditor(model: model, eventBus: eventBus);
  }

  @override
  Widget buildModelView(Model model, EventBus<BoardEventName> eventBus) {
    return PlantUMLModelWidget(data: PlantUMLModelData(model.data));
  }

  @override
  String get modelTypeName => 'plantuml';
  @override
  Model buildDefaultAddModel({
    required int modelId,
    required Offset position,
  }) {
    return Model({})
      ..id = modelId
      ..common = (CommonModelData({})..position = position)
      ..type = modelTypeName
      ..data = (PlantUMLModelData({})).map;
  }

  @override
  String get inMenuName => 'PlantUML';
}
