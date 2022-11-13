import 'dart:math';

import 'package:flutter/material.dart';

import 'data.dart';

class LinePainter extends CustomPainter {
  final FreeStylePathModelData path;
  LinePainter(this.path);

  @override
  void paint(Canvas canvas, Size size) {
    double minX = double.maxFinite;
    double maxX = 0;
    double minY = double.maxFinite;
    double maxY = 0;
    for (final point in path.points) {
      minX = min(minX, point.dx);
      maxX = max(maxX, point.dx);
      minY = min(minY, point.dy);
      maxY = max(maxY, point.dy);
    }
    // 该路径的最小包围矩形
    final bound = Size(maxX - minX, maxY - minY);
    final s = bound.longestSide / size.shortestSide;

    final strokeWidth = path.paint.strokeWidth;
    final paint = Paint()
      ..color = path.paint.color
      ..strokeCap = StrokeCap.round
      ..strokeWidth = strokeWidth > 10 ? 10 : strokeWidth
      ..isAntiAlias = path.paint.isAntiAlias;
    final points = path.points;
    for (int i = 0; i < points.length - 1; i++) {
      final srcStart = points[i] - Offset(minX, minY);
      final srcEnd = points[i + 1] - Offset(minX, minY);
      canvas.drawLine(srcStart / s, srcEnd / s, paint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return true;
  }
}

class LineWatcherColumn extends StatelessWidget {
  final List<FreeStylePathModelData> pathList;
  final void Function(int id)? onDeletePath;
  const LineWatcherColumn({
    Key? key,
    required this.pathList,
    this.onDeletePath,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: GridView.builder(
        gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
          maxCrossAxisExtent: 70,
          crossAxisSpacing: 5.0,
          childAspectRatio: 0.7,
        ),
        padding: const EdgeInsets.all(10.0),
        itemCount: pathList.length,
        itemBuilder: (context, index) {
          final i = pathList.length - 1 - index;
          final path = pathList[i];
          return InkWell(
            onTap: () {
              showDialog(
                  context: context,
                  builder: (context) {
                    return Dialog(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text('是否删除该路径？', style: Theme.of(context).textTheme.headline5),
                          ElevatedButton(
                            onPressed: () {
                              onDeletePath?.call(path.id);
                              Navigator.of(context).pop();
                            },
                            child: const Text('删除'),
                          ),
                          TextButton(
                            onPressed: () {
                              Navigator.of(context).pop();
                            },
                            child: Text('取消'),
                          ),
                        ],
                      ),
                    );
                  });
            },
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  padding: const EdgeInsets.all(8.0),
                  decoration: BoxDecoration(border: Border.all(color: Colors.black54)),
                  child: Center(
                    child: CustomPaint(
                      painter: LinePainter(path),
                      size: const Size(50, 50),
                    ),
                  ),
                ),
                Text(i.toString()),
              ],
            ),
          );
        },
      ),
    );
  }
}
