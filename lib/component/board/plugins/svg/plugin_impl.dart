import 'package:board_event_bus/board_event_bus.dart';
import 'package:board_front/component/board/board.dart';
import 'package:board_front/component/board/board_event.dart';
import 'package:board_front/component/board/model/data.dart';
import 'package:board_front/component/board/model/model_plugin_interface.dart';
import 'package:flutter/material.dart';

import 'data.dart';
import 'editor.dart';
import 'widget.dart';

class SvgModelPlugin extends BoardModelPluginInterface {
  @override
  Widget buildModelEditor(Model model, EventBus<BoardEventName> eventBus) {
    return ImageModelEditor(model: model, eventBus: eventBus);
  }

  @override
  Widget buildModelView(Model model, EventBus<BoardEventName> eventBus) {
    return SvgModelWidget(data: SvgModelData(model.data));
  }

  @override
  String get modelTypeName => 'svg';
  @override
  Model buildDefaultAddModel({
    required int modelId,
    required Offset position,
  }) {
    return Model({})
      ..id = modelId
      ..common = (CommonModelData({})..position = position)
      ..type = modelTypeName
      ..data = (SvgModelData({})).map;
  }

  @override
  String get inMenuName => 'SVG矢量图形';
}
