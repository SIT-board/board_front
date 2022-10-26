import 'package:flutter/material.dart';
import 'package:interactive_infinity_container/interactive_infinity_container.dart';

import 'model.dart';

class TextModelWidget extends StatelessWidget {
  final TextModelData data;
  const TextModelWidget({Key? key, required this.data}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Text(
      data.content,
      style: TextStyle(color: data.color),
    );
  }
}

class RectModelWidget extends StatelessWidget {
  final RectModelData data;
  const RectModelWidget({Key? key, required this.data}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: data.fillColor,
        border: Border.all(
          color: data.borderColor ?? const Color(0xFF000000),
          width: data.borderWidth ?? 1.0,
        ),
      ),
    );
  }
}

class ImageModelWidget extends StatelessWidget {
  final ImageModelData data;
  const ImageModelWidget({Key? key, required this.data}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Image.network(
      data.url,
      fit: BoxFit.fill,
    );
  }
}

class ModelWidget extends StatelessWidget {
  final Model model;
  const ModelWidget({Key? key, required this.model}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    late Widget modelWidget;
    if (model.type == ModelType.text) modelWidget = TextModelWidget(data: model.data as TextModelData);
    if (model.type == ModelType.rect) modelWidget = RectModelWidget(data: model.data as RectModelData);
    if (model.type == ModelType.image) modelWidget = ImageModelWidget(data: model.data as ImageModelData);

    if (model.size != null) {
      modelWidget = SizedBox.fromSize(
        size: model.size!,
        child: modelWidget,
      );
    }
    if (model.transform != null) {
      modelWidget = Transform(
        transform: model.transform!,
        child: modelWidget,
      );
    }

    return modelWidget;
  }
}

class CanvasViewModelWidget extends StatelessWidget {
  final CanvasViewModel viewModel;
  final TransformationController controller;
  const CanvasViewModelWidget({Key? key, required this.viewModel, required this.controller}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    if (viewModel.viewerTransform != null) {
      controller.value = viewModel.viewerTransform!;
    }
    return InteractiveInfinityContainer(
      viewerTransformationController: controller,
      minScale: 0.3,
      maxScale: 100,
      children: viewModel.models.map((e) {
        return ModelWidget(model: e);
      }).toList(),
    );
  }
}
