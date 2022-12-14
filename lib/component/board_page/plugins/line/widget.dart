import 'package:dotted_line/dotted_line.dart';
import 'package:flutter/material.dart';

import 'data.dart';

class LineModelWidget extends StatelessWidget {
  final LineModelData data;
  const LineModelWidget({
    Key? key,
    required this.data,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // 添加Container是为了扩大可点击区域
    return Container(
      alignment: Alignment.center,
      height: 20,
      color: Colors.transparent,
      child: DottedLine(
        // 厚度
        lineThickness: data.thickness,
        // 实线长度，颜色
        dashLength: data.dashLength,
        dashColor: data.color,
        // 虚线长度，颜色
        dashGapLength: data.dashGapLength,
        dashGapColor: Colors.transparent,
      ),
    );
  }
}
