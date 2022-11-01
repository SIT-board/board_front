import 'package:flutter/material.dart';

import 'model.dart';

class ModelWidgetBuilder {
  final Model model;
  ModelWidgetBuilder(this.model);
  Widget build() {
    final builders = {
      ModelType.text: (data) => TextModelWidget(data: model.data as TextModelData),
      ModelType.rect: (data) => RectModelWidget(data: model.data as RectModelData),
      ModelType.image: (data) => ImageModelWidget(data: model.data as ImageModelData),
      ModelType.freeStyle: (data) => FreeStyleWidget(data: model.data as FreeStyleModelData),
    };
    if (!builders.containsKey(model.type)) throw UnimplementedError();
    return builders[model.type]!(model.data);
  }
}
