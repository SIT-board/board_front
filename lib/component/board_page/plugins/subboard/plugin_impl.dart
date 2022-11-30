import 'package:board_event_bus/board_event_bus.dart';
import 'package:board_front/component/board/board.dart';
import 'package:flutter/material.dart';

import '../model_plugin_interface.dart';
import 'widget.dart';

class SubBoardModelPlugin implements BoardModelPluginInterface {
  @override
  Model buildDefaultAddModel({required int modelId, required Offset position}) {
    return Model({})
      ..id = modelId
      ..common = (CommonModelData({})..position = position)
      ..type = modelTypeName
      ..data = {};
  }

  @override
  Widget buildModelEditor(Model model, EventBus<BoardEventName> eventBus) {
    return Container();
  }

  @override
  Widget buildModelView(Model model, EventBus<BoardEventName> eventBus) {
    return Container(
      decoration: BoxDecoration(
        border: Border.all(
          color: Colors.black,
        ),
      ),
      child: SubBoardWidget(model: model, eventBus: eventBus),
    );
  }

  @override
  String get inMenuName => '子画板';

  @override
  String get modelTypeName => 'sub_board';
}
