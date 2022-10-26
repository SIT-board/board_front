import 'dart:math';
import 'dart:ui';

import 'package:flutter/material.dart';

abstract class Drawable {
  void draw(Canvas canvas, Size size);
}

class DrawableGroup implements Drawable {
  final Iterable<Drawable> drawables;
  DrawableGroup(this.drawables);

  @override
  void draw(Canvas canvas, Size size) {
    for (final e in drawables) {
      e.draw(canvas, size);
    }
  }
}

enum ObjectDrawableAssist {
  horizontal,
  vertical,
  rotation,
}

/// 2D变换信息
class TransformState {
  final Offset position;
  final Size scale;
  final double rotation;
  TransformState({
    this.position = const Offset(0, 0),
    this.scale = const Size(1, 1),
    this.rotation = 0,
  });
}

/// 可渲染的对象
abstract class ObjectDrawable implements Drawable {
  final TransformState transformState;

  ObjectDrawable({required this.transformState});

  Offset get position => transformState.position;
  Size get scale => transformState.scale;
  double get rotation => transformState.rotation;

  /// 绘制旋转平移过程中的辅助线
  void drawAssists(Canvas canvas, Size size) {
    final defaultAssistPaint = Paint()
      ..strokeWidth = 1.5
      ..color = Colors.pink;

    // 旋转辅助线
    final intersections = _calculateBoxIntersections(position, rotation, size);
    if (intersections.length == 2) {
      final p1 = intersections[0], p2 = intersections[1];
      canvas.drawLine(p1, p2, defaultAssistPaint);
    }
    // 水平辅助线
    canvas.drawLine(
      Offset(0, position.dy),
      Offset(size.width, position.dy),
      defaultAssistPaint,
    );
    // 垂直辅助线
    canvas.drawLine(
      Offset(position.dx, 0),
      Offset(position.dx, size.height),
      defaultAssistPaint,
    );
  }

  /// 计算经过点point，倾斜角为angle的直线与尺寸为size的矩形的交点
  List<Offset> _calculateBoxIntersections(Offset point, double angle, Size size) {
    // 根据点斜式得到直线方程y-y0=k(x-x0)
    final k = tan(angle);
    final x0 = point.dx, y0 = point.dy;
    final w = size.width, h = size.height;
    // 计算与直线y=0的交点, 则x = x0 - y0/k
    double x1 = x0 - y0 / k;
    // 计算与直线y=h的交点, 则x=x0-(h-y0)/k
    double x2 = x0 + (h - y0) / k;
    // 计算与直线x=0的交点, 则y=-k*x0+y0
    double y1 = -k * x0 + y0;
    // 计算与直线x=w的交点, 则y=k*(w-x0)+y0
    double y2 = k * (w - x0) + y0;
    return <Offset>[
      if (x1 >= 0 && x1 <= size.width) Offset(x1, 0),
      if (x2 >= 0 && x2 <= size.width) Offset(x2, size.height),
      if (y1 >= 0 && y1 <= size.height) Offset(0, y1),
      if (y2 >= 0 && y2 <= size.height) Offset(size.width, y2),
    ];
  }

  @override
  void draw(Canvas canvas, Size size) {
    drawAssists(canvas, size);
    canvas.save();

    canvas.translate(position.dx, position.dy);
    canvas.rotate(rotation);
    canvas.translate(-position.dx, -position.dy);

    drawObject(canvas, size);
    canvas.restore();
  }

  void drawObject(Canvas canvas, Size size);
}

/// 基本图形渲染对象，需要至少有一个画笔
abstract class BasicShapeDrawable extends ObjectDrawable {
  final Paint paint;

  BasicShapeDrawable({
    required super.transformState,
    required this.paint,
  });

  @override
  void drawObject(Canvas canvas, Size size);
}

/// 直线
class LineDrawable extends BasicShapeDrawable {
  LineDrawable({required super.transformState, required super.paint});

  @override
  void drawObject(Canvas canvas, Size size) {
    final p1 = Offset(position.dx - scale.width / 2, position.dy);
    final p2 = Offset(position.dx + scale.width / 2, position.dy);

    canvas.drawLine(p1, p2, paint);
  }
}

/// 矩形对象
class RectDrawable extends BasicShapeDrawable {
  RectDrawable({required super.transformState, required super.paint});

  @override
  void drawObject(Canvas canvas, Size size) {
    canvas.drawRect(
      Rect.fromCenter(center: position, width: scale.width, height: scale.height),
      paint,
    );
  }
}

/// 任意路径
class PathDrawable extends BasicShapeDrawable {
  final Path path;

  PathDrawable({
    required super.transformState,
    required super.paint,
    required this.path,
  });
  @override
  void drawObject(Canvas canvas, Size size) {
    canvas.drawPath(path, paint);
  }
}

class MyCustomPainter extends CustomPainter {
  final Drawable drawable;

  MyCustomPainter(this.drawable);

  @override
  void paint(Canvas canvas, Size size) => drawable.draw(canvas, size);

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}
