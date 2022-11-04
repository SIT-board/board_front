import 'package:flutter/material.dart';

import 'model.dart';

/// 构造出模型对应的 Widget
class ModelWidgetBuilder {
  final Model model;
  ModelWidgetBuilder(this.model);

  Widget buildFreeStyleWidget() {
    return FreeStyleWidget(
      data: model.data as FreeStyleModelData,
      editable: model.common.editableState,
      onDrawPath: (path) {},
    );
  }

  Widget build() {
    final builders = {
      ModelType.text: (data) => TextModelWidget(data: model.data as TextModelData),
      ModelType.rect: (data) => RectModelWidget(data: model.data as RectModelData),
      ModelType.image: (data) => ImageModelWidget(data: model.data as ImageModelData),
      ModelType.freeStyle: (data) => buildFreeStyleWidget(),
      ModelType.line: (data) => LineModelWidget(data: model.data as LineModelData),
      ModelType.oval: (data) => OvalModelWidget(data: model.data as OvalModelData),
    };
    if (!builders.containsKey(model.type)) throw UnimplementedError();
    return builders[model.type]!(model.data);
  }
}
