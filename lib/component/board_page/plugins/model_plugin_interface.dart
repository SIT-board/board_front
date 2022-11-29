import 'package:board_event_bus/board_event_bus.dart';
import 'package:board_front/component/board/board_event.dart';
import 'package:board_front/component/board/model/data.dart';
import 'package:flutter/material.dart';

export 'package:board_front/component/board/board_event.dart';
export 'package:board_front/component/board/model/data.dart';

abstract class BoardModelPluginInterface {
  String get modelTypeName;
  String get inMenuName;
  Widget buildModelView(Model model, EventBus<BoardEventName> eventBus);
  Widget buildModelEditor(Model model, EventBus<BoardEventName> eventBus);
  Model buildDefaultAddModel({
    required int modelId,
    required Offset position,
  });
}
