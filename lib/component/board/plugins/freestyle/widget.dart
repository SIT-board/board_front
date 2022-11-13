import 'package:board_event_bus/board_event_bus.dart';
import 'package:board_front/component/board/board_event.dart';
import 'package:flutter/material.dart';

import 'data.dart';

class MyCustomPainter extends CustomPainter {
  final FreeStyleModelData data;

  MyCustomPainter(this.data);

  @override
  void paint(Canvas canvas, Size size) {
    for (final pathId in data.pathIdList) {
      final path = data.getPathById(pathId);
      final paint = Paint()
        ..color = path.paint.color
        ..strokeCap = StrokeCap.round
        ..strokeWidth = path.paint.strokeWidth
        ..isAntiAlias = path.paint.isAntiAlias;
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
  final bool editable;
  final EventBus<BoardEventName> eventBus;

  const FreeStyleWidget({
    Key? key,
    required this.data,
    required this.editable,
    required this.eventBus,
  }) : super(key: key);

  @override
  State<FreeStyleWidget> createState() => _FreeStyleWidgetState();
}

class _FreeStyleWidgetState extends State<FreeStyleWidget> {
  int? currentPathId;
  void saveState() => widget.eventBus.publish(BoardEventName.saveState);
  @override
  Widget build(BuildContext context) {
    Widget child = CustomPaint(
      painter: MyCustomPainter(widget.data),
      size: Size.infinite,
    );
    child = ClipRect(
      child: child,
    );
    child = Container(
      color: widget.data.backgroundColor,
      child: child,
    );
    if (!widget.editable) return child;
    return GestureDetector(
      behavior: HitTestBehavior.deferToChild,
      onPanStart: (d) {
        currentPathId = widget.data.getNextModelId();
        widget.data.addPath(
          FreeStylePathModelData({})
            ..paint = widget.data.paint.copy()
            ..id = currentPathId!,
        );
      },
      onPanUpdate: (d) {
        if (!context.size!.contains(d.localPosition)) return;
        // 绘制越界
        final path = widget.data.getPathById(currentPathId!);
        final points = path.points;
        points.add(d.localPosition);
        path.points = points;
        setState(() {});
      },
      onPanEnd: (d) {
        print('Add path: $currentPathId');
        saveState();
      },
      child: child,
    );
  }
}
