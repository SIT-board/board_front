import 'package:flutter/material.dart';

import 'model.dart';

class TextModelWidget extends StatelessWidget {
  final TextModelData data;
  const TextModelWidget({Key? key, required this.data}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final controller = TextEditingController();
    controller.text = data.content;
    controller.addListener(() {});
    return EditableText(
      controller: controller,
      focusNode: FocusNode(),
      selectionColor: Colors.blue,
      style: TextStyle(
        color: data.color ?? Colors.black,
      ),
      cursorColor: Colors.black,
      backgroundCursorColor: Colors.transparent,
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

class ModelWidgetBuilder {
  final Model model;
  ModelWidgetBuilder(this.model);
  Widget build() {
    final builders = {
      ModelType.text: (data) => TextModelWidget(data: model.data as TextModelData),
      ModelType.rect: (data) => RectModelWidget(data: model.data as RectModelData),
      ModelType.image: (data) => ImageModelWidget(data: model.data as ImageModelData),
    };
    if (!builders.containsKey(model.type)) throw UnimplementedError();
    return builders[model.type]!(model.data);
  }
}
