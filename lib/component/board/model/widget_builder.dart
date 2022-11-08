import 'package:board_event_bus/board_event_bus.dart';
import 'package:flutter/material.dart';

import '../board_event.dart';
import 'freestyle/editor.dart';
import 'model.dart';

/// 构造出模型对应的 Widget
class ModelWidgetBuilder {
  final Model model;
  final EventBus<BoardEventName>? eventBus;
  ModelWidgetBuilder({
    required this.model,
    this.eventBus,
  });

  Widget buildFreeStyleWidget() {
    return FreeStyleWidget(
      data: model.data as FreeStyleModelData,
      editable: model.common.editableState,
      onDrawPath: (path) {},
    );
  }

  Widget buildModelWidget() {
    final builders = {
      ModelType.rect: (data) => RectModelWidget(data: model.data as RectModelData),
      ModelType.image: (data) => ImageModelWidget(data: model.data as ImageModelData),
      ModelType.freeStyle: (data) => buildFreeStyleWidget(),
      ModelType.line: (data) => LineModelWidget(data: model.data as LineModelData),
    };
    if (!builders.containsKey(model.type)) throw UnimplementedError();
    return builders[model.type]!(model.data);
  }

  Widget buildModelEditorWidget() {
    final builders = {
      ModelType.rect: (data) => RectModelEditor(model: model, eventBus: eventBus),
      ModelType.image: (data) => ImageModelEditor(model: model, eventBus: eventBus),
      ModelType.freeStyle: (data) => FreeStyleModelEditor(model: model, eventBus: eventBus),
      ModelType.line: (data) => LineModelEditor(model: model, eventBus: eventBus),
    };
    if (!builders.containsKey(model.type)) throw UnimplementedError();
    return builders[model.type]!(model.data);
  }
}
