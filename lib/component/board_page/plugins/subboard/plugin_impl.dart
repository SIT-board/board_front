import 'dart:ui';

import 'package:board_event_bus/board_event_bus.dart';
import 'package:board_front/component/board/board.dart';
import 'package:flutter/material.dart';

import '../model_plugin_interface.dart';
import 'data.dart';
import 'editor.dart';
import 'widget.dart';

class MarkdownModelPlugin implements BoardModelPluginInterface {
  @override
  Model buildDefaultAddModel({required int modelId, required Offset position}) {
    return Model({})
      ..id = modelId
      ..common = (CommonModelData({})..position = position)
      ..type = modelTypeName
      ..data = (MarkdownModelData({})..markdown = '# HelloWorld').map;
  }

  @override
  Widget buildModelEditor(Model model, EventBus<BoardEventName> eventBus) {
    return MarkdownModelEditor(eventBus: eventBus, model: model);
  }

  @override
  Widget buildModelView(Model model, EventBus<BoardEventName> eventBus) {
    return MarkdownModelWidget(data: MarkdownModelData(model.data));
  }

  @override
  String get inMenuName => 'Markdown文档';

  @override
  String get modelTypeName => 'markdown';
}
