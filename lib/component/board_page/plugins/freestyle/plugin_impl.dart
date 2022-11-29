import 'package:board_event_bus/board_event_bus.dart';
import 'package:board_front/component/board/board.dart';
import 'package:flutter/material.dart';

import '../model_plugin_interface.dart';
import 'data.dart';
import 'editor.dart';
import 'widget.dart';

class FreeStyleModelPlugin implements BoardModelPluginInterface {
  @override
  Widget buildModelView(Model model, EventBus<BoardEventName> eventBus) {
    return FreeStyleWidget(
      data: FreeStyleModelData(model.data),
      editable: model.common.editableState,
      eventBus: eventBus,
      modelId: model.id,
    );
  }

  @override
  Widget buildModelEditor(Model model, EventBus<BoardEventName> eventBus) {
    return FreeStyleModelEditor(model: model, eventBus: eventBus);
  }

  @override
  String get modelTypeName => 'freestyle';

  @override
  Model buildDefaultAddModel({
    required int modelId,
    required Offset position,
  }) {
    return Model({})
      ..id = modelId
      ..common = (CommonModelData({})..position = position)
      ..type = modelTypeName;
  }

  @override
  String get inMenuName => '自由画板';
}
