import 'dart:math';

import 'package:flutter/material.dart';

import 'data.dart';

class MyCustomPainter extends CustomPainter {
  final FreeStyleModelData data;

  MyCustomPainter(this.data);

  @override
  void paint(Canvas canvas, Size size) {
    for (final path in data.pathList.value) {
      final paint = Paint()
        ..color = path.color.value
        ..strokeCap = StrokeCap.round
        ..strokeWidth = 5.0;
      final points = path.points.value;
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
        widget.data.pathList.value.add(FreeStylePathModelData()
          ..color.value = Color.fromARGB(
            255,
            Random().nextInt(256),
            Random().nextInt(256),
            Random().nextInt(256),
          ));
      },
      onPanUpdate: (d) {
        // 绘制越界
        if (!context.size!.contains(d.localPosition)) return;
        widget.data.pathList.value.last.points.value.add(d.localPosition);
      },
      onPanEnd: (d) {
        print('Add path: ${widget.data.pathList.value.last}');
      },
      child: CustomPaint(
        painter: MyCustomPainter(widget.data),
        size: Size.infinite,
      ),
    );
  }
}
