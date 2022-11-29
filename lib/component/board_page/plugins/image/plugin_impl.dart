import 'package:board_event_bus/board_event_bus.dart';
import 'package:board_front/component/board/board.dart';
import 'package:flutter/material.dart';

import '../model_plugin_interface.dart';
import 'data.dart';
import 'editor.dart';
import 'widget.dart';

class ImageModelPlugin extends BoardModelPluginInterface {
  @override
  Widget buildModelEditor(Model model, EventBus<BoardEventName> eventBus) {
    return ImageModelEditor(model: model, eventBus: eventBus);
  }

  @override
  Widget buildModelView(Model model, EventBus<BoardEventName> eventBus) {
    return ImageModelWidget(data: ImageModelData(model.data));
  }

  @override
  String get modelTypeName => 'image';
  @override
  Model buildDefaultAddModel({
    required int modelId,
    required Offset position,
  }) {
    return Model({})
      ..id = modelId
      ..common = (CommonModelData({})..position = position)
      ..type = modelTypeName
      ..data = (ImageModelData({})..url = '').map;
  }

  @override
  String get inMenuName => '图像';
}
