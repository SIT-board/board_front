import 'dart:math';

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

class MyCustomPainter extends CustomPainter {
  final FreeStyleModelData data;

  MyCustomPainter(this.data);

  @override
  void paint(Canvas canvas, Size size) {
    for (final path in data.pathList) {
      final paint = Paint()
        ..color = path.color
        ..strokeCap = StrokeCap.round
        ..strokeWidth = 5.0;
      final points = path.points;
      for (int i = 0; i < points.length - 1; i++) {
        canvas.drawLine(points[i], points[i + 1], paint);
      }
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return true;
  }
}

class FreeStyleWidget extends StatefulWidget {
  final FreeStyleModelData data;
  const FreeStyleWidget({Key? key, required this.data}) : super(key: key);

  @override
  State<FreeStyleWidget> createState() => _FreeStyleWidgetState();
}

class _FreeStyleWidgetState extends State<FreeStyleWidget> {
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      behavior: HitTestBehavior.deferToChild,
      onPanStart: (d) {
        final pathList = widget.data.pathList;
        pathList.add(
          FreeStylePathModelData({
            'color': Color.fromARGB(
              255,
              Random().nextInt(256),
              Random().nextInt(256),
              Random().nextInt(256),
            ).value,
          }),
        );
        widget.data.pathList = pathList;
      },
      onPanUpdate: (d) {
        // 绘制越界
        if (!context.size!.contains(d.localPosition)) return;
        final points = widget.data.pathList.last.points;
        points.add(d.localPosition);
        widget.data.pathList.last.points = points;
        setState(() {});
      },
      onPanEnd: (d) {
        print('Add path: ${widget.data.pathList.last}');
      },
      child: CustomPaint(
        painter: MyCustomPainter(widget.data),
        size: Size.infinite,
      ),
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
      ModelType.freeStyle: (data) => FreeStyleWidget(data: model.data as FreeStyleModelData),
    };
    if (!builders.containsKey(model.type)) throw UnimplementedError();
    return builders[model.type]!(model.data);
  }
}
