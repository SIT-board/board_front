import 'package:board_event_bus/board_event_bus.dart';
import 'package:board_front/component/board/board.dart';
import 'package:flutter/material.dart';

import '../model_plugin_interface.dart';
import 'data.dart';
import 'editor.dart';
import 'widget.dart';

class OvalModelPlugin extends BoardModelPluginInterface {
  @override
  Widget buildModelView(Model model, EventBus<BoardEventName> eventBus) {
    return OvalModelWidget(data: OvalModelData(model.data));
  }

  @override
  Widget buildModelEditor(Model model, EventBus<BoardEventName> eventBus) {
    return OvalModelEditor(model: model, eventBus: eventBus);
  }

  @override
  String get modelTypeName => 'oval';

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
  String get inMenuName => '椭圆';
}
